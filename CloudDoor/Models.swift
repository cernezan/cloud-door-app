import Foundation

struct TokenResponse: Decodable, Sendable {
    var access_token: String
}

struct TokenErrorResponse: Decodable, Sendable {
    var error: String
    var error_description: String
}

struct Geolocation: Codable, Sendable, Equatable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Int
}

struct Location: Codable, Sendable, Equatable {
    var name: String
    var id: String
    var geolocations: [Geolocation]
}

struct GetUserLocationsResponse: Decodable, Sendable {
    var result: [Location]
}

struct OpenDoorResponseResultData: Decodable, Sendable {
    var id: String
}

struct OpenDoorResponseResult: Decodable, Sendable {
    var data: OpenDoorResponseResultData
}

struct OpenDoorResponse: Decodable, Sendable {
    var result: OpenDoorResponseResult
}
