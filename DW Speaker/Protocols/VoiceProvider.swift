//
//  VoiceProvider.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation

protocol VoiceProvider {
    
    /// The provider's unique identifier.
    var id: String {get}
    
    /// The provider's name, suitable to be displayed in an UI.
    var displayName: String { get set }
    
    /// Returns an array of supported locales.
    func supportedLocales() async -> [Locale]
    
    /// An array of the voices that are available for hte given locale.
    func availableVoicesForLocale(locale: Locale) async -> [Voice]
    
    /// The provider's preferred voice for the given locale
    func preferedVoiceForLocale(locale: Locale) async -> Voice?
    
    func voice(forId voiceId: String) async -> Voice?
    

}
