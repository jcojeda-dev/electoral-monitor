import SwiftUI

struct CustomButton<Content: View>: View {
    let action: () -> Void
    let gradientColors: [Color]
    let content: Content
    
    init(
        colors: [Color] = [.blue, .purple],
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.gradientColors = colors
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                content
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}