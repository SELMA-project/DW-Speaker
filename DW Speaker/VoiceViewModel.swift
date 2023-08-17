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
            
            if oldValue != selectedLocaleId {
                
                print("Updating selectedLocaleId to: \(selectedLocaleId)")
                
                // store in user defaults
                UserDefaults.standard.set(selectedLocaleId, forKey: UserDefaultKeys.selectedLocaleIdName)
                
                ensureConsistency()
            }
//
//            // after the Locale changes, adjust the list of selectable provider and and choose the first on the list
//            let selectedLocale = Locale(identifier: selectedLocaleId)
//            Task {
//
//                let providers = await voiceController.providers(forLocale: selectedLocale)
//                DispatchQueue.main.async {
//
//                    // set list of providers
//                    self.selectableProviders = providers
//
//                    // select first provider on the list
//                    if let firstProvider = providers.first {
//                        self.selectedProviderId = firstProvider.id
//                    }
//                }
//
//            }
        }
    }
    
    /// The identifer of the selected provider.
    @Published var selectedProviderId: String = "" {
        didSet {
            
            if oldValue != selectedProviderId {
                
                print("Updating selectedProviderId to: \(selectedProviderId)")
                // store in user defaults
                UserDefaults.standard.set(selectedProviderId, forKey: UserDefaultKeys.selectedProviderIdName)
                
                ensureConsistency()
                
            }
            
//            // after the provider changes, adjust the list of selectable voice and choose the prefered one
//            if let selectedProvider {
//                Task {
//                    let selectedLocale = Locale(identifier: selectedLocaleId)
//                    let voices = await selectedProvider.availableVoicesForLocale(locale: selectedLocale)
//                    let preferedVoice = await selectedProvider.preferedVoiceForLocale(locale: selectedLocale)
//
//                    DispatchQueue.main.async {
//                        self.selectableVoices = voices
//
//                        if let preferedVoice {
//                            self.selectedVoiceId = preferedVoice.id
//                        }
//                    }
//                }
//            }
        }
    }
    
    /// The identifier of the selected voice.
    @Published var selectedVoiceId: String = "" {
        didSet {
            //if oldValue != selectedVoiceId {
                
                print("Updating selectedVoiceId to: \(selectedVoiceId)")
                
                // store in user defaults
                UserDefaults.standard.set(selectedVoiceId, forKey: UserDefaultKeys.selectedVoiceIdName)
            //}
        }
    }
    
    /// Looks at current Ids and updates them if need to keep consistency
    private func ensureConsistency()   {

        Task {
            
            // read current ids
            let proposedLocaleId = selectedLocaleId
            let proposedProviderId = selectedProviderId
            let proposedVoiceId = selectedVoiceId
            
            // the proposed Locale becomes the recommended Locale
            let recommendedLocaleId = proposedLocaleId
            
            // convert locale id to locale and get all availabe providers
            let selectedLocale = Locale(identifier: proposedLocaleId)
            let providers = await voiceController.providers(forLocale: selectedLocale)
            
            // find provider for proposedProviderId. Fallback: use first on the list
            let recommendedProvider = providers.first(where: { $0.id == proposedProviderId}) ?? providers.first
            let recommendedProviderId = recommendedProvider?.id
            
            // find voice for recommended provider
            var recommendedVoiceId: String? = nil
            var voices = [Voice]()
            if let recommendedProvider {
                voices = await recommendedProvider.availableVoicesForLocale(locale: selectedLocale) // get all voices
                let fallbackVoiceVoice = await recommendedProvider.preferedVoiceForLocale(locale: selectedLocale) // used if proposedVoiceId does not match
                let recommendedVoice = voices.first(where: { $0.id == proposedVoiceId}) ?? fallbackVoiceVoice
                recommendedVoiceId = recommendedVoice?.id
            }
            
            // publish properties
            DispatchQueue.main.async {
                
                // publish locale
                self.selectedLocaleId = recommendedLocaleId
                
                // publish provider if it has changed
                self.selectableProviders = providers
                if recommendedProviderId != proposedProviderId {
                    if let recommendedProviderId {
                        self.selectedProviderId = recommendedProviderId
                    }
                }
                
                // publish voice if it has changed
                self.selectableVoices = voices
                if recommendedVoiceId != proposedVoiceId {
                    if let recommendedVoiceId {
                        self.selectedVoiceId = recommendedVoiceId
                    }
                }
                
            }
            
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
    
    struct UserDefaultKeys {
        static let selectedLocaleIdName = "voiceViewModelSelectedLocaleId"
        static let selectedProviderIdName = "voiceViewModelSelectedProviderId"
        static let selectedVoiceIdName = "voiceViewModelSelectedVoiceId"
    }
    
    private func restoreDefaults() {
        
        Task {
        
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
            
            // When the app was already launched before, the USerDefaults are set, so the registered defaults do not count
            
            // restore selected locale from User Defaults
            let localekey = UserDefaultKeys.selectedLocaleIdName
            let selectedLocaleId = UserDefaults.standard.string(forKey: localekey)!
            let selectedLocale = Locale(identifier: selectedLocaleId)
            
            // restore selected provider from User Defaults
            let providerKey = UserDefaultKeys.selectedProviderIdName
            let selectedProviderId = UserDefaults.standard.string(forKey: providerKey)!
            let locales = await voiceController.availableLocales() // all available locales
            let providers = await voiceController.providers(forLocale: selectedLocale) // all available providers
            let selectedProvider = providers.first { $0.id == selectedProviderId} ?? AppleVoiceProvider() // derive selectedProvider based on its ID
            
            // restore selected voiceId from User Defaults
            let voiceKey = UserDefaultKeys.selectedVoiceIdName
            let selectedVoiceId = UserDefaults.standard.string(forKey: voiceKey)!
            
            // publish
            DispatchQueue.main.async {
                self.selectableLocales = locales
                self.selectableProviders = providers
                
                self.selectedLocaleId = selectedLocale.identifier
                self.selectedProviderId = selectedProvider.id
                self.selectedVoiceId = selectedVoiceId
                
                self.ensureConsistency()
            }
            
        }
        
    }
    
    init() {
        
        /// Access to voice functionalitites
        self.voiceController = VoiceController()

        /// Access to voice functionalitites
        self.audioPlayerController = AudioPlayerController()
        
        restoreDefaults()
        
//        // restore provider from UserDefaults
//        let selectedProvider = AppleVoiceProvider()
//
//        // set available locales and providers
//        Task {
//            let locales = await voiceController.availableLocales()
//            let providers = await voiceController.providers(forLocale: selectedLocale)
//
//            DispatchQueue.main.async {
//                self.selectableLocales = locales
//                self.selectableProviders = providers
//
//                self.selectedLocaleId = selectedLocale.identifier
//                self.selectedProviderId = selectedProvider.id
//
//            }
//        }
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
    
    
    func audioURL(fromText text: String) async -> URL?  {

        var result: URL?
        
        if let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) {
        
            playerStatus = .rendering
            
            if let audioURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
                result = audioURL
            }
        }
        
        playerStatus = .idle
        
        return result
        
    }
    
    func render(text: String, toURL destinationURL: URL) async {
        
        if let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) {
        
            playerStatus = .rendering
            
            if let tempURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
                try? FileManager.default.moveItem(at: tempURL, to: destinationURL)
            }
            
            playerStatus = .idle
        }
    }
    
//    func audioFile(fromText text: String) async -> AudioFile?  {
//
//        var audioFile: AudioFile?
//
//        if let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) {
//
//            playerStatus = .rendering
//
//            if let audioURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
//                if let audioData = try? Data(contentsOf: audioURL) {
//                    audioFile = AudioFile(data: audioData)
//                }
//            }
//        }
//
//        playerStatus = .idle
//
//        return audioFile
//
//    }

}

