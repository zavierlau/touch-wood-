import Foundation
import SwiftUI

// MARK: - Daily Challenge Models

struct DailyChallenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: ChallengeType
    let target: Int
    let reward: ChallengeReward
    let date: Date
    var progress: Int = 0
    var isCompleted: Bool = false
    var completedAt: Date?
    
    enum ChallengeType: String, CaseIterable, Codable {
        case rituals = "rituals"
        case streak = "streak"
        case mood = "mood"
        case variety = "variety"
        case time = "time"
        
        var displayName: String {
            switch self {
            case .rituals: return NSLocalizedString("challenge_type_rituals", comment: "")
            case .streak: return NSLocalizedString("challenge_type_streak", comment: "")
            case .mood: return NSLocalizedString("challenge_type_mood", comment: "")
            case .variety: return NSLocalizedString("challenge_type_variety", comment: "")
            case .time: return NSLocalizedString("challenge_type_time", comment: "")
            }
        }
        
        var iconName: String {
            switch self {
            case .rituals: return "star.circle.fill"
            case .streak: return "flame.circle.fill"
            case .mood: return "heart.circle.fill"
            case .variety: return "shuffle.circle.fill"
            case .time: return "clock.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .rituals: return .blue
            case .streak: return .orange
            case .mood: return .pink
            case .variety: return .purple
            case .time: return .green
            }
        }
    }
    
    struct ChallengeReward: Codable {
        let points: Int
        let badge: String?
        let customRitualUnlock: String?
        
        var description: String {
            var parts: [String] = []
            parts.append(String(format: NSLocalizedString("reward_points", comment: ""), points))
            
            if let badge = badge {
                parts.append(String(format: NSLocalizedString("reward_badge", comment: ""), badge))
            }
            
            if let ritual = customRitualUnlock {
                parts.append(String(format: NSLocalizedString("reward_ritual", comment: ""), ritual))
            }
            
            return parts.joined(separator: " • ")
        }
    }
    
    var progressPercentage: Double {
        return min(Double(progress) / Double(target), 1.0)
    }
    
    var isExpired: Bool {
        let calendar = Calendar.current
        return !calendar.isDate(date, inSameDayAs: Date())
    }
}

// MARK: - Daily Challenge Manager

class DailyChallengeManager: ObservableObject {
    @Published var currentChallenges: [DailyChallenge] = []
    @Published var completedChallenges: [DailyChallenge] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var userRank: LeaderboardEntry?
    
    private let userDefaults = UserDefaults.standard
    private let challengesKey = "dailyChallenges"
    private let completedKey = "completedChallenges"
    private let lastRefreshKey = "lastChallengeRefresh"
    
    private var challengeTemplates: [DailyChallenge] = []
    
    init() {
        setupChallengeTemplates()
        loadChallenges()
        refreshChallengesIfNeeded()
        loadLeaderboard()
    }
    
    // MARK: - Challenge Templates
    
