import SwiftUI

@main
struct ClaudeCodeSwitcherApp: App {
    @StateObject private var configManager = ConfigManager()

    var body: some Scene {
        // 菜单栏入口
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(configManager)
        } label: {
            Image(systemName: "arrow.triangle.swap")
        }
        .menuBarExtraStyle(.window)

        // 配置编辑窗口
        Window("New Configuration", id: "config-add") {
            ConfigEditView(config: nil)
                .environmentObject(configManager)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        // 配置编辑窗口（编辑模式）
        WindowGroup("Edit Configuration", id: "config-edit", for: ProxyConfig.ID.self) { $configId in
            if let configId = configId,
               let config = configManager.configs.first(where: { $0.id == configId }) {
                ConfigEditView(config: config)
                    .environmentObject(configManager)
            }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        // 设置窗口
        Settings {
            SettingsView()
                .environmentObject(configManager)
        }
    }
}
