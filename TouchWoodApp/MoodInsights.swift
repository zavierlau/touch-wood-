import SwiftUI
import Charts

// MARK: - Mood Analytics Models

struct MoodAnalytics: Identifiable {
    let id = UUID()
    let date: Date
    let mood: Int
    let ritualId: UUID
    let ritualName: String
    let note: String?
    let timeOfDay: TimeOfDay
    
    enum TimeOfDay: String, CaseIterable {
        case morning = "morning"
        case afternoon = "afternoon"
        case evening = "evening"
        case night = "night"
        
        var displayName: String {
            switch self {
            case .morning: return NSLocalizedString("time_morning", comment: "Morning")
            case .afternoon: return NSLocalizedString("time_afternoon", comment: "Afternoon")
            case .evening: return NSLocalizedString("time_evening", comment: "Evening")
            case .night: return NSLocalizedString("time_night", comment: "Night")
            }
        }
        
        var iconName: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .afternoon: return "sun.max.fill"
            case .evening: return "sunset.fill"
            case .night: return "moon.fill"
            }
        }
        
        var hourRange: ClosedRange<Int> {
            switch self {
            case .morning: return 5...11
            case .afternoon: return 12...17
            case .evening: return 18...21
            case .night: return 22...4
            }
        }
    }
    
    static func getTimeOfDay(from date: Date) -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: date)
        
        for timeOfDay in TimeOfDay.allCases {
            if timeOfDay.hourRange.contains(hour) {
                return timeOfDay
            }
        }
        
        return .morning
    }
}

// MARK: - Mood Insights Manager

class MoodInsightsManager: ObservableObject {
    @Published var moodData: [MoodAnalytics] = []
    @Published var weeklyMoodTrend: [MoodDataPoint] = []
    @Published var monthlyMoodTrend: [MoodDataPoint] = []
    @Published var ritualMoodCorrelation: [RitualMoodData] = []
    @Published var timeOfDayMoodData: [TimeMoodData] = []
    @Published var moodStreaks: [MoodStreak] = []
    @Published var insights: [MoodInsight] = []
    
    private let userDefaults = UserDefaults.standard
    private let moodDataKey = "moodAnalytics"
    
