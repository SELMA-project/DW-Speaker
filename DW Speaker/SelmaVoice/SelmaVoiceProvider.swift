//
//  SelmaVoiceProvider.swift
//  DW Speaker
//
//  Created by Andy Giefer on 18.08.23.
//

import Foundation

struct SelmaVoiceProvider: VoiceProvider {

    var id = "selmaVoiceProvider"

    var displayName = "Selma"
    
    var selmaVoiceManager: SelmaVoiceManager
    
    init() {
        selmaVoiceManager = SelmaVoiceManager()
    }

    func supportedLocales() async -> [Locale] {
        return [Locale(identifier: "pt-BR")]
    }

    func availableVoicesForLocale(locale: Locale) async -> [Voice] {
        return allVoices[locale] ?? []
    }

    func preferedVoiceForLocale(locale: Locale) async -> Voice? {
        return allVoices[locale]?.first(where: {$0.id == "leila endruweit"})
    }

    func voice(forId voiceId: String) async -> Voice? {
        
        // the keys are all supported locales
        let supportedLocales = allVoices.keys
        
        // go through each available locale
        for locale in supportedLocales {
            
            // get associated voices
            let voicesForLocale = allVoices[locale]
            
            // if any of these voices mathces the given id, reutrn this voice
            if let matchingVoice = voicesForLocale?.first(where: {$0.id == voiceId} ) {
                return matchingVoice
            }
            
        }
        
        // no match found, return nil
        return nil
    }

    private var allVoices: [Locale: [SelmaVoice]] {
        
        var voices = [Locale: [SelmaVoice]]()
        
        let voicesBR = [
            SelmaVoice(id: "alexandre schossler", displayName: "Alexandre", selmaVoiceManager: selmaVoiceManager),
            SelmaVoice(id: "bruno lupion", displayName: "Bruno", selmaVoiceManager: selmaVoiceManager),
            //SelmaVoice(id: "clarissa nehere", displayName: "Clarissa", selmaVoiceManager: selmaVoiceManager),
            SelmaVoice(id: "leila endruweit", displayName: "Leila", selmaVoiceManager: selmaVoiceManager),
            //SelmaVoice(id: "marcio damascenoe", displayName: "Marcio", selmaVoiceManager: selmaVoiceManager),
            SelmaVoice(id: "philip verminnen", displayName: "Philip", selmaVoiceManager: selmaVoiceManager),
            SelmaVoice(id: "renate krieger", displayName: "Renate", selmaVoiceManager: selmaVoiceManager),
            SelmaVoice(id: "roberto crescenti", displayName: "Roberto", selmaVoiceManager: selmaVoiceManager)
        ]
        
        let localeBR = Locale(identifier: "pt-BR")
        voices[localeBR] = voicesBR
        
        return voices
    }

}
