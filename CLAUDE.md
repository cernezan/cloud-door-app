# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CloudDoor is a native iOS app (SwiftUI, iOS 26+, Swift 6.2) that lets users remotely open doors via the DoorCloud API. Users authenticate with email/password, the app fetches their accessible doors, and allows opening doors when the device is within a geofenced radius.

## Build & Test

Build and test via Xcode or `xcodebuild`. The scheme is `CloudDoor`.

```bash
# Build
xcodebuild build -scheme CloudDoor -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'

# Run unit tests
xcodebuild test -scheme CloudDoor -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'

# Run UI tests
xcodebuild test -scheme CloudDoor -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' -only-testing:CloudDoorUITests
```

If XcodeBuildMCP is available, prefer using that for builds, tests, and running the app.

## Architecture

All source lives in `CloudDoor/` (flat structure, no subdirectories). Uses `@Observable` pattern with `@MainActor` isolation.

**App entry & UI:**
- `CloudDoorApp.swift` -- `@main` entry point; `TabView` with `Tab` API (Liquid Glass tab bar)
- `ContentView.swift` -- Doors tab; `NavigationStack` with door list, `ContentUnavailableView` for empty states, `Button`-based rows with accessibility labels
- `SettingsView.swift` -- Settings tab; `NavigationStack` + `Form`, credential entry with "Test & Save" validation

**Services:**
- `API.swift` -- `final class API: Sendable`. HTTP client calling `/token`, `/api/Location/GetUserLocations`, `/api/Location/OpenDoorOnLocation`. Also contains `ApiError` enum and `urlEncodedParams()` helper.
- `Configuration.swift` -- `@MainActor` class wrapping KeychainSwift for secure credential storage
- `Cache.swift` -- `@MainActor` class wrapping UserDefaults for location caching
- `LocationManager.swift` -- `@Observable @MainActor` CLLocationManager wrapper; publishes live `CLLocation` and reverse-geocoded `CLPlacemark`

**Data models:**
- `Models.swift` -- All API response structs (`Location`, `Geolocation`, `TokenResponse`, etc.), all `Sendable`
- `Locations.swift` -- `LocationWithDistance` struct (enriches `Location` with computed distance and `inRadius` flag), distance formatting helpers

**Data flow:** SettingsView saves creds to Keychain -> ContentView reads creds, calls API via `.task` modifier -> doors cached in UserDefaults -> LocationManager provides live GPS -> distance recalculated via `.onChange(of:)` -> tap opens door if within geofence radius.

**Tests (Swift Testing framework):**
- `LocationsTests.swift` -- Pure function tests for distance calculations and `LocationWithDistance`
- `ModelsTests.swift` -- JSON decoding/encoding round-trip tests for all model structs
- `APITests.swift` -- URL encoding and `ApiError` tests
- `CacheTests.swift` -- UserDefaults caching round-trip tests
- `ConfigurationTests.swift` -- `ConfigurationValues` struct tests

## Dependencies

Single external dependency managed via Swift Package Manager:
- **KeychainSwift** (>= 24.0.0) -- secure credential storage

## Environments

- Production API: `https://api.doorcloud.com`
- Testing mock API: `https://cloud-door-mock.test.dejanlevec.com` (test credentials: `user@example.com` / `password`)

The hostname defaults to production; can be changed in Settings. A "Reset to Default Server" button appears when using a non-production host.