    struct MoodDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let averageMood: Double
        let count: Int
    }
    
    struct RitualMoodData: Identifiable {
        let id = UUID()
        let ritualName: String
        let averageMood: Double
        let count: Int
        let trend: MoodTrend
    }
    
    enum MoodTrend {
        case improving
        case declining
        case stable
        
        var displayName: String {
            switch self {
            case .improving: return NSLocalizedString("trend_improving", comment: "Improving")
            case .declining: return NSLocalizedString("trend_declining", comment: "Declining")
            case .stable: return NSLocalizedString("trend_stable", comment: "Stable")
            }
        }
        
        var color: Color {
            switch self {
            case .improving: return .green
            case .declining: return .red
            case .stable: return .gray
            }
        }
        
        var iconName: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .declining: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
    }
    
    struct TimeMoodData: Identifiable {
        let id = UUID()
        let timeOfDay: MoodAnalytics.TimeOfDay
        let averageMood: Double
        let count: Int
    }
    
    struct MoodStreak: Identifiable {
        let id = UUID()
        let startDate: Date
        let endDate: Date
        let duration: Int
        let averageMood: Double
        let type: StreakType
        
        enum StreakType {
            case positive
            case neutral
            case improving
            
            var displayName: String {
                switch self {
                case .positive: return NSLocalizedString("streak_positive", comment: "Positive")
                case .neutral: return NSLocalizedString("streak_neutral", comment: "Neutral")
                case .improving: return NSLocalizedString("streak_improving", comment: "Improving")
                }
            }
            
            var color: Color {
                switch self {
                case .positive: return .green
                case .neutral: return .yellow
                case .improving: return .blue
                }
            }
        }
    }
    
    struct MoodInsight: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let type: InsightType
        let actionable: Bool
        let priority: InsightPriority
        
        enum InsightType {
            case pattern
            case recommendation
            case achievement
            case warning
            
            var iconName: String {
                switch self {
                case .pattern: return "brain.head.profile"
                case .recommendation: return "lightbulb.fill"
                case .achievement: return "trophy.fill"
                case .warning: return "exclamationmark.triangle.fill"
                }
            }
            
            var color: Color {
                switch self {
                case .pattern: return .blue
                case .recommendation: return .green
                case .achievement: return .yellow
                case .warning: return .red
                }
            }
        }
        
        enum InsightPriority {
            case high
            case medium
            case low
            
            var displayName: String {
                switch self {
                case .high: return NSLocalizedString("priority_high", comment: "High")
                case .medium: return NSLocalizedString("priority_medium", comment: "Medium")
                case .low: return NSLocalizedString("priority_low", comment: "Low")
                }
            }
        }
    }
    
    init() {
        loadMoodData()
        generateMockDataIfNeeded()
        analyzeMoodData()
    }
    
    // MARK: - Data Management
    
    func addMoodData(_ ritualId: UUID, ritualName: String, mood: Int, note: String?, date: Date = Date()) {
        let analytics = MoodAnalytics(
            date: date,
            mood: mood,
            ritualId: ritualId,
            ritualName: ritualName,
            note: note,
            timeOfDay: MoodAnalytics.getTimeOfDay(from: date)
        )
        
        moodData.append(analytics)
        saveMoodData()
        analyzeMoodData()
    }
    
    private func generateMockDataIfNeeded() {
        if moodData.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            
            for i in -30...0 {
                if let date = calendar.date(byAdding: .day, value: i, to: today) {
                    let moodCount = Int.random(in: 1...4)
                    
                    for _ in 0..<moodCount {
                        let hour = Int.random(in: 6...22)
                        let ritualDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) ?? date
                        
                        let rituals = ["Knock on Wood", "Cross Fingers", "Salt Over Shoulder"]
                        let ritualName = rituals.randomElement() ?? "Knock on Wood"
                        
                        let mood = Int.random(in: 2...5)
                        let note = mood > 4 ? "Feeling great!" : (mood < 3 ? "A bit down" : nil)
                        
                        let analytics = MoodAnalytics(
                            date: ritualDate,
                            mood: mood,
                            ritualId: UUID(),
                            ritualName: ritualName,
                            note: note,
                            timeOfDay: MoodAnalytics.getTimeOfDay(from: ritualDate)
                        )
                        
                        moodData.append(analytics)
                    }
                }
            }
            
            saveMoodData()
        }
    }
    
    // MARK: - Analytics
    
    private func analyzeMoodData() {
        calculateWeeklyTrend()
        calculateMonthlyTrend()
        calculateRitualCorrelation()
        calculateTimeOfDayAnalysis()
        calculateMoodStreaks()
        generateInsights()
    }
    
    private func calculateWeeklyTrend() {
        let calendar = Calendar.current
        let today = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        var weeklyData: [Date: [Int]] = [:]
        
        for data in moodData {
            if data.date >= sevenDaysAgo {
                let day = calendar.startOfDay(for: data.date)
                weeklyData[day, default: []].append(data.mood)
            }
        }
        
        weeklyMoodTrend = weeklyData.map { date, moods in
            let average = Double(moods.reduce(0, +)) / Double(moods.count)
            return MoodDataPoint(date: date, averageMood: average, count: moods.count)
        }.sorted { $0.date < $1.date }
    }
    
    private func calculateMonthlyTrend() {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        var monthlyData: [Date: [Int]] = [:]
        
        for data in moodData {
            if data.date >= thirtyDaysAgo {
                let day = calendar.startOfDay(for: data.date)
                monthlyData[day, default: []].append(data.mood)
            }
        }
        
        monthlyMoodTrend = monthlyData.map { date, moods in
            let average = Double(moods.reduce(0, +)) / Double(moods.count)
            return MoodDataPoint(date: date, averageMood: average, count: moods.count)
        }.sorted { $0.date < $1.date }
    }
    
    private func calculateRitualCorrelation() {
        let groupedData = Dictionary(grouping: moodData) { $0.ritualName }
        
        ritualMoodCorrelation = groupedData.map { ritualName, data in
            let moods = data.map { $0.mood }
            let average = Double(moods.reduce(0, +)) / Double(moods.count)
            
            let trend = calculateTrend(from: moods)
            
            return RitualMoodData(
                ritualName: ritualName,
                averageMood: average,
                count: data.count,
                trend: trend
            )
        }.sorted { $0.averageMood > $1.averageMood }
    }
    
    private func calculateTrend(from moods: [Int]) -> MoodTrend {
        guard moods.count >= 3 else { return .stable }
        
        let firstHalf = moods.prefix(moods.count / 2)
        let secondHalf = moods.suffix(moods.count / 2)
        
        let firstAverage = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
        let secondAverage = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
        
        let difference = secondAverage - firstAverage
        
        if difference > 0.3 {
            return .improving
        } else if difference < -0.3 {
            return .declining
        } else {
            return .stable
        }
    }
    
    private func calculateTimeOfDayAnalysis() {
        let groupedData = Dictionary(grouping: moodData) { $0.timeOfDay }
        
        timeOfDayMoodData = groupedData.map { timeOfDay, data in
            let moods = data.map { $0.mood }
            let average = Double(moods.reduce(0, +)) / Double(moods.count)
            
            return TimeMoodData(
                timeOfDay: timeOfDay,
                averageMood: average,
                count: data.count
            )
        }.sorted { $0.averageMood > $1.averageMood }
    }
    
    private func calculateMoodStreaks() {
        let sortedData = moodData.sorted { $0.date < $1.date }
        var streaks: [MoodStreak] = []
        var currentStreak: [MoodAnalytics] = []
        
        for data in sortedData {
            if currentStreak.isEmpty {
                currentStreak.append(data)
            } else {
                let calendar = Calendar.current
                let lastDate = currentStreak.last!.date
                let daysDifference = calendar.dateComponents([.day], from: lastDate, to: data.date).day ?? 0
                
                if daysDifference <= 1 {
                    currentStreak.append(data)
                } else {
                    if currentStreak.count >= 3 {
                        let streak = createStreak(from: currentStreak)
                        streaks.append(streak)
                    }
                    currentStreak = [data]
                }
            }
        }
        
        if currentStreak.count >= 3 {
            let streak = createStreak(from: currentStreak)
            streaks.append(streak)
        }
        
        moodStreaks = streaks.sorted { $0.duration > $1.duration }
    }
    
    private func createStreak(from data: [MoodAnalytics]) -> MoodStreak {
        let moods = data.map { $0.mood }
        let averageMood = Double(moods.reduce(0, +)) / Double(moods.count)
        
        let type: MoodStreak.StreakType
        if averageMood >= 4.0 {
            type = .positive
        } else if averageMood >= 3.0 {
            type = .neutral
        } else {
            type = .improving
        }
        
        return MoodStreak(
            startDate: data.first!.date,
            endDate: data.last!.date,
            duration: data.count,
            averageMood: averageMood,
            type: type
        )
    }
    
    private func generateInsights() {
        var newInsights: [MoodInsight] = []
        
        // Best time of day
        if let bestTime = timeOfDayMoodData.first {
            let insight = MoodInsight(
                title: NSLocalizedString("insight_best_time_title", comment: "Best Time"),
                description: String(format: NSLocalizedString("insight_best_time_desc", comment: ""), bestTime.timeOfDay.displayName),
                type: .pattern,
                actionable: true,
                priority: .medium
            )
            newInsights.append(insight)
        }
        
        // Most effective ritual
        if let bestRitual = ritualMoodCorrelation.first {
            let insight = MoodInsight(
                title: NSLocalizedString("insight_best_ritual_title", comment: "Best Ritual"),
                description: String(format: NSLocalizedString("insight_best_ritual_desc", comment: ""), bestRitual.ritualName),
                type: .recommendation,
                actionable: true,
                priority: .high
            )
            newInsights.append(insight)
        }
        
        // Mood trend
        if let recent = weeklyMoodTrend.suffix(7), recent.count >= 2 {
            let recentAverage = recent.reduce(0.0) { $0 + $1.averageMood } / Double(recent.count)
            
            if recentAverage >= 4.0 {
                let insight = MoodInsight(
                    title: NSLocalizedString("insight_positive_trend_title", comment: "Positive Trend"),
                    description: NSLocalizedString("insight_positive_trend_desc", comment: ""),
                    type: .achievement,
                    actionable: false,
                    priority: .low
                )
                newInsights.append(insight)
            } else if recentAverage <= 2.5 {
                let insight = MoodInsight(
                    title: NSLocalizedString("insight_concern_title", comment: "Concern"),
                    description: NSLocalizedString("insight_concern_desc", comment: ""),
                    type: .warning,
                    actionable: true,
                    priority: .high
                )
                newInsights.append(insight)
            }
        }
        
        insights = newInsights.sorted { $0.priority == .high && $1.priority != .high }
    }
    
    // MARK: - Statistics
    
    var averageMood: Double {
        guard !moodData.isEmpty else { return 0 }
        return Double(moodData.map { $0.mood }.reduce(0, +)) / Double(moodData.count)
    }
    
    var moodImprovementRate: Double {
        guard moodData.count >= 10 else { return 0 }
        
        let recent = moodData.suffix(10).map { $0.mood }
        let earlier = moodData.prefix(10).map { $0.mood }
        
        let recentAverage = Double(recent.reduce(0, +)) / Double(recent.count)
        let earlierAverage = Double(earlier.reduce(0, +)) / Double(earlier.count)
        
        return recentAverage - earlierAverage
    }
    
    var mostProductiveTime: MoodAnalytics.TimeOfDay? {
        return timeOfDayMoodData.first?.timeOfDay
    }
    
    var totalEntries: Int {
        return moodData.count
    }
    
    // MARK: - Data Persistence
    
    private func loadMoodData() {
        if let data = userDefaults.data(forKey: moodDataKey),
           let decoded = try? JSONDecoder().decode([MoodAnalytics].self, from: data) {
            moodData = decoded
        }
    }
    
    private func saveMoodData() {
        if let encoded = try? JSONEncoder().encode(moodData) {
            userDefaults.set(encoded, forKey: moodDataKey)
        }
    }
}

