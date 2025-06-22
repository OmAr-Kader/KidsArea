//
//  SpeechRecognizer.swift
//  Mix
//
//  Created by OmAr Kader on 02/02/2025.
//

import SwiftUI
import Foundation
import AVFoundation

class TextToSpeech : NSObject, ObservableObject, @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer()

    @Published var isSpeechEnabled: Bool = false

    @Published var isPaused: Bool = true
    
    func speakStop(text: String, language: String = "en-US", rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        if isSpeechEnabled {
            stopSpeaking()
        } else {
            speak(text: text, language: language, rate: rate)
        }
    }
    
    func speak(text: String, language: String = "en-US", rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func stopSpeakingIf() {
        if isSpeechEnabled {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    func pauseResumeSpeaking() {
        let isPaused = synthesizer.isPaused
        if !isPaused {
            synthesizer.pauseSpeaking(at: .word)
        } else {
            synthesizer.continueSpeaking()
        }
    }

    func pauseSpeaking() {
        if !synthesizer.isPaused {
            synthesizer.pauseSpeaking(at: .word)
        }
    }

    func continueSpeaking() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }
    }
}


extension TextToSpeech: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        withAnimation {
            isSpeechEnabled = true
            isPaused = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        withAnimation {
            self.isPaused = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        withAnimation {
            self.isPaused = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        withAnimation {
            isSpeechEnabled = false
            isPaused = true
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        withAnimation {
            isSpeechEnabled = false
            isPaused = true
        }
    }
}
