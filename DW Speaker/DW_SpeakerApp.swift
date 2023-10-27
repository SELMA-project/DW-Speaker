//
//  DW_SpeakerApp.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import SwiftUI

// TODO: Remove
import DWSpeakerKit

@main
struct DW_SpeakerApp: App {
    
    //let priberamGoogleVoiceManager = PriberamVoiceManager(voiceSubProvider: .google, executeTest: true)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
