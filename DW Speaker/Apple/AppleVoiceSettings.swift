//
//  AppleVoiceSettings.swift
//  DW Speaker
//
//  Created by Andy Giefer on 08.08.23.
//

import Foundation
import AVFoundation

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
