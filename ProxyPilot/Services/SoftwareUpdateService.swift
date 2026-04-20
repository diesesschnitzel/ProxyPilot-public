import Combine
import Foundation

@MainActor
final class SoftwareUpdateService: ObservableObject {
    @Published var canCheckForUpdates = false

    init() {}

    func checkForUpdates() {}
    func checkForUpdatesInBackground() {}
}
