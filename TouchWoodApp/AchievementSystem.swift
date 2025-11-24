import Foundation
import SwiftUI

// MARK: - Achievement Models

struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let requirement: AchievementRequirement
    let points: Int
    let isHidden: Bool
    
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    enum AchievementCategory: String, CaseIterable, Codable {
        case streak = "streak"
        case rituals = "rituals"
        case mood = "mood"
        case social = "social"
        case special = "special"
        
        var displayName: String {
            switch self {
            case .streak: return NSLocalizedString("achievement_category_streak", comment: "Streak achievements")
            case .rituals: return NSLocalizedString("achievement_category_rituals", comment: "Ritual achievements")
            case .mood: return NSLocalizedString("achievement_category_mood", comment: "Mood achievements")
            case .social: return NSLocalizedString("achievement_category_social", comment: "Social achievements")
            case .special: return NSLocalizedString("achievement_category_special", comment: "Special achievements")
            }
        }
        
        var color: Color {
            switch self {
            case .streak: return .orange
            case .rituals: return .blue
            case .mood: return .green
            case .social: return .purple
            case .special: return .red
            }
        }
    }
    
    enum AchievementRequirement: Codable {
        case streakDays(Int)
        case totalRituals(Int)
        case perfectWeek
        case moodAverage(Double)
        case shareCount(Int)
        case customRituals(Int)
        case consecutiveDays(Int)
        
        var description: String {
            switch self {
            case .streakDays(let days):
                return String(format: NSLocalizedString("achievement_requirement_streak_days", comment: ""), days)
            case .totalRituals(let count):
                return String(format: NSLocalizedString("achievement_requirement_total_rituals", comment: ""), count)
            case .perfectWeek:
                return NSLocalizedString("achievement_requirement_perfect_week", comment: "")
            case .moodAverage(let average):
                return String(format: NSLocalizedString("achievement_requirement_mood_average", comment: ""), average)
            case .shareCount(let count):
                return String(format: NSLocalizedString("achievement_requirement_share_count", comment: ""), count)
            case .customRituals(let count):
                return String(format: NSLocalizedString("achievement_requirement_custom_rituals", comment: ""), count)
            case .consecutiveDays(let days):
                return String(format: NSLocalizedString("achievement_requirement_consecutive_days", comment: ""), days)
            }
        }
    }
}