    private func setupChallengeTemplates() {
        challengeTemplates = [
            // Ritual Count Challenges
            DailyChallenge(id: "daily_rituals_3", title: NSLocalizedString("challenge_daily_3_title", comment: ""), description: NSLocalizedString("challenge_daily_3_desc", comment: ""), type: .rituals, target: 3, reward: ChallengeReward(points: 10, badge: nil, customRitualUnlock: nil), date: Date()),
            DailyChallenge(id: "daily_rituals_5", title: NSLocalizedString("challenge_daily_5_title", comment: ""), description: NSLocalizedString("challenge_daily_5_desc", comment: ""), type: .rituals, target: 5, reward: ChallengeReward(points: 25, badge: "Daily Devoted", customRitualUnlock: nil), date: Date()),
            
            // Streak Challenges
            DailyChallenge(id: "maintain_streak", title: NSLocalizedString("challenge_streak_title", comment: ""), description: NSLocalizedString("challenge_streak_desc", comment: ""), type: .streak, target: 1, reward: ChallengeReward(points: 15, badge: "Streak Keeper", customRitualUnlock: nil), date: Date()),
            
            // Mood Challenges
            DailyChallenge(id: "positive_mood", title: NSLocalizedString("challenge_mood_title", comment: ""), description: NSLocalizedString("challenge_mood_desc", comment: ""), type: .mood, target: 4, reward: ChallengeReward(points: 20, badge: "Positive Mind", customRitualUnlock: nil), date: Date()),
            
            // Variety Challenges
            DailyChallenge(id: "ritual_variety", title: NSLocalizedString("challenge_variety_title", comment: ""), description: NSLocalizedString("challenge_variety_desc", comment: ""), type: .variety, target: 2, reward: ChallengeReward(points: 30, badge: "Variety Master", customRitualUnlock: "Lucky Charm"), date: Date()),
            
            // Time-based Challenges
            DailyChallenge(id: "morning_ritual", title: NSLocalizedString("challenge_morning_title", comment: ""), description: NSLocalizedString("challenge_morning_desc", comment: ""), type: .time, target: 1, reward: ChallengeReward(points: 15, badge: "Early Bird", customRitualUnlock: nil), date: Date()),
            DailyChallenge(id: "evening_ritual", title: NSLocalizedString("challenge_evening_title", comment: ""), description: NSLocalizedString("challenge_evening_desc", comment: ""), type: .time, target: 1, reward: ChallengeReward(points: 15, badge: "Night Owl", customRitualUnlock: nil), date: Date())
        ]
    }
    
    // MARK: - Challenge Management
    
    private func refreshChallengesIfNeeded() {
        let lastRefresh = userDefaults.object(forKey: lastRefreshKey) as? Date ?? Date.distantPast
        let calendar = Calendar.current
        
        if !calendar.isDate(lastRefresh, inSameDayAs: Date()) {
            generateNewChallenges()
        }
    }
    
    private func generateNewChallenges() {
        var newChallenges: [DailyChallenge] = []
        let selectedTypes = selectChallengeTypes()
        
        for type in selectedTypes {
            if let template = challengeTemplates.randomElement(where: { $0.type == type }) {
                var newChallenge = template
                newChallenge.id = UUID().uuidString
                newChallenge.date = Date()
                newChallenge.progress = 0
                newChallenge.isCompleted = false
                newChallenge.completedAt = nil
                newChallenges.append(newChallenge)
            }
        }
        
        currentChallenges = newChallenges
        saveChallenges()
        
        // Update last refresh date
        userDefaults.set(Date(), forKey: lastRefreshKey)
    }
    
    private func selectChallengeTypes() -> [DailyChallenge.ChallengeType] {
        let availableTypes: [DailyChallenge.ChallengeType] = [.rituals, .streak, .mood, .variety, .time]
        let count = Int.random(in: 2...3) // 2-3 challenges per day
        return Array(availableTypes.shuffled().prefix(count))
    }
    
    // MARK: - Progress Tracking
    
    func updateProgress(for type: DailyChallenge.ChallengeType, increment: Int = 1) {
        for i in 0..<currentChallenges.count {
            var challenge = currentChallenges[i]
            
            if challenge.type == type && !challenge.isCompleted {
                challenge.progress += increment
                
                if challenge.progress >= challenge.target {
                    challenge.isCompleted = true
                    challenge.completedAt = Date()
                    completeChallenge(challenge)
                }
                
                currentChallenges[i] = challenge
            }
        }
        
        saveChallenges()
    }
    
    func updateMoodProgress(mood: Int) {
        for i in 0..<currentChallenges.count {
            var challenge = currentChallenges[i]
            
            if challenge.type == .mood && !challenge.isCompleted {
                // Check if mood meets or exceeds target
                if mood >= challenge.target {
                    challenge.progress = 1
                    challenge.isCompleted = true
                    challenge.completedAt = Date()
                    completeChallenge(challenge)
                }
                
                currentChallenges[i] = challenge
            }
        }
        
        saveChallenges()
    }
    
    func updateVarietyProgress(ritualIds: Set<UUID>) {
        for i in 0..<currentChallenges.count {
            var challenge = currentChallenges[i]
            
            if challenge.type == .variety && !challenge.isCompleted {
                challenge.progress = ritualIds.count
                
                if challenge.progress >= challenge.target {
                    challenge.isCompleted = true
                    challenge.completedAt = Date()
                    completeChallenge(challenge)
                }
                
                currentChallenges[i] = challenge
            }
        }
        
        saveChallenges()
    }
    
