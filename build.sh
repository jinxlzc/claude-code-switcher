#!/bin/bash

# Claude Code Switcher - Build and Package Script
# This script builds the app and creates a DMG installer

set -e

# Configuration
APP_NAME="Claude Code Switcher"
BUNDLE_ID="com.claudecode.switcher"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"

echo "==================================="
echo "Claude Code Switcher Build Script"
echo "==================================="

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "Installing xcodegen..."
    brew install xcodegen
fi

# Generate Xcode project
echo ""
echo "Step 1: Generating Xcode project..."
cd "${PROJECT_DIR}/ClaudeCodeSwitcher"
xcodegen generate

# Clean build directory
echo ""
echo "Step 2: Cleaning build directory..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build the app
echo ""
echo "Step 3: Building the application..."
xcodebuild -project ClaudeCodeSwitcher.xcodeproj \
    -scheme ClaudeCodeSwitcher \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    -archivePath "${ARCHIVE_PATH}" \
    archive \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Export the app
echo ""
echo "Step 4: Exporting the application..."
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${BUILD_DIR}" \
    -exportOptionsPlist "${PROJECT_DIR}/ExportOptions.plist" \
    2>/dev/null || {
    # Fallback: manually copy app from archive
    echo "Using fallback export method..."
    cp -R "${ARCHIVE_PATH}/Products/Applications/${APP_NAME}.app" "${APP_PATH}"
}

# Verify the app exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App not found at ${APP_PATH}"
    exit 1
fi

echo ""
echo "Step 5: Creating DMG installer..."

# Create a temporary directory for DMG contents
DMG_TEMP="${BUILD_DIR}/dmg_temp"
mkdir -p "${DMG_TEMP}"

# Copy app to temp directory
cp -R "${APP_PATH}" "${DMG_TEMP}/"

# Create Applications symlink
ln -s /Applications "${DMG_TEMP}/Applications"

# Create DMG
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_TEMP}" \
    -ov -format UDZO \
    "${DMG_PATH}"

# Cleanup
rm -rf "${DMG_TEMP}"

echo ""
echo "==================================="
echo "Build completed successfully!"
echo "==================================="
echo ""
echo "Output files:"
echo "  App: ${APP_PATH}"
echo "  DMG: ${DMG_PATH}"
echo ""
