import SwiftUI
import UserNotifications
import CoreData

@main
struct TouchWoodApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear(perform: requestNotificationPermission)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingFlow(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .onAppear(perform: checkOnboardingStatus)
    }

    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TouchWoodView()
                .tabItem {
                    Label("Touch Wood", systemImage: "tree.fill")
                }
            RitualLibraryView()
                .tabItem {
                    Label("Rituals", systemImage: "list.bullet")
                }
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
