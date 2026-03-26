import Foundation

@MainActor
final class DoorAliasStore {
    private let key = "v1-doorAliases"
    private let primaryDoorKey = "v1-primaryDoorId"

    func getPrimaryDoorId() -> String? {
        UserDefaults.standard.string(forKey: primaryDoorKey)
    }

    func setPrimaryDoorId(_ id: String?) {
        if let id {
            UserDefaults.standard.set(id, forKey: primaryDoorKey)
        } else {
            UserDefaults.standard.removeObject(forKey: primaryDoorKey)
        }
    }

    func getAlias(for locationId: String) -> String? {
        getAllAliases()[locationId]
    }

    func setAlias(_ alias: String?, for locationId: String) {
        var aliases = getAllAliases()
        if let alias, !alias.isEmpty {
            aliases[locationId] = alias
        } else {
            aliases.removeValue(forKey: locationId)
        }
        do {
            let data = try JSONEncoder().encode(aliases)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Non-critical error: \(error).")
        }
    }

    func getAllAliases() -> [String: String] {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return [:]
        }
        do {
            return try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("Non-critical error: \(error).")
            return [:]
        }
    }
}
