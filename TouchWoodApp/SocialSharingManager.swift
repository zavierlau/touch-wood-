import SwiftUI
import UIKit

// MARK: - Social Sharing Manager

class SocialSharingManager: ObservableObject {
    static let shared = SocialSharingManager()
    
    @Published var shareCount: Int = 0
    @Published var lastSharedDate: Date?
    
    private let userDefaults = UserDefaults.standard
    private let shareCountKey = "shareCount"
    private let lastSharedDateKey = "lastSharedDate"
    
    private init() {
        loadShareData()
    }
    
    // MARK: - Achievement Sharing
    
    func shareAchievement(_ achievement: Achievement, stats: RitualStats) {
        let shareText = generateAchievementShareText(achievement, stats: stats)
        let shareImage = generateAchievementImage(achievement, stats: stats)
        
        shareContent(text: shareText, image: shareImage) { [weak self] success in
            if success {
                self?.incrementShareCount()
                self?.trackShare(type: .achievement, itemId: achievement.id)
            }
        }
    }
    
    // MARK: - Streak Sharing
    
    func shareStreak(_ streak: Int, days: Int) {
        let shareText = generateStreakShareText(streak, days: days)
        let shareImage = generateStreakImage(streak, days: days)
        
        shareContent(text: shareText, image: shareImage) { [weak self] success in
            if success {
                self?.incrementShareCount()
                self?.trackShare(type: .streak)
            }
        }
    }
    
    // MARK: - Ritual Completion Sharing
    
    func shareRitualCompletion(_ ritual: RitualModel, mood: Int?, note: String?) {
        let shareText = generateRitualShareText(ritual, mood: mood, note: note)
        let shareImage = generateRitualImage(ritual, mood: mood)
        
        shareContent(text: shareText, image: shareImage) { [weak self] success in
            if success {
                self?.incrementShareCount()
                self?.trackShare(type: .ritual, itemId: ritual.id.uuidString)
            }
        }
    }
    
    // MARK: - Challenge Sharing
    
