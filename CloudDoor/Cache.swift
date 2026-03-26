import Foundation

@MainActor
final class Cache {
    let cachedLocationsKey = "v1-cachedLocations"

    private func retrieve<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Non-critical error: \(error).")
            return nil
        }
    }

    private func store<T: Encodable>(key: String, obj: T) {
        do {
            let data = try JSONEncoder().encode(obj)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Non-critical error: \(error).")
        }
    }

    func getCachedLocations() -> [Location]? {
        retrieve(key: cachedLocationsKey)
    }

    func setCachedLocations(locations: [Location]) {
        store(key: cachedLocationsKey, obj: locations)
    }
}
