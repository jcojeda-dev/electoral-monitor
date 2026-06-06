import SwiftUI
import SwiftData

struct CourseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Course.grade) private var courses: [Course]
    
    @StateObject private var viewModel = CourseViewModel()
    @State private var isShowingAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    if courses.isEmpty {
                        emptyCoursesPlaceholder
                    } else {
                        List {
                            ForEach(courses) { course in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(course.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        Text("\(course.grade) - Sección \(course.section)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text("\(course.activities.count) notas")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.purple.opacity(0.1))
                                            .cornerRadius(6)
                                            .foregroundColor(.purple)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteCourse)
                        }
                    }
                }
            }
            .navigationTitle("Mis Cursos / Aulas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isShowingAddSheet.toggle() }) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                addCourseSheet
            }
        }
    }
    
    private var emptyCoursesPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 56))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No tienes cursos creados")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Agrega tus salones de clase para poder clasificar las notas diarias de voz.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { isShowingAddSheet.toggle() }) {
                Text("Crear Primer Curso")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
    }
    
    private var addCourseSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información del Aula")) {
                    TextField("Nombre del Curso (ej. Matemática)", text: $viewModel.newCourseName)
                    TextField("Grado (ej. Primero de Primaria)", text: $viewModel.newCourseGrade)
                    TextField("Sección (ej. A)", text: $viewModel.newCourseSection)
                }
                
                Section {
                    Button("Guardar Aula") {
                        viewModel.addCourse(modelContext: modelContext)
                        isShowingAddSheet = false
                    }
                    .disabled(!viewModel.isValid)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(viewModel.isValid ? .purple : .secondary)
                    .fontWeight(.bold)
                }
            }
            .navigationTitle("Agregar Curso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        viewModel.clearFields()
                        isShowingAddSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func deleteCourse(at offsets: IndexSet) {
        for index in offsets {
            let course = courses[index]
            viewModel.deleteCourse(course, modelContext: modelContext)
        }
    }
}