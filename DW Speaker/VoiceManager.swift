//
//  VoiceManager.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation

@MainActor
class VoiceManager: ObservableObject {
    
    @Published var selectableLocales: [Locale] = []
    @Published var selectableProviders: [VoiceProvider] = []
    @Published var selectableVoices: [Voice] = []
    
    /// The identifier of the selected language.
    @Published var selectedLocaleId: String = "" {
        didSet {
            
            // after the Locale changes, adjust the list of selectable provider and and choose the first on the list
            let selectedLocale = Locale(identifier: selectedLocaleId)
            Task {
                
                let providers = await providers(forLocale: selectedLocale)
                DispatchQueue.main.async {
                    
                    // set list of providers
                    self.selectableProviders = providers
                    
                    // select first provider on the list
                    if let firstProvider = providers.first {
                        self.selectedProviderId = firstProvider.id
                    }
                }
                

            }
        }
    }
    
    /// The identifer of the selected provider.
    @Published var selectedProviderId: String = "" {
        didSet {
            
            // after the provider changes, adjust the list of selectable voice and choose the prefered one
            if let provider = availableProviders.filter({ $0.id == selectedProviderId}).first {
                Task {
                    
                    let selectedLocale = Locale(identifier: selectedLocaleId)
                    let voices = await provider.availableVoicesForLocale(locale: selectedLocale)
                    let preferedVoice = await provider.preferedVoiceForLocale(locale: selectedLocale)
                    
                    DispatchQueue.main.async {
                        self.selectableVoices = voices
                        
                        if let preferedVoice {
                            self.selectedVoiceId = preferedVoice.id
                        }
                    }
                }
            }
        }
    }
    
    /// The identifier of the selected voice.
    @Published var selectedVoiceId: String = ""
    
    private var availableProviders: [VoiceProvider] = []
    
    init() {
        
        let selectedLocale = Locale(identifier: "en-US")
        let selectedProvider = AppleVoiceProvider()
        
        // which providers to we have?
        self.availableProviders = getAvailableProviders()
        
        // set available locales and providers
        Task {
            let locales = await availableLocales()
            let providers = await providers(forLocale: selectedLocale)
            
            DispatchQueue.main.async {
                self.selectableLocales = locales
                self.selectableProviders = providers
                
                self.selectedLocaleId = selectedLocale.identifier
                self.selectedProviderId = selectedProvider.id
                
            }
        }
    }
    
    /// All available voice providers.
    private func getAvailableProviders() -> [VoiceProvider] {
        let appleVoiceProvider = AppleVoiceProvider()
        
        return [appleVoiceProvider]
    }
    
    /// All available locales.
    private func availableLocales() async -> [Locale] {
        
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
    private func providers(forLocale locale: Locale) async  -> [VoiceProvider] {

        // all available providers
        let availableProviders = availableProviders
  
        // prepare result
        var filteredProviders = [VoiceProvider]()
        
        // go through each provider
        for provider in availableProviders {
            
            // which locales does it support?
            let supportedLocales = await provider.supportedLocales()
            
            // if the locale we are looking for amongst the supported locales?
            if supportedLocales.contains(locale) {
                
                // if so, add provider to result and check the next provider
                filteredProviders.append(provider)
                break
            }
        }
        
        return filteredProviders
    }
    

    
}

