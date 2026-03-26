import SwiftUI

struct SettingsView: View {
    @State private var username: String
    @State private var password: String
    @State private var hostname: String
    @State private var alertItem: AlertItem?
    @State private var showAlert = false
    @State private var isTesting = false
    @State private var primaryDoorId: String?
    @State private var cachedLocations: [Location] = []

    private let productionHost = "https://api.doorcloud.com"
    @State private var configuration = Configuration()
    @State private var cache = Cache()
    @State private var aliasStore = DoorAliasStore()

    init() {
        let config = Configuration()
        let values = config.get()
        self._configuration = State(initialValue: config)
        self.username = values.username
        self.password = values.password
        self.hostname = values.hostname.isEmpty ? "https://api.doorcloud.com" : values.hostname
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $username, prompt: Text("name@example.com"))
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)

                    SecureField("Password", text: $password, prompt: Text("Required"))
                        .textContentType(.password)

                    TextField("Server", text: $hostname, prompt: Text("https://api.doorcloud.com"))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                } header: {
                    Text("Account")
                } footer: {
                    if hostname != productionHost {
                        Button("Reset to Default Server") {
                            hostname = productionHost
                        }
                        .font(.footnote)
                    }
                }

                Section {
                    Button {
                        Task { await testAndSave() }
                    } label: {
                        HStack {
                            Text("Test Connection & Save")
                            Spacer()
                            if isTesting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isTesting || username.isEmpty || password.isEmpty || hostname.isEmpty)
                }

                if !cachedLocations.isEmpty {
                    Section {
                        Picker("Primary Door", selection: $primaryDoorId) {
                            Text("None").tag(String?.none)
                            ForEach(cachedLocations, id: \.id) { location in
                                Text(location.name).tag(Optional(location.id))
                            }
                        }
                    } header: {
                        Text("Siri")
                    } footer: {
                        if primaryDoorId != nil {
                            Text("\"Hey Siri, open door in CloudDoor\" opens your primary door. Swipe a door in the list to set a custom Siri name.")
                        } else {
                            Text("Choose a door to enable hands-free opening with Siri.")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                cachedLocations = cache.getCachedLocations() ?? []
                primaryDoorId = aliasStore.getPrimaryDoorId()
            }
            .onChange(of: primaryDoorId) {
                aliasStore.setPrimaryDoorId(primaryDoorId)
            }
            .onChange(of: alertItem) {
                showAlert = alertItem != nil
            }
            .alert(alertItem?.title ?? "", isPresented: $showAlert) { } message: {
                Text(alertItem?.message ?? "")
            }
        }
    }

    private func testAndSave() async {
        isTesting = true
        defer { isTesting = false }

        let api = API(url: hostname, username: username, password: password)
        do {
            _ = try await api.getToken()
            configuration.set(username: username, password: password, hostname: hostname)
            alertItem = AlertItem(title: "Saved", message: "Connected successfully.")
        } catch ApiError.runtimeError(let message) {
            alertItem = AlertItem(title: "Authentication Failed", message: message)
        } catch {
            alertItem = AlertItem(title: "Connection Failed", message: "Could not reach the server. Check the hostname and try again.")
        }
    }
}

#Preview {
    SettingsView()
}
