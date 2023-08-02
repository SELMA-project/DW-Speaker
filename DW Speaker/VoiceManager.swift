//
//  VoiceManager.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation

class VoiceManager {
    
    /// Voice Manager Singleton.
    static let shared = VoiceManager()
    
    func availableProviders() -> [VoiceProvider] {
        let appleVoiceProvider = AppleVoiceProvider()
        return [appleVoiceProvider]
    }
    
    func availableLocales() async -> [Locale] {
        
        // store locales in set to assure uniqueness
        var uniqueLocales: Set<Locale> = Set()
        
        for provider in availableProviders() {
            let providerLocales = await provider.supportedLocales()
            uniqueLocales.formUnion(providerLocales)
        }
        
        // sort by identifer while converting to an array
        let sortedLocales = uniqueLocales.sorted {$0.identifier < $1.identifier}
        
        return sortedLocales
    }
    
    init() {
        debug()
    }
    
    func debug() {
        let providers = availableProviders()
        
        Task {
            
            
            let locales = await availableLocales()
            
            for locale in locales {
                print(locale.identifier)
            }
        }
        
    }
    
}
