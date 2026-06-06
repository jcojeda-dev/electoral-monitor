import Foundation
import Combine

protocol AuthServiceProtocol: ObservableObject {
    var isAuthenticated: Bool { get set }
    var userDisplayName: String { get set }
    var userEmail: String { get set }
    
    func signInWithApple()
    func signInWithGoogle()
    func signOut()
}

final class AuthService: AuthServiceProtocol, ObservableObject {
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "is_authenticated")
        }
    }
    
    @Published var userDisplayName: String {
        didSet {
            UserDefaults.standard.set(userDisplayName, forKey: "user_display_name")
        }
    }
    
    @Published var userEmail: String {
        didSet {
            UserDefaults.standard.set(userEmail, forKey: "user_email")
        }
    }
    
    init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "is_authenticated")
        self.userDisplayName = UserDefaults.standard.string(forKey: "user_display_name") ?? "Profe Camila"
        self.userEmail = UserDefaults.standard.string(forKey: "user_email") ?? "camila.torres@colegio.edu"
    }
    
    func signInWithApple() {
        self.userDisplayName = "Profe Camila (Apple)"
        self.userEmail = "camila.torres@icloud.com"
        self.isAuthenticated = true
    }
    
    func signInWithGoogle() {
        self.userDisplayName = "Profe Camila (Google)"
        self.userEmail = "camila.torres.teacher@gmail.com"
        self.isAuthenticated = true
    }
    
    func signOut() {
        self.isAuthenticated = false
        self.userDisplayName = ""
        self.userEmail = ""
    }
}