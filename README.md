# 📚 Teacher Daily Assistant

A comprehensive iOS and web application designed to empower teachers with intelligent, voice-first note management and WhatsApp integration for parent communication.

## 🎯 Overview

**Teacher Daily Assistant** transforms classroom observations into professional parent communications instantly. Teachers record voice notes about daily classroom activities, the app processes them with AI, and shares polished messages via WhatsApp—all in seconds.

### MVP Scope (Phase 1)
- ✅ Local-first architecture with SwiftData (iOS 17+)
- ✅ Real-time speech-to-text transcription
- ✅ AI-powered text refinement (OpenAI GPT-4o-mini)
- ✅ WhatsApp integration via URL schemes
- ✅ Daily activity tracking and reminders
- ✅ Biometric security (Face ID/Touch ID)
- ✅ Course/classroom management
- ✅ CSV export for record-keeping

## 📁 Project Structure

```
.
├── Documentation/          # Product requirements, user stories, architecture
├── TeacherDailyAssistant/  # iOS app (SwiftUI + SwiftData)
│   ├── App/                # Entry point and app initialization
│   ├── Models/             # Course, Activity data models
│   ├── Services/           # Auth, Speech, OpenAI, Notifications, WhatsApp
│   ├── ViewModels/         # Dashboard, Record, Settings, Course logic
│   ├── Views/              # SwiftUI components (Auth, Dashboard, Record, etc.)
│   └── Resources/          # Info.plist configuration
├── webapp/                 # React + Vite web version
│   ├── src/
│   │   ├── App.jsx         # Main React component
│   │   ├── hooks/          # useGeminiAI, useAudioRecording, useReminders
│   │   └── *.css           # Styles
│   ├── package.json        # Dependencies
│   └── vite.config.js      # Build configuration
└── Simulation/             # HTML demo dashboard
```

## 🚀 Quick Start

### iOS App
1. Open `TeacherDailyAssistant.xcodeproj` in Xcode
2. Configure signing & team in Build Settings
3. Run on simulator or device (iOS 17+)

### Web App
```bash
cd webapp
npm install
VITE_GEMINI_API_KEY="your-key" npm run dev
```

## 🔧 Configuration

### Environment Variables (Web)
Create `.env.local` in `/webapp`:
```
VITE_GEMINI_API_KEY=your_google_generative_ai_key
```

### iOS OpenAI Setup
In Settings view, paste your OpenAI API key to enable advanced AI features.

## 📱 Key Features

### 1. Voice Recording
- Real-time speech-to-text with Apple Speech framework
- Supports Spanish language by default
- Mock phrases in simulator for testing

### 2. AI Text Refinement
- Three tone options: Professional, Friendly, Informative
- OpenAI GPT-4o-mini for iOS
- Google Gemini 2.0-flash for web
- Offline fallback templates when API unavailable

### 3. Activity Management
- 8 activity categories (Daily, Behavior, Assessment, etc.)
- Course filtering and daily summaries
- Status tracking (pending, sent)

### 4. WhatsApp Integration
- One-tap sharing with pre-formatted messages
- Bulk digest sending per course
- Message templating with teacher name

### 5. Reminders & Notifications
- Configurable daily reminder times
- Push notifications for pending items
- localStorage persistence (web)

## 🏗️ Architecture

### iOS (SwiftUI + SwiftData)
- **@Model decorator** for local data persistence
- **MVVM pattern** with Observable objects
- **Async/await** for API calls
- **Biometric auth** via LocalAuthentication

### Web (React + Vite)
- **Custom hooks** for feature isolation
- **localStorage** for client-side persistence
- **PWA-ready** with service worker
- **Responsive design** for mobile/tablet/desktop

## 🔐 Security & Privacy

- ✅ Face ID/Touch ID optional protection
- ✅ No cloud sync in MVP (local data only)
- ✅ API keys stored securely
- ✅ COPPA/FERPA compliant design
- ✅ Child data never stored or shared

## 📊 Data Models

### Course
```swift
@Model final class Course {
    var id: UUID
    var name: String
    var grade: String        // "Primero de Primaria"
    var section: String      // "A"
    @Relationship(deleteRule: .cascade) var activities: [Activity] = []
}
```

### Activity
```swift
@Model final class Activity {
    var id: UUID
    var date: Date
    var category: ActivityCategory
    var content: String
    var course: Course?
    var wasSent: Bool = false
    var sentDate: Date?
}
```

## 🎯 Roadmap (Future Phases)

**Phase 2** (Cloud & Sync)
- Firebase authentication
- Cloud sync across devices
- Parent account linking

**Phase 3** (Analytics & Insights)
- Dashboard analytics
- Progress tracking
- AI-powered recommendations

**Phase 4** (Monetization)
- Premium features
- B2B school subscriptions
- Admin dashboards

## 📝 File Structure Reference

| File | Purpose |
|------|----------|
| `TeacherDailyAssistant/App/TeacherDailyAssistantApp.swift` | App entry, SwiftData container setup |
| `TeacherDailyAssistant/Services/OpenAIService.swift` | API integration + offline simulator |
| `TeacherDailyAssistant/Services/SpeechRecognizer.swift` | Voice recording with fallback |
| `webapp/src/hooks/useGeminiAI.js` | Gemini API integration |
| `webapp/src/App.jsx` | Main React component with state |

## 🤝 Contributing

This project is designed for the Teacher Daily Assistant MVP. All code follows:
- Swift naming conventions (camelCase, Types PascalCase)
- React hooks best practices
- MVVM pattern for testability

## 📄 License

Proprietary - All rights reserved

## 📞 Support

For issues or questions:
1. Check Documentation folder for detailed specs
2. Review Architecture guide for technical decisions
3. Test with mock data in simulator before debugging

---

**Made with ❤️ for teachers everywhere** 🍎