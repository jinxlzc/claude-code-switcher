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
        GlassEffectContainer {
            VStack(spacing: 0) {
                // Header
                headerView

                Divider()
                    .padding(.horizontal, 16)

                // Form content
                formContent

                Divider()
                    .padding(.horizontal, 16)

                // Footer
                footerView
            }
            .frame(width: 380, height: 480)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text(isEditing ? "Edit Configuration" : "New Configuration")
                .font(.headline)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .glassEffect(.clear.interactive(), in: .circle)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    // MARK: - Form
    private var formContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Name field
                formField(title: "Name", hint: nil) {
                    TextField("Configuration Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .glassEffect(.clear, in: .rect(cornerRadius: 8))
                }

                // API Key field
                formField(title: "API Key", hint: "e.g., sk-ant-sid01-...") {
                    HStack {
                        Group {
                            if showAPIKey {
                                TextField("API Key", text: $apiKey)
                                    .font(.system(.body, design: .monospaced))
                            } else {
                                SecureField("API Key", text: $apiKey)
                            }
                        }
                        .textFieldStyle(.plain)

                        Button {
                            showAPIKey.toggle()
                        } label: {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(10)
                    .glassEffect(.clear, in: .rect(cornerRadius: 8))
                }

                // Base URL field
                formField(title: "Base URL", hint: "e.g., https://relay.nf.video") {
                    TextField("https://...", text: $baseURL)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .monospaced))
                        .padding(10)
                        .glassEffect(.clear, in: .rect(cornerRadius: 8))
                }

                // Model picker
                formField(title: "Model", hint: nil) {
                    Picker("", selection: $model) {
                        ForEach(availableModels, id: \.self) { m in
                            Text(m.capitalized).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .glassEffect(.regular.interactive(), in: .capsule)
                }

                // Toggle
                formField(title: "Options", hint: nil) {
                    Toggle("Always Thinking Enabled", isOn: $alwaysThinkingEnabled)
                        .toggleStyle(.switch)
                        .padding(10)
                        .glassEffect(.clear, in: .rect(cornerRadius: 8))
                }
            }
            .padding(16)
        }
    }

    // MARK: - Footer
    private var footerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape)
            .glassEffect(.clear.interactive(), in: .capsule)

            Spacer()

            Button(isEditing ? "Save" : "Add") {
                saveConfig()
            }
            .keyboardShortcut(.return)
            .buttonStyle(.borderedProminent)
            .disabled(!isValid)
            .glassEffect(.regular.tint(.blue).interactive(), in: .capsule)
        }
        .padding(16)
    }

    // MARK: - Helper Views
    @ViewBuilder
    private func formField<Content: View>(title: String, hint: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            content()

            if let hint = hint {
                Text(hint)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Logic
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
