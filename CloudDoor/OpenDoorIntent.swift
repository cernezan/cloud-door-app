import AppIntents

struct OpenDoorIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Open Door"
    nonisolated(unsafe) static var description: IntentDescription = "Opens a door using CloudDoor"
    nonisolated(unsafe) static var openAppWhenRun: Bool = false

    @Parameter(title: "Door")
    var door: DoorAppEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let name = try await DoorOpener.open(doorId: door.id)
        return .result(dialog: "Opened \(name).")
    }
}
