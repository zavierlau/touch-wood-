import Foundation
import UserNotifications

class NotificationScheduler: ObservableObject {
    static let shared = NotificationScheduler()
    
    private init() {}
    
    // MARK: - Daily Ritual Reminder
    
    func scheduleDailyRitualReminder(time: Date, ritualName: String) {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing daily reminder
        center.removePendingNotificationRequests(withIdentifiers: ["daily_ritual"])
        
        let content = UNMutableNotificationContent()
        content.title = "Time for your ritual!"
        content.body = "Tap to perform \(ritualName) and keep your streak going."
        content.sound = .default
        content.categoryIdentifier = "RITUAL_REMINDER"
        content.userInfo = ["ritual_name": ritualName]
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_ritual", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily ritual reminder: \(error)")
            } else {
                print("Daily ritual reminder scheduled for \(time)")
            }
        }
    }
    
    // MARK: - Streak Milestone Notifications
    
    func scheduleStreakMilestoneNotification(streak: Int) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak Milestone!"
        content.body = "Congratulations! You've reached a \(streak)-day streak!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_MILESTONE"
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak_milestone_\(streak)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling streak milestone notification: \(error)")
            }
        }
    }
    
    // MARK: - Custom Ritual Reminders
    
    func scheduleCustomRitualReminder(ritual: Ritual, time: Date) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Time for \(ritual.name ?? "your ritual")!"
        content.body = ritual.ritualDescription ?? "Don't forget to perform your custom ritual."
        content.sound = .default
        content.categoryIdentifier = "CUSTOM_RITUAL"
        content.userInfo = ["ritual_id": ritual.id?.uuidString ?? ""]
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "custom_ritual_\(ritual.id?.uuidString ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling custom ritual reminder: \(error)")
            }
        }
    }
    
    // MARK: - Streak Recovery Notifications
    
    func scheduleStreakRecoveryNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Don't lose your streak!"
        content.body = "You haven't performed your ritual today. Tap to keep your streak alive!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_RECOVERY"
        content.userInfo = ["is_recovery": true]
        
        // Schedule for evening if ritual not completed
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_recovery", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling streak recovery notification: \(error)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func updateDailyReminderTime(newTime: Date, ritualName: String) {
        scheduleDailyRitualReminder(time: newTime, ritualName: ritualName)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Notification Categories and Actions
    
    func setupNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Ritual Reminder Category
        let performAction = UNNotificationAction(
            identifier: "PERFORM_RITUAL",
            title: "Perform Ritual",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Remind Later",
            options: []
        )
        
        let ritualCategory = UNNotificationCategory(
            identifier: "RITUAL_REMINDER",
            actions: [performAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Streak Milestone Category
        let shareAction = UNNotificationAction(
            identifier: "SHARE_STREAK",
            title: "Share",
            options: []
        )
        
        let streakCategory = UNNotificationCategory(
            identifier: "STREAK_MILESTONE",
            actions: [shareAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([ritualCategory, streakCategory])
    }
    
    // MARK: - Helper Methods
    
    func getPendingNotificationCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests.count)
        }
    }
    
    func printAllPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending notifications:")
            for request in requests {
                print("- \(request.identifier): \(request.content.title)")
            }
        }
    }
}

// MARK: - Notification Handling Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        switch identifier {
        case "PERFORM_RITUAL":
            // Navigate to main ritual view
            NotificationCenter.default.post(name: .performRitualFromNotification, object: nil)
            
        case "SNOOZE":
            // Schedule a snooze notification for 1 hour later
            if let ritualName = userInfo["ritual_name"] as? String {
                let content = UNMutableNotificationContent()
                content.title = "Reminder: \(ritualName)"
                content.body = "Don't forget to perform your ritual!"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1 hour
                let request = UNNotificationRequest(identifier: "snooze_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
            
        case "SHARE_STREAK":
            // Trigger share functionality
            NotificationCenter.default.post(name: .shareStreakFromNotification, object: userInfo)
            
        default:
            // Handle notification tap (no action)
            NotificationCenter.default.post(name: .notificationTapped, object: userInfo)
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let performRitualFromNotification = Notification.Name("performRitualFromNotification")
    static let shareStreakFromNotification = Notification.Name("shareStreakFromNotification")
    static let notificationTapped = Notification.Name("notificationTapped")
}
