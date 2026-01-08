import SwiftUI

struct ContentView: View {
    @EnvironmentObject var configManager: ConfigManager
    @State private var showingAddSheet = false
    @State private var editingConfig: ProxyConfig?
    @State private var showingDeleteAlert = false
    @State private var configToDelete: ProxyConfig?

    var body: some View {
        VStack(spacing: 0) {
            // Header with status
            HeaderView()

            Divider()

            // Config list
            if configManager.configs.isEmpty {
                EmptyStateView(showingAddSheet: $showingAddSheet)
            } else {
                ConfigListView(
                    editingConfig: $editingConfig,
                    configToDelete: $configToDelete,
                    showingDeleteAlert: $showingDeleteAlert
                )
            }

            Divider()

            // Footer with add button
            FooterView(showingAddSheet: $showingAddSheet)
        }
        .frame(width: 500, height: 450)
        .sheet(isPresented: $showingAddSheet) {
            ConfigEditView(config: nil)
        }
        .sheet(item: $editingConfig) { config in
            ConfigEditView(config: config)
        }
        .alert("Delete Configuration", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let config = configToDelete {
                    configManager.deleteConfig(config)
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(configToDelete?.name ?? "")\"?")
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    @EnvironmentObject var configManager: ConfigManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Claude Code Switcher")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)

                    if let active = configManager.activeConfig {
                        Text("Active: \(active.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No active configuration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: {
                configManager.detectActiveConfig()
            }) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .help("Refresh status")
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
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

// MARK: - Empty State

struct EmptyStateView: View {
    @Binding var showingAddSheet: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Configurations")
                .font(.headline)

            Text("Add your first proxy configuration to get started")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Add Configuration") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Config List

struct ConfigListView: View {
    @EnvironmentObject var configManager: ConfigManager
    @Binding var editingConfig: ProxyConfig?
    @Binding var configToDelete: ProxyConfig?
    @Binding var showingDeleteAlert: Bool

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(configManager.configs) { config in
                    ConfigRowView(
                        config: config,
                        isActive: configManager.activeConfigId == config.id,
                        onActivate: {
                            configManager.switchToConfig(config)
                        },
                        onEdit: {
                            editingConfig = config
                        },
                        onDelete: {
                            configToDelete = config
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Config Row

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
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

            // Config info
            VStack(alignment: .leading, spacing: 2) {
                Text(config.name)
                    .font(.headline)

                Text(config.baseURL)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(config.model, systemImage: "cpu")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if config.alwaysThinkingEnabled {
                        Label("Thinking", systemImage: "brain")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Action buttons
            if isHovering || isActive {
                HStack(spacing: 8) {
                    if !isActive {
                        Button("Activate") {
                            onActivate()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }

                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderless)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.red)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color.accentColor.opacity(0.1) : (isHovering ? Color.secondary.opacity(0.1) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Footer

struct FooterView: View {
    @Binding var showingAddSheet: Bool

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                showingAddSheet = true
            }) {
                Label("Add Configuration", systemImage: "plus")
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .environmentObject(ConfigManager())
}
