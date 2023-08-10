//
//  AppleVoice.swift
//  DW Speaker
//
//  Created by Andy Giefer on 08.08.23.
//

import Foundation
import AVFoundation

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
            let fileURL = FileManager.temporaryAudioUrl()
            
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

