import AppIntents

struct DoorEntityQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [DoorAppEntity] {
        let all = allDoorEntities()
        return all.filter { identifiers.contains($0.id) }
    }

    @MainActor
    func entities(matching string: String) async throws -> [DoorAppEntity] {
        let all = allDoorEntities()
        return all.filter {
            $0.name.localizedStandardContains(string) ||
            $0.originalName.localizedStandardContains(string)
        }
    }

    @MainActor
    func suggestedEntities() async throws -> [DoorAppEntity] {
        allDoorEntities()
    }

    @MainActor
    private func allDoorEntities() -> [DoorAppEntity] {
        let cache = Cache()
        let aliasStore = DoorAliasStore()
        guard let locations = cache.getCachedLocations() else { return [] }
        let aliases = aliasStore.getAllAliases()
        return locations.map { location in
            DoorAppEntity.from(location: location, alias: aliases[location.id])
        }
    }
}
