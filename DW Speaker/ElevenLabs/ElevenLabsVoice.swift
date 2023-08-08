//
//  ElevenLabsVoice.swift
//  DW Speaker
//
//  Created by Andy Giefer on 08.08.23.
//

import Foundation

struct ElevenLabsVoice: Voice {
    var id: String
    
    var displayName: String
    
    func synthesizeText(_ text: String, settings: VoiceSettings) async -> URL? {
        return nil
    }
    
}
