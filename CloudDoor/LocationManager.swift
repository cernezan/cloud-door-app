import CoreLocation

@Observable
@MainActor
class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0]
        Task { @MainActor in
            self.location = newLocation
        }
    }
}
