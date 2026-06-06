import SwiftUI

struct LoginView: View {
    @ObservedObject var authService: AuthService
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            RadialGradient(
                colors: [.purple.opacity(0.12), .clear],
                center: animateGlow ? .topLeading : .bottomTrailing,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: true)) {
                    animateGlow.toggle()
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                            .shadow(color: .purple.opacity(0.3), radius: 15, x: 0, y: 10)
                        
                        Image(systemName: "mic.badge.checkmark")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    
                    Text("Teacher Daily")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .tracking(-0.5)
                    
                    Text("Assistant")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .offset(y: -10)
                    
                    Text("Registra actividades con voz, redacta profesionalmente con IA y notifica por WhatsApp en segundos.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            authService.signInWithApple()
                        }
                    }) {
                        HStack {
                            Image(systemName: "apple.logo")
                                .font(.title3)
                            Text("Continuar con Apple")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primary)
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .cornerRadius(14)
                        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    
                    Button(action: {
                        withAnimation {
                            authService.signInWithGoogle()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                            Text("Continuar con Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                Text("Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
        }
    }
}