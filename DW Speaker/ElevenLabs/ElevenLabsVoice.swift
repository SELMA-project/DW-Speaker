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
    
    let voiceManager: ElevenLabsVoiceManager
    
    func synthesizeText(_ text: String, settings: VoiceSettings) async -> URL? {
    
        // early return if there is no text
        guard text.count > 0 else {return nil}
        
        // create URL to store the audio in
        let audioURL = FileManager.temporaryAudioUrl()
        
        let success = await voiceManager.renderSpeech(voiceId: self.id, text: text, toURL: audioURL, stability: settings.elevenLabs.stability, similarityBoost: settings.elevenLabs.similarityBoost)
        
        print("\(success ? "Success" : "Error"). Audio data written to \(audioURL)")
        
        return success ? audioURL : nil
    }
    
}
