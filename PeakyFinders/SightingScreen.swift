//
//  SightingScreen.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/12/26.
//

import ARKit
import Combine
import RealityKit
import SwiftUI
import simd

// MARK: - Model

@MainActor @Observable
final class SightingModel {
    var sightings: [Sighting] = []  // set once we have a location fix
    var aimed: Sighting?  // peak currently down the barrel
    var resetToken = 0
}

// MARK: - ARView bridge
// UIViewRepresentable is the SwiftUI wrapper for UIKit views.
// ARView is a UIKit view (UIView subclass), so this is how we host it in SwiftUI.

struct SightingARView: UIViewRepresentable {
    let model: SightingModel

    func makeCoordinator() -> Coordinator { Coordinator() }

    // Coordinator is the standard UIViewRepresentable pattern for mutable
    // per-instance state that needs to outlive the struct (which is value-typed
    // and recreated on every re-render). We use it to retain the Cancellable —
    // if it deinits, the subscription fires no more frames.
    final class Coordinator {
        var frameSub: (any Cancellable)?
        var lastToken: Int = 0
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false  // we provide the config ourselves
        )

        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading  // +x East, +y Up, −z North
        config.planeDetection = []
        arView.session.run(config)

        // SceneEvents.Update fires once per frame on the main thread.
        // We compute aimed peak here so every rendered frame reflects the latest pose.
        context.coordinator.frameSub = arView.scene.subscribe(
            to: SceneEvents.Update.self
        ) { [weak arView] _ in
            guard let arView else { return }
            // The closure isn't marked @MainActor, but RealityKit delivers
            // SceneEvents.Update on main. assumeIsolated is a runtime assertion
            // of that fact — it lets us touch @MainActor state without an await.
            MainActor.assumeIsolated {
                let pose = arView.cameraTransform.matrix
                model.aimed = aimedPeak(camera: pose, among: model.sightings)
            }
        }
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        guard context.coordinator.lastToken != model.resetToken else { return }
        context.coordinator.lastToken = model.resetToken
        guard let config = uiView.session.configuration else { return }
        uiView.session.run(config, options: [.resetTracking])
    }
}

// MARK: - Screen

struct SightingScreen: View {
    let locationProvider: LocationProvider
    @State private var model = SightingModel()
    let sightingRange: CLLocationDistance
    
    var body: some View {
        ZStack {
            SightingARView(model: model).ignoresSafeArea()

            // Crosshair reticle
            Circle()
                .stroke(.white.opacity(0.7), lineWidth: 2)
                .frame(width: 64, height: 64)

            // Aimed-peak readout, pinned just below the reticle.
            if let s = model.aimed {
                VStack(spacing: 4) {
                    Text(s.peak.name).font(.headline)
                    Text("\(Int(s.distance / 1000)) km").font(.subheadline)
                    // No arrow without a true-north heading; bearing would be meaningless.
                    if let heading = locationProvider.heading {
                        BearingDisplay(
                            bearingToTarget: s.bearing,
                            currentHeading: heading
                        )
                    }
                }
                .padding(10)
                .background(.black.opacity(0.6), in: .rect(cornerRadius: 10))
                .foregroundStyle(.white)
                .offset(y: 56)  // just below the reticle
            }

            // Recenter control, anchored above the tab bar like a search button.
            VStack {
                Spacer()
                Button("Recenter") {
                    model.resetToken += 1
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
        }
        .onAppear {
            // Seed immediately if the Map tab already produced a fix.
            if let loc = locationProvider.currentLocation {
                model.sightings = PeakCatalog.all.sightings(
                    from: loc,
                    within: sightingRange
                )
            }
        }
        .onChange(of: locationProvider.currentLocation) { _, newLocation in
            if let loc = newLocation {
                model.sightings = PeakCatalog.all.sightings(
                    from: loc,
                    within: sightingRange
                )
            }
        }
    }
}

// MARK: - Sighting engine

/// Returns the sighting whose direction most closely matches the camera's forward
/// ray, or `nil` if nothing falls within the aiming cone.
///
/// - Parameters:
///   - camera: 4×4 camera pose in ARKit world space
///             (worldAlignment: .gravityAndHeading — +x East, +y Up, −z North).
///   - sightings: Candidate sightings with bearings in degrees clockwise from true north.
func aimedPeak(camera: simd_float4x4, among sightings: [Sighting]) -> Sighting? {
    let cameraDir = -camera.columns.2
    // `.max(by:)` wants "is s1 ordered before s2?" — i.e. less-aligned first —
    // so the element it returns is the one with the greatest alignment.
    let closestSighting = sightings.max { s1, s2 in
        dot(s1.direction, cameraDir) < dot(s2.direction, cameraDir)
    }

    guard let best = closestSighting,
        dot(best.direction, cameraDir) > 0.8
    else { return nil }
    return best
}