// MARK: - Mood Insights Views

struct MoodInsightsView: View {
    @StateObject private var insightsManager = MoodInsightsManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Overview
                MoodOverviewView()
                    .environmentObject(insightsManager)
                    .tabItem {
                        Label(NSLocalizedString("insights_overview", comment: "Overview"), systemImage: "chart.bar.fill")
                    }
                    .tag(0)
                
                // Trends
                MoodTrendsView()
                    .environmentObject(insightsManager)
                    .tabItem {
                        Label(NSLocalizedString("insights_trends", comment: "Trends"), systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(1)
                
                // Patterns
                MoodPatternsView()
                    .environmentObject(insightsManager)
                    .tabItem {
                        Label(NSLocalizedString("insights_patterns", comment: "Patterns"), systemImage: "brain.head.profile")
                    }
                    .tag(2)
                
                // Insights
                MoodRecommendationsView()
                    .environmentObject(insightsManager)
                    .tabItem {
                        Label(NSLocalizedString("insights_recommendations", comment: "Insights"), systemImage: "lightbulb.fill")
                    }
                    .tag(3)
            }
            .navigationTitle(NSLocalizedString("mood_insights_title", comment: "Mood Insights"))
        }
    }
}

struct MoodOverviewView: View {
    @EnvironmentObject var insightsManager: MoodInsightsManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Average Mood Card
                OverviewCard(
                    title: NSLocalizedString("average_mood", comment: "Average Mood"),
                    value: String(format: "%.1f", insightsManager.averageMood),
                    subtitle: moodEmojiForValue(Int(insightsManager.averageMood)),
                    color: .blue,
                    icon: "heart.fill"
                )
                
