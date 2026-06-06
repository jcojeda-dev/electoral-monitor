import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [Activity]
    
    @ObservedObject var authService: AuthService
    @StateObject private var viewModel = SettingsViewModel()
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("CONECTIVIDAD IA (OPENAI)")) {
                    SecureField("API Key de OpenAI", text: $viewModel.openaiKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Text("Ingresa tu clave para habilitar la redacción inteligente con IA. Si está vacía, la app utilizará un procesador simulado offline.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("RECORDATORIOS DIARIOS")) {
                    Toggle("Habilitar Alertas", isOn: $viewModel.isReminderEnabled)
                    
                    if viewModel.isReminderEnabled {
                        DatePicker("Hora de Alerta", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Text("Recibe una alerta diaria si tienes notas registradas en el día que aún no compartiste por WhatsApp.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("SEGURIDAD")) {
                    Toggle("Proteger con Face ID", isOn: $viewModel.isFaceIDEnabled)
                        .disabled(!viewModel.checkBiometricAvailability())
                }
                
                Section(header: Text("DATOS DE ACTIVIDADES")) {
                    if let fileURL = viewModel.generateCSV(activities: activities) {
                        ShareLink(item: fileURL) {
                            HStack {
                                Image(systemName: "doc.zipper")
                                Text("Exportar Historial (CSV)")
                            }
                            .foregroundColor(.purple)
                            .fontWeight(.semibold)
                        }
                    } else {
                        Text("No hay datos para exportar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Borrar Base de Datos", role: .destructive) {
                        isShowingDeleteAlert = true
                    }
                }
                
                Section {
                    Button("Cerrar Sesión") {
                        authService.signOut()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Aceptar") {
                        dismiss()
                    }
                }
            }
            .alert("¿Borrar Base de Datos?", isPresented: $isShowingDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Borrar Todo", role: .destructive) {
                    viewModel.clearAllData(modelContext: modelContext)
                }
            } message: {
                Text("Esta acción es irreversible y eliminará todos tus cursos, secciones y registros de actividades locales.")
            }
        }
    }
}