    func updateTimeProgress(ritualTime: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: ritualTime)
        
        for i in 0..<currentChallenges.count {
            var challenge = currentChallenges[i]
            
            if challenge.type == .time && !challenge.isCompleted {
                let isMorning = hour >= 6 && hour < 12
                let isEvening = hour >= 18 && hour < 24
                
                if (challenge.id.contains("morning") && isMorning) || (challenge.id.contains("evening") && isEvening) {
                    challenge.progress = 1
                    challenge.isCompleted = true
                    challenge.completedAt = Date()
                    completeChallenge(challenge)
                }
                
                currentChallenges[i] = challenge
            }
        }
        
        saveChallenges()
    }
    
    private func completeChallenge(_ challenge: DailyChallenge) {
        // Move to completed challenges
        var completedChallenge = challenge
        completedChallenges.append(completedChallenge)
        
        // Remove from current challenges
        currentChallenges.removeAll { $0.id == challenge.id }
        
        // Award rewards
        awardReward(challenge.reward)
        
        // Update leaderboard
        updateLeaderboard(points: challenge.reward.points)
        
        saveChallenges()
        
        // Show completion notification
        showChallengeCompletionNotification(challenge)
    }
    
    private func awardReward(_ reward: DailyChallenge.ChallengeReward) {
        // This would integrate with the achievement system
        print("Awarded reward: \(reward.description)")
    }
    
    private func showChallengeCompletionNotification(_ challenge: DailyChallenge) {
        // This would trigger UI notifications
        print("Challenge completed: \(challenge.title)")
    }
    
    // MARK: - Leaderboard
    
    private func loadLeaderboard() {
        // In a real app, this would fetch from a backend
        // For now, we'll create mock data
        leaderboard = [
            LeaderboardEntry(userId: "user1", username: "RitualMaster", points: 1250, rank: 1, isCurrentUser: false),
            LeaderboardEntry(userId: "user2", username: "LuckyCharm", points: 980, rank: 2, isCurrentUser: false),
            LeaderboardEntry(userId: "user3", username: "WoodKnocker", points: 750, rank: 3, isCurrentUser: false),
            LeaderboardEntry(userId: "current", username: "You", points: 450, rank: 4, isCurrentUser: true)
        ]
        
        userRank = leaderboard.first { $0.isCurrentUser }
    }
    
    private func updateLeaderboard(points: Int) {
        guard var currentUser = userRank else { return }
        
        currentUser.points += points
        
        // Recalculate ranks
        var sortedEntries = leaderboard.sorted { $0.points > $1.points }
        
        for i in 0..<sortedEntries.count {
            sortedEntries[i].rank = i + 1
        }
        
        leaderboard = sortedEntries
        userRank = sortedEntries.first { $0.isCurrentUser }
    }
    
    // MARK: - Data Persistence
    
    private func loadChallenges() {
        if let data = userDefaults.data(forKey: challengesKey),
           let decoded = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            currentChallenges = decoded.filter { !$0.isExpired }
        }
        
        if let data = userDefaults.data(forKey: completedKey),
           let decoded = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            completedChallenges = decoded
        }
    }
    
    private func saveChallenges() {
        if let encoded = try? JSONEncoder().encode(currentChallenges) {
            userDefaults.set(encoded, forKey: challengesKey)
        }
        
        if let encoded = try? JSONEncoder().encode(completedChallenges) {
            userDefaults.set(encoded, forKey: completedKey)
        }
    }
    
    // MARK: - Statistics
    
    var totalCompletedToday: Int {
        return currentChallenges.filter { $0.isCompleted }.count
    }
    
    var totalAvailableToday: Int {
        return currentChallenges.count
    }
    
    var completionRateToday: Double {
        guard totalAvailableToday > 0 else { return 0 }
        return Double(totalCompletedToday) / Double(totalAvailableToday)
    }
}

// MARK: - Leaderboard Model

struct LeaderboardEntry: Identifiable, Codable {
    let id = UUID()
    let userId: String
    let username: String
    var points: Int
    var rank: Int
    let isCurrentUser: Bool
}