// MARK: - Achievement Manager

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var totalPoints: Int = 0
    @Published var newlyUnlocked: [Achievement] = []
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievements"
    private let totalPointsKey = "totalPoints"
    
    init() {
        loadAchievements()
        setupDefaultAchievements()
    }
    
    private func setupDefaultAchievements() {
        if achievements.isEmpty {
            achievements = [
                // Streak Achievements
                Achievement(id: "first_streak", name: NSLocalizedString("achievement_first_streak", comment: ""), description: NSLocalizedString("achievement_first_streak_desc", comment: ""), iconName: "flame.fill", category: .streak, requirement: .streakDays(3), points: 10, isHidden: false, isUnlocked: false, unlockedAt: nil),
                Achievement(id: "week_warrior", name: NSLocalizedString("achievement_week_warrior", comment: ""), description: NSLocalizedString("achievement_week_warrior_desc", comment: ""), iconName: "calendar", category: .streak, requirement: .streakDays(7), points: 25, isHidden: false, isUnlocked: false, unlockedAt: nil),
                Achievement(id: "month_master", name: NSLocalizedString("achievement_month_master", comment: ""), description: NSLocalizedString("achievement_month_master_desc", comment: ""), iconName: "calendar.circle.fill", category: .streak, requirement: .streakDays(30), points: 100, isHidden: false, isUnlocked: false, unlockedAt: nil),
                
                // Ritual Achievements
                Achievement(id: "first_ritual", name: NSLocalizedString("achievement_first_ritual", comment: ""), description: NSLocalizedString("achievement_first_ritual_desc", comment: ""), iconName: "star.fill", category: .rituals, requirement: .totalRituals(1), points: 5, isHidden: false, isUnlocked: false, unlockedAt: nil),
                Achievement(id: "ritual_collector", name: NSLocalizedString("achievement_ritual_collector", comment: ""), description: NSLocalizedString("achievement_ritual_collector_desc", comment: ""), iconName: "cube.fill", category: .rituals, requirement: .totalRituals(50), points: 50, isHidden: false, isUnlocked: false, unlockedAt: nil),
                Achievement(id: "ritual_master", name: NSLocalizedString("achievement_ritual_master", comment: ""), description: NSLocalizedString("achievement_ritual_master_desc", comment: ""), iconName: "crown.fill", category: .rituals, requirement: .totalRituals(100), points: 200, isHidden: false, isUnlocked: false, unlockedAt: nil),
                
                // Mood Achievements
                Achievement(id: "positive_thinker", name: NSLocalizedString("achievement_positive_thinker", comment: ""), description: NSLocalizedString("achievement_positive_thinker_desc", comment: ""), iconName: "heart.fill", category: .mood, requirement: .moodAverage(4.0), points: 30, isHidden: false, isUnlocked: false, unlockedAt: nil),
                Achievement(id: "perfect_week", name: NSLocalizedString("achievement_perfect_week", comment: ""), description: NSLocalizedString("achievement_perfect_week_desc", comment: ""), iconName: "sun.max.fill", category: .mood, requirement: .perfectWeek, points: 75, isHidden: false, isUnlocked: false, unlockedAt: nil),
                
                // Social Achievements
                Achievement(id: "social_butterfly", name: NSLocalizedString("achievement_social_butterfly", comment: ""), description: NSLocalizedString("achievement_social_butterfly_desc", comment: ""), iconName: "person.2.fill", category: .social, requirement: .shareCount(5), points: 20, isHidden: false, isUnlocked: false, unlockedAt: nil),
                
                // Special Achievements
                Achievement(id: "early_bird", name: NSLocalizedString("achievement_early_bird", comment: ""), description: NSLocalizedString("achievement_early_bird_desc", comment: ""), iconName: "sunrise.fill", category: .special, requirement: .consecutiveDays(7), points: 40, isHidden: false, isUnlocked: false, unlockedAt: nil),
                Achievement(id: "creator", name: NSLocalizedString("achievement_creator", comment: ""), description: NSLocalizedString("achievement_creator_desc", comment: ""), iconName: "paintbrush.fill", category: .special, requirement: .customRituals(3), points: 60, isHidden: false, isUnlocked: false, unlockedAt: nil)
            ]
            saveAchievements()
        }
    }
    
    func checkAchievements(stats: RitualStats) {
        var newUnlocks: [Achievement] = []
        
        for i in 0..<achievements.count {
            var achievement = achievements[i]
            
            if !achievement.isUnlocked {
                let shouldUnlock = checkRequirement(requirement: achievement.requirement, stats: stats)
                
                if shouldUnlock {
                    achievement.isUnlocked = true
                    achievement.unlockedAt = Date()
                    achievements[i] = achievement
                    
                    newUnlocks.append(achievement)
                    totalPoints += achievement.points
                }
            }
        }
        
        if !newUnlocks.isEmpty {
            newlyUnlocked = newUnlocks
            saveAchievements()
            
            // Show achievement notifications
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showAchievementNotifications(newUnlocks)
            }
        }
    }
    
    private func checkRequirement(requirement: Achievement.AchievementRequirement, stats: RitualStats) -> Bool {
        switch requirement {
        case .streakDays(let days):
            return stats.currentStreak >= days
        case .totalRituals(let count):
            return stats.totalRituals >= count
        case .perfectWeek:
            return stats.hasPerfectWeek
        case .moodAverage(let average):
            return stats.averageMood >= average
        case .shareCount(let count):
            return stats.shareCount >= count
        case .customRituals(let count):
            return stats.customRitualCount >= count
        case .consecutiveDays(let days):
            return stats.consecutiveDays >= days
        }
    }
    
    private func showAchievementNotifications(_ achievements: [Achievement]) {
        // This would trigger UI notifications
        // For now, we'll just update the published property
    }
    
    func clearNewlyUnlocked() {
        newlyUnlocked = []
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
        
        totalPoints = userDefaults.integer(forKey: totalPointsKey)
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: achievementsKey)
        }
        
        userDefaults.set(totalPoints, forKey: totalPointsKey)
    }
}

// MARK: - Ritual Stats Model

struct RitualStats {
    let currentStreak: Int
    let totalRituals: Int
    let averageMood: Double
    let hasPerfectWeek: Bool
    let shareCount: Int
    let customRitualCount: Int
    let consecutiveDays: Int
}
