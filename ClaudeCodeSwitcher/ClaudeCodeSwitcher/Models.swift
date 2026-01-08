import Foundation

struct ProxyConfig: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var apiKey: String
    var baseURL: String
    var model: String
    var alwaysThinkingEnabled: Bool

    init(name: String, apiKey: String, baseURL: String, model: String = "opus", alwaysThinkingEnabled: Bool = true) {
        self.name = name
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.alwaysThinkingEnabled = alwaysThinkingEnabled
    }
}

struct ClaudeSettings: Codable {
    var apiKeyHelper: String?
    var env: EnvironmentSettings
    var permissions: Permissions
    var model: String?
    var alwaysThinkingEnabled: Bool?

    struct EnvironmentSettings: Codable {
        var ANTHROPIC_AUTH_TOKEN: String?
        var ANTHROPIC_BASE_URL: String?
        var CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: String?

        enum CodingKeys: String, CodingKey {
            case ANTHROPIC_AUTH_TOKEN
            case ANTHROPIC_BASE_URL
            case CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
        }
    }

    struct Permissions: Codable {
        var allow: [String]
        var deny: [String]
    }
}

extension ProxyConfig {
    func toClaudeSettings() -> ClaudeSettings {
        ClaudeSettings(
            apiKeyHelper: "echo '\(apiKey)'",
            env: ClaudeSettings.EnvironmentSettings(
                ANTHROPIC_AUTH_TOKEN: apiKey,
                ANTHROPIC_BASE_URL: baseURL,
                CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1"
            ),
            permissions: ClaudeSettings.Permissions(allow: [], deny: []),
            model: model,
            alwaysThinkingEnabled: alwaysThinkingEnabled
        )
    }
}
