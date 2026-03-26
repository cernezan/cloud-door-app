import CoreLocation

struct LocationWithDistance: Identifiable, Sendable, Equatable {
    static func == (lhs: LocationWithDistance, rhs: LocationWithDistance) -> Bool {
        lhs.id == rhs.id
    }

    var id: String
    var location: Location
    var distance: Int?
    var inRadius: Bool

    init(location: Location, distance: Int?) {
        self.location = location
        self.id = location.id
        self.distance = distance

        guard let geo = location.geolocations.first, let distance else {
            self.inRadius = false
            return
        }
        self.inRadius = distance < geo.radius
    }
}

func getLocationsWithDistance(locations: [Location], distanceToLocation: CLLocation?) -> [LocationWithDistance] {
    locations.map { location in
        if let distanceToLocation, let geo = location.geolocations.first {
            let distance = Int(distanceToLocation.distance(from: CLLocation(latitude: geo.latitude, longitude: geo.longitude)))
            return LocationWithDistance(location: location, distance: distance)
        }
        return LocationWithDistance(location: location, distance: nil)
    }
}
