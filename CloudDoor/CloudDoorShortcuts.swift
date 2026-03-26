import AppIntents

struct CloudDoorShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenPrimaryDoorIntent(),
            phrases: [
                "Open door in \(.applicationName)",
                "Open my door in \(.applicationName)",
                "Unlock door in \(.applicationName)",
                "\(.applicationName) open door",
            ],
            shortTitle: "Open Primary Door",
            systemImageName: "door.left.hand.open"
        )

        AppShortcut(
            intent: OpenDoorIntent(),
            phrases: [
                "Open \(\.$door) in \(.applicationName)",
                "Open \(\.$door) with \(.applicationName)",
                "Unlock \(\.$door) in \(.applicationName)",
            ],
            shortTitle: "Open Door",
            systemImageName: "door.left.hand.open"
        )
    }
}
