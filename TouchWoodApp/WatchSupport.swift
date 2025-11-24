import SwiftUI
import ClockKit

// MARK: - Apple Watch App

struct WatchApp: View {
    @StateObject private var watchManager = WatchDataManager()
    @State private var selectedRitual: RitualModel = .touchWood
    @State private var showingRitualDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Quick Actions
                    QuickActionsSection(watchManager: watchManager)
                    
                    // Today's Progress
                    TodayProgressSection(watchManager: watchManager)
                    
                    // Recent Rituals
                    RecentRitualsSection(watchManager: watchManager)
                    
                    // Challenges
                    ChallengesSection(watchManager: watchManager)
                }
                .padding()
            }
            .navigationTitle("Touch Wood")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingRitualDetail) {
            RitualDetailView(ritual: selectedRitual, watchManager: watchManager)
        }
    }
}

struct QuickActionsSection: View {
    @ObservedObject var watchManager: WatchDataManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("quick_actions", comment: "Quick Actions"))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach([RitualModel.touchWood, RitualModel.crossFingers, RitualModel.saltOverShoulder], id: \.id) { ritual in
                    Button(action: {
                        watchManager.completeRitual(ritual)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: ritual.icon)
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text(ritual.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct TodayProgressSection: View {
    @ObservedObject var watchManager: WatchDataManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("today_progress", comment: "Today's Progress"))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack {
                    Text("\(watchManager.todayRitualCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(NSLocalizedString("rituals", comment: "Rituals"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(watchManager.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text(NSLocalizedString("streak", comment: "Streak"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(watchManager.todayChallenges)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(NSLocalizedString("challenges", comment: "Challenges"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct RecentRitualsSection: View {
    @ObservedObject var watchManager: WatchDataManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("recent_rituals", comment: "Recent Rituals"))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(watchManager.recentRituals.prefix(3), id: \.id) { ritual in
                HStack {
                    Image(systemName: ritual.icon)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ritual.name)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text(formatTime(ritual.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let mood = ritual.mood {
                        Text(moodEmojiForValue(mood))
                            .font(.title2)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func moodEmojiForValue(_ value: Int) -> String {
        switch value {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
}

struct ChallengesSection: View {
    @ObservedObject var watchManager: WatchDataManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("daily_challenges", comment: "Daily Challenges"))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(watchManager.todayChallenges.prefix(2), id: \.id) { challenge in
                HStack {
                    Image(systemName: challenge.type.iconName)
                        .foregroundColor(challenge.type.color)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.title)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("\(challenge.progress)/\(challenge.target)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CircularProgressView(progress: challenge.progressPercentage)
                        .frame(width: 20, height: 20)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct RitualDetailView: View {
    let ritual: RitualModel
    @ObservedObject var watchManager: WatchDataManager
    @State private var selectedMood: Int = 3
    @State private var note: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Ritual Icon and Name
                    VStack(spacing: 12) {
                        Image(systemName: ritual.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(ritual.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(ritual.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Mood Selection
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("how_feel", comment: "How do you feel?"))
                            .font(.headline)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                }) {
                                    Text(moodEmojiForValue(mood))
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(selectedMood == mood ? Color.blue : Color(.systemGray6))
                                        .cornerRadius(20)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Note
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("add_note", comment: "Add Note (Optional)"))
                            .font(.headline)
                        
                        TextField(NSLocalizedString("note_placeholder", comment: "Note..."), text: $note)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Complete Button
                    Button(action: {
                        watchManager.completeRitual(ritual, mood: selectedMood, note: note.isEmpty ? nil : note)
                        dismiss()
                    }) {
                        Text(NSLocalizedString("complete_ritual", comment: "Complete Ritual"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("complete_ritual", comment: "Complete Ritual"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func moodEmojiForValue(_ value: Int) -> String {
        switch value {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray6), lineWidth: 2)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

// MARK: - Watch Data Manager

class WatchDataManager: ObservableObject {
    @Published var todayRitualCount: Int = 0
    @Published var currentStreak: Int = 0
    @Published var todayChallenges: [DailyChallenge] = []
    @Published var recentRituals: [RitualLogModel] = []
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadData()
    }
    
    func completeRitual(_ ritual: RitualModel, mood: Int? = nil, note: String? = nil) {
        let ritualLog = RitualLogModel(
            id: UUID(),
            ritualId: ritual.id,
            timestamp: Date(),
            note: note,
            mood: mood
        )
        
        // Add to recent rituals
        recentRituals.insert(ritualLog, at: 0)
        if recentRituals.count > 10 {
            recentRituals.removeLast()
        }
        
        // Update today's count
        todayRitualCount += 1
        
        // Trigger haptic feedback
        WKInterfaceDevice.current().play(.click)
        
        // Save data
        saveData()
        
        // Notify phone app
        syncWithPhone()
    }
    
    private func loadData() {
        todayRitualCount = userDefaults.integer(forKey: "watchTodayRitualCount")
        currentStreak = userDefaults.integer(forKey: "watchCurrentStreak")
        
        if let data = userDefaults.data(forKey: "watchRecentRituals"),
           let decoded = try? JSONDecoder().decode([RitualLogModel].self, from: data) {
            recentRituals = decoded
        }
        
        // Load challenges (simplified for watch)
        loadChallenges()
    }
    
    private func loadChallenges() {
        // Mock challenges for watch
        todayChallenges = [
            DailyChallenge(
                id: "watch_rituals_3",
                title: NSLocalizedString("challenge_complete_3", comment: "Complete 3 Rituals"),
                description: "",
                type: .rituals,
                target: 3,
                reward: DailyChallenge.ChallengeReward(points: 10, badge: nil, customRitualUnlock: nil),
                date: Date(),
                progress: todayRitualCount,
                isCompleted: todayRitualCount >= 3,
                completedAt: todayRitualCount >= 3 ? Date() : nil
            )
        ]
    }
    
    private func saveData() {
        userDefaults.set(todayRitualCount, forKey: "watchTodayRitualCount")
        userDefaults.set(currentStreak, forKey: "watchCurrentStreak")
        
        if let encoded = try? JSONEncoder().encode(recentRituals) {
            userDefaults.set(encoded, forKey: "watchRecentRituals")
        }
    }
    
    private func syncWithPhone() {
        // In a real app, this would use WatchConnectivity to sync with phone
        print("Syncing with phone app...")
    }
}

// MARK: - Widget Support

struct TouchWoodWidget: Widget {
    let kind: String = "TouchWoodWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TouchWoodProvider()) { entry in
            TouchWoodWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("widget_name", comment: "Touch Wood"))
        .description(NSLocalizedString("widget_description", comment: "Track your daily rituals and streaks"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TouchWoodProvider: TimelineProvider {
    func placeholder(in context: Context) -> TouchWoodEntry {
        TouchWoodEntry(date: Date(), todayRituals: 2, currentStreak: 7, nextRitual: .touchWood)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TouchWoodEntry) -> ()) {
        let entry = TouchWoodEntry(date: Date(), todayRituals: 2, currentStreak: 7, nextRitual: .touchWood)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.TouchWoodApp")
        let todayRituals = userDefaults?.integer(forKey: "widgetTodayRituals") ?? 0
        let currentStreak = userDefaults?.integer(forKey: "widgetCurrentStreak") ?? 0
        
        let entry = TouchWoodEntry(
            date: Date(),
            todayRituals: todayRituals,
            currentStreak: currentStreak,
            nextRitual: .touchWood
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct TouchWoodEntry: TimelineEntry {
    let date: Date
    let todayRituals: Int
    let currentStreak: Int
    let nextRitual: RitualModel
}

struct TouchWoodWidgetEntryView: View {
    var entry: TouchWoodProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        @unknown default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: TouchWoodProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // App Icon
            Image(systemName: "tree.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            // Streak
            VStack(spacing: 2) {
                Text("\(entry.currentStreak)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(NSLocalizedString("day_streak", comment: "Day Streak"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Today's Progress
            VStack(spacing: 2) {
                Text("\(entry.todayRituals)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(NSLocalizedString("today", comment: "Today"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .containerBackground(Color(.systemBackground), for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: TouchWoodProvider.Entry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Streak and Progress
            VStack(spacing: 12) {
                // App Title
                HStack {
                    Image(systemName: "tree.fill")
                        .foregroundColor(.blue)
                    
                    Text("Touch Wood")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Streak
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text(NSLocalizedString("current_streak", comment: "Current Streak"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Today's Progress
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.todayRituals)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(NSLocalizedString("rituals_today", comment: "Rituals Today"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Right side - Quick Action
            VStack(spacing: 12) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: entry.nextRitual.icon)
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text(entry.nextRitual.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text(NSLocalizedString("tap_to_complete", comment: "Tap to complete"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .containerBackground(Color(.systemBackground), for: .widget)
    }
}

struct LargeWidgetView: View {
    let entry: TouchWoodProvider.Entry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "tree.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Touch Wood")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats Grid
            HStack(spacing: 16) {
                // Streak
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("\(entry.currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("day_streak", comment: "Day Streak"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Today's Rituals
                VStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("\(entry.todayRituals)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("rituals_today", comment: "Rituals Today"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Next Ritual
                VStack(spacing: 8) {
                    Image(systemName: entry.nextRitual.icon)
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text(NSLocalizedString("next", comment: "Next"))
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(entry.nextRitual.name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Recent Activity (Mock)
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("recent_activity", comment: "Recent Activity"))
                    .font(.headline)
                
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 8, height: 8)
                    
                    Text("Completed Knock on Wood")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("2h ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 8, height: 8)
                    
                    Text("Unlocked Week Warrior")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("5h ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .containerBackground(Color(.systemBackground), for: .widget)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Widget Bundle

@main
struct TouchWoodWidgetBundle: WidgetBundle {
    var body: some Widget {
        TouchWoodWidget()
    }
}

// MARK: - Complication Support (for Watch faces)

struct TouchWoodComplication: ClockKit.Complication {
    static let complicationIdentifier = "TouchWoodComplication"
    
    func getComplicationTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate {
        switch family {
        case .circularSmall:
            return createCircularSmallTemplate()
        case .modularSmall:
            return createModularSmallTemplate()
        case .modularLarge:
            return createModularLargeTemplate()
        case .utilitarianSmall:
            return createUtilitarianSmallTemplate()
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate()
        default:
            return createModularSmallTemplate()
        }
    }
    
    private func createCircularSmallTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateCircularSmallSimpleImage()
        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "tree.fill")!)
        return template
    }
    
    private func createModularSmallTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularSmallSimpleImage()
        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "tree.fill")!)
        return template
    }
    
    private func createModularLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerImageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "tree.fill")!)
        template.headerTextProvider = CLKSimpleTextProvider(text: "Touch Wood")
        template.body1TextProvider = CLKSimpleTextProvider(text: "7 Day Streak")
        template.body2TextProvider = CLKSimpleTextProvider(text: "2 Rituals Today")
        return template
    }
    
    private func createUtilitarianSmallTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "tree.fill")!)
        template.textProvider = CLKSimpleTextProvider(text: "7 🔥")
        return template
    }
    
    private func createUtilitarianLargeTemplate() -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "tree.fill")!)
        template.textProvider = CLKSimpleTextProvider(text: "Touch Wood: 7 Day Streak, 2 Rituals Today")
        return template
    }
}
