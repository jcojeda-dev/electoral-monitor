import SwiftUI

struct RecordVoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var recordViewModel: RecordViewModel
    let courses: [Course]
    
    @State private var secondsElapsed = 0.0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            if recordViewModel.isShowingEditor {
                ActivityEditorView(recordViewModel: recordViewModel, courses: courses)
            } else {
                recordingStageView
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onDisappear {
            stopTimer()
            recordViewModel.clearData()
        }
    }
    
    private var recordingStageView: some View {
        VStack(spacing: 32) {
            HStack {
                Button("Cancelar") {
                    stopTimer()
                    recordViewModel.clearData()
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.red)
                
                Spacer()
                
                Text("Registrar por Voz")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Cancelar").font(.headline).opacity(0)
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                Text(timeString(time: secondsElapsed))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                Text("Grabando nota de voz...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            WaveformView(isAnimating: recordViewModel.speechRecognizer.isRecording)
                .frame(height: 80)
            
            ScrollView {
                Text(recordViewModel.speechRecognizer.transcript.isEmpty ? "Di algo, tu voz aparecerá aquí..." : recordViewModel.speechRecognizer.transcript)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(recordViewModel.speechRecognizer.transcript.isEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .frame(maxHeight: 180)
            
            Spacer()
            
            Button(action: {
                stopTimer()
                recordViewModel.stopSpeechRecording()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 88, height: 88)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 64, height: 64)
                        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.bottom, 40)
        }
        .onAppear {
            startTimer()
            recordViewModel.startSpeechRecording()
        }
    }
    
    private func startTimer() {
        secondsElapsed = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            secondsElapsed += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let tenths = Int((time - Double(Int(time))) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, tenths)
    }
}

struct WaveformView: View {
    let isAnimating: Bool
    @State private var heights: [CGFloat] = Array(repeating: 12.0, count: 18)
    
    private let waveTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<18, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [.purple, .indigo, .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5, height: heights[idx])
            }
        }
        .onReceive(waveTimer) { _ in
            guard isAnimating else {
                withAnimation {
                    heights = Array(repeating: 12.0, count: 18)
                }
                return
            }
            withAnimation(.easeInOut(duration: 0.1)) {
                heights = (0..<18).map { _ in CGFloat.random(in: 10...75) }
            }
        }
    }
}