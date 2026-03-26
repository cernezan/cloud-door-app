import Foundation
import Testing

@testable import CloudDoor

struct APITests {

    // MARK: - urlEncodedParams

    @Test func urlEncodedParams_basicParams() throws {
        let result = try urlEncodedParams(params: ["key": "value"])
        #expect(result == "key=value")
    }

    @Test func urlEncodedParams_multipleParams() throws {
        let result = try urlEncodedParams(params: ["a": "1", "b": "2"])
        #expect(result.contains("a=1"))
        #expect(result.contains("b=2"))
        #expect(result.contains("&"))
    }

    @Test func urlEncodedParams_specialCharacters() throws {
        let result = try urlEncodedParams(params: ["email": "user@example.com"])
        #expect(result.contains("email="))
        #expect(result.contains("example.com"))
    }

    @Test func urlEncodedParams_emptyParams() throws {
        let result = try urlEncodedParams(params: [:])
        #expect(result == "")
    }

    @Test func urlEncodedParams_spaceInValue() throws {
        let result = try urlEncodedParams(params: ["name": "hello world"])
        #expect(result == "name=hello world")
    }

    // MARK: - ApiError

    @Test func apiError_runtimeErrorMessage() {
        let error = ApiError.runtimeError("something went wrong")
        if case .runtimeError(let message) = error {
            #expect(message == "something went wrong")
        } else {
            Issue.record("Expected runtimeError case")
        }
    }
}
