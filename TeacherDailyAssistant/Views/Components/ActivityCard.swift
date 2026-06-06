import SwiftUI

struct ActivityCard: View {
    let activity: Activity
    var onShare: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Text(activity.category.emoji)
                    Text(activity.category.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(activity.category.systemColor.opacity(0.15))
                )
                .foregroundColor(activity.category.systemColor)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: activity.wasSent ? "checkmark.circle.fill" : "paperplane.fill")
                        .font(.caption)
                    Text(activity.wasSent ? "Enviado" : "Pendiente")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundColor(activity.wasSent ? .green : .orange)
            }
            
            if let course = activity.course {
                Text(course.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text(activity.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Divider()
                .padding(.vertical, 2)
            
            HStack {
                Text(activity.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.red)
                }
                
                Button(action: onShare) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Enviar")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.green, .emerald],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

extension Color {
    static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)
}