//
//  AppleVoiceSettingsView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 08.08.23.
//

import SwiftUI

struct AppleVoiceSettingsView: View {

    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    @State var volume = 1.0
        
    var body: some View {

        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.volume, in: 0...1, step: 0.1) {
                Text("Volume:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.volume.formatted(.number.precision(.fractionLength(1))))")
                .frame(width:30)
        }
        
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.pitchMultiplier, in: 0.5...2.0, step: 0.1) {
                Text("Pitch:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.pitchMultiplier.formatted(.number.precision(.fractionLength(1))))")
                .frame(width:30)
        }

        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.rate, in: voiceViewModel.voiceSettings.apple.minimumSpeechRate...voiceViewModel.voiceSettings.apple.maximumSpeechRate, step: 0.1) {
                Text("Rate:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.rate.formatted(.number.precision(.fractionLength(1))))")
                .frame(width:30)
        }
        
    }
}

struct VoiceSettings_Previews: PreviewProvider {
    static var previews: some View {
        
        @StateObject var viewModel = VoiceViewModel()
        
        AppleVoiceSettingsView()
            .environmentObject(viewModel)
    }
}
