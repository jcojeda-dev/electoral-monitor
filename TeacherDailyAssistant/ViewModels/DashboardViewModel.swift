import Foundation
import SwiftUI
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var selectedCourse: Course?
    @Published var selectedCategoryFilter: ActivityCategory?
    
    var authService = AuthService()
    
    func getStats(for activities: [Activity]) -> (registered: Int, sent: Int, pending: Int, progress: Double) {
        let calendar = Calendar.current
        let todayActivities = activities.filter { calendar.isDateInToday($0.date) }
        
        let registered = todayActivities.count
        let sent = todayActivities.filter { $0.wasSent }.count
        let pending = registered - sent
        let progress = registered > 0 ? Double(sent) / Double(registered) : 0.0
        
        return (registered, sent, pending, progress)
    }
    
    func filterActivities(_ activities: [Activity], forDate date: Date = Date()) -> [Activity] {
        let calendar = Calendar.current
        return activities.filter { activity in
            guard calendar.isDate(activity.date, inSameDayAs: date) else { return false }
            
            if let selectedCourse = selectedCourse, activity.course?.id != selectedCourse.id {
                return false
            }
            
            if let filterCat = selectedCategoryFilter, activity.category != filterCat {
                return false
            }
            
            return true
        }
    }
}