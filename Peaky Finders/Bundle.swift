//
//  Bundle.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/6/26.
//

import Foundation

extension Peak {
    /// Loads the bundled peak dataset. Traps on failure, by design — see note.
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
