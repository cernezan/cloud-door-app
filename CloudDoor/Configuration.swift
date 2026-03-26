import KeychainSwift

struct ConfigurationValues: Sendable {
    var username: String
    var password: String
    var hostname: String
}

@MainActor
final class Configuration {
    let keychain = KeychainSwift()

    func get() -> ConfigurationValues {
        ConfigurationValues(
            username: keychain.get("username") ?? "",
            password: keychain.get("password") ?? "",
            hostname: keychain.get("hostname") ?? ""
        )
    }

    func set(username: String, password: String, hostname: String) {
        keychain.set(username, forKey: "username", withAccess: .accessibleAfterFirstUnlock)
        keychain.set(password, forKey: "password", withAccess: .accessibleAfterFirstUnlock)
        keychain.set(hostname, forKey: "hostname", withAccess: .accessibleAfterFirstUnlock)
    }
}
