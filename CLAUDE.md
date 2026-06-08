# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Peaky Finders is a single-target SwiftUI/CoreLocation iOS app (iOS 26+, portrait, iPhone-only). It reads the device's compass heading and location, computes the great-circle bearing to a set of mountain peaks, and shows an arrow that points toward each peak (straight up = you're facing it) plus the distance to it.

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

- **`ContentView.swift`** — Root view. Owns the `LocationProvider`, calls `.start()` on appear, and gates the UI through a switch on authorization status then on location/heading availability. Only renders the finder once both location and heading exist.

- **`DebugDisplay.swift`** — A debug/scaffolding view, not the real UI (the "main" UI hasn't been built yet). `BundleDebugDisplay` calls `Peak.loadBundled()` and `ForEach`es over every peak, rendering an arrow + name + distance for each — currently what `ContentView` renders.

- **`Peak.swift`** — The `Peak` model (`Codable`/`Identifiable`, `id` = `name`) plus three concerns kept here as the single source of truth:
  - Static peak constants (`.mountMitchell`, `.waterRock`, `.duckerMountain`) used by previews. Do not re-inline peak coordinates elsewhere — a prior cleanup consolidated duplicates from three files into these.
  - Angle conversion helpers (`.radians` / `.degrees` on `BinaryFloatingPoint`).
  - `CLLocationCoordinate2D.bearing(to:)` — the great-circle bearing math (0..<360, clockwise from true north).

- **`Bundle.swift`** — `Peak.loadBundled(named:)` decodes the runtime peak dataset from `peaks.json`. It **`fatalError`s** on a missing or malformed resource by design (the dataset ships in the bundle, so failure is a build/packaging bug, not a runtime condition to handle gracefully).

- **`GeoDisplay.swift`** — The small presentational views: `HeadingDisplay`, `BearingDisplay` (the rotating arrow; `relativeBearing = bearingToTarget − currentHeading`), `DistanceDisplay` (km).

- **`peaks.json`** — The runtime list of peaks (Western NC summits). This, not the static constants in `Peak.swift`, is what the live app displays. Add/edit peaks here.

## Conventions

- Document the non-obvious — every type and the tricky computed properties (relative bearing, the heading `nil` sentinel, the bearing formula) carry explanatory comments. Match that density.
- Keep peak coordinates in one place (`peaks.json` for runtime, `Peak` static constants for previews); don't reintroduce inline literals.

## Commit messages — Conventional Commits

All commits MUST follow the Conventional Commits 1.0.0 spec. Format:

    <type>(<optional scope>): <description>

    [optional body]

    [optional footer(s)]

### Rules
- **Type** is required and lowercase. Allowed types ONLY:
  - `feat` — a new user-facing capability (maps to semver MINOR)
  - `fix` — a bug fix in existing behavior (maps to semver PATCH)
  - `refactor` — code change that neither fixes a bug nor adds a feature
  - `perf` — a change that improves performance
  - `docs` — documentation only
  - `test` — adding or correcting tests
  - `build` — build system, dependencies, project/target config
  - `chore` — tooling, gitignore, housekeeping with no src/ impact
  - `style` — formatting/whitespace only, no logic change
- **Scope** is optional but preferred; use the area of the codebase
  (e.g. `location`, `ar`, `sighting`, `catalog`, `map`).
- **Description**: imperative mood ("add", not "added"/"adds"),
  no trailing period, ≤ 72 chars on the subject line.
- **Breaking changes**: append `!` after type/scope AND add a
  `BREAKING CHANGE:` footer explaining the break (maps to semver MAJOR).

### Honesty rules (these override convenience)
- The type MUST reflect what the diff actually does. If a change adds a
  feature but also refactors, that's two commits, not one `feat`.
- Do NOT combine unrelated changes under one type. Prefer multiple small
  commits over one mixed-bag commit.
- `feat`/`fix` are for changes to shipping behavior only. Renames,
  extractions, and reorganizations are `refactor`, not `feat`.
- If unsure whether something is `feat` or `fix`, look at whether it adds
  new behavior (`feat`) or corrects existing behavior (`fix`).
- The body explains *why*, not *what* — the diff already shows the what.
- Never invent a scope or claim a change the diff doesn't contain.

### Examples
    feat(ar): project peak labels onto the camera feed
    fix(location): use true heading instead of magnetic for bearings
    refactor(sighting): freeze bearing and distance at construction
    docs(readme): document the rung-based project structure
    feat(catalog)!: load peaks from remote API

    BREAKING CHANGE: peaks.json is no longer bundled; network required.
