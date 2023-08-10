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
    
    var nativeName: String
    var category: String // premade
    
    var accent: String?
    var description: String?
    var age: String?
    var gender: String?
    var useCase: String?
    
    
    
    func synthesizeText(_ text: String, settings: VoiceSettings) async -> URL? {
        return nil
    }
    
}
