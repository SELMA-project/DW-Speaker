//
//  SettingsView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 18.08.23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(Constants.userDefaultsElevenLabsAPIKeyName) var elevenLabsAPIKey = ""
    @AppStorage(Constants.userDefaultsPriberamAPIKeyName) var priberamAPIKey = ""
    
    var body: some View {
        
        VStack {
            Form {
                TextField("ElevenLabs API Key:", text: $elevenLabsAPIKey)
                Text("Required to use ElevenLabs voices.")
                    .font(.caption)
                
                TextField("Priberam API Key:", text: $priberamAPIKey)
                Text("Required to use Google and Azure voices.")
                    .font(.caption)
                    .padding(.bottom, 16)
                
                Text("Please restart the app after setting the API keys.")
            }
            
            
        }.padding()
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
