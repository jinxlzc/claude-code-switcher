#!/usr/bin/env swift

import AppKit
import Foundation

// Icon sizes for macOS
let iconSizes: [(size: Int, scale: Int, filename: String)] = [
    (16, 1, "icon_16x16.png"),
    (16, 2, "icon_16x16@2x.png"),
    (32, 1, "icon_32x32.png"),
    (32, 2, "icon_32x32@2x.png"),
    (128, 1, "icon_128x128.png"),
    (128, 2, "icon_128x128@2x.png"),
    (256, 1, "icon_256x256.png"),
    (256, 2, "icon_256x256@2x.png"),
    (512, 1, "icon_512x512.png"),
    (512, 2, "icon_512x512@2x.png")
]

func generateIcon(pixelSize: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    image.lockFocus()

    let context = NSGraphicsContext.current!.cgContext

    // Background gradient - blue like system icons
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors: [CGColor] = [
        NSColor(red: 0.231, green: 0.510, blue: 0.965, alpha: 1.0).cgColor,  // #3B82F6 - Light blue
        NSColor(red: 0.114, green: 0.306, blue: 0.847, alpha: 1.0).cgColor   // #1D4ED8 - Dark blue
    ]
    let locations: [CGFloat] = [0.0, 1.0]

    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
        // Draw rounded rectangle background
        let cornerRadius = pixelSize * 0.22
        let rect = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
        let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

        context.addPath(path)
        context.clip()
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: pixelSize),
                                   end: CGPoint(x: pixelSize, y: 0),
                                   options: [])
    }

    // Reset clip
    context.resetClip()

    // Draw the swap arrows icon
    let iconSize = pixelSize * 0.5
    let centerX = pixelSize / 2
    let centerY = pixelSize / 2
    let arrowWidth = iconSize * 0.15
    let arrowLength = iconSize * 0.7

    context.setFillColor(NSColor.white.cgColor)
    context.setStrokeColor(NSColor.white.cgColor)
    context.setLineWidth(arrowWidth * 0.3)
    context.setLineCap(.round)
    context.setLineJoin(.round)

    // Upper arrow (pointing right)
    let upperY = centerY + iconSize * 0.15
    let arrowPath1 = CGMutablePath()
    arrowPath1.move(to: CGPoint(x: centerX - arrowLength/2, y: upperY))
    arrowPath1.addLine(to: CGPoint(x: centerX + arrowLength/2 - arrowWidth, y: upperY))

    // Arrow head
    arrowPath1.move(to: CGPoint(x: centerX + arrowLength/2 - arrowWidth * 1.5, y: upperY + arrowWidth * 0.8))
    arrowPath1.addLine(to: CGPoint(x: centerX + arrowLength/2, y: upperY))
    arrowPath1.addLine(to: CGPoint(x: centerX + arrowLength/2 - arrowWidth * 1.5, y: upperY - arrowWidth * 0.8))

    context.addPath(arrowPath1)
    context.strokePath()

    // Lower arrow (pointing left)
    let lowerY = centerY - iconSize * 0.15
    let arrowPath2 = CGMutablePath()
    arrowPath2.move(to: CGPoint(x: centerX + arrowLength/2, y: lowerY))
    arrowPath2.addLine(to: CGPoint(x: centerX - arrowLength/2 + arrowWidth, y: lowerY))

    // Arrow head
    arrowPath2.move(to: CGPoint(x: centerX - arrowLength/2 + arrowWidth * 1.5, y: lowerY + arrowWidth * 0.8))
    arrowPath2.addLine(to: CGPoint(x: centerX - arrowLength/2, y: lowerY))
    arrowPath2.addLine(to: CGPoint(x: centerX - arrowLength/2 + arrowWidth * 1.5, y: lowerY - arrowWidth * 0.8))

    context.addPath(arrowPath2)
    context.strokePath()

    image.unlockFocus()
    return image
}

func saveIcon(_ image: NSImage, to url: URL) -> Bool {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        return false
    }

    do {
        try pngData.write(to: url)
        return true
    } catch {
        print("Error saving \(url.lastPathComponent): \(error)")
        return false
    }
}

// Main
let args = CommandLine.arguments
guard args.count > 1 else {
    print("Usage: swift generate_icons.swift <output_directory>")
    exit(1)
}

let outputDir = URL(fileURLWithPath: args[1])

// Create directory if needed
try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

print("Generating icons...")

for (size, scale, filename) in iconSizes {
    let pixelSize = CGFloat(size * scale)
    let icon = generateIcon(pixelSize: pixelSize)
    let fileURL = outputDir.appendingPathComponent(filename)

    if saveIcon(icon, to: fileURL) {
        print("  ✓ \(filename) (\(Int(pixelSize))x\(Int(pixelSize)))")
    } else {
        print("  ✗ Failed: \(filename)")
    }
}

print("\nDone! Icons saved to: \(outputDir.path)")