                // Total Entries
                OverviewCard(
                    title: NSLocalizedString("total_entries", comment: "Total Entries"),
                    value: "\(insightsManager.totalEntries)",
                    subtitle: NSLocalizedString("entries_recorded", comment: "Entries recorded"),
                    color: .green,
                    icon: "book.fill"
                )
                
                // Improvement Rate
                OverviewCard(
                    title: NSLocalizedString("improvement_rate", comment: "Improvement Rate"),
                    value: String(format: "%+.1f", insightsManager.moodImprovementRate),
                    subtitle: NSLocalizedString("points_change", comment: "Points change"),
                    color: insightsManager.moodImprovementRate >= 0 ? .green : .red,
                    icon: insightsManager.moodImprovementRate >= 0 ? "arrow.up.right" : "arrow.down.right"
                )
                
                // Best Time
                if let bestTime = insightsManager.mostProductiveTime {
                    OverviewCard(
                        title: NSLocalizedString("best_time", comment: "Best Time"),
                        value: bestTime.displayName,
                        subtitle: NSLocalizedString("most_productive", comment: "Most productive"),
                        color: .purple,
                        icon: bestTime.iconName
                    )
                }
            }
            .padding()
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

struct OverviewCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MoodTrendsView: View {
    @EnvironmentObject var insightsManager: MoodInsightsManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weekly Trend Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("weekly_trend", comment: "Weekly Trend"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(insightsManager.weeklyMoodTrend) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date, unit: .day),
                            y: .value("Mood", dataPoint.averageMood)
                        )
                        .foregroundStyle(.blue)
                        .symbol(.circle)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Monthly Trend Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("monthly_trend", comment: "Monthly Trend"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(insightsManager.monthlyMoodTrend) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date, unit: .day),
                            y: .value("Mood", dataPoint.averageMood)
                        )
                        .foregroundStyle(.green)
                        .symbol(.square)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct MoodPatternsView: View {
    @EnvironmentObject var insightsManager: MoodInsightsManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Ritual Performance
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("ritual_performance", comment: "Ritual Performance"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(insightsManager.ritualMoodCorrelation) { data in
                        HStack {
                            Text(data.ritualName)
                                .font(.body)
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: data.trend.iconName)
                                    .foregroundColor(data.trend.color)
                                
                                Text(String(format: "%.1f", data.averageMood))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Time of Day Analysis
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("time_analysis", comment: "Time of Day Analysis"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(insightsManager.timeOfDayMoodData) { data in
                        BarMark(
                            x: .value("Time", data.timeOfDay.displayName),
                            y: .value("Mood", data.averageMood)
                        )
                        .foregroundStyle(by: .value("Time", data.timeOfDay.displayName))
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct MoodRecommendationsView: View {
    @EnvironmentObject var insightsManager: MoodInsightsManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(insightsManager.insights) { insight in
                    InsightCard(insight: insight)
                }
            }
            .padding()
        }
    }
}

struct InsightCard: View {
    let insight: MoodInsightsManager.MoodInsight
    
    var body: some View {
        HStack {
            Image(systemName: insight.type.iconName)
                .font(.title2)
                .foregroundColor(insight.type.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(insight.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            if insight.actionable {
                Button(action: {
                    // Handle action
                }) {
                    Text(NSLocalizedString("action", comment: "Action"))
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
