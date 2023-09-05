//
//  VoiceViewModel.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation
import DWSpeakerKit

@MainActor
class VoiceViewModel: ObservableObject {
    
    var voiceController: VoiceController
    var audioPlayerController: AudioPlayerController
    
    @Published var selectableLocales: [Locale] = []
    @Published var selectableProviders: [VoiceProvider] = []
    @Published var selectableVoices: [Voice] = []
    
    /// The identifier of the selected language.
    @Published var selectedLocaleId: String = "" {
        willSet {
            
            print("Updating selectedLocaleId to: \(newValue)")
            
            // store in user defaults
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.selectedLocaleIdName)
            
            Task {
                
                // find the right providers for the locale and publish them
                let selectedLocale = Locale(identifier: selectedLocaleId)
                let providers = await voiceController.providers(forLocale: selectedLocale) // all available providers
                
                self.selectableProviders = providers
                
                // if the currently selected providerId is not support by the locale, set a new one
                if providers.first(where: {$0.id == selectedProviderId}) == nil {
                    if let firstProviderId = providers.first?.id {
                        self.selectedProviderId = firstProviderId
                    }
                } else { // otherwise, re-set the existing providerID -> this will trigger the willSet code to adjust the voices
                    self.selectedProviderId = self.selectedProviderId
                }
                
            }
            
            // manual publication
            objectWillChange.send()
            
        }
        
    }
    
    
    /// The identifer of the selected provider.
    @Published var selectedProviderId: String = "" {
        willSet {
            
            print("Updating selectedProviderId to: \(newValue)")
            
            // store in user defaults
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.selectedProviderIdName)
            
            objectWillChange.send()
            
            Task {
                
                
                let selectedLocale = Locale(identifier: selectedLocaleId)
                if let selectedProvider {
                    
                    let voices = await selectedProvider.availableVoicesForLocale(locale: selectedLocale)
                    
                    // publish voices
                    self.selectableVoices = voices
                    
                    
                    // if currenty selected voice does not match any of the selectable voices...
                    if voices.first(where: { $0.id == selectedVoiceId}) == nil {
                        
                        // find the provier'S refered voice
                        if let preferedVoiceId = await selectedProvider.preferedVoiceForLocale(locale: selectedLocale)?.id {
                            
                            // publish new voiceId
                            self.selectedVoiceId = preferedVoiceId
                        }
                    }
                }
            }
        }
    }
    
    /// The identifier of the selected voice.
    @Published var selectedVoiceId: String = "" {
        willSet {
            
            print("Updating selectedVoiceId to: \(newValue)")
            
            // store in user defaults
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.selectedVoiceIdName)
            
            objectWillChange.send()
        }
        
    }
    
    
    /// Stores the individual settings for all voices.
    @Published var voiceSettings = VoiceSettings()
    
    /// The selected Voice Provider.
    var selectedProvider: VoiceProvider? {
        return voiceController.provider(forId: selectedProviderId)
    }
    
    enum PlayerStatus {
        case idle, rendering, playing
    }
    
    @Published var playerStatus: PlayerStatus = .idle
    
    
    init() {
        
        /// Access to voice functionalitites
        self.voiceController = VoiceController(userDefaultsElevenLabsAPIKeyName: Constants.userDefaultsElevenLabsAPIKeyName)
        
        /// Access to audio player functionalitites
        self.audioPlayerController = AudioPlayerController()
        
        restoreDefaults()
    }
    
}

// MARK: Working with defaults
extension VoiceViewModel {
    
    struct UserDefaultKeys {
        static let selectedLocaleIdName = "voiceViewModelSelectedLocaleId"
        static let selectedProviderIdName = "voiceViewModelSelectedProviderId"
        static let selectedVoiceIdName = "voiceViewModelSelectedVoiceId"
    }
    
    private func restoreDefaults() {
        
        Task {
            
            // register defaults for all ids
            await registerDefaults()
            
            // all available locales can be selected
            self.selectableLocales = await voiceController.availableLocales() // all available locales
            
            // get stored ids from userDefaults
            let (restoredLocaleId, restoredProviderId, restoredVoiceId) = getStoredIds()
            
            // convert localeId to locale
            let restoredLocale = Locale(identifier: restoredLocaleId)
            
            // convert restoredProviderId to provider
            let restoredProvider = voiceController.provider(forId: restoredProviderId)
            
            // Download the restoredProvider's voices ahead of time.
            // The voices are then downloaded before a possible re-download can be triggered by updating the selectedProviderId.
            if let restoredProvider {
                self.selectableVoices = await restoredProvider.availableVoicesForLocale(locale: restoredLocale)
            }
            
            // locale
            self.selectedLocaleId = restoredLocale.identifier // this also sets the selectable Providers
            
            // provider id
            self.selectedProviderId = restoredProviderId
            
            // voiceId
            self.selectedVoiceId = restoredVoiceId
            
        }
    }
    
    
    
    private func registerDefaults() async {
        
        // which provider and locale  should be shosen when the app starts the first time?
        let defaultLocaleId = "en-US"
        let defaultProvider = AppleVoiceProvider()
        
        // derive ids
        let defaultProviderId = defaultProvider.id
        let defaultVoiceId = await defaultProvider.preferedVoiceForLocale(locale: Locale(identifier: defaultLocaleId))!.id
        
        // register defaults
        UserDefaults.standard.register(defaults: [
            UserDefaultKeys.selectedLocaleIdName : defaultLocaleId,
            UserDefaultKeys.selectedProviderIdName: defaultProviderId,
            UserDefaultKeys.selectedVoiceIdName: defaultVoiceId,
        ])
        
    }
    
    /// Reads stored ids from userDefaults.
    /// - Returns: A tuple of (selectedLocaleId, selectedProviderId, selectedVoiceId)
    private func getStoredIds() -> (selectedLocaleId: String, selectedProviderId: String, selectedVoiceId: String) {
        
        let localekey = UserDefaultKeys.selectedLocaleIdName
        let selectedLocaleId = UserDefaults.standard.string(forKey: localekey)!
        
        // restore selected provider from User Defaults
        let providerKey = UserDefaultKeys.selectedProviderIdName
        let selectedProviderId = UserDefaults.standard.string(forKey: providerKey)!
        
        // restore selected voiceId from User Defaults
        let voiceKey = UserDefaultKeys.selectedVoiceIdName
        let selectedVoiceId = UserDefaults.standard.string(forKey: voiceKey)!
        
        return (selectedLocaleId: selectedLocaleId, selectedProviderId: selectedProviderId, selectedVoiceId: selectedVoiceId)
    }
    
}


// MARK: Speaking, stoping and rendeing text.
extension VoiceViewModel {

    /// Speaks given text.
    /// - Parameter text: The text to speak.
    func speak(text: String) {

        Task {
            if let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) {
                
                playerStatus = .rendering
                
                if let audioURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
                    playerStatus = .playing
                    await audioPlayerController.playAudio(audioUrl: audioURL)
                    playerStatus = .idle
                }
            }
        }
    }
    
    /// Stops audio playback.
    func stopSpeaking() {
        audioPlayerController.stopAudio()
    }
    
    /// Converts given text to speech and stores in in the given `destinationURL`.
    /// - Parameters:
    ///   - text: The text to convert,
    ///   - destinationURL: The file URL in which the resulting speech should be stored.
    func render(text: String, toURL destinationURL: URL) async {
        
        if let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) {
        
            playerStatus = .rendering
            
            if let tempURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
                try? FileManager.default.moveItem(at: tempURL, to: destinationURL)
            }
            
            playerStatus = .idle
        }
    }

}

