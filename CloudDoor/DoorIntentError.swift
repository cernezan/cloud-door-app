import AppIntents

enum DoorIntentError: Error, CustomLocalizedStringResourceConvertible {
    case notConfigured
    case noPrimaryDoor
    case authenticationFailed(String)
    case doorOpenFailed(String)
    case networkError

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notConfigured:
            "Open CloudDoor and add your account in Settings."
        case .noPrimaryDoor:
            "No primary door set. Open CloudDoor Settings and choose one."
        case .authenticationFailed(let detail):
            "Sign-in failed: \(detail)"
        case .doorOpenFailed(let detail):
            "Could not open the door. \(detail)"
        case .networkError:
            "No connection. Check your internet and try again."
        }
    }
}
