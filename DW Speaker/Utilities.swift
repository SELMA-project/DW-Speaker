//
//  Utilities.swift
//  DW Speaker
//
//  Created by Andy Giefer on 10.08.23.
//

import Foundation

extension FileManager {
    static func temporaryAudioUrl() -> URL {
        return FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")
    }
}
