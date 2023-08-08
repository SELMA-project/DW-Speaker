//
//  AppleVoiceProvider.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation
import AVFoundation

struct AppleVoiceProvider: VoiceProvider, Identifiable {
    
    var id = "appleVoiceProvider"
    
    var displayName = "Apple"
    
    func supportedLocales() async -> [Locale] {
        
        // store locales in set to assure uniqueness
        var uniqueLocales: Set<Locale> = Set()
        
        // get all available avoices
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // add each voice's lanuageIdentifier to the set
        for voice in allVoices {
            let languageIdentifier = voice.language // BP47
            let locale = Locale(identifier: languageIdentifier)
            uniqueLocales.insert(locale)
        }
        
        // sort by identifer while converting to an array
        let sortedLocales = uniqueLocales.sorted {$0.identifier < $1.identifier}
        
        return sortedLocales
    }
    
    func availableVoicesForLocale(locale: Locale) async -> [Voice] {
        
        var availableVoices: [AppleVoice] = []
        
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        let speechVoicesForLocale = allVoices.filter {
            
            var keepVoice = true
            
            // filter by language
            if $0.language != locale.identifier {keepVoice = false}
            
            // exclude eloquence
            if $0.identifier.contains("eloquence") {keepVoice = false}
            
            // exclude novelty voices
            if $0.identifier.contains("speech.synthesis") {keepVoice = false}
            
            return keepVoice
        }
        
        for speechVoice in speechVoicesForLocale {
            
            // get properties
            let identifier = speechVoice.identifier
            let name = speechVoice.name
            let quality = speechVoice.quality
            
            var displayName = "\(name)"
            
            // add quality to the displayName
            if quality == .enhanced {displayName += " (enhanced)"}
            if quality == .premium {displayName += " (premium)"}
            
            // create apple voice and add it to result
            let appleVoice = AppleVoice(id: identifier, displayName: displayName, quality: quality)
            availableVoices.append(appleVoice)
        }
        
        // sort by name
        let sortedAvailableVoices = availableVoices.sorted { (lhs, rhs) in
            if lhs.quality.rawValue == rhs.quality.rawValue {
                return lhs.displayName < rhs.displayName
            }
            
            return lhs.quality.rawValue > rhs.quality.rawValue
            
        }
        
        // map AppleVoices to Voices
        let result = sortedAvailableVoices.map( {$0 as Voice} )
        
        return result
    }
    
    /// Return the voice with the highest quality as prefered voice
    func preferedVoiceForLocale(locale: Locale) async -> Voice? {
        
        var preferedVoice: Voice?
        
        let allVoicesForLocale = await availableVoicesForLocale(locale: locale)
        
        if let premiumVoice = allVoicesForLocale.filter({$0.id.contains("premium")}).first {
            preferedVoice = premiumVoice
            
        } else if let enhancedVoice = allVoicesForLocale.filter({$0.id.contains("enhanced")}).first {
            preferedVoice = enhancedVoice
            
        } else {
            preferedVoice = allVoicesForLocale.first
        }
        
        return preferedVoice
        
    }
    
    
    func voice(forId voiceId: String) -> Voice {
        let nativeVoice = AVSpeechSynthesisVoice(identifier: voiceId)!
        
        // convert to AppleVoice
        let identifier = nativeVoice.identifier
        let displayName = nativeVoice.name
        
        let appleVoice = AppleVoice(id: identifier, displayName: displayName, quality: nativeVoice.quality)
        return appleVoice
    }
    
    
}

struct AppleVoice: Voice {
    
    var id: String
    var displayName: String

    
    var quality: AVSpeechSynthesisVoiceQuality
    
    // setup synthesizer
    private let synthesizer = AVSpeechSynthesizer()

    
    func synthesizeText(_ text: String, settings: VoiceSettings) async -> URL? {
        
        // create utterance
        let utterance = AVSpeechUtterance(string: text)
        
        // apply settings
        utterance.pitchMultiplier = settings.apple.pitchMultiplier
        utterance.volume = settings.apple.volume
        utterance.rate = settings.apple.rate
        utterance.preUtteranceDelay = settings.apple.preUtteranceDelay
        utterance.postUtteranceDelay = settings.apple.postUtteranceDelay
        
        // associate voice
        let voice = AVSpeechSynthesisVoice(identifier: self.id)
        utterance.voice = voice
        
        // render utterance to audio file
        let audioURL = await synthesizeUtterance(utterance)
        
        return audioURL
    }
    

    
    
    /// Synthesize text using given voice. Save to file and return its URL.
    func synthesizeUtterance(_ utterance: AVSpeechUtterance) async -> URL? {
        
        await withCheckedContinuation { continuation in
            
            // create URL to store the audio in
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("wav")
            
            // result will be stored here
            var returnedURL: URL? = nil
            
            
            // Only create new file handle if `output` is nil.
            var output: AVAudioFile?
            
            // for example, see https://stackoverflow.com/questions/25965601/avspeechsynthesizer-output-as-file/58118583#58118583
            synthesizer.write(utterance) {(buffer: AVAudioBuffer) in
                
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    fatalError("unknown buffer type: \(buffer)")
                }
                
                
                if pcmBuffer.frameLength == 0 {
                    // Done
                    
                    if output != nil {
                        
                        // here, we know that we have been successful
                        returnedURL = fileURL
                        
                        // set output AVAudioFile to nil to close it
                        output = nil
                        
                        continuation.resume(returning: returnedURL)
                    }
                    
                    
                } else {
                                        
                    do{
                        // this closure is called multiple times. so to save a complete audio, try create a file only for once.
                        if output == nil {
                            try  output = AVAudioFile(
                                forWriting: fileURL,
                                settings: pcmBuffer.format.settings,
                                commonFormat: .pcmFormatInt16,
                                interleaved: false)
                            
                            //print("pcmBuffer settings: \(pcmBuffer.format.settings)")
                        }
                        try output?.write(from: pcmBuffer)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
    }
}


    
struct AppleVoiceSettings {
    
    /// The volume of the spoken utterance.  Range is etween 0 and 1.
    var volume : Float = 1.0
    
    /// The baseline pitch the speech synthesizer uses when speaking the utterance.
    /// Values are between 0.5 and 2.0.
    var pitchMultiplier: Float = 1.0
    
    /// The rate the speech synthesizer uses when speaking the utterance.
    var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    let minimumSpeechRate: Float = AVSpeechUtteranceMinimumSpeechRate
    let maximumSpeechRate: Float = AVSpeechUtteranceMaximumSpeechRate
    
    /// The amount of time the speech synthesizer pauses before speaking the utterance.
    var preUtteranceDelay: TimeInterval = 0.0
    
    /// The amount of time the speech synthesizer pauses after speaking an utterance before handling the next utterance in the queue.
    var postUtteranceDelay: TimeInterval = 0.0
    
}

