import Foundation
import SwiftData

final class CourseViewModel: ObservableObject {
    @Published var newCourseName: String = ""
    @Published var newCourseGrade: String = ""
    @Published var newCourseSection: String = ""
    
    var isValid: Bool {
        !newCourseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !newCourseGrade.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !newCourseSection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func addCourse(modelContext: ModelContext) {
        guard isValid else { return }
        
        let course = Course(
            name: newCourseName.trimmingCharacters(in: .whitespacesAndNewlines),
            grade: newCourseGrade.trimmingCharacters(in: .whitespacesAndNewlines),
            section: newCourseSection.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        modelContext.insert(course)
        
        do {
            try modelContext.save()
            clearFields()
        } catch {
            print("Failed to save course: \(error.localizedDescription)")
        }
    }
    
    func seedSampleCourses(modelContext: ModelContext, existingCount: Int) {
        guard existingCount == 0 else { return }
        
        let samples = [
            Course(name: "Matemáticas y Psicomotricidad", grade: "Inicial 3 años", section: "A"),
            Course(name: "Lenguaje y Dibujo", grade: "Inicial 4 años", section: "B"),
            Course(name: "Comunicación y Ciencia", grade: "Primero de Primaria", section: "A"),
            Course(name: "Álgebra y Física", grade: "Quinto de Secundaria", section: "C")
        ]
        
        for sample in samples {
            modelContext.insert(sample)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to seed sample courses: \(error.localizedDescription)")
        }
    }
    
    func deleteCourse(_ course: Course, modelContext: ModelContext) {
        modelContext.delete(course)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete course: \(error.localizedDescription)")
        }
    }
    
    func clearFields() {
        newCourseName = ""
        newCourseGrade = ""
        newCourseSection = ""
    }
}