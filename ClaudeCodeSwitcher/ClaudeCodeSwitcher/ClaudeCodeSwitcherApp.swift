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

        // 设置窗口
        Settings {
            SettingsView()
                .environmentObject(configManager)
        }
    }
}
