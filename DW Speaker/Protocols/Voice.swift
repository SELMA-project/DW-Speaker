//
//  Voice.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation

protocol Voice {
    
    /// The voice's unique id.
    var id: String {get}
    
    /// The voice's name, suitable to be displayed in an UI.
    var displayName: String { get set }
        
    /// Converts the provided text into speech.
    func synthesizeText(_ text: String, settings: VoiceSettings) async -> URL?
}

