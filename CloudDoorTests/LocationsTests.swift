import CoreLocation
import Testing

@testable import CloudDoor

struct LocationsTests {

    // MARK: - LocationWithDistance.init

    @Test func locationWithDistance_withinRadius() {
        let location = Location(
            name: "Front Door",
            id: "1",
            geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]
        )
        let lwd = LocationWithDistance(location: location, distance: 50)

        #expect(lwd.inRadius == true)
        #expect(lwd.distance == 50)
        #expect(lwd.id == "1")
    }

    @Test func locationWithDistance_outsideRadius() {
        let location = Location(
            name: "Back Door",
            id: "2",
            geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]
        )
        let lwd = LocationWithDistance(location: location, distance: 150)

        #expect(lwd.inRadius == false)
    }

    @Test func locationWithDistance_exactlyAtRadius_isOutside() {
        let location = Location(
            name: "Side Door",
            id: "3",
            geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]
        )
        let lwd = LocationWithDistance(location: location, distance: 100)

        #expect(lwd.inRadius == false) // uses <, not <=
    }

    @Test func locationWithDistance_nilDistance() {
        let location = Location(
            name: "Door",
            id: "4",
            geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]
        )
        let lwd = LocationWithDistance(location: location, distance: nil)

        #expect(lwd.inRadius == false)
        #expect(lwd.distance == nil)
    }

    @Test func locationWithDistance_emptyGeolocations() {
        let location = Location(name: "Empty", id: "5", geolocations: [])
        let lwd = LocationWithDistance(location: location, distance: 50)

        #expect(lwd.inRadius == false)
    }

    // MARK: - getLocationsWithDistance

    @Test func getLocationsWithDistance_nilLocation() {
        let locations = [
            Location(name: "A", id: "1", geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]),
        ]
        let result = getLocationsWithDistance(locations: locations, distanceToLocation: nil)

        #expect(result.count == 1)
        #expect(result[0].distance == nil)
        #expect(result[0].inRadius == false)
    }

    @Test func getLocationsWithDistance_withLocation_nearbyPoint() {
        let locations = [
            Location(name: "A", id: "1", geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.05, longitude: 14.5, radius: 100_000)]),
        ]
        let userLocation = CLLocation(latitude: 46.05, longitude: 14.5)
        let result = getLocationsWithDistance(locations: locations, distanceToLocation: userLocation)

        #expect(result.count == 1)
        #expect(result[0].distance != nil)
        #expect(result[0].distance! < 100)
        #expect(result[0].inRadius == true)
    }

    @Test func getLocationsWithDistance_emptyArray() {
        let result = getLocationsWithDistance(locations: [], distanceToLocation: nil)
        #expect(result.isEmpty)
    }

    @Test func getLocationsWithDistance_multipleLocations() {
        let locations = [
            Location(name: "A", id: "1", geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]),
            Location(name: "B", id: "2", geolocations: [Geolocation(id: "g2", name: "geo", latitude: 47.0, longitude: 15.0, radius: 200)]),
        ]
        let result = getLocationsWithDistance(locations: locations, distanceToLocation: nil)

        #expect(result.count == 2)
        #expect(result[0].id == "1")
        #expect(result[1].id == "2")
    }
}
