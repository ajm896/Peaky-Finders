# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Peaky Finders is a SwiftUI/CoreLocation/MapKit iOS app (iOS 26+, portrait, iPhone-only). It reads the device's GPS location and compass heading, then plots nearby Western NC mountain peaks on a map. Tapping a peak shows a rotating bearing arrow (straight up = you're facing it) and the distance to it.

## Build & run

The project name and `.xcodeproj` contain a space — always quote paths.

```sh
# Build for simulator
xcodebuild -project "Peaky Finders.xcodeproj" -scheme "Peaky Finders" \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# List schemes/targets
xcodebuild -list -project "Peaky Finders.xcodeproj"
```

There is **no test target** and no SPM/CocoaPods dependencies — everything is first-party SwiftUI + CoreLocation. Day-to-day, build and run from Xcode; location/heading need a real device or a simulator with a simulated location (the magnetometer/heading often won't resolve in the simulator, leaving the UI stuck on "Aquiring heading...").

## Info.plist gotcha

`Peaky-Finders-Info.plist` is an **empty dict by design**. The project sets `GENERATE_INFOPLIST_FILE = YES`, so the real Info.plist is synthesized at build time from `INFOPLIST_KEY_*` build settings in `project.pbxproj`. The location/camera usage strings (`NSLocationWhenInUseUsageDescription`, etc.) live there — edit the build settings, not the plist file, or the authorization prompt will be silently suppressed.

## Architecture

Data flows in one direction: CoreLocation → `LocationProvider` → views.

- **`LocationProvider.swift`** — `@Observable` `final class` wrapping `CLLocationManager` as its delegate. The single source of live device state: `authorizationStatus`, `currentLocation`, `heading`. `heading` is `trueHeading` (geographic north), normalized to `nil` when the device reports a negative value (no valid true north). Bearings are also computed geographically, so heading and bearing share the same reference frame.

- **`ContentView.swift`** — Root view. Owns the `LocationProvider`, calls `.start()` on appear, and gates the UI through a switch on authorization status then on location/heading availability. Holds the `sightingRange` state (meters) that drives the map's range slider. Only renders `SightingsMapView` once both location and heading exist.

- **`Peak.swift`** — The `Peak` model (`Codable`/`Identifiable`, `id` = `name`) plus several concerns kept here as the single source of truth:
  - Preview/debug constants (`.mountMitchellDebug`, `.waterrockDebug`, `.duckerMountainDebug`). Don't re-inline peak coordinates in individual previews.
  - Angle conversion helpers (`.radians` / `.degrees` on `BinaryFloatingPoint`).
  - `CLLocationCoordinate2D.bearing(to:)` — the great-circle bearing math (0..<360, clockwise from true north).
  - `Collection<Peak>.sightings(from:within:)` — filters and sorts a peak collection into `[Sighting]` by bearing.

- **`Sighting.swift`** — `Sighting` is an immutable snapshot of a peak's bearing and distance from a specific user location. `SightingView` is the detail sheet (bearing arrow + distance + satellite map) presented when the user taps a peak marker.

- **`PeakCatalog.swift`** — `Peak.loadBundled(named:)` decodes the runtime peak dataset from `peaks.json`. `PeakCatalog.all` is the app-wide access point. Both `fatalError` on a missing or malformed resource by design (the dataset ships in the bundle, so failure is a build/packaging bug, not a runtime condition to handle gracefully).

- **`GeoViews.swift`** — Small presentational views: `HeadingDisplay` (numeric heading text), `BearingDisplay` (the rotating arrow; `relativeBearing = (bearingToTarget − currentHeading + 360) % 360`), `DistanceDisplay` (km).

- **`SightingsMapView.swift`** — The main screen. Shows all in-range peaks as markers on a satellite map. Tapping a marker opens a `SightingView` sheet. A slider at the bottom controls `sightingRange` (0–100 km, bound to `ContentView`'s state).

- **`DebugViews.swift`** — Scrollable list of bearing arrows and distances for every sighting. Used by previews and for layout testing; not shown in production. Also defines the module-level `homeOfficeDebug`/`officeLocationDebug` `CLLocation` constants shared by previews in other files.

- **`peaks.json`** — The runtime list of peaks (Western NC summits). This, not the static constants in `Peak.swift`, is what the live app displays. Add/edit peaks here.

## Conventions

- Document the non-obvious — every type and the tricky computed properties (relative bearing, the heading `nil` sentinel, the bearing formula) carry explanatory comments. Match that density.
- Keep peak coordinates in one place (`peaks.json` for runtime, `Peak` static constants for previews); don't reintroduce inline literals.
