//
//  SelmaVoice.swift
//  DW Speaker
//
//  Created by Andy Giefer on 18.08.23.
//

import Foundation

struct SelmaVoice: Voice {
    
    var id: String
    
    var displayName: String
    
    var selmaVoiceManager: SelmaVoiceManager
    
    func synthesizeText(_ text: String, settings: VoiceSettings) async -> URL? {
        
        // early return if there is no text
        guard text.count > 0 else {return nil}
        
        // create URL to store the audio in
        let audioURL = FileManager.temporaryAudioUrl()
        
        let success = await selmaVoiceManager.renderSpeech(voiceId: self.id, text: text, toURL: audioURL)
        
        print("\(success ? "Success" : "Error"). Audio data written to \(audioURL)")
        
        return success ? audioURL : nil
    }
    

    
}
