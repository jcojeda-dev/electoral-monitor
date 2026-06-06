import Foundation
import SwiftData

@Model
final class Course: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var grade: String
    var section: String
    
    @Relationship(deleteRule: .cascade, inverse: \Activity.course)
    var activities: [Activity] = []
    
    init(id: UUID = UUID(), name: String, grade: String, section: String) {
        self.id = id
        self.name = name
        self.grade = grade
        self.section = section
    }
    
    var displayName: String {
        return "\(grade) \(section) - \(name)"
    }
}