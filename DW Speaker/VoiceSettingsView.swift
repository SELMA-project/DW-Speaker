//
//  VoiceSettingsView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 16.08.23.
//

import SwiftUI

struct VoiceSettingsView: View {
    
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    var body: some View {
        
        if let _ = voiceViewModel.selectedProvider as? AppleVoiceProvider {
            AppleVoiceSettingsView()
        } else {
            ElevenLabsVoiceSettingsView()
        }
    }
}

struct VoiceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceSettingsView()
    }
}
