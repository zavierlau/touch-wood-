import Foundation
import SwiftUI

// MARK: - Core Data entities are auto-generated from .xcdatamodeld

// MARK: - SwiftUI Models

struct RitualModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let isCustom: Bool
    let isFavorite: Bool
    let customImageData: Data?
    let createdAt: Date
    
    // Computed properties
    var hasCustomImage: Bool {
        customImageData != nil
    }
    
    static let touchWood = RitualModel(
        id: UUID(),
        name: NSLocalizedString("knock_on_wood", comment: "Knock on wood ritual name"),
        description: NSLocalizedString("tap_wood_for_good_luck", comment: "Knock on wood description"),
        icon: "tree.fill",
        isCustom: false,
        isFavorite: true,
        customImageData: nil,
        createdAt: Date()
    )
    
    static let crossFingers = RitualModel(
        id: UUID(),
        name: NSLocalizedString("cross_fingers", comment: "Cross fingers ritual name"),
        description: NSLocalizedString("cross_fingers_for_good_fortune", comment: "Cross fingers description"),
        icon: "hand.tap.fill",
        isCustom: false,
        isFavorite: false,
        customImageData: nil,
        createdAt: Date()
    )
    
    static let saltOverShoulder = RitualModel(
        id: UUID(),
        name: NSLocalizedString("salt_over_shoulder", comment: "Salt over shoulder ritual name"),
        description: NSLocalizedString("toss_salt_to_ward_off_bad_luck", comment: "Salt over shoulder description"),
        icon: "drop.fill",
        isCustom: false,
        isFavorite: false,
        customImageData: nil,
        createdAt: Date()
    )
}

struct RitualLogModel: Identifiable {
    let id: UUID
    let ritualId: UUID
    let timestamp: Date
    let note: String?
    let mood: Int? // 1-5 scale
    
    var moodEmoji: String {
        guard let mood = mood else { return "😐" }
        switch mood {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct StreakModel: Identifiable {
    let id: UUID
    let ritualId: UUID
    let currentCount: Int
    let lastPerformedDate: Date
    let bestCount: Int
    
    var daysSinceLastPerform: Int {
        Calendar.current.dateComponents([.day], from: lastPerformedDate, to: Date()).day ?? 0
    }
    
    var isActive: Bool {
        daysSinceLastPerform <= 1 // Allow for same day or next day
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var soundEnabled: Bool
    var hapticStyle: String // "light", "medium", "heavy"
    var dailyReminderTime: Date
    var shareAnonymously: Bool
    var defaultRitualId: UUID?
    
    static let `default` = UserPreferences(
        soundEnabled: true,
        hapticStyle: "medium",
        dailyReminderTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        shareAnonymously: false,
        defaultRitualId: nil
    )
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var todayRitualCount: Int = 0
    @Published var selectedRitual: RitualModel = .touchWood
    @Published var userPreferences: UserPreferences = .default
    @Published var hasCompletedOnboarding: Bool = false
    
    init() {
        loadUserPreferences()
        loadOnboardingStatus()
    }
    
    private func loadUserPreferences() {
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            userPreferences = preferences
        }
    }
    
    func saveUserPreferences() {
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }
    
    private func loadOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        saveUserPreferences()
    }
}

// MARK: - Haptic Feedback Helper

struct HapticFeedback {
    static func trigger(_ style: String) {
        let generator: UIImpactFeedbackGenerator
        
        switch style {
        case "light":
            generator = UIImpactFeedbackGenerator(style: .light)
        case "medium":
            generator = UIImpactFeedbackGenerator(style: .medium)
        case "heavy":
            generator = UIImpactFeedbackGenerator(style: .heavy)
        default:
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
