//
//  PeakCatalog.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/6/26.
//

import Foundation

extension Peak {
    /// Loads and decodes the bundled JSON peak dataset. Traps on a missing or
    /// malformed file — the JSON ships in the bundle, so failure is a build or
    /// packaging bug, not a runtime condition worth recovering from gracefully.
    static func loadBundled(named filename: String = "peaks") -> [Peak] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Missing bundled resource: \(filename).json")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Peak].self, from: data)
        } catch {
            fatalError("Failed to decode \(filename).json: \(error)")
        }
    }
}

/// App-wide access point for the bundled peak list. Loaded once at startup.
enum PeakCatalog {
    static let all: [Peak] = Peak.loadBundled()
}

