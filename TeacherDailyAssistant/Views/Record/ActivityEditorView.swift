import SwiftUI
import SwiftData

struct ActivityEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var recordViewModel: RecordViewModel
    let courses: [Course]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("CLASIFICACIÓN")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Curso / Aula")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Picker("Selecciona Curso", selection: $recordViewModel.selectedCourse) {
                                Text("Sin curso asignado").tag(nil as Course?)
                                ForEach(courses) { course in
                                    Text(course.displayName).tag(course as Course?)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Categoría")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Picker("Selecciona Categoría", selection: $recordViewModel.selectedCategory) {
                                ForEach(ActivityCategory.allCases) { category in
                                    Text("\(category.emoji) \(category.rawValue)").tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TEXTO TRANSCRIBIERTO")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $recordViewModel.transcriptText)
                            .frame(minHeight: 100)
                            .padding(10)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                    }
                    .padding(20)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("REDACTOR INTELIGENTE IA")
                                .font(.caption)
                                .fontWeight(.black)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                Text("OpenAI")
                            }
                            .font(.caption2)
                            .fontWeight(.black)
                            .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tono del Mensaje")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Picker("Tono", selection: $recordViewModel.selectedTone) {
                                ForEach(recordViewModel.availableTones, id: \.self) { tone in
                                    Text(tone).tag(tone)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Button(action: {
                            recordViewModel.applyAIRewrite()
                        }) {
                            HStack {
                                if recordViewModel.isRewriting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Mejorar redacción con IA")
                                }
                            }
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                        }
                        .disabled(recordViewModel.isRewriting || recordViewModel.transcriptText.isEmpty)
                        
                        if !recordViewModel.aiRewrittenText.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Resultado Sugerido (Editable)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                
                                TextEditor(text: $recordViewModel.aiRewrittenText)
                                    .frame(minHeight: 120)
                                    .padding(10)
                                    .background(Color.purple.opacity(0.04))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        
                        if let error = recordViewModel.rewriteError {
                            Text("Error de redacción: \(error). Se usará el borrador local.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(20)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(20)
                    
                    CustomButton(colors: [.purple, .indigo]) {
                        recordViewModel.saveActivity(modelContext: modelContext)
                        dismiss()
                    } content: {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Guardar Actividad")
                    }
                    .disabled(recordViewModel.transcriptText.isEmpty)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Detalles de la Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Atrás") {
                        recordViewModel.isShowingEditor = false
                    }
                }
            }
        }
    }
}