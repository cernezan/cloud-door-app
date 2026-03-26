import Foundation

enum ApiError: Error, Sendable {
    case runtimeError(String)
}

func urlEncodedParams(params: [String: String]) throws -> String {
    let queryItems = params.map { (key, value) in
        URLQueryItem(name: key, value: value)
    }
    if var urlComponents = URLComponents(string: "") {
        urlComponents.queryItems = queryItems
        if let query = urlComponents.query {
            return query
        }
    }

    throw ApiError.runtimeError("Failed to urlencode parameters")
}

final class API: Sendable {
    let url: String
    let username: String
    let password: String

    init(url: String, username: String, password: String) {
        self.url = url
        self.username = username
        self.password = password
    }

    @MainActor
    static func initFromConfiguration(configuration: Configuration) -> API {
        let values = configuration.get()
        return API(url: values.hostname, username: values.username, password: values.password)
    }

    private func request<T: Decodable>(method: String, path: String, contentType: String?, data: String?, token: String?) async throws -> T {
        guard let url = URL(string: "\(self.url)\(path)") else {
            throw ApiError.runtimeError("Invalid URL: \(self.url)\(path)")
        }
        var request = URLRequest(url: url)

        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpMethod = method

        if let data {
            request.httpBody = data.data(using: .utf8)
        }

        let (returnedData, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 400 {
                let error = try JSONDecoder().decode(TokenErrorResponse.self, from: returnedData)
                throw ApiError.runtimeError(error.error_description)
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: returnedData, encoding: .utf8) ?? "<unreadable>"
                throw ApiError.runtimeError("Response failed with status \(httpResponse.statusCode): \(body)")
            }
        } else {
            throw ApiError.runtimeError("Response failed without status code")
        }

        return try JSONDecoder().decode(T.self, from: returnedData)
    }

    func getToken() async throws -> String {
        let data = try urlEncodedParams(params: [
            "client_id": "DoorCloudWebApp",
            "grant_type": "password",
            "username": username,
            "password": password,
        ])
        let response: TokenResponse = try await self.request(method: "POST", path: "/token", contentType: "application/x-www-form-urlencoded", data: data, token: nil)
        return response.access_token
    }

    func getLocations(token: String) async throws -> [Location] {
        let response: GetUserLocationsResponse = try await self.request(method: "GET", path: "/api/Location/GetUserLocations", contentType: nil, data: nil, token: token)
        return response.result
    }

    func openDoor(token: String, accessPointId: String) async throws -> OpenDoorResponse {
        let data = "accessPointId=\(accessPointId)"
        return try await self.request(method: "POST", path: "/api/Location/OpenDoorOnLocation", contentType: nil, data: data, token: token)
    }
}
