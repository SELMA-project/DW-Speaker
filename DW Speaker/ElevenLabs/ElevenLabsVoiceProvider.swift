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
    
    /// The manager that give access to the ElevenLabs API.
    let elevenLabsVoiceManager: ElevenLabsVoiceManager
    
    var allVoices = [ElevenLabsVoice]()
    
    init?(apiKey: String? = nil) {
        
        if let keyToUse = apiKey ?? ProcessInfo.processInfo.environment["elevenLabsAPIKey"] {
            elevenLabsVoiceManager = ElevenLabsVoiceManager(apiKey: keyToUse)
        } else {
            return nil
        }
        
        // retrieve voices
        Task {
            //allVoices = await self.retrieveVoices()
        }

    }
    
    func supportedLocales() async -> [Locale] {
        let locales = await elevenLabsVoiceManager.supportedLocales()
        return locales
    }
    
    private func retrieveVoices() async -> [ElevenLabsVoice] {
        var result = [ElevenLabsVoice]()
        
        // get voice from api or from cache
        let nativeVoices = await elevenLabsVoiceManager.nativeVoices()
        
        for nativeVoice in nativeVoices {
            let elevenLabsVoice = ElevenLabsVoice(id: nativeVoice.voiceId,
                                                  displayName: "\(nativeVoice.name) (\(nativeVoice.category)",
                                                  nativeName: nativeVoice.name,
                                                  category: nativeVoice.category,
                                                  accent: nativeVoice.labels.accent,
                                                  description: nativeVoice.labels.description,
                                                  age: nativeVoice.labels.age,
                                                  gender: nativeVoice.labels.gender,
                                                  useCase: nativeVoice.labels.useCase)
            
            result.append(elevenLabsVoice)
        }
        
        return result
    }
    
    /// Returns all available ElevenLabs voices, regardless of their locale.
    func availableVoicesForLocale(locale: Locale) async -> [Voice] {
        
        var result = [ElevenLabsVoice]()
        
        // get voice from api or from cache
        let nativeVoices = await elevenLabsVoiceManager.nativeVoices()
        
        for nativeVoice in nativeVoices {
            let elevenLabsVoice = ElevenLabsVoice(id: nativeVoice.voiceId,
                                                  displayName: "\(nativeVoice.name) (\(nativeVoice.category))",
                                                  nativeName: nativeVoice.name,
                                                  category: nativeVoice.category,
                                                  accent: nativeVoice.labels.accent,
                                                  description: nativeVoice.labels.description,
                                                  age: nativeVoice.labels.age,
                                                  gender: nativeVoice.labels.gender,
                                                  useCase: nativeVoice.labels.useCase)
            
            result.append(elevenLabsVoice)
        }
        
        // sort by category and name
        let sortedAvailableVoices = result.sorted { (lhs, rhs) in
            if lhs.category == rhs.category {
                return lhs.displayName < rhs.displayName
            }
            
            return lhs.category < rhs.category
            
        }
        
        return sortedAvailableVoices
    }
    
    func preferedVoiceForLocale(locale: Locale) async -> Voice? {
        let availableVoices = await availableVoicesForLocale(locale: Locale.current) // the locale is not important
        return availableVoices.first(where: { voice in
            
            // cast to ElevenLabsVoice
            if let elevenLabsVoice = voice as? ElevenLabsVoice {
                
                // clonsed voices are prefered
                if elevenLabsVoice.category == "cloned" {
                    return true
                }
            }
            return false
        })
    }
    
    func voice(forId voiceId: String) async -> Voice? {
        let availableVoices = await availableVoicesForLocale(locale: Locale.current) // the locale is not important
        return availableVoices.first(where: {$0.id == voiceId})!
    }
    
    
}
