//
//  ContentView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var voiceManager = VoiceManager()
    
    @State var textToSpeak: String = "Hello, my name is Andy."
    
    
    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $textToSpeak)
                .font(.title2)
                .padding(40)
                .background(ignoresSafeAreaEdges: .all)
            
            HStack {
                Picker("Language:", selection: $voiceManager.selectedLocaleId) {
                    ForEach(voiceManager.selectableLocales, id: \.identifier) { locale in
                        Text(locale.displayName).tag(locale)
                    }
                }
                
                Picker("Provider:", selection: $voiceManager.selectedProviderId) {
                    ForEach(voiceManager.selectableProviders, id: \.id) { provider in
                        Text(provider.displayName).tag(provider.id)
                    }
                }
                
                Picker("Voice:", selection: $voiceManager.selectedVoiceId) {
                    ForEach(voiceManager.selectableVoices, id: \.id) { voice in
                        Text(voice.displayName).tag(voice.id)
                    }
                }
                
                Button("Speak") {
                    print("Speaking")
                }
                .buttonStyle(BlueButtonStyle())
            }
            .padding()

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
