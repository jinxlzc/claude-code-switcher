import Foundation
import Combine

class ConfigManager: ObservableObject {
    @Published var configs: [ProxyConfig] = []
    @Published var activeConfigId: UUID?
    @Published var connectionStatus: ConnectionStatus = .unknown

    private let appConfigURL: URL
    private let claudeSettingsURL: URL

    enum ConnectionStatus: Equatable {
        case unknown
        case connected
        case disconnected
        case error(String)

        var displayText: String {
            switch self {
            case .unknown: return "Unknown"
            case .connected: return "Connected"
            case .disconnected: return "Disconnected"
            case .error(let msg): return "Error: \(msg)"
            }
        }

        var color: String {
            switch self {
            case .unknown: return "gray"
            case .connected: return "green"
            case .disconnected: return "red"
            case .error: return "orange"
            }
        }
    }

    init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        self.claudeSettingsURL = homeDir.appendingPathComponent(".claude/settings.json")

        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("ClaudeCodeSwitcher")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        self.appConfigURL = appDir.appendingPathComponent("configs.json")

        loadConfigs()
        detectActiveConfig()
    }

    // MARK: - Config Management

    func loadConfigs() {
        guard FileManager.default.fileExists(atPath: appConfigURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: appConfigURL)
            let decoded = try JSONDecoder().decode(AppConfig.self, from: data)
            configs = decoded.configs
            activeConfigId = decoded.activeConfigId
        } catch {
            print("Failed to load configs: \(error)")
        }
    }

    func saveConfigs() {
        do {
            let appConfig = AppConfig(configs: configs, activeConfigId: activeConfigId)
            let data = try JSONEncoder().encode(appConfig)
            try data.write(to: appConfigURL)
        } catch {
            print("Failed to save configs: \(error)")
        }
    }

    func addConfig(_ config: ProxyConfig) {
        configs.append(config)
        saveConfigs()
    }

    func updateConfig(_ config: ProxyConfig) {
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
            saveConfigs()
        }
    }

    func deleteConfig(_ config: ProxyConfig) {
        configs.removeAll { $0.id == config.id }
        if activeConfigId == config.id {
            activeConfigId = nil
        }
        saveConfigs()
    }

    // MARK: - Switch Config

    func switchToConfig(_ config: ProxyConfig) {
        do {
            let settings = config.toClaudeSettings()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(settings)

            // Ensure .claude directory exists
            let claudeDir = claudeSettingsURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: claudeDir, withIntermediateDirectories: true)

            try data.write(to: claudeSettingsURL)
            activeConfigId = config.id
            saveConfigs()
            checkConnection(for: config)
        } catch {
            connectionStatus = .error(error.localizedDescription)
        }
    }

    // MARK: - Status Detection

    func detectActiveConfig() {
        guard FileManager.default.fileExists(atPath: claudeSettingsURL.path) else {
            connectionStatus = .disconnected
            return
        }

        do {
            let data = try Data(contentsOf: claudeSettingsURL)
            let settings = try JSONDecoder().decode(ClaudeSettings.self, from: data)

            // Try to match with existing configs
            if let baseURL = settings.env.ANTHROPIC_BASE_URL,
               let apiKey = settings.env.ANTHROPIC_AUTH_TOKEN {
                if let matchedConfig = configs.first(where: {
                    $0.baseURL == baseURL && $0.apiKey == apiKey
                }) {
                    activeConfigId = matchedConfig.id
                    saveConfigs()
                    checkConnection(for: matchedConfig)
                    return
                }
            }

            connectionStatus = .connected
        } catch {
            connectionStatus = .error("Failed to read settings")
        }
    }

    func checkConnection(for config: ProxyConfig) {
        connectionStatus = .connected

        // Simple check: verify URL is valid
        guard URL(string: config.baseURL) != nil else {
            connectionStatus = .error("Invalid URL")
            return
        }
    }

    var activeConfig: ProxyConfig? {
        guard let activeId = activeConfigId else { return nil }
        return configs.first { $0.id == activeId }
    }
}

// MARK: - App Config Storage

private struct AppConfig: Codable {
    var configs: [ProxyConfig]
    var activeConfigId: UUID?
}
