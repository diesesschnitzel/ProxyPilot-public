import SwiftUI

struct AddCustomProviderView: View {
    @Environment(\.dismiss) private var dismiss

    var onAdd: (String, String, String, CustomProvider.EndpointType) -> Void

    @State private var name: String = ""
    @State private var apiBaseURL: String = ""
    @State private var apiKey: String = ""
    @State private var endpointType: CustomProvider.EndpointType = .openAI

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && URL(string: apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Custom Provider")
                .font(.headline)

            Text("If you're just adding a new LLM endpoint, consider using OpenRouter to verify functionality before adding a custom provider.")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Provider Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("API Base URL (e.g. https://api.together.xyz/v1)", text: $apiBaseURL)
                .textFieldStyle(.roundedBorder)

            SecureField("API Key", text: $apiKey)
                .textFieldStyle(.roundedBorder)

            Picker("Endpoint Type", selection: $endpointType) {
                ForEach(CustomProvider.EndpointType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)

            Text(endpointType == .anthropic
                ? "Anthropic-compatible endpoint: sends requests directly to /v1/messages without OpenAI translation."
                : "OpenAI-compatible endpoint: requests forwarded to /v1/chat/completions. No parameter normalization is applied.")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") {
                    onAdd(
                        name.trimmingCharacters(in: .whitespacesAndNewlines),
                        apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines),
                        apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
                        endpointType
                    )
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canAdd)
            }
        }
        .padding()
        .frame(width: 420)
    }
}
