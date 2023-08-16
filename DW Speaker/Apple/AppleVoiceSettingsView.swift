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
    
    var volumeSlider: some View {
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.volume, in: 0...1, step: 0.1) {
                Text("Volume:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.volume.formatted(.number.precision(.fractionLength(1))))")
                //.frame(width:30, alignment: .trailing)
        }
    }
    
    var pitchSlider: some View {
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.pitchMultiplier, in: 0.5...2.0, step: 0.1) {
                Text("Pitch:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.pitchMultiplier.formatted(.number.precision(.fractionLength(1))))")
                //.frame(width:30, alignment: .trailing)
        }
    }
    
    var rateSlider: some View {
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.rate, in: voiceViewModel.voiceSettings.apple.minimumSpeechRate...voiceViewModel.voiceSettings.apple.maximumSpeechRate) {
                Text("Rate:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.rate.formatted(.number.precision(.fractionLength(2))))")
                //.frame(width:30, alignment: .trailing)
        }
    }
    
    var preUtteranceDelaySlider: some View {
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.preUtteranceDelay, in: 0...1) {
                Text("Pre Delay:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.preUtteranceDelay.formatted(.number.precision(.fractionLength(1))))")
                //.frame(width:30, alignment: .trailing)
        }
    }
    
    var postUtteranceDelaySlider: some View {
        HStack {
            Slider(value: $voiceViewModel.voiceSettings.apple.postUtteranceDelay, in: 0...1) {
                Text("Post Delay:")
            }
            Text("\(voiceViewModel.voiceSettings.apple.postUtteranceDelay.formatted(.number.precision(.fractionLength(1))))")
                //.frame(width:30, alignment: .trailing)
        }
    }
    
    var body: some View {

        VStack {
            Form {
                volumeSlider
                pitchSlider
                rateSlider
            }
            //preUtteranceDelaySlider
            //postUtteranceDelaySlider
    
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
