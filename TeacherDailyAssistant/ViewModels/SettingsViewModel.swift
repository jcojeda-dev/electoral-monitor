import Foundation
import SwiftUI
import LocalAuthentication
import SwiftData

final class SettingsViewModel: ObservableObject {
    @Published var openaiKey: String = "" {
        didSet {
            UserDefaults.standard.set(openaiKey, forKey: "openai_api_key")
        }
    }
    
    @Published var isReminderEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isReminderEnabled, forKey: "is_reminder_enabled")
            toggleReminders()
        }
    }
    @Published var reminderTime: Date = Date() {
        didSet {
            UserDefaults.standard.set(reminderTime.timeIntervalSince1970, forKey: "reminder_time")
            if isReminderEnabled {
                NotificationManager.shared.scheduleDailyReminder(at: reminderTime)
            }
        }
    }
    
    @Published var isFaceIDEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isFaceIDEnabled, forKey: "is_faceid_enabled")
        }
    }
    
    private let context = LAContext()
    
    init() {
        self.openaiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        self.isReminderEnabled = UserDefaults.standard.bool(forKey: "is_reminder_enabled")
        
        let savedTime = UserDefaults.standard.double(forKey: "reminder_time")
        if savedTime > 0 {
            self.reminderTime = Date(timeIntervalSince1970: savedTime)
        } else {
            var components = DateComponents()
            components.hour = 17
            components.minute = 0
            self.reminderTime = Calendar.current.date(from: components) ?? Date()
        }
        
        self.isFaceIDEnabled = UserDefaults.standard.bool(forKey: "is_faceid_enabled")
    }
    
    func checkBiometricAvailability() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateUser(completion: @escaping (Bool) -> Void) {
        guard isFaceIDEnabled && checkBiometricAvailability() else {
            completion(true)
            return
        }
        
        let reason = "Inicia sesión de forma segura para proteger tus datos escolares."
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    private func toggleReminders() {
        if isReminderEnabled {
            NotificationManager.shared.requestPermissions { [weak self] granted in
                if granted {
                    guard let self = self else { return }
                    NotificationManager.shared.scheduleDailyReminder(at: self.reminderTime)
                } else {
                    DispatchQueue.main.async {
                        self?.isReminderEnabled = false
                    }
                }
            }
        } else {
            NotificationManager.shared.cancelAllReminders()
        }
    }
    
    func generateCSV(activities: [Activity]) -> URL? {
        var csvString = "ID;Fecha;Curso;Grado;Seccion;Categoria;Contenido;FueEnviado;FechaEnvio\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for activity in activities {
            let id = activity.id.uuidString
            let dateStr = formatter.string(from: activity.date)
            let courseName = activity.course?.name ?? "Sin Curso"
            let grade = activity.course?.grade ?? ""
            let section = activity.course?.section ?? ""
            let category = activity.categoryRaw
            
            let contentCleaned = activity.content
                .replacingOccurrences(of: "\"", with: "\"\"")
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: ";", with: ",")
            
            let wasSent = activity.wasSent ? "SI" : "NO"
            let sentDateStr = activity.sentDate != nil ? formatter.string(from: activity.sentDate!) : ""
            
            csvString += "\"\(id)\";\"\(dateStr)\";\"\(courseName)\";\"\(grade)\";\"\(section)\";\"\(category)\";\"\(contentCleaned)\";\"\(wasSent)\";\"\(sentDateStr)\"\n"
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("Reporte_Actividades_\(Int(Date().timeIntervalSince1970)).csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV file: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Activity.self)
            try modelContext.delete(model: Course.self)
            try modelContext.save()
            print("Successfully purged database")
        } catch {
            print("Failed to delete database: \(error.localizedDescription)")
        }
    }
}