import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.permissionStatus = granted ? .authorized : .denied
                completion(granted)
            }
        }
    }
    
    func scheduleDailyReminder(at date: Date) {
        cancelAllReminders()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let content = UNMutableNotificationContent()
        content.title = "📝 Teacher Daily Assistant"
        content.body = "Tienes actividades pendientes por comunicar a los padres. ¡Haz clic para enviarlas!"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_unsent_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local reminder: \(error.localizedDescription)")
            } else {
                print("Daily local reminder scheduled successfully at \(components.hour ?? 17):\(components.minute ?? 0)")
            }
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}