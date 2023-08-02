//
//  ContentView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import SwiftUI

struct ContentView: View {
    
    @State var textToSpeak: String = "Hello, my name is Andy."
    
    @State var selectedLocale: Locale = Locale(identifier: "en-US")
    @State var availableLocales: [Locale] = []
//    enum Language: String, CaseIterable {
//        case German, English, Hindi, Urdu
//    }

    @State var selectedVoiceProvider: VoiceProvider = .Apple
    enum VoiceProvider: String, CaseIterable {
        case Apple, Azure, Google, ElevenLabs
    }

    @State var selectedVoice: Voice = .Andy
    enum Voice: String, CaseIterable {
        case Andy, Johann, Alice
    }
    
    var voiceManager = VoiceManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $textToSpeak)
                .font(.title2)
                .padding(40)
                .background(ignoresSafeAreaEdges: .all)
            
            HStack {
                Picker("Language:", selection: $selectedLocale) {
                    ForEach(availableLocales, id: \.self.identifier) { locale in
                        Text(locale.description).tag(locale)
                    }
                }
                
                Picker("Provider:", selection: $selectedVoiceProvider) {
                    ForEach(VoiceProvider.allCases, id: \.self) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                
                Picker("Voice:", selection: $selectedVoice) {
                    ForEach(Voice.allCases, id: \.self) { voice in
                        Text(voice.rawValue).tag(voice)
                    }
                }
                
                Button("Speak") {
                    print("Speaking")
                }
                .buttonStyle(BlueButtonStyle())
            }
            .padding()

        }.onAppear {
            Task {
                availableLocales = await voiceManager.availableLocales()
            }
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
