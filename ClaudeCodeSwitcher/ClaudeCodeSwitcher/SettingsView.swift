import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var configManager: ConfigManager
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 24)

            // Content
            VStack(spacing: 20) {
                // General Section
                SettingsSection(title: "General") {
                    SettingsRow(
                        title: "Launch at Login",
                        subtitle: "Start automatically when you log in"
                    ) {
                        Toggle("", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }

                // Status Section
                SettingsSection(title: "Status") {
                    SettingsRow(title: "Configurations", subtitle: nil) {
                        Text("\(configManager.configs.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let active = configManager.activeConfig {
                        SettingsRow(title: "Active Configuration", subtitle: nil) {
                            Text(active.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // About Section
                SettingsSection(title: "About") {
                    SettingsRow(title: "Version", subtitle: nil) {
                        Text("2.0.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    SettingsRow(title: "Platform", subtitle: nil) {
                        Text("macOS 26")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(width: 400, height: 380)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                content()
            }
            .background(.quaternary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Settings Row

struct SettingsRow<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let trailing: () -> Content

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ConfigManager())
}
