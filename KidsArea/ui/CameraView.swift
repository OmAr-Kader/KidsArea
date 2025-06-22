//
//  ContentView.swift
//  TestCoreML
//
//  Created by OmAr Kader on 16/06/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var text: String = "Searching..."
    
    @State private var wiki: WikiData?

    @StateObject var speechRecognizer = TextToSpeech()

    var body: some View {
        ZStack {
            // Camera preview fills the entire screen
            CameraPreviewView(viewModel: cameraViewModel)
                .edgesIgnoringSafeArea(.all)
            if let wiki {
                WikiView(wiki: wiki, isSpeechEnabled: speechRecognizer.isSpeechEnabled, isSpeechPaused: speechRecognizer.isPaused) {
                    speechRecognizer.pauseResumeSpeaking()
                } speech: {
                    speechRecognizer.speakStop(text: wiki.extract)
                } close: {
                    withAnimation {
                        self.cameraViewModel.isCameraActive = true
                        self.wiki = nil
                    }
                }
                
            } else {
                extractorsView
            }
        }.onAppeared {
            checkCameraPermission()
        }.onDisappear {
            speechRecognizer.stopSpeakingIf()
        }
    }
    
    @ViewBuilder
    var extractorsView: some View {
        VStack {
            if !cameraViewModel.recognizedObjects.isEmpty {
                VStack {
                    ForEach(Array(cameraViewModel.recognizedObjects.enumerated()), id: \.offset) { _, it in
                        Text(it.0 + " " + it.1)
                            .padding(2)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center).onTapGesture {
                                doSearch(it.0)
                            }
                    }
                }.background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.6))).padding(20)
            } else {
                Text(cameraViewModel.notRecognized)
                    .padding(22)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.6)))
            }
            Spacer()
        }.padding(.top, 50)
    }
    
    
    @MainActor
    private func doSearch(_ txt: String){
        withAnimation {
            self.cameraViewModel.isCameraActive = false
            self.wiki = WikiData(extract: "Loading...")
        }
        fetchWikipediaSummary(for: txt) { it in
            DispatchQueue.main.async {
                withAnimation {
                    self.wiki = it
                }

            }
        } failed: {
            guard let newText = txt.split(separator: ",").first?.lowercased() else {
                DispatchQueue.main.async {
                    withAnimation {
                        self.cameraViewModel.isCameraActive = true
                        self.wiki = nil
                    }
                }
                return
            }
            fetchWikipediaSummary(for: newText) { it in
                DispatchQueue.main.async {
                    withAnimation {
                        self.wiki = it
                    }

                }
            } failed: {
                DispatchQueue.main.async {
                    withAnimation {
                        self.cameraViewModel.isCameraActive = true
                        self.wiki = nil
                    }
                }
            }

            
        }
    }
    
    /// Checks and requests camera permissions.
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraViewModel.initial()
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    // Handle case where user denies permission after prompt
                    DispatchQueue.main.async {
                        cameraViewModel.notRecognized = "Camera access denied. Please enable in Settings."
                    }
                    return
                }
                cameraViewModel.initial()
            }
        case .denied, .restricted:
            // Permission denied or restricted. Inform the user.
            cameraViewModel.notRecognized = "Camera access denied. Please enable in Settings."
        @unknown default:
            break
        }
    }
}

struct WikiView: View {
    
    let wiki: WikiData
    let isSpeechEnabled: Bool
    let isSpeechPaused: Bool
    let pause: () -> Void
    let speech: () -> Void
    let close: () -> Void
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    ZStack {
                        ZStack {
                            if let image = wiki.originalimage?.source ?? wiki.thumbnail?.source {
                                KingsImageFull(urlString: image, height: proxy.size.height - 50, contentMode: .fit)
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.black.opacity(0.6)))
                                Spacer().background(RoundedRectangle(cornerRadius: 25).fill(Color.black.opacity(0.6)))
                            }
                        }
                        VStack {
                            HStack {
                                Spacer()
                                
                                Spacer()
                                if isSpeechEnabled {
                                    Image(systemName: isSpeechPaused ? "play.fill" : "pause")
                                        .resizable()
                                        .padding(4)
                                        .frame(size: 30)
                                        .onTapGesture(perform: pause)
                                    Spacer().frame(width: 10)

                                }
                                Image(systemName: isSpeechEnabled ? "stop.fill" : "speaker.wave.2.fill")
                                    .resizable()
                                    .padding(4)
                                    .frame(size: 30)
                                    .onTapGesture(perform: speech)
                                Spacer().frame(width: 10)
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(size: 30)
                                    .onTapGesture(perform: close)
                            }
                            Spacer()
                        }.frame(width: proxy.size.width - 75, height: proxy.size.height - 75)
                        VStack {
                            ScrollView {
                                Text(wiki.extract)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }.padding(15)
                        }.frame(width: proxy.size.width - 75, height: proxy.size.height - 110)
                            .padding(50)
                    }.frame(width: proxy.size.width - 50, height: proxy.size.height - 50)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.black.opacity(0.6)))
                        .cornerRadius(25)
                        .padding(25)
                }
            }
        }
    }
}
