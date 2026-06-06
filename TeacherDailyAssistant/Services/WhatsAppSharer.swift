import Foundation
import UIKit

final class WhatsAppSharer {
    static let shared = WhatsAppSharer()
    
    private init() {}
    
    func canOpenWhatsApp() -> Bool {
        guard let url = URL(string: "whatsapp://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func share(message: String) {
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let urlStrings = [
            "whatsapp://send?text=\(encodedMessage)",
            "https://api.whatsapp.com/send?text=\(encodedMessage)"
        ]
        
        for urlString in urlStrings {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
            }
        }
        
        if let fallbackURL = URL(string: "https://api.whatsapp.com/send?text=\(encodedMessage)") {
            UIApplication.shared.open(fallbackURL, options: [:], completionHandler: nil)
        }
    }
    
    func formatDailyDigest(course: Course, activities: [Activity]) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es")
        let todayStr = formatter.string(from: Date())
        
        var message = """
        *TEACHER DAILY ASSISTANT*
        🏫 *Curso:* \(course.displayName)
        📅 *Fecha:* \(todayStr)
        
        Estimados padres de familia, les compartimos el resumen de la jornada de hoy:
        
        """
        
        let categories = ActivityCategory.allCases
        var hasContent = false
        
        for category in categories {
            let filtered = activities.filter { $0.categoryRaw == category.rawValue }
            if !filtered.isEmpty {
                hasContent = true
                message += "\n*\(category.emoji) \(category.rawValue.uppercased()):*\n"
                for act in filtered {
                    message += "• \(act.content)\n"
                }
            }
        }
        
        if !hasContent {
            message += "\nNo se registraron actividades para el día de hoy."
        }
        
        message += """
        
        Muchísimas gracias por su continuo apoyo en el aprendizaje de los alumnos.
        
        Saludos cordiales,
        \(UserDefaults.standard.string(forKey: "user_display_name") ?? "Docente")
        """
        
        return message
    }
}