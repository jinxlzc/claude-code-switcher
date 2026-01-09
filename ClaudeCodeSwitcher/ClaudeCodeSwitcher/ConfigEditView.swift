import SwiftUI

struct ConfigEditView: View {
    @EnvironmentObject var configManager: ConfigManager
    @Environment(\.dismiss) var dismiss

    let config: ProxyConfig?

    @State private var name: String = ""
    @State private var apiKey: String = ""
    @State private var baseURL: String = ""
    @State private var model: String = "opus"
    @State private var alwaysThinkingEnabled: Bool = true
    @State private var showAPIKey: Bool = false

    var isEditing: Bool { config != nil }

    let availableModels = ["opus", "sonnet", "haiku"]

    init(config: ProxyConfig?) {
        self.config = config
        if let config = config {
            _name = State(initialValue: config.name)
            _apiKey = State(initialValue: config.apiKey)
            _baseURL = State(initialValue: config.baseURL)
            _model = State(initialValue: config.model)
            _alwaysThinkingEnabled = State(initialValue: config.alwaysThinkingEnabled)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEditing ? "Edit Configuration" : "New Configuration")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(isEditing ? "Modify your proxy settings" : "Add a new proxy configuration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 24)

            // Form content
            ScrollView {
                VStack(spacing: 20) {
                    // Name field
                    FormField(title: "Configuration Name") {
                        TextField("My Config", text: $name)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // API Key field
                    FormField(title: "API Key") {
                        HStack(spacing: 8) {
                            Group {
                                if showAPIKey {
                                    TextField("sk-ant-...", text: $apiKey)
                                        .font(.system(.body, design: .monospaced))
                                } else {
                                    SecureField("sk-ant-...", text: $apiKey)
                                }
                            }
                            .textFieldStyle(.plain)

                            Button {
                                showAPIKey.toggle()
                            } label: {
                                Image(systemName: showAPIKey ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(.quaternary.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Base URL field
                    FormField(title: "Base URL") {
                        TextField("https://api.example.com", text: $baseURL)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                            .padding(12)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Model picker
                    FormField(title: "Default Model") {
                        HStack(spacing: 8) {
                            ForEach(availableModels, id: \.self) { m in
                                ModelButton(
                                    title: m.capitalized,
                                    isSelected: model == m
                                ) {
                                    model = m
                                }
                            }
                        }
                    }

                    // Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Extended Thinking")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Enable always thinking mode")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $alwaysThinkingEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                    .padding(12)
                    .background(.quaternary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(24)
            }

            Divider()
                .padding(.horizontal, 24)

            // Footer
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 10)
                .background(.quaternary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .keyboardShortcut(.escape)

                Button {
                    saveConfig()
                } label: {
                    Text(isEditing ? "Save Changes" : "Add Configuration")
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 10)
                .background(isValid ? Color.accentColor : Color.accentColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(!isValid)
                .keyboardShortcut(.return)
            }
            .padding(24)
        }
        .frame(width: 400, height: 520)
        .background(.ultraThinMaterial)
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !apiKey.trimmingCharacters(in: .whitespaces).isEmpty &&
        !baseURL.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func saveConfig() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespaces)
        let trimmedBaseURL = baseURL.trimmingCharacters(in: .whitespaces)

        if var existingConfig = config {
            existingConfig.name = trimmedName
            existingConfig.apiKey = trimmedApiKey
            existingConfig.baseURL = trimmedBaseURL
            existingConfig.model = model
            existingConfig.alwaysThinkingEnabled = alwaysThinkingEnabled
            configManager.updateConfig(existingConfig)
        } else {
            let newConfig = ProxyConfig(
                name: trimmedName,
                apiKey: trimmedApiKey,
                baseURL: trimmedBaseURL,
                model: model,
                alwaysThinkingEnabled: alwaysThinkingEnabled
            )
            configManager.addConfig(newConfig)
        }

        dismiss()
    }
}

// MARK: - Helper Views

struct FormField<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            content()
        }
    }
}

struct ModelButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Add") {
    ConfigEditView(config: nil)
        .environmentObject(ConfigManager())
}

#Preview("Edit") {
    ConfigEditView(config: ProxyConfig(
        name: "Test Config",
        apiKey: "sk-test-key",
        baseURL: "https://example.com"
    ))
    .environmentObject(ConfigManager())
}
