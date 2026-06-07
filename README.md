# Peaky Finders

An iPhone app for hikers in the Western North Carolina mountains. It reads your GPS location and compass heading, then shows a map of nearby summits with a bearing arrow and distance for each one. Tap any peak to get a live compass arrow and a satellite map framing you and the summit.

## What it does

- Plots all peaks from `peaks.json` within a user-adjustable radius (0–100 km) on a satellite map
- Tap a peak marker → detail sheet with a rotating arrow that points straight up when you're facing the summit, plus the distance in km
- The range slider re-filters the map in real time

## Requirements

- Xcode 26+
- iOS 26+ device or simulator (portrait, iPhone-only)
- Real device strongly recommended — the magnetometer/heading sensor rarely resolves on a simulator, leaving the UI on "Acquiring heading…"

## Building

The project name contains a space — always quote paths in shell commands.

```sh
# Build for simulator
xcodebuild -project "Peaky Finders.xcodeproj" \
           -scheme "Peaky Finders" \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build

# List available schemes/targets
xcodebuild -list -project "Peaky Finders.xcodeproj"
```

There are no external dependencies (no SPM packages, no CocoaPods). Everything is first-party SwiftUI + CoreLocation + MapKit.

## Info.plist note

`Peaky-Finders-Info.plist` is an **empty dict by design**. The project uses `GENERATE_INFOPLIST_FILE = YES`, so the real Info.plist is synthesized at build time from `INFOPLIST_KEY_*` build settings in `project.pbxproj`. Location usage strings (`NSLocationWhenInUseUsageDescription`) live there — edit build settings, not the plist file.

## Architecture

Data flows one way: CoreLocation → `LocationProvider` → views.

```
LocationProvider (CLLocationManager delegate)
    │
    ▼
ContentView (authorization + sensor gate)
    │
    ▼
SightingsMapView (map + range slider)
    │   tap marker
    ▼
SightingView (bearing arrow + detail map)
```

| File | Role |
|---|---|
| `LocationProvider.swift` | `@Observable` wrapper for `CLLocationManager`. Publishes `authorizationStatus`, `currentLocation`, and `heading` (true-north degrees, `nil` when invalid). |
| `ContentView.swift` | Root view. Guards on authorization then on sensor availability, then renders `SightingsMapView`. |
| `Peak.swift` | `Peak` model (`Codable`/`Identifiable`). Bearing and distance helpers. Great-circle bearing math (`CLLocationCoordinate2D.bearing(to:)`). Preview/debug constants. |
| `Sighting.swift` | Immutable snapshot of a peak's bearing and distance from a specific location. `SightingView` is the tap-to-open detail sheet. |
| `PeakCatalog.swift` | Loads and decodes `peaks.json` once at startup via `PeakCatalog.all`. Traps on failure — a missing or malformed bundle file is a build bug, not a runtime condition. |
| `GeoViews.swift` | Reusable UI: `HeadingDisplay` (numeric heading text), `BearingDisplay` (rotating compass arrow), `DistanceDisplay` (km label). |
| `SightingsMapView.swift` | Map with peak markers and a range slider. Presents `SightingView` as a sheet on marker tap. |
| `DebugViews.swift` | Scrollable list of all sightings with arrows and distances. Not shown in production; used by previews and for layout testing. |
| `peaks.json` | Runtime peak dataset — Western NC summits. Add or edit peaks here; the app reads this at launch. |

## Adding peaks

Edit `peaks.json`. Each entry needs a unique `name`, a `latitude`, and a `longitude`:

```json
{ "name": "Max Patch", "latitude": 35.79389, "longitude": -82.95833 }
```

The name is the stable identifier — duplicates will cause the second entry to shadow the first in SwiftUI lists.

## Current peak list

| Peak | Elevation (approx.) |
|---|---|
| Mount Mitchell | 6,684 ft — highest peak in eastern North America |
| Celo Knob | 6,327 ft |
| Waterrock Knob | 6,292 ft |
| Cold Mountain | 6,030 ft |
| Mount Pisgah | 5,721 ft |
| Richland Balsam | 6,410 ft |
| Black Balsam Knob | 6,214 ft |
| Shining Rock | 6,040 ft |
| Devil's Courthouse | 5,720 ft |
| Tanasee Bald | 5,840 ft |
