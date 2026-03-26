import Foundation
import Testing

@testable import CloudDoor

struct ModelsTests {

    // MARK: - TokenResponse

    @Test func tokenResponse_decodesValidJSON() throws {
        let json = #"{"access_token": "abc123"}"#
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(TokenResponse.self, from: data)
        #expect(result.access_token == "abc123")
    }

    @Test func tokenResponse_missingField_throws() {
        let json = #"{}"#
        let data = Data(json.utf8)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TokenResponse.self, from: data)
        }
    }

    // MARK: - TokenErrorResponse

    @Test func tokenErrorResponse_decodesValidJSON() throws {
        let json = #"{"error": "invalid_grant", "error_description": "Bad credentials"}"#
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(TokenErrorResponse.self, from: data)
        #expect(result.error == "invalid_grant")
        #expect(result.error_description == "Bad credentials")
    }

    // MARK: - Geolocation

    @Test func geolocation_decodesValidJSON() throws {
        let json = #"{"id": "g1", "name": "Office", "latitude": 46.05, "longitude": 14.50, "radius": 100}"#
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(Geolocation.self, from: data)
        #expect(result.id == "g1")
        #expect(result.latitude == 46.05)
        #expect(result.longitude == 14.50)
        #expect(result.radius == 100)
    }

    @Test func geolocation_roundtrips() throws {
        let original = Geolocation(id: "g1", name: "Test", latitude: 46.0, longitude: 14.0, radius: 50)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Geolocation.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.radius == original.radius)
    }

    // MARK: - Location

    @Test func location_decodesValidJSON() throws {
        let json = #"{"name": "Front Door", "id": "loc1", "geolocations": [{"id": "g1", "name": "geo", "latitude": 46.0, "longitude": 14.0, "radius": 100}]}"#
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(Location.self, from: data)
        #expect(result.name == "Front Door")
        #expect(result.id == "loc1")
        #expect(result.geolocations.count == 1)
    }

    @Test func location_roundtrips() throws {
        let original = Location(
            name: "Door",
            id: "d1",
            geolocations: [Geolocation(id: "g1", name: "geo", latitude: 46.0, longitude: 14.0, radius: 100)]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Location.self, from: data)
        #expect(decoded.name == original.name)
        #expect(decoded.geolocations.count == 1)
    }

    // MARK: - GetUserLocationsResponse

    @Test func getUserLocationsResponse_decodesValidJSON() throws {
        let json = #"{"result": [{"name": "A", "id": "1", "geolocations": []}]}"#
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(GetUserLocationsResponse.self, from: data)
        #expect(result.result.count == 1)
        #expect(result.result[0].name == "A")
    }

    @Test func getUserLocationsResponse_emptyResult() throws {
        let json = #"{"result": []}"#
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(GetUserLocationsResponse.self, from: data)
        #expect(result.result.isEmpty)
    }

    // MARK: - OpenDoorResponse

    @Test func openDoorResponse_decodesValidJSON() throws {
        let json = #"{"result": {"data": {"id": "op123"}}}"#
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(OpenDoorResponse.self, from: data)
        #expect(result.result.data.id == "op123")
    }
}
