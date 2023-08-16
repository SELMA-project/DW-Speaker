//
//  ElevenLabsVoiceSettingsView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 16.08.23.
//

import SwiftUI

struct ElevenLabsVoiceSettingsView: View {
    
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    var stabilitySlider: some View {
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.elevenLabs.stability, in: 0...1) {
                Text("Stability:")
            }
            Text("\(voiceViewModel.voiceSettings.elevenLabs.stability.formatted(.number.precision(.fractionLength(1))))")
        }
    }
    
    var similaritySlider: some View {
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.elevenLabs.similarityBoost, in: 0...1) {
                Text("Similarity:")
            }
            Text("\(voiceViewModel.voiceSettings.elevenLabs.similarityBoost.formatted(.number.precision(.fractionLength(1))))")
        }
    }
    
    var body: some View {
        Form {
            stabilitySlider
            similaritySlider
        }
    }
}

struct ElevenLabsVoiceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = VoiceViewModel()
        
        ElevenLabsVoiceSettingsView()
            .environmentObject(viewModel)
    }
}
