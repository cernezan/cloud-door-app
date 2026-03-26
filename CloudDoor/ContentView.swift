import SwiftUI

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var locations: [LocationWithDistance] = []
    @State private var alertItem: AlertItem?
    @State private var showAlert = false
    @State private var configuration = Configuration()
    @State private var cache = Cache()
    @State private var aliasStore = DoorAliasStore()
    @State private var isConfigured = false
    @State private var isLoading = false
    @State private var editingAliasDoor: LocationWithDistance?
    @State private var aliasText = ""

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Doors")
                .task {
                    let values = configuration.get()
                    isConfigured = !values.hostname.isEmpty
                    loadCachedLocations()
                    if !values.username.isEmpty {
                        await refreshLocations()
                    }
                }
                .refreshable {
                    await refreshLocations()
                }
                .onChange(of: locationManager.location) {
                    recalculateDistances()
                }
                .onChange(of: alertItem) {
                    showAlert = alertItem != nil
                }
                .alert(alertItem?.title ?? "", isPresented: $showAlert) { } message: {
                    Text(alertItem?.message ?? "")
                }
                .sheet(item: $editingAliasDoor) { door in
                    siriNameSheet(for: door)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if !isConfigured {
            ContentUnavailableView(
                "No Account",
                systemImage: "person.crop.circle.badge.questionmark",
                description: Text("To see your doors, add your credentials in Settings.")
            )
        } else if isLoading && locations.isEmpty {
            ProgressView("Loading doors...")
        } else if locations.isEmpty {
            ContentUnavailableView(
                "No Doors",
                systemImage: "door.left.hand.closed",
                description: Text("Pull down to refresh.")
            )
        } else {
            DoorListView(
                doors: locations,
                onDoorTap: { door in Task { await handleDoorTap(door) } },
                onSetAlias: { door in
                    aliasText = aliasStore.getAlias(for: door.id) ?? ""
                    editingAliasDoor = door
                }
            )
        }
    }

    private func siriNameSheet(for door: LocationWithDistance) -> some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g. work door, home, garage", text: $aliasText)
                        .textInputAutocapitalization(.never)
                } header: {
                    Text("Siri Name")
                } footer: {
                    Text("Say \"Hey Siri, open \(aliasText.isEmpty ? door.location.name : aliasText) in CloudDoor\"")
                }
            }
            .navigationTitle("Siri Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        aliasStore.setAlias(aliasText.isEmpty ? nil : aliasText, for: door.id)
                        editingAliasDoor = nil
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editingAliasDoor = nil }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func loadCachedLocations() {
        let cached = cache.getCachedLocations() ?? []
        locations = getLocationsWithDistance(locations: cached, distanceToLocation: nil)
    }

    private func refreshLocations() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let api = API.initFromConfiguration(configuration: configuration)
            let token = try await api.getToken()
            let fetched = try await api.getLocations(token: token)
            cache.setCachedLocations(locations: fetched)
            locations = getLocationsWithDistance(locations: fetched, distanceToLocation: locationManager.location)
        } catch {
            alertItem = AlertItem(title: "Connection Problem", message: "Could not load doors. Check your connection and try again.")
        }
    }

    private func recalculateDistances() {
        let raw = locations.map { $0.location }
        locations = getLocationsWithDistance(locations: raw, distanceToLocation: locationManager.location)
    }

    private func handleDoorTap(_ door: LocationWithDistance) async {
        guard door.inRadius else {
            if let distance = door.distance, let geo = door.location.geolocations.first {
                alertItem = AlertItem(
                    title: "Out of Range",
                    message: "\(door.location.name) is \(distance) m away. You need to be within \(geo.radius) m."
                )
            } else {
                alertItem = AlertItem(
                    title: "Location Unavailable",
                    message: "To open doors, allow location access in Settings > Privacy > Location Services."
                )
            }
            return
        }

        do {
            let api = API.initFromConfiguration(configuration: configuration)
            let token = try await api.getToken()
            _ = try await api.openDoor(token: token, accessPointId: door.id)
            alertItem = AlertItem(title: "Opened", message: "\(door.location.name) opened.")
        } catch {
            alertItem = AlertItem(title: "Could Not Open Door", message: "Check your connection and try again.")
        }
    }
}

#Preview {
    ContentView()
}
