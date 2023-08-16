//
//  VoiceViewModel.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation

@MainActor
class VoiceViewModel: ObservableObject {
    
    var voiceController: VoiceController
    var audioPlayerController: AudioPlayerController

    @Published var selectableLocales: [Locale] = []
    @Published var selectableProviders: [VoiceProvider] = []
    @Published var selectableVoices: [Voice] = []

    
    /// The identifier of the selected language.
    @Published var selectedLocaleId: String = "" {
        didSet {
            
            // after the Locale changes, adjust the list of selectable provider and and choose the first on the list
            let selectedLocale = Locale(identifier: selectedLocaleId)
            Task {
                
                let providers = await voiceController.providers(forLocale: selectedLocale)
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
            if let selectedProvider {
                Task {
                    let selectedLocale = Locale(identifier: selectedLocaleId)
                    let voices = await selectedProvider.availableVoicesForLocale(locale: selectedLocale)
                    let preferedVoice = await selectedProvider.preferedVoiceForLocale(locale: selectedLocale)
                    
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
        self.voiceController = VoiceController()

        /// Access to voice functionalitites
        self.audioPlayerController = AudioPlayerController()
        
        // default locale and provider
        let selectedLocale = Locale(identifier: "en-US")
        let selectedProvider = AppleVoiceProvider()
        
        // set available locales and providers
        Task {
            let locales = await voiceController.availableLocales()
            let providers = await voiceController.providers(forLocale: selectedLocale)
            
            DispatchQueue.main.async {
                self.selectableLocales = locales
                self.selectableProviders = providers
                
                self.selectedLocaleId = selectedLocale.identifier
                self.selectedProviderId = selectedProvider.id
                
            }
        }
    }
    
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
    
    func stopSpeaking() {
        audioPlayerController.stopAudio()
    }
    
}

