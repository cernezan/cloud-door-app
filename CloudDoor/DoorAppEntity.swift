import AppIntents

struct DoorAppEntity: AppEntity {
    nonisolated(unsafe) static var typeDisplayRepresentation: TypeDisplayRepresentation = "Door"
    nonisolated(unsafe) static var defaultQuery = DoorEntityQuery()

    var id: String

    @Property(title: "Name")
    var name: String

    @Property(title: "Original Name")
    var originalName: String

    var displayRepresentation: DisplayRepresentation {
        if name != originalName {
            DisplayRepresentation(title: "\(name)", subtitle: "\(originalName)")
        } else {
            DisplayRepresentation(title: "\(name)")
        }
    }

    init(id: String, name: String, originalName: String) {
        self.id = id
        self.name = name
        self.originalName = originalName
    }

    @MainActor
    static func from(location: Location, alias: String?) -> DoorAppEntity {
        let displayName = alias ?? location.name
        return DoorAppEntity(id: location.id, name: displayName, originalName: location.name)
    }
}
