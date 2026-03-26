import Foundation
import Testing

@testable import CloudDoor

@MainActor
struct CacheTests {

    private func cleanUp() {
        UserDefaults.standard.removeObject(forKey: "v1-cachedLocations")
    }

    @Test func getCachedLocations_emptyCache_returnsNil() {
        cleanUp()
        let cache = Cache()
        #expect(cache.getCachedLocations() == nil)
    }

    @Test func setCachedLocations_thenGet_roundTrips() {
        cleanUp()
        let cache = Cache()
        let locations = [
            Location(
                name: "Test Door",
                id: "t1",
                geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]
            ),
        ]

        cache.setCachedLocations(locations: locations)
        let retrieved = cache.getCachedLocations()

        #expect(retrieved != nil)
        #expect(retrieved?.count == 1)
        #expect(retrieved?[0].name == "Test Door")
        #expect(retrieved?[0].id == "t1")

        cleanUp()
    }

    @Test func setCachedLocations_emptyArray() {
        cleanUp()
        let cache = Cache()
        cache.setCachedLocations(locations: [])
        let retrieved = cache.getCachedLocations()

        #expect(retrieved != nil)
        #expect(retrieved?.isEmpty == true)

        cleanUp()
    }

    @Test func setCachedLocations_overwritesPrevious() {
        cleanUp()
        let cache = Cache()

        let first = [Location(name: "A", id: "1", geolocations: [])]
        cache.setCachedLocations(locations: first)

        let second = [Location(name: "B", id: "2", geolocations: [])]
        cache.setCachedLocations(locations: second)

        let retrieved = cache.getCachedLocations()
        #expect(retrieved?.count == 1)
        #expect(retrieved?[0].name == "B")

        cleanUp()
    }
}