    func shareChallengeCompletion(_ challenge: DailyChallenge) {
        let shareText = generateChallengeShareText(challenge)
        let shareImage = generateChallengeImage(challenge)
        
        shareContent(text: shareText, image: shareImage) { [weak self] success in
            if success {
                self?.incrementShareCount()
                self?.trackShare(type: .challenge, itemId: challenge.id)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func shareContent(text: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            completion(false)
            return
        }
        
        var items: [Any] = [text]
        
        if let image = image {
            items.append(image)
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        window.rootViewController?.present(activityViewController, animated: true) {
            // Track if share was initiated
            completion(true)
        }
    }
    
    // MARK: - Share Text Generation
    
    private func generateAchievementShareText(_ achievement: Achievement, stats: RitualStats) -> String {
        let appName = NSLocalizedString("app_name", comment: "Touch Wood")
        let streakText = NSLocalizedString("share_achievement_streak", comment: "Streak info")
        let pointsText = NSLocalizedString("share_achievement_points", comment: "Points info")
        
        return String(format: NSLocalizedString("share_achievement_format", comment: "Achievement share format"),
                     appName, achievement.name, achievement.description,
                     String(format: streakText, stats.currentStreak),
                     String(format: pointsText, achievement.points))
    }
    
    private func generateStreakShareText(_ streak: Int, days: Int) -> String {
        let appName = NSLocalizedString("app_name", comment: "Touch Wood")
        return String(format: NSLocalizedString("share_streak_format", comment: "Streak share format"),
                     appName, streak, days)
    }
    
    private func generateRitualShareText(_ ritual: RitualModel, mood: Int?, note: String?) -> String {
        let appName = NSLocalizedString("app_name", comment: "Touch Wood")
        let moodEmoji = mood != nil ? moodEmojiForValue(mood!) : ""
        let noteText = note?.isEmpty == false ? "\n\n\(note!)" : ""
        
        return String(format: NSLocalizedString("share_ritual_format", comment: "Ritual share format"),
                     appName, ritual.name, moodEmoji, noteText)
    }
    
    private func generateChallengeShareText(_ challenge: DailyChallenge) -> String {
        let appName = NSLocalizedString("app_name", comment: "Touch Wood")
        return String(format: NSLocalizedString("share_challenge_format", comment: "Challenge share format"),
                     appName, challenge.title, challenge.progress, challenge.target)
    }
    
    // MARK: - Image Generation
    
    private func generateAchievementImage(_ achievement: Achievement, stats: RitualStats) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600))
        
        return renderer.image { context in
            // Background gradient
            let gradient = LinearGradientGradient(colors: [achievement.category.color.opacity(0.8), achievement.category.color.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing)
            
            // Draw background
            UIColor.systemBackground.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 600))
            
            // Draw achievement icon
            let iconSize: CGFloat = 120
            let iconRect = CGRect(x: (400 - iconSize) / 2, y: 80, width: iconSize, height: iconSize)
            
            UIColor.systemBlue.setFill()
            context.fill(CGPath(roundedRect: iconRect, cornerWidth: 30, cornerHeight: 30, transform: nil))
            
            // Draw achievement name
            let titleRect = CGRect(x: 20, y: 240, width: 360, height: 80)
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.alignment = .center
            
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28),
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.paragraphStyle: titleStyle
            ]
            
            achievement.name.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Draw achievement description
            let descRect = CGRect(x: 20, y: 330, width: 360, height: 60)
            let descAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel,
                NSAttributedString.Key.paragraphStyle: titleStyle
            ]
            
            achievement.description.draw(in: descRect, withAttributes: descAttributes)
            
            // Draw stats
            let statsRect = CGRect(x: 20, y: 420, width: 360, height: 80)
            let statsText = "🔥 \(stats.currentStreak) Day Streak\n⭐ \(achievement.points) Points"
            let statsAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                NSAttributedString.Key.paragraphStyle: titleStyle
            ]
            
            statsText.draw(in: statsRect, withAttributes: statsAttributes)
            
            // Draw app branding
            let brandRect = CGRect(x: 20, y: 540, width: 360, height: 40)
            let brandAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.tertiaryLabel,
                NSAttributedString.Key.paragraphStyle: titleStyle
            ]
            
            "Touch Wood App".draw(in: brandRect, withAttributes: brandAttributes)
        }
    }
    
    private func generateStreakImage(_ streak: Int, days: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 500))
        
        return renderer.image { context in
            // Background
            UIColor.systemBackground.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 500))
            
            // Fire emoji and streak number
            let fireText = "🔥"
            let fireRect = CGRect(x: 150, y: 100, width: 100, height: 100)
            let fireAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 80)]
            fireText.draw(in: fireRect, withAttributes: fireAttributes)
            
            // Streak number
            let streakText = "\(streak)"
            let streakRect = CGRect(x: 50, y: 220, width: 300, height: 80)
            let streakAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 60),
                NSAttributedString.Key.foregroundColor: UIColor.systemOrange,
                NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle().apply { $0.alignment = .center }
            ]
            streakText.draw(in: streakRect, withAttributes: streakAttributes)
            
            // Days text
            let daysText = "Day Streak!"
            let daysRect = CGRect(x: 50, y: 300, width: 300, height: 40)
            let daysAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24),
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle().apply { $0.alignment = .center }
            ]
            daysText.draw(in: daysRect, withAttributes: daysAttributes)
        }
    }
    
    private func generateRitualImage(_ ritual: RitualModel, mood: Int?) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 500))
        
        return renderer.image { context in
            // Background
            UIColor.systemBackground.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 500))
            
            // Ritual icon
            let iconText = ritual.icon
            let iconRect = CGRect(x: 150, y: 80, width: 100, height: 100)
            let iconAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 60)]
            iconText.draw(in: iconRect, withAttributes: iconAttributes)
            
            // Ritual name
            let nameRect = CGRect(x: 20, y: 200, width: 360, height: 60)
            let nameAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle().apply { $0.alignment = .center }
            ]
            ritual.name.draw(in: nameRect, withAttributes: nameAttributes)
            
            // Mood if available
            if let mood = mood {
                let moodText = "Feeling: \(moodEmojiForValue(mood))"
                let moodRect = CGRect(x: 20, y: 280, width: 360, height: 40)
                let moodAttributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
                    NSAttributedString.Key.foregroundColor: UIColor.systemGreen,
                    NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle().apply { $0.alignment = .center }
                ]
                moodText.draw(in: moodRect, withAttributes: moodAttributes)
            }
        }
    }
    
    private func generateChallengeImage(_ challenge: DailyChallenge) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 500))
        
        return renderer.image { context in
            // Background
            UIColor.systemBackground.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 500))
            
            // Challenge icon
            let iconText = "🏆"
            let iconRect = CGRect(x: 150, y: 80, width: 100, height: 100)
            let iconAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 80)]
            iconText.draw(in: iconRect, withAttributes: iconAttributes)
            
            // Challenge title
            let titleRect = CGRect(x: 20, y: 200, width: 360, height: 60)
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle().apply { $0.alignment = .center }
            ]
            challenge.title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Progress
            let progressText = "\(challenge.progress)/\(challenge.target) Completed"
            let progressRect = CGRect(x: 20, y: 280, width: 360, height: 40)
            let progressAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle().apply { $0.alignment = .center }
            ]
            progressText.draw(in: progressRect, withAttributes: progressAttributes)
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    private func incrementShareCount() {
        shareCount += 1
        lastSharedDate = Date()
        saveShareData()
    }
    
    private func trackShare(type: ShareType, itemId: String? = nil) {
        // This would integrate with analytics
        print("Tracked share: \(type.rawValue), item: \(itemId ?? "none")")
    }
    
    private func loadShareData() {
        shareCount = userDefaults.integer(forKey: shareCountKey)
        if let date = userDefaults.object(forKey: lastSharedDateKey) as? Date {
            lastSharedDate = date
        }
    }
    
    private func saveShareData() {
        userDefaults.set(shareCount, forKey: shareCountKey)
        if let date = lastSharedDate {
            userDefaults.set(date, forKey: lastSharedDateKey)
        }
    }
}

// MARK: - Supporting Types

enum ShareType: String {
    case achievement = "achievement"
    case streak = "streak"
    case ritual = "ritual"
    case challenge = "challenge"
}

// Helper for paragraph style
extension NSMutableParagraphStyle {
    func apply(_ block: (NSMutableParagraphStyle) -> Void) -> NSMutableParagraphStyle {
        block(self)
        return self
    }
}

// Gradient helper
struct LinearGradientGradient {
    static func colors(_ colors: [UIColor]) -> [CGColor] {
        return colors.map { $0.cgColor }
    }
}
