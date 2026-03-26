import AppIntents

struct OpenPrimaryDoorIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Open Primary Door"
    nonisolated(unsafe) static var description: IntentDescription = "Opens your primary door set in CloudDoor settings"
    nonisolated(unsafe) static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let aliasStore = DoorAliasStore()
        guard let primaryId = aliasStore.getPrimaryDoorId() else {
            throw DoorIntentError.noPrimaryDoor
        }

        let name = try await DoorOpener.open(doorId: primaryId)
        return .result(dialog: "Opened \(name).")
    }
}
