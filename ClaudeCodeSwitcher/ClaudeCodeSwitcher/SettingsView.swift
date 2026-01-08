import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var configManager: ConfigManager
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        GlassEffectContainer {
            Form {
                Section("General") {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                }

                Section("Status") {
                    LabeledContent("Configurations") {
                        Text("\(configManager.configs.count)")
                    }

                    if let active = configManager.activeConfig {
                        LabeledContent("Active") {
                            Text(active.name)
                        }
                    }
                }

                Section("About") {
                    LabeledContent("Version") {
                        Text("2.0.0")
                    }
                    LabeledContent("Build") {
                        Text("macOS 26")
                    }
                }
            }
            .formStyle(.grouped)
            .frame(width: 350, height: 280)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ConfigManager())
}
