//
//  VoiceController.swift
//  DW Speaker
//
//  Created by Andy Giefer on 07.08.23.
//

import Foundation


class VoiceController {
    
    private var availableProviders: [VoiceProvider] = []
    
    init() {
        // which providers to we have?
        self.availableProviders = getAvailableProviders()
    }
    
    /// All available voice providers.
    private func getAvailableProviders() -> [VoiceProvider] {
        
        var providers: [VoiceProvider] = []
        
        // add apple
        providers.append(AppleVoiceProvider())

        // add elevenLabs
        if let elevenLabsProvider = ElevenLabsVoiceProvider() {
            providers.append(elevenLabsProvider)
        }
        
        return providers
    }
    
    /// All available locales.
    func availableLocales() async -> [Locale] {
        
        // store locales in set to assure uniqueness
        var uniqueLocales: Set<Locale> = Set()
        
        for provider in availableProviders {
            let providerLocales = await provider.supportedLocales()
            uniqueLocales.formUnion(providerLocales)
        }
        
        // sort by identifer while converting to an array
        let sortedLocales = uniqueLocales.sorted {$0.displayName < $1.displayName}
        
        return sortedLocales
    }
    
    /// An array of voice providers that support the given locale.
    func providers(forLocale locale: Locale) async  -> [VoiceProvider] {

        // all available providers
        let availableProviders = availableProviders
  
        // prepare result
        var filteredProviders = [VoiceProvider]()
        
        // go through each provider
        for provider in availableProviders {
            
            // which locales does it support?
            let supportedLocales = await provider.supportedLocales()
            
            // is the locale we are looking for amongst the supported locales?
            if supportedLocales.contains(locale) {
                
                // if so, add provider to result and check the next provider
                filteredProviders.append(provider)
            }
        }
        
        return filteredProviders
    }
    
    /// Returns the voice provider for the given ID.
    func provider(forId providerId: String) -> VoiceProvider? {
        return availableProviders.filter({ $0.id == providerId}).first
    }
    
    func synthesizeText(_ text: String, usingVoice voice: Voice, settings: VoiceSettings) async -> URL? {
        return await voice.synthesizeText(text, settings: settings)
    }
    
 
    
}
