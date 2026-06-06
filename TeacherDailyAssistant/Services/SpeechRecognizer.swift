import Foundation
import Speech
import AVFoundation
import SwiftUI

final class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var permissionGranted: Bool = false
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    
    private var timer: Timer?
    private let mockPhrases = [
        "Hoy avanzamos sumas con llevadas de dos cifras en matemáticas. ",
        "Como actividad adicional resolvimos la página 24 del libro de texto. ",
        "Dejamos de tarea la página 25 para el lunes, favor de revisarlo con los niños. ",
        "Además, recuerden traer cartulinas de colores para la clase de arte del martes. ",
        "Todos los alumnos se portaron excelente hoy. ¡Feliz fin de semana!"
    ]
    private var mockPhraseIndex = 0
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.permissionGranted = true
                default:
                    self?.permissionGranted = false
                }
            }
        }
    }
    
    func startRecording() {
        self.transcript = ""
        self.isRecording = true
        
        #if targetEnvironment(simulator)
        startMockRecording()
        #else
        if permissionGranted {
            do {
                try startAudioEngineRecording()
            } catch {
                print("Failed to start audio engine speech recognition: \(error.localizedDescription)")
                startMockRecording()
            }
        } else {
            startMockRecording()
        }
        #endif
    }
    
    func stopRecording() {
        isRecording = false
        
        #if targetEnvironment(simulator)
        stopMockRecording()
        #else
        stopAudioEngineRecording()
        stopMockRecording()
        #endif
    }
    
    private func startAudioEngineRecording() throws {
        audioEngine = AVAudioEngine()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let audioEngine = audioEngine, let recognitionRequest = recognitionRequest else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopAudioEngineRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func stopAudioEngineRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    private func startMockRecording() {
        mockPhraseIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.mockPhraseIndex < self.mockPhrases.count {
                withAnimation {
                    self.transcript += self.mockPhrases[self.mockPhraseIndex]
                }
                self.mockPhraseIndex += 1
            } else {
                self.stopRecording()
            }
        }
    }
    
    private func stopMockRecording() {
        timer?.invalidate()
        timer = nil
    }
}