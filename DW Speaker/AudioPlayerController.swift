//
//  AudioPlayerController.swift
//  DW Speaker
//
//  Created by Andy Giefer on 07.08.23.
//

import Foundation
import AVFoundation

class AudioPlayerController: NSObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    
    private typealias AudioPlayerCheckedContinuation = CheckedContinuation<Void, Never>
    private var audioPlayerCheckedContinuation: AudioPlayerCheckedContinuation?
    
    func playAudio(audioUrl: URL) async {
        
        // in case that we have an outstanding checkedContinuation, resume it
        audioPlayerCheckedContinuation?.resume()
        
        return await withCheckedContinuation({ continuation in
            
            audioPlayerCheckedContinuation = continuation
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } catch {
                print("Could not play audio.")
            }
            
        })
        
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayerCheckedContinuation?.resume()
        audioPlayerCheckedContinuation = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        audioPlayerCheckedContinuation?.resume()
        audioPlayerCheckedContinuation = nil
    }
}
