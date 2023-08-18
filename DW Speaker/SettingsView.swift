//
//  SettingsView.swift
//  DW Speaker
//
//  Created by Andy Giefer on 18.08.23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(Constants.userDefaultsElevenLabsAPIKeyName) var elevenLabsAPIKey = ""
    
    var body: some View {
        
        VStack {
            Form {
                TextField("ElevenLabs API Key:", text: $elevenLabsAPIKey)
                Text("Please restart the app after settings the API Key.")
            }
            
            
        }.padding()
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
