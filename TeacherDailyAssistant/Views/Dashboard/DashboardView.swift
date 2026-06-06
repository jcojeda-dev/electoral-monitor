import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Activity.date, order: .reverse) private var activities: [Activity]
    @Query(sort: \Course.grade) private var courses: [Course]
    
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var recordViewModel = RecordViewModel()
    @StateObject private var courseViewModel = CourseViewModel()
    
    @State private var isShowingSettings = false
    @State private var isShowingCourses = false
    @State private var isShowingSummary = false
    @State private var isRecordingSheetPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            statsSection
                            filtersSection
                            activitiesSection
                        }
                        .padding(.vertical, 16)
                    }
                }
                
                floatingMicButton
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { isShowingCourses.toggle() }) {
                        Image(systemName: "book.pages")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { isShowingSummary.toggle() }) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .foregroundColor(.primary)
                        }
                        Button(action: { isShowingSettings.toggle() }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(authService: viewModel.authService)
            }
            .sheet(isPresented: $isShowingCourses) {
                CourseListView()
            }
            .sheet(isPresented: $isShowingSummary) {
                DailySummaryView(activities: activities, courses: courses)
            }
            .sheet(isPresented: $isRecordingSheetPresented) {
                RecordVoiceView(recordViewModel: recordViewModel, courses: courses)
            }
            .onAppear {
                courseViewModel.seedSampleCourses(modelContext: modelContext, existingCount: courses.count)
                
                if recordViewModel.selectedCourse == nil, let firstCourse = courses.first {
                    recordViewModel.selectedCourse = firstCourse
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("¡Hola, \(viewModel.authService.userDisplayName)!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .tracking(-0.3)
                    
                    Text("Teacher Daily Assistant")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                Spacer()
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(Color.green.opacity(0.4), lineWidth: 4))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            Divider()
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private var statsSection: some View {
        let stats = viewModel.getStats(for: activities)
        
        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RESUMEN DE HOY")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundColor(.secondary)
                    Text(Date(), style: .date)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
                
                Text("\(Int(stats.progress * 100))%")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.green)
            }
            
            ProgressView(value: stats.progress)
                .tint(.green)
                .background(Color.green.opacity(0.1))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .cornerRadius(4)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("\(stats.registered)")
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                    Text("Registradas")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("\(stats.sent)")
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(.green)
                    Text("Enviadas")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("\(stats.pending)")
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(.orange)
                    Text("Pendientes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation { viewModel.selectedCourse = nil }
                    }) {
                        Text("Todos")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedCourse == nil ? Color.purple : Color(uiColor: .systemBackground))
                            .foregroundColor(viewModel.selectedCourse == nil ? .white : .primary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    }
                    
                    ForEach(courses) { course in
                        Button(action: {
                            withAnimation { viewModel.selectedCourse = course }
                        }) {
                            Text("\(course.grade) \(course.section)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedCourse?.id == course.id ? Color.purple : Color(uiColor: .systemBackground))
                                .foregroundColor(viewModel.selectedCourse?.id == course.id ? .white : .primary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation { viewModel.selectedCategoryFilter = nil }
                    }) {
                        Text("Todas Categorías")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedCategoryFilter == nil ? Color.blue : Color(uiColor: .systemBackground))
                            .foregroundColor(viewModel.selectedCategoryFilter == nil ? .white : .primary)
                            .cornerRadius(8)
                    }
                    
                    ForEach(ActivityCategory.allCases) { category in
                        Button(action: {
                            withAnimation { viewModel.selectedCategoryFilter = category }
                        }) {
                            HStack(spacing: 4) {
                                Text(category.emoji)
                                Text(category.rawValue)
                            }
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedCategoryFilter == category ? Color.blue : Color(uiColor: .systemBackground))
                            .foregroundColor(viewModel.selectedCategoryFilter == category ? .white : .primary)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var activitiesSection: some View {
        let filtered = viewModel.filterActivities(activities)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVIDADES REGISTRADAS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            if filtered.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No hay actividades para el día de hoy.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filtered) { activity in
                        ActivityCard(
                            activity: activity,
                            onShare: {
                                shareActivityToWhatsApp(activity)
                            },
                            onDelete: {
                                deleteActivity(activity)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var floatingMicButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isRecordingSheetPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .padding(24)
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
    
    private func deleteActivity(_ activity: Activity) {
        modelContext.delete(activity)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete activity: \(error.localizedDescription)")
        }
    }
    
    private func shareActivityToWhatsApp(_ activity: Activity) {
        let prefix = "Estimados padres de familia, les compartimos el siguiente reporte:\n\n"
        let suffix = "\n\nMuchas gracias por su atención.\nDocente: \(viewModel.authService.userDisplayName)"
        
        let message = "\(prefix)*[\(activity.category.rawValue.uppercased())]*\n\(activity.content)\(suffix)"
        WhatsAppSharer.shared.share(message: message)
        
        activity.wasSent = true
        activity.sentDate = Date()
        try? modelContext.save()
    }
}