import Foundation
import Testing

@testable import CloudDoor

@MainActor
struct DoorAliasStoreTests {

    private func cleanUp() {
        UserDefaults.standard.removeObject(forKey: "v1-doorAliases")
    }

    @Test func getAlias_noAliasSet_returnsNil() {
        cleanUp()
        let store = DoorAliasStore()
        #expect(store.getAlias(for: "loc1") == nil)
    }

    @Test func setAlias_thenGet_roundTrips() {
        cleanUp()
        let store = DoorAliasStore()
        store.setAlias("work door", for: "loc1")
        #expect(store.getAlias(for: "loc1") == "work door")
        cleanUp()
    }

    @Test func setAlias_nil_removesAlias() {
        cleanUp()
        let store = DoorAliasStore()
        store.setAlias("home", for: "loc1")
        store.setAlias(nil, for: "loc1")
        #expect(store.getAlias(for: "loc1") == nil)
        cleanUp()
    }

    @Test func setAlias_emptyString_removesAlias() {
        cleanUp()
        let store = DoorAliasStore()
        store.setAlias("garage", for: "loc1")
        store.setAlias("", for: "loc1")
        #expect(store.getAlias(for: "loc1") == nil)
        cleanUp()
    }

    @Test func getAllAliases_multipleEntries() {
        cleanUp()
        let store = DoorAliasStore()
        store.setAlias("work door", for: "loc1")
        store.setAlias("home", for: "loc2")
        let all = store.getAllAliases()
        #expect(all.count == 2)
        #expect(all["loc1"] == "work door")
        #expect(all["loc2"] == "home")
        cleanUp()
    }

    @Test func setAlias_overwritesPrevious() {
        cleanUp()
        let store = DoorAliasStore()
        store.setAlias("old name", for: "loc1")
        store.setAlias("new name", for: "loc1")
        #expect(store.getAlias(for: "loc1") == "new name")
        cleanUp()
    }
}
