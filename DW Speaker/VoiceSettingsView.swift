//
//  VoiceSettingsView.swift
//  DW Speaker
//
//  This View switches between the various concrete VoiceSettingsViews.
//
//  Created by Andy Giefer on 16.08.23.
//

import SwiftUI
import DWSpeakerKit

struct VoiceSettingsView: View {
    
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    var body: some View {
        
        if let _ = voiceViewModel.selectedProvider as? AppleVoiceProvider {
            AppleVoiceSettingsView()
        } else if let _ = voiceViewModel.selectedProvider as? ElevenLabsVoiceProvider {
            ElevenLabsVoiceSettingsView()
        } else {
            EmptyView()
        }
    }
}

struct VoiceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceSettingsView()
    }
}
