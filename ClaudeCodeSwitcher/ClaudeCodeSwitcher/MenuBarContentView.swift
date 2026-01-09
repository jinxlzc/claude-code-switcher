import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var configManager: ConfigManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()

            // Content
            if configManager.configs.isEmpty {
                EmptyStateView(openWindow: openWindow)
            } else {
                ConfigListView(openWindow: openWindow)
            }

            // Footer
            FooterView(openWindow: openWindow)
        }
        .frame(width: 300, height: 400)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Header View

struct HeaderView: View {
    @EnvironmentObject var configManager: ConfigManager

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Claude Code Switcher")
                    .font(.headline)

                if let active = configManager.activeConfig {
                    Text(active.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No active configuration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                configManager.detectActiveConfig()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(.quaternary.opacity(0.5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Refresh status")
        }
        .padding(16)
        .background(.quaternary.opacity(0.3))
    }

    var statusColor: Color {
        switch configManager.connectionStatus {
        case .connected: return .green
        case .disconnected: return .red
        case .error: return .orange
        case .unknown: return .gray
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let openWindow: OpenWindowAction

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.quaternary.opacity(0.5))
                    .frame(width: 64, height: 64)

                Image(systemName: "gear.badge.questionmark")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 6) {
                Text("No Configurations")
                    .font(.headline)

                Text("Add a configuration to get started")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                openWindow(id: "config-add")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("Add Configuration", systemImage: "plus")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Config List View

struct ConfigListView: View {
    @EnvironmentObject var configManager: ConfigManager
    let openWindow: OpenWindowAction
    @State private var configToDelete: ProxyConfig?
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(configManager.configs) { config in
                    ConfigRowView(
                        config: config,
                        isActive: configManager.activeConfigId == config.id,
                        onActivate: {
                            configManager.switchToConfig(config)
                        },
                        onEdit: {
                            openWindow(id: "config-edit", value: config.id)
                            NSApp.activate(ignoringOtherApps: true)
                        },
                        onDelete: {
                            configToDelete = config
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding(12)
        }
        .alert("Delete Configuration", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let config = configToDelete {
                    configManager.deleteConfig(config)
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(configToDelete?.name ?? "")\"? This action cannot be undone.")
        }
    }
}

// MARK: - Config Row View

struct ConfigRowView: View {
    let config: ProxyConfig
    let isActive: Bool
    let onActivate: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            // Active indicator
            Circle()
                .fill(isActive ? Color.green : Color.clear)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color.green : Color.secondary.opacity(0.3), lineWidth: 1.5)
                )

            // Config info
            VStack(alignment: .leading, spacing: 3) {
                Text(config.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(config.model.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .clipShape(Capsule())

                    if config.alwaysThinkingEnabled {
                        HStack(spacing: 2) {
                            Image(systemName: "brain")
                            Text("Thinking")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Action buttons
            if isHovering {
                HStack(spacing: 4) {
                    if !isActive {
                        ActionButton(icon: "checkmark", color: .green) {
                            onActivate()
                        }
                        .help("Activate")
                    }

                    ActionButton(icon: "pencil", color: .secondary) {
                        onEdit()
                    }
                    .help("Edit")

                    ActionButton(icon: "trash", color: .red) {
                        onDelete()
                    }
                    .help("Delete")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive ? Color.green.opacity(0.1) : (isHovering ? Color.primary.opacity(0.05) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .onTapGesture {
            if !isActive {
                onActivate()
            }
        }
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Footer View

struct FooterView: View {
    let openWindow: OpenWindowAction

    var body: some View {
        HStack {
            Button {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(.quaternary.opacity(0.5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Quit")

            Spacer()

            Button {
                openWindow(id: "config-add")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Add")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.quaternary.opacity(0.3))
    }
}

#Preview {
    MenuBarContentView()
        .environmentObject(ConfigManager())
}
