import Foundation

/// A user-defined upstream provider with custom API base URL and key.
struct CustomProvider: Codable, Identifiable, Sendable, Equatable {

    enum EndpointType: String, Codable, Sendable, CaseIterable {
        case openAI = "openai"
        case anthropic = "anthropic"

        var displayName: String {
            switch self {
            case .openAI: return "OpenAI-compatible"
            case .anthropic: return "Anthropic-compatible"
            }
        }
    }

    let id: UUID
    var name: String
    var apiBaseURL: String
    var endpointType: EndpointType

    /// Keychain account name for this provider's API key.
    var keychainAccountName: String { "CUSTOM_\(id.uuidString)" }

    init(id: UUID = UUID(), name: String, apiBaseURL: String, endpointType: EndpointType = .openAI) {
        self.id = id
        self.name = name
        self.apiBaseURL = apiBaseURL
        self.endpointType = endpointType
    }
}
