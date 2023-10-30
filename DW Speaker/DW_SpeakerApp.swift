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
    
    
    // TODO: remove after testing
    let priberamGoogleVoiceManager = PriberamVoiceManager(voiceSubProvider: .azure, executeTest: true)
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // WARNING: only activate to create files once.
                    PriberamVoiceManager.createCSVDatafiles()
                }
        }
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
