# Code Review — Peaky Finders

A SwiftUI/CoreLocation iOS app that points the user toward a target mountain
peak using compass heading and a computed bearing. This review covers the state
after documentation + constant consolidation.

## Overview of the code

| File | Responsibility |
| --- | --- |
| `Peaky_FindersApp.swift` | App entry point; hosts `ContentView`. |
| `ContentView.swift` | Root view; drives location/heading acquisition and gates UI on authorization + data availability. |
| `LocationProvider.swift` | `@Observable` `CLLocationManager` wrapper publishing auth status, location, and heading. |
| `Peak.swift` | `Peak` model, the known-peaks catalog, angle/bearing math, and `PeakDisplay`/`DistanceDisplay` views. |
| `HeadingDisplay.swift` | Rotating arrow that points from current heading toward the target bearing. |
| `DebugDisplay.swift` | Composite readout (arrow + coordinates + distance) used as the main screen. |

**Build status:** `xcodebuild ... build` → **BUILD SUCCEEDED**.

## Changes made in this pass

- **Documentation** added to every type, the public methods, and the non-obvious
  computed properties (relative bearing, heading sentinel, bearing math).
- **Consolidated redundant constants.** Peak coordinates were previously defined
  in up to three places:
  - `mountMitchell` / `waterRock` / `duckerMountain` in `ContentView.swift`
    (`mountMitchell` and `waterRock` were never used — dead code).
  - `mountMitchellCoordinates` / `waterRockCoordinates` in `Peak.swift`.
  - Ducker Mountain inlined again in `DebugDisplay.swift` (with a trailing-space
    typo in its name: `"Ducker Mountain "`).

  These are now a single source of truth: `Peak.mountMitchell`,
  `Peak.waterRock`, `Peak.duckerMountain` static constants in `Peak.swift`.
  All views and previews reference the catalog.

- **Removed dead bearing code.** `Peak.bearing(from:)` (a flat-earth
  approximation) was unused — the app computes bearings via the great-circle
  `CLLocationCoordinate2D.bearing(to:)`. The method and the commented-out call
  in `DebugDisplay` were deleted.

## Findings & recommendations

### 1. Heading is true vs. magnetic north — confirm the intent (medium)
`LocationProvider` reads `newHeading.trueHeading`, while bearings are computed
geographically (also true north), so the two are consistent — good. Just note
that `trueHeading` is only valid when location updates are active (they are
here). No change needed.

### 2. No error/timeout UX for "Acquiring…" states (low)
`ContentView` shows "Acquiring location…/heading…" indefinitely. On a device
that never gets a heading (e.g. simulator, magnetometer issue) the user is
stuck. Consider a timeout/hint after a few seconds. Also note "Acquiring" is
currently spelled "Aquiring" in two strings.

### 3. `Info.plist` usage-description string (verify)
`requestWhenInUseAuthorization()` requires
`NSLocationWhenInUseUsageDescription` in the Info.plist or the prompt is
suppressed at runtime. Worth confirming it's present and user-facing.

### 4. Minor naming / hygiene (low)
- `DebugDisplay` is the *main* screen, not a debug-only view — the name
  undersells it. Consider renaming to e.g. `PeakFinderView` if it's the real UI.
- `officeLocationDebug` is preview-only; fine as-is but lives at file scope
  (global). Acceptable for a small app.
- Force-unwrap-free and concurrency-clean; `@Observable` + delegate pattern is
  idiomatic.

## Summary

The code is small, idiomatic SwiftUI, and now free of duplicated coordinate
constants, dead bearing code, and undocumented intent. Remaining items are all
polish (typos, naming, an empty-state timeout) plus an Info.plist sanity check.
