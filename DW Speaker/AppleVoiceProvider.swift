//
//  AppleVoiceProvider.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation
import AVFoundation

struct AppleVoiceProvider: VoiceProvider {
    
    var id = "appleVoiceProvider"

    var displayName = "Apple"

    func supportedLocales() async -> [Locale] {
        
        // store locales in set to assure uniqueness
        var uniqueLocales: Set<Locale> = Set()
        
        // get all availae avoices
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // add each voice's lanugaeIdentifier to the set
        for voice in allVoices {
            let languageIdentifier = voice.language // BP47
            let locale = Locale(identifier: languageIdentifier)
            uniqueLocales.insert(locale)
        }
        
        // sort by identifer while converting to an array
        let sortedLocales = uniqueLocales.sorted {$0.identifier < $1.identifier}
        
        return sortedLocales
    }

    func availableVoicesForLocale(locale: Locale) async -> [Voice] {
        
        var availableVoices: [Voice] = []
        
        let speechVoicesForLocale = AVSpeechSynthesisVoice.speechVoices().filter {$0.language == locale.identifier}
        
        for speechVoice in speechVoicesForLocale {
            
            // get properties
            let identifier = speechVoice.identifier
            let displayName = speechVoice.name

            
            // create apple voice and add it to result
            let appleVoice = AppleVoice(id: identifier, displayName: displayName)
            availableVoices.append(appleVoice)
        }
        
        return availableVoices
    }


}

struct AppleVoice: Voice {
    
    var id: String
    
    var displayName: String
    
    func synthesizeText(_ text: String) async -> Data? {
        print("Speaking: \(text)")
        return nil
    }
    
    
}
