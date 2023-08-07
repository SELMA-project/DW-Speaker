//
//  AppleVoiceProvider.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation
import AVFoundation

struct AppleVoiceProvider: VoiceProvider, Identifiable {
    
    var id = "appleVoiceProvider"

    var displayName = "Apple"

    func supportedLocales() async -> [Locale] {
        
        // store locales in set to assure uniqueness
        var uniqueLocales: Set<Locale> = Set()
        
        // get all available avoices
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // add each voice's lanuageIdentifier to the set
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
        
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        let speechVoicesForLocale = allVoices.filter {
            
            var keepVoice = true
            
            // filter by language
            if $0.language != locale.identifier {keepVoice = false}
            
            // exclude eloquence
            if $0.identifier.contains("eloquence") {keepVoice = false}
            
            // exclude novelty voices
            if $0.identifier.contains("speech.synthesis") {keepVoice = false}
            
            return keepVoice
        }
        
        for speechVoice in speechVoicesForLocale {
            
            // get properties
            let identifier = speechVoice.identifier
            let name = speechVoice.name
            let quality = speechVoice.quality

            let displayName = "\(name) (\(quality)"
            
            // create apple voice and add it to result
            let appleVoice = AppleVoice(id: identifier, displayName: displayName)
            availableVoices.append(appleVoice)
        }
        
        // sort by name
        let sortedAvailableVoice = availableVoices.sorted {$0.displayName < $1.displayName}
        
        return sortedAvailableVoice
    }
    
    /// Return the voice with the highest quality as prefered voice
    func preferedVoiceForLocale(locale: Locale) async -> Voice? {
        
        var preferedVoice: Voice?
        
        let allVoicesForLocale = await availableVoicesForLocale(locale: locale)
        
        if let premiumVoice = allVoicesForLocale.filter({$0.id.contains("premium")}).first {
            preferedVoice = premiumVoice
            
        } else if let enhancedVoice = allVoicesForLocale.filter({$0.id.contains("enhanced")}).first {
            preferedVoice = enhancedVoice
            
        } else {
            preferedVoice = allVoicesForLocale.first
        }
        
        return preferedVoice
        
    }
    
    
    func voice(forId voiceId: String) -> Voice {
        let nativeVoice = AVSpeechSynthesisVoice(identifier: voiceId)!
        
        // convert to AppleVoice
        let identifier = nativeVoice.identifier
        let displayName = nativeVoice.name
        
        let appleVoice = AppleVoice(id: identifier, displayName: displayName)
        return appleVoice
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
