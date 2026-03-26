import Testing

@testable import CloudDoor

struct ConfigurationTests {

    @Test func configurationValues_initSetsProperties() {
        let values = ConfigurationValues(username: "user@example.com", password: "secret", hostname: "https://example.com")
        #expect(values.username == "user@example.com")
        #expect(values.password == "secret")
        #expect(values.hostname == "https://example.com")
    }

    @Test func configurationValues_emptyStrings() {
        let values = ConfigurationValues(username: "", password: "", hostname: "")
        #expect(values.username.isEmpty)
        #expect(values.password.isEmpty)
        #expect(values.hostname.isEmpty)
    }
}
