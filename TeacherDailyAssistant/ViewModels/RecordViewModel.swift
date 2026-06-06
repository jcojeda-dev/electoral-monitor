import Foundation
import SwiftUI
import SwiftData

final class RecordViewModel: ObservableObject {
    @Published var transcriptText: String = ""
    @Published var aiRewrittenText: String = ""
    @Published var selectedCourse: Course?
    @Published var selectedCategory: ActivityCategory = .dailyActivity
    @Published var selectedTone: String = "Cercano"
    @Published var isRewriting: Bool = false
    @Published var rewriteError: String? = nil
    @Published var isShowingEditor: Bool = false
    
    var speechRecognizer = SpeechRecognizer()
    private let openAIService = OpenAIService.shared
    
    let availableTones = ["Cercano", "Formal", "Breve", "Institucional"]
    
    func startSpeechRecording() {
        speechRecognizer.startRecording()
    }
    
    func stopSpeechRecording() {
        speechRecognizer.stopRecording()
        self.transcriptText = speechRecognizer.transcript
        self.isShowingEditor = true
    }
    
    func applyAIRewrite() {
        guard !transcriptText.isEmpty else { return }
        
        isRewriting = true
        rewriteError = nil
        
        openAIService.rewriteActivity(
            content: transcriptText,
            tone: selectedTone,
            category: selectedCategory.rawValue
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isRewriting = false
                switch result {
                case .success(let text):
                    self.aiRewrittenText = text
                case .failure(let error):
                    self.rewriteError = error.localizedDescription
                    self.aiRewrittenText = self.transcriptText
                }
            }
        }
    }
    
    func saveActivity(modelContext: ModelContext) {
        let contentToSave = aiRewrittenText.isEmpty ? transcriptText : aiRewrittenText
        
        let newActivity = Activity(
            category: selectedCategory,
            content: contentToSave,
            course: selectedCourse
        )
        
        modelContext.insert(newActivity)
        
        do {
            try modelContext.save()
            clearData()
        } catch {
            print("Failed to save activity: \(error.localizedDescription)")
        }
    }
    
    func clearData() {
        transcriptText = ""
        aiRewrittenText = ""
        selectedCategory = .dailyActivity
        selectedTone = "Cercano"
        rewriteError = nil
        isShowingEditor = false
        speechRecognizer.transcript = ""
    }
}