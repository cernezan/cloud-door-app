import SwiftUI

@main
struct CloudDoorApp: App {
    enum AppTab: String {
        case doors
        case settings
    }

    @State private var selectedTab: AppTab = .doors

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                Tab("Doors", systemImage: "door.left.hand.closed", value: .doors) {
                    ContentView()
                }
                Tab("Settings", systemImage: "gear", value: .settings) {
                    SettingsView()
                }
            }
        }
    }
}
