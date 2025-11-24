import SwiftUI
import UserNotifications

struct OnboardingFlow: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var selectedRitual = RitualModel.touchWood
    @State private var dailyReminderTime = Date()
    @State private var soundEnabled = true
    @State private var hapticStyle = "medium"

    private let pages = [
        OnboardingPage(
            title: NSLocalizedString("welcome_title", comment: "Welcome title"),
            subtitle: NSLocalizedString("welcome_subtitle", comment: "Welcome subtitle"),
            imageName: "tree.fill",
            description: NSLocalizedString("welcome_description", comment: "Welcome description")
        ),
        OnboardingPage(
            title: NSLocalizedString("choose_ritual_title", comment: "Choose ritual title"),
            subtitle: NSLocalizedString("choose_ritual_subtitle", comment: "Choose ritual subtitle"),
            imageName: "hand.tap.fill",
            description: NSLocalizedString("choose_ritual_description", comment: "Choose ritual description")
        ),
        OnboardingPage(
            title: NSLocalizedString("set_reminder_title", comment: "Set reminder title"),
            subtitle: NSLocalizedString("set_reminder_subtitle", comment: "Set reminder subtitle"),
            imageName: "bell.fill",
            description: NSLocalizedString("set_reminder_description", comment: "Set reminder description")
        ),
        OnboardingPage(
            title: NSLocalizedString("customize_title", comment: "Customize title"),
            subtitle: NSLocalizedString("customize_subtitle", comment: "Customize subtitle"),
            imageName: "speaker.wave.3.fill",
            description: NSLocalizedString("customize_description", comment: "Customize description")
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(
                        page: pages[index],
                        selectedRitual: $selectedRitual,
                        dailyReminderTime: $dailyReminderTime,
                        soundEnabled: $soundEnabled,
                        hapticStyle: $hapticStyle,
                        isLastPage: index == pages.count - 1,
                        onNext: {
                            if index < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                completeOnboarding()
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .animation(.easeInOut, value: currentPage)

            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(selectedRitual.id.uuidString, forKey: "defaultRitualId")
        UserDefaults.standard.set(dailyReminderTime, forKey: "dailyReminderTime")
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(hapticStyle, forKey: "hapticStyle")
        
        // Schedule notification
        scheduleDailyReminder(time: dailyReminderTime)
        
        hasCompletedOnboarding = true
    }

    private func scheduleDailyReminder(time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Time for your ritual!"
        content.body = "Tap to perform \(selectedRitual.name) and keep your streak going."
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_ritual", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Binding var selectedRitual: RitualModel
    @Binding var dailyReminderTime: Date
    @Binding var soundEnabled: Bool
    @Binding var hapticStyle: String
    let isLastPage: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: page.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Page-specific content
            if page.title.contains("Choose Your Ritual") {
                RitualPicker(selectedRitual: $selectedRitual)
            } else if page.title.contains("Set Daily Reminder") {
                ReminderTimePicker(time: $dailyReminderTime)
            } else if page.title.contains("Customize Experience") {
                ExperienceSettings(soundEnabled: $soundEnabled, hapticStyle: $hapticStyle)
            }

            Spacer()

            Button(action: onNext) {
                Text(isLastPage ? NSLocalizedString("get_started", comment: "Get started button") : NSLocalizedString("continue", comment: "Continue button"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct RitualPicker: View {
    @Binding var selectedRitual: RitualModel
    private let rituals = [RitualModel.touchWood, RitualModel.crossFingers, RitualModel.saltOverShoulder]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rituals, id: \.id) { ritual in
                Button(action: { selectedRitual = ritual }) {
                    HStack {
                        Image(systemName: ritual.icon)
                            .frame(width: 30)
                        Text(ritual.name)
                        Spacer()
                        if selectedRitual.id == ritual.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(selectedRitual.id == ritual.id ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ReminderTimePicker: View {
    @Binding var time: Date

    var body: some View {
        VStack {
            Text(NSLocalizedString("choose_daily_reminder_time", comment: "Choose reminder time"))
                .font(.headline)
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
                .frame(maxHeight: 150)
        }
        .padding(.horizontal, 20)
    }
}

struct ExperienceSettings: View {
    @Binding var soundEnabled: Bool
    @Binding var hapticStyle: String
    private let hapticOptions = ["light", "medium", "heavy"]
    
    private func localizedHapticStyle(_ style: String) -> String {
        switch style {
        case "light":
            return NSLocalizedString("light", comment: "Light haptic")
        case "medium":
            return NSLocalizedString("medium", comment: "Medium haptic")
        case "heavy":
            return NSLocalizedString("heavy", comment: "Heavy haptic")
        default:
            return style
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Toggle(NSLocalizedString("sound_effects", comment: "Sound effects toggle"), isOn: $soundEnabled)
                .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("haptic_feedback", comment: "Haptic feedback"))
                    .font(.headline)
                Picker("Haptic Style", selection: $hapticStyle) {
                    ForEach(hapticOptions, id: \.self) { style in
                        Text(localizedHapticStyle(style)).tag(style)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal, 20)
        }
    }
}
