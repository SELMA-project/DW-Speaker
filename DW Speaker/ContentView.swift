//
//  ContentView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var voiceViewModel = VoiceViewModel()
    
    @AppStorage("textToSpeak") var textToSpeak: String = "Hello, my name is Andy."
    
    var body: some View {
                
        HStack(spacing: 0) {
            TextEditor(text: $textToSpeak)
                .autocorrectionDisabled(true)
                .font(.title2)
                .padding(40)
                .background(ignoresSafeAreaEdges: .all)
            
            VStack {
                Form {
                    Picker("Language:", selection: $voiceViewModel.selectedLocaleId) {
                        ForEach(voiceViewModel.selectableLocales, id: \.identifier) { locale in
                            Text(locale.displayName).tag(locale)
                        }
                    }
                    
                    Picker("Provider:", selection: $voiceViewModel.selectedProviderId) {
                        ForEach(voiceViewModel.selectableProviders, id: \.id) { provider in
                            Text(provider.displayName).tag(provider.id)
                        }
                    }
                    
                    Picker("Voice:", selection: $voiceViewModel.selectedVoiceId) {
                        ForEach(voiceViewModel.selectableVoices, id: \.id) { voice in
                            Text(voice.displayName).tag(voice.id)
                        }
                    }.padding(.bottom, 16)
                    
                    AppleVoiceSettingsView()
                        .environmentObject(voiceViewModel)
                }
                

                              
                Spacer()
                
                Button {
                    if voiceViewModel.playerStatus == .idle {
                        voiceViewModel.speak(text: textToSpeak)
                    }
                    
                    if voiceViewModel.playerStatus == .playing {
                        voiceViewModel.stopSpeaking()
                    }
                    
                } label: {
                    Text(voiceViewModel.playerStatus == .idle ? "Speak" : "Stop")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BlueButtonStyle())
                .disabled(voiceViewModel.playerStatus == .rendering)
                
            }
            .padding()
            .frame(width: 300)
     
    
            

        }
        
    }
}

struct BlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .foregroundColor(configuration.isPressed ? Color.blue : Color.white)
            .background(configuration.isPressed ? Color.white : Color.blue)
            .cornerRadius(6)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: 800, minHeight: 600)
    }
}
