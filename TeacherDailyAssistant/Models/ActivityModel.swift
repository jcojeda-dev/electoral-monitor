import Foundation
import SwiftData
import SwiftUI

enum ActivityCategory: String, CaseIterable, Codable, Identifiable {
    case dailyActivity = "Actividades del día"
    case homework = "Tareas"
    case announcement = "Comunicados"
    case materials = "Materiales"
    case incidence = "Incidencias"
    case reminder = "Recordatorios"
    
    var id: String { self.rawValue }
    
    var emoji: String {
        switch self {
        case .dailyActivity: return "🎨"
        case .homework: return "📝"
        case .announcement: return "📢"
        case .materials: return "🎒"
        case .incidence: return "⚠️"
        case .reminder: return "⏰"
        }
    }
    
    var colorName: String {
        switch self {
        case .dailyActivity: return "blue"
        case .homework: return "orange"
        case .announcement: return "red"
        case .materials: return "purple"
        case .incidence: return "yellow"
        case .reminder: return "teal"
        }
    }
    
    var systemColor: Color {
        switch self {
        case .dailyActivity: return .blue
        case .homework: return .orange
        case .announcement: return .red
        case .materials: return .purple
        case .incidence: return .yellow
        case .reminder: return .teal
        }
    }
}

@Model
final class Activity: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var categoryRaw: String
    var content: String
    var wasSent: Bool
    var sentDate: Date?
    
    var course: Course?
    
    init(id: UUID = UUID(), date: Date = Date(), category: ActivityCategory, content: String, wasSent: Bool = false, sentDate: Date? = nil, course: Course? = nil) {
        self.id = id
        self.date = date
        self.categoryRaw = category.rawValue
        self.content = content
        self.wasSent = wasSent
        self.sentDate = sentDate
        self.course = course
    }
    
    var category: ActivityCategory {
        get {
            ActivityCategory(rawValue: categoryRaw) ?? .dailyActivity
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }
}