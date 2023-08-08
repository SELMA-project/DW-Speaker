//
//  ElevenLabsVoiceProvider.swift
//  DW Speaker
//
//  Created by Andy Giefer on 08.08.23.
//

import Foundation

struct ElevenLabsVoiceProvider: VoiceProvider, Identifiable {
    
    var id = "elevenLabs"
    var displayName = "ElevenLabs"
    
    let elevenLabsVoiceManager: ElevenLabsVoiceManager
    
    init?(apiKey: String? = nil) {
        
        if let keyToUse = apiKey ?? ProcessInfo.processInfo.environment["elevenLabsAPIKey"] {
            elevenLabsVoiceManager = ElevenLabsVoiceManager(apiKey: keyToUse)
        } else {
            return nil
        }

    }
    
    func supportedLocales() async -> [Locale] {
        let locales = await elevenLabsVoiceManager.supportedLocales()
        return locales
    }
    
    func availableVoicesForLocale(locale: Locale) async -> [Voice] {
        return [ElevenLabsVoice(id: "temp", displayName: "temp")]
    }
    
    func preferedVoiceForLocale(locale: Locale) async -> Voice? {
        return nil
    }
    
    func voice(forId voiceId: String) -> Voice {
        return ElevenLabsVoice(id: "temp", displayName: "temp")
    }
    
    
}
