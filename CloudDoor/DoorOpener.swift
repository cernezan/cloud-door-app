import Foundation

enum DoorOpener {
    @MainActor
    static func open(doorId: String) async throws -> String {
        let configuration = Configuration()
        let values = configuration.get()

        guard !values.hostname.isEmpty, !values.username.isEmpty, !values.password.isEmpty else {
            throw DoorIntentError.notConfigured
        }

        let api = API(url: values.hostname, username: values.username, password: values.password)

        let token: String
        do {
            token = try await api.getToken()
        } catch let error as ApiError {
            if case .runtimeError(let msg) = error {
                throw DoorIntentError.authenticationFailed(msg)
            }
            throw DoorIntentError.networkError
        } catch is URLError {
            throw DoorIntentError.networkError
        } catch {
            throw DoorIntentError.authenticationFailed(error.localizedDescription)
        }

        do {
            _ = try await api.openDoor(token: token, accessPointId: doorId)
        } catch let error as ApiError {
            if case .runtimeError(let msg) = error {
                throw DoorIntentError.doorOpenFailed(msg)
            }
            throw DoorIntentError.doorOpenFailed("Unknown error")
        } catch is URLError {
            throw DoorIntentError.networkError
        } catch {
            throw DoorIntentError.doorOpenFailed(error.localizedDescription)
        }

        let cache = Cache()
        let locations = cache.getCachedLocations() ?? []
        let name = locations.first(where: { $0.id == doorId })?.name ?? "door"
        return name
    }
}
