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
    
    let priberamVoiceManager = PriberamVoiceManager(executeTest: true)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
//                .task {
//                    let priberamVoiceManager = PriberamVoiceManager()
//                    await priberamVoiceManager?.test()
//                }
        }
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
