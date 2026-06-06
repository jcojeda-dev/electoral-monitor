import SwiftUI

struct DailySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let activities: [Activity]
    let courses: [Course]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 16) {
                        Text(Date(), style: .date)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("Resumen de Actividades")
                            .font(.title2)
                            .fontWeight(.black)
                        
                        HStack(spacing: 12) {
                            metricBox(title: "Registradas", value: "\(todayActivities.count)", color: .blue)
                            metricBox(title: "Enviadas", value: "\(todayActivities.filter { $0.wasSent }.count)", color: .green)
                            metricBox(title: "Pendientes", value: "\(todayActivities.filter { !$0.wasSent }.count)", color: .orange)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(24)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ENVIAR RESUMEN POR CURSO")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        if courses.isEmpty {
                            Text("No hay cursos creados para resumir.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(courses) { course in
                                let courseActs = todayActivities.filter { $0.course?.id == course.id }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(course.displayName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("\(courseActs.count) hoy")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.secondary.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                    
                                    if !courseActs.isEmpty {
                                        VStack(alignment: .leading, spacing: 6) {
                                            ForEach(courseActs.prefix(3)) { act in
                                                HStack(alignment: .top, spacing: 6) {
                                                    Text(act.category.emoji)
                                                    Text(act.content)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            if courseActs.count > 3 {
                                                Text("+ \(courseActs.count - 3) más...")
                                                    .font(.caption2)
                                                    .foregroundColor(.purple)
                                                    .padding(.leading, 24)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                        
                                        Button(action: {
                                            shareCourseDigest(course: course, activities: courseActs)
                                        }) {
                                            HStack {
                                                Image(systemName: "square.and.arrow.up")
                                                Text("Enviar Compilado Diario")
                                                    .fontWeight(.bold)
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(Color.green)
                                            .cornerRadius(10)
                                        }
                                    } else {
                                        Text("Sin actividades registradas hoy.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .italic()
                                    }
                                }
                                .padding(16)
                                .background(Color(uiColor: .systemBackground))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Resumen Diario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var todayActivities: [Activity] {
        let calendar = Calendar.current
        return activities.filter { calendar.isDateInToday($0.date) }
    }
    
    private func metricBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(16)
    }
    
    private func shareCourseDigest(course: Course, activities: [Activity]) {
        let message = WhatsAppSharer.shared.formatDailyDigest(course: course, activities: activities)
        WhatsAppSharer.shared.share(message: message)
        
        for activity in activities {
            activity.wasSent = true
            activity.sentDate = Date()
        }
    }
}