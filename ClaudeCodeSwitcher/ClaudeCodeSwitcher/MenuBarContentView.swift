import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var configManager: ConfigManager
    @State private var showingAddSheet = false
    @State private var editingConfig: ProxyConfig?

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 0) {
                // 头部状态栏
                MenuBarHeaderView()

                Divider()
                    .padding(.horizontal, 12)

                // 配置列表
                if configManager.configs.isEmpty {
                    MenuBarEmptyView(showingAddSheet: $showingAddSheet)
                } else {
                    MenuBarConfigListView(editingConfig: $editingConfig)
                }

                Divider()
                    .padding(.horizontal, 12)

                // 底部操作栏
                MenuBarFooterView(showingAddSheet: $showingAddSheet)
            }
            .frame(width: 320, height: 420)
        }
        .sheet(isPresented: $showingAddSheet) {
            ConfigEditView(config: nil)
        }
        .sheet(item: $editingConfig) { config in
            ConfigEditView(config: config)
        }
    }
}

// MARK: - 头部视图
struct MenuBarHeaderView: View {
    @EnvironmentObject var configManager: ConfigManager

    var body: some View {
        HStack(spacing: 12) {
            // 状态指示器
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .glassEffect(.clear, in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text("Claude Code Switcher")
                    .font(.headline)

                if let active = configManager.activeConfig {
                    Text(active.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No active config")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                configManager.detectActiveConfig()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .glassEffect(.clear.interactive(), in: .circle)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
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

// MARK: - 空状态视图
struct MenuBarEmptyView: View {
    @Binding var showingAddSheet: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No Configurations")
                .font(.subheadline)
                .fontWeight(.medium)

            Text("Add your first config")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Add Config") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
            .glassEffect(.regular.tint(.blue).interactive(), in: .capsule)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - 配置列表视图
struct MenuBarConfigListView: View {
    @EnvironmentObject var configManager: ConfigManager
    @Binding var editingConfig: ProxyConfig?
    @State private var configToDelete: ProxyConfig?
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(configManager.configs) { config in
                    MenuBarConfigRow(
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
            Text("Are you sure you want to delete \"\(configToDelete?.name ?? "")\"?")
        }
    }
}

// MARK: - 配置行视图
struct MenuBarConfigRow: View {
    let config: ProxyConfig
    let isActive: Bool
    let onActivate: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            // 激活状态指示
            Circle()
                .fill(isActive ? Color.green : Color.clear)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

            // 配置信息
            VStack(alignment: .leading, spacing: 2) {
                Text(config.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 6) {
                    Text(config.model)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if config.alwaysThinkingEnabled {
                        Image(systemName: "brain")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // 操作按钮
            if isHovering || isActive {
                HStack(spacing: 6) {
                    if !isActive {
                        Button {
                            onActivate()
                        } label: {
                            Image(systemName: "checkmark.circle")
                        }
                        .buttonStyle(.borderless)
                        .help("Activate")
                    }

                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderless)
                    .help("Edit")

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.red)
                    .help("Delete")
                }
            }
        }
        .padding(10)
        .glassEffect(
            isActive ? .regular.tint(.green.opacity(0.2)).interactive() :
            (isHovering ? .regular.interactive() : .clear),
            in: .rect(cornerRadius: 10)
        )
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

// MARK: - 底部视图
struct MenuBarFooterView: View {
    @Binding var showingAddSheet: Bool

    var body: some View {
        HStack {
            Button {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.borderless)
            .help("Quit")

            Spacer()

            Button {
                showingAddSheet = true
            } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.borderless)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
        .padding(12)
    }
}

#Preview {
    MenuBarContentView()
        .environmentObject(ConfigManager())
        .frame(width: 320, height: 420)
}
