import SwiftUI
import Foundation

// MARK: - Friend System Models

struct UserProfile: Identifiable, Codable {
    let id: UUID
    let username: String
    let displayName: String
    let avatarImageData: Data?
    let bio: String?
    let isCurrentUser: Bool
    let stats: UserStats
    let preferences: UserPreferences
    let createdAt: Date
    let lastActive: Date
    
    struct UserStats: Codable {
        let totalRituals: Int
        let currentStreak: Int
        let bestStreak: Int
        let totalPoints: Int
        let achievementsUnlocked: Int
        let friendsCount: Int
        let shareCount: Int
        
        var level: Int {
            return totalPoints / 100 + 1
        }
        
        var progressToNextLevel: Double {
            return Double(totalPoints % 100) / 100.0
        }
    }
}

struct Friendship: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let friendId: UUID
    let status: FriendshipStatus
    let requestedAt: Date
    let acceptedAt: Date?
    
    enum FriendshipStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case accepted = "accepted"
        case declined = "declined"
        case blocked = "blocked"
        
        var displayName: String {
            switch self {
            case .pending: return NSLocalizedString("friendship_pending", comment: "Pending")
            case .accepted: return NSLocalizedString("friendship_accepted", comment: "Friends")
            case .declined: return NSLocalizedString("friendship_declined", comment: "Declined")
            case .blocked: return NSLocalizedString("friendship_blocked", comment: "Blocked")
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .accepted: return .green
            case .declined: return .red
            case .blocked: return .gray
            }
        }
    }
}

struct SocialActivity: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let type: ActivityType
    let content: ActivityContent
    let timestamp: Date
    let likes: [UUID]
    let comments: [ActivityComment]
    
    enum ActivityType: String, CaseIterable, Codable {
        case ritualCompleted = "ritual_completed"
        case achievementUnlocked = "achievement_unlocked"
        case streakMilestone = "streak_milestone"
        case challengeCompleted = "challenge_completed"
        case customRitualCreated = "custom_ritual_created"
        
        var iconName: String {
            switch self {
            case .ritualCompleted: return "star.fill"
            case .achievementUnlocked: return "trophy.fill"
            case .streakMilestone: return "flame.fill"
            case .challengeCompleted: return "target"
            case .customRitualCreated: return "paintbrush.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .ritualCompleted: return .blue
            case .achievementUnlocked: return .yellow
            case .streakMilestone: return .orange
            case .challengeCompleted: return .green
            case .customRitualCreated: return .purple
            }
        }
    }
    
    struct ActivityContent: Codable {
        let title: String
        let description: String
        let metadata: [String: String]
    }
    
    struct ActivityComment: Identifiable, Codable {
        let id = UUID()
        let userId: UUID
        let username: String
        let content: String
        let timestamp: Date
    }
}

// MARK: - Friend System Manager

class FriendSystemManager: ObservableObject {
    @Published var currentUser: UserProfile
    @Published var friends: [UserProfile] = []
    @Published var friendRequests: [UserProfile] = []
    @Published var pendingRequests: [UserProfile] = []
    @Published var socialFeed: [SocialActivity] = []
    @Published var searchResults: [UserProfile] = []
    @Published var isSearching = false
    
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "currentUser"
    private let friendsKey = "friends"
    private let socialFeedKey = "socialFeed"
    
    init() {
        self.currentUser = createCurrentUser()
        loadUserData()
        generateMockData()
    }
    
    // MARK: - User Management
    
    private func createCurrentUser() -> UserProfile {
        return UserProfile(
            id: UUID(),
            username: "current_user",
            displayName: "You",
            avatarImageData: nil,
            bio: "Love my daily rituals!",
            isCurrentUser: true,
            stats: UserProfile.UserStats(
                totalRituals: 45,
                currentStreak: 7,
                bestStreak: 14,
                totalPoints: 450,
                achievementsUnlocked: 8,
                friendsCount: 0,
                shareCount: 3
            ),
            preferences: UserPreferences.default,
            createdAt: Date(),
            lastActive: Date()
        )
    }
    
    func updateProfile(displayName: String, bio: String) {
        currentUser = UserProfile(
            id: currentUser.id,
            username: currentUser.username,
            displayName: displayName,
            avatarImageData: currentUser.avatarImageData,
            bio: bio,
            isCurrentUser: currentUser.isCurrentUser,
            stats: currentUser.stats,
            preferences: currentUser.preferences,
            createdAt: currentUser.createdAt,
            lastActive: Date()
        )
        saveUserData()
    }
    
    // MARK: - Friend Management
    
    func searchUsers(query: String) {
        isSearching = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Mock search - in real app, this would query a backend
            self.searchResults = self.mockUsers.filter { user in
                !user.isCurrentUser &&
                (user.displayName.localizedCaseInsensitiveContains(query) ||
                 user.username.localizedCaseInsensitiveContains(query))
            }
            self.isSearching = false
        }
    }
    
    func sendFriendRequest(to user: UserProfile) {
        // In a real app, this would send to backend
        pendingRequests.append(user)
        saveUserData()
        
        // Create activity
        let activity = SocialActivity(
            id: UUID(),
            userId: currentUser.id,
            type: .ritualCompleted,
            content: SocialActivity.ActivityContent(
                title: NSLocalizedString("activity_friend_request", comment: "Friend Request"),
                description: String(format: NSLocalizedString("activity_friend_request_desc", comment: ""), user.displayName),
                metadata: ["friendId": user.id.uuidString]
            ),
            timestamp: Date(),
            likes: [],
            comments: []
        )
        
        // This would be sent to the other user
        print("Friend request sent to \(user.displayName)")
    }
    
    func acceptFriendRequest(from user: UserProfile) {
        friends.append(user)
        friendRequests.removeAll { $0.id == user.id }
        saveUserData()
        
        // Create activity for both users
        let activity = SocialActivity(
            id: UUID(),
            userId: currentUser.id,
            type: .ritualCompleted,
            content: SocialActivity.ActivityContent(
                title: NSLocalizedString("activity_new_friend", comment: "New Friend"),
                description: String(format: NSLocalizedString("activity_new_friend_desc", comment: ""), user.displayName),
                metadata: ["friendId": user.id.uuidString]
            ),
            timestamp: Date(),
            likes: [],
            comments: []
        )
        
        addToSocialFeed(activity)
    }
    
    func declineFriendRequest(from user: UserProfile) {
        friendRequests.removeAll { $0.id == user.id }
        saveUserData()
    }
    
    func removeFriend(_ user: UserProfile) {
        friends.removeAll { $0.id == user.id }
        saveUserData()
    }
    
    // MARK: - Social Feed
    
    func postActivity(type: SocialActivity.ActivityType, content: SocialActivity.ActivityContent) {
        let activity = SocialActivity(
            id: UUID(),
            userId: currentUser.id,
            type: type,
            content: content,
            timestamp: Date(),
            likes: [],
            comments: []
        )
        
        addToSocialFeed(activity)
        
        // In a real app, this would be sent to backend
        print("Activity posted: \(content.title)")
    }
    
    private func addToSocialFeed(_ activity: SocialActivity) {
        socialFeed.insert(activity, at: 0)
        if socialFeed.count > 50 {
            socialFeed.removeLast()
        }
        saveUserData()
    }
    
    func likeActivity(_ activity: SocialActivity) {
        // In a real app, this would be sent to backend
        print("Liked activity: \(activity.content.title)")
    }
    
    func commentOnActivity(_ activity: SocialActivity, comment: String) {
        let newComment = SocialActivity.ActivityComment(
            userId: currentUser.id,
            username: currentUser.displayName,
            content: comment,
            timestamp: Date()
        )
        
        // In a real app, this would be sent to backend
        print("Commented on activity: \(activity.content.title)")
    }
    
    // MARK: - Activity Tracking
    
    func trackRitualCompletion(ritualName: String, mood: Int?) {
        let content = SocialActivity.ActivityContent(
            title: NSLocalizedString("activity_ritual_completed", comment: "Ritual Completed"),
            description: String(format: NSLocalizedString("activity_ritual_desc", comment: ""), ritualName),
            metadata: [
                "ritualName": ritualName,
                "mood": mood != nil ? "\(mood!)" : ""
            ]
        )
        
        postActivity(type: .ritualCompleted, content: content)
    }
    
    func trackAchievement(achievementName: String, points: Int) {
        let content = SocialActivity.ActivityContent(
            title: NSLocalizedString("activity_achievement", comment: "Achievement Unlocked"),
            description: String(format: NSLocalizedString("activity_achievement_desc", comment: ""), achievementName, points),
            metadata: [
                "achievementName": achievementName,
                "points": "\(points)"
            ]
        )
        
        postActivity(type: .achievementUnlocked, content: content)
    }
    
    func trackStreakMilestone(streak: Int) {
        let content = SocialActivity.ActivityContent(
            title: NSLocalizedString("activity_streak_milestone", comment: "Streak Milestone"),
            description: String(format: NSLocalizedString("activity_streak_desc", comment: ""), streak),
            metadata: ["streak": "\(streak)"]
        )
        
        postActivity(type: .streakMilestone, content: content)
    }
    
    func trackChallengeCompletion(challengeName: String, reward: String) {
        let content = SocialActivity.ActivityContent(
            title: NSLocalizedString("activity_challenge_completed", comment: "Challenge Completed"),
            description: String(format: NSLocalizedString("activity_challenge_desc", comment: ""), challengeName, reward),
            metadata: [
                "challengeName": challengeName,
                "reward": reward
            ]
        )
        
        postActivity(type: .challengeCompleted, content: content)
    }
    
    func trackCustomRitual(ritualName: String, category: String) {
        let content = SocialActivity.ActivityContent(
            title: NSLocalizedString("activity_custom_ritual", comment: "Custom Ritual Created"),
            description: String(format: NSLocalizedString("activity_custom_ritual_desc", comment: ""), ritualName, category),
            metadata: [
                "ritualName": ritualName,
                "category": category
            ]
        )
        
        postActivity(type: .customRitualCreated, content: content)
    }
    
    // MARK: - Mock Data
    
    private var mockUsers: [UserProfile] {
        return [
            UserProfile(
                id: UUID(),
                username: "ritual_master",
                displayName: "Ritual Master",
                avatarImageData: nil,
                bio: "30-day streak holder! 🎯",
                isCurrentUser: false,
                stats: UserProfile.UserStats(
                    totalRituals: 120,
                    currentStreak: 30,
                    bestStreak: 45,
                    totalPoints: 1200,
                    achievementsUnlocked: 15,
                    friendsCount: 8,
                    shareCount: 12
                ),
                preferences: UserPreferences.default,
                createdAt: Date().addingTimeInterval(-86400 * 90),
                lastActive: Date().addingTimeInterval(-3600)
            ),
            UserProfile(
                id: UUID(),
                username: "lucky_charm",
                displayName: "Lucky Charm",
                avatarImageData: nil,
                bio: "Sharing positive vibes daily ✨",
                isCurrentUser: false,
                stats: UserProfile.UserStats(
                    totalRituals: 85,
                    currentStreak: 14,
                    bestStreak: 21,
                    totalPoints: 850,
                    achievementsUnlocked: 10,
                    friendsCount: 5,
                    shareCount: 8
                ),
                preferences: UserPreferences.default,
                createdAt: Date().addingTimeInterval(-86400 * 60),
                lastActive: Date().addingTimeInterval(-1800)
            ),
            UserProfile(
                id: UUID(),
                username: "zen_warrior",
                displayName: "Zen Warrior",
                avatarImageData: nil,
                bio: "Mindfulness and meditation 🧘‍♂️",
                isCurrentUser: false,
                stats: UserProfile.UserStats(
                    totalRituals: 200,
                    currentStreak: 7,
                    bestStreak: 60,
                    totalPoints: 2000,
                    achievementsUnlocked: 20,
                    friendsCount: 12,
                    shareCount: 25
                ),
                preferences: UserPreferences.default,
                createdAt: Date().addingTimeInterval(-86400 * 120),
                lastActive: Date().addingTimeInterval(-900)
            )
        ]
    }
    
    private func generateMockData() {
        if friends.isEmpty {
            friends = Array(mockUsers.prefix(2))
        }
        
        if socialFeed.isEmpty {
            socialFeed = generateMockSocialFeed()
        }
        
        if friendRequests.isEmpty {
            friendRequests = Array(mockUsers.suffix(1))
        }
    }
    
    private func generateMockSocialFeed() -> [SocialActivity] {
        var feed: [SocialActivity] = []
        
        // Friend activities
        for friend in friends {
            let activities = [
                SocialActivity(
                    id: UUID(),
                    userId: friend.id,
                    type: .ritualCompleted,
                    content: SocialActivity.ActivityContent(
                        title: NSLocalizedString("activity_ritual_completed", comment: "Ritual Completed"),
                        description: String(format: NSLocalizedString("activity_ritual_desc", comment: ""), "Knock on Wood"),
                        metadata: ["ritualName": "Knock on Wood", "mood": "4"]
                    ),
                    timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400)),
                    likes: [UUID(), UUID()],
                    comments: []
                ),
                SocialActivity(
                    id: UUID(),
                    userId: friend.id,
                    type: .achievementUnlocked,
                    content: SocialActivity.ActivityContent(
                        title: NSLocalizedString("activity_achievement", comment: "Achievement Unlocked"),
                        description: String(format: NSLocalizedString("activity_achievement_desc", comment: ""), "Week Warrior", 25),
                        metadata: ["achievementName": "Week Warrior", "points": "25"]
                    ),
                    timestamp: Date().addingTimeInterval(-Double.random(in: 0...172800)),
                    likes: [UUID()],
                    comments: []
                )
            ]
            
            feed.append(contentsOf: activities)
        }
        
        return feed.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Data Persistence
    
    private func loadUserData() {
        if let data = userDefaults.data(forKey: currentUserKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            currentUser = decoded
        }
        
        if let data = userDefaults.data(forKey: friendsKey),
           let decoded = try? JSONDecoder().decode([UserProfile].self, from: data) {
            friends = decoded
        }
        
        if let data = userDefaults.data(forKey: socialFeedKey),
           let decoded = try? JSONDecoder().decode([SocialActivity].self, from: data) {
            socialFeed = decoded
        }
    }
    
    private func saveUserData() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            userDefaults.set(encoded, forKey: currentUserKey)
        }
        
        if let encoded = try? JSONEncoder().encode(friends) {
            userDefaults.set(encoded, forKey: friendsKey)
        }
        
        if let encoded = try? JSONEncoder().encode(socialFeed) {
            userDefaults.set(encoded, forKey: socialFeedKey)
        }
    }
    
    // MARK: - Statistics
    
    var totalFriends: Int {
        return friends.count
    }
    
    var pendingRequestsCount: Int {
        return friendRequests.count
    }
    
    var sentRequestsCount: Int {
        return pendingRequests.count
    }
}

// MARK: - Social Views

struct SocialMainView: View {
    @StateObject private var friendManager = FriendSystemManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Social Feed
                SocialFeedView()
                    .environmentObject(friendManager)
                    .tabItem {
                        Label(NSLocalizedString("social_feed", comment: "Feed"), systemImage: "list.bullet")
                    }
                    .tag(0)
                
                // Friends
                FriendsView()
                    .environmentObject(friendManager)
                    .tabItem {
                        Label(NSLocalizedString("friends", comment: "Friends"), systemImage: "person.2")
                    }
                    .tag(1)
                
                // Search
                UserSearchView()
                    .environmentObject(friendManager)
                    .tabItem {
                        Label(NSLocalizedString("search", comment: "Search"), systemImage: "magnifyingglass")
                    }
                    .tag(2)
                
                // Profile
                ProfileView()
                    .environmentObject(friendManager)
                    .tabItem {
                        Label(NSLocalizedString("profile", comment: "Profile"), systemImage: "person.circle")
                    }
                    .tag(3)
            }
            .navigationTitle(NSLocalizedString("social_title", comment: "Social"))
        }
    }
}

struct SocialFeedView: View {
    @EnvironmentObject var friendManager: FriendSystemManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(friendManager.socialFeed) { activity in
                    ActivityCard(activity: activity)
                }
            }
            .padding()
        }
    }
}

struct ActivityCard: View {
    let activity: SocialActivity
    @EnvironmentObject var friendManager: FriendSystemManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: activity.type.iconName)
                    .foregroundColor(activity.type.color)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(activity.content.title)
                        .font(.headline)
                    
                    Text(formatDate(activity.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Content
            Text(activity.content.description)
                .font(.body)
                .foregroundColor(.primary)
            
            // Actions
            HStack(spacing: 20) {
                Button(action: {
                    friendManager.likeActivity(activity)
                }) {
                    HStack {
                        Image(systemName: "heart")
                        Text("\(activity.likes.count)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Button(action: {
                    // Show comments
                }) {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("\(activity.comments.count)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    friendManager.commentOnActivity(activity, comment: "Great job! 🎉")
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct FriendsView: View {
    @EnvironmentObject var friendManager: FriendSystemManager
    
    var body: some View {
        NavigationView {
            List {
                if !friendManager.friendRequests.isEmpty {
                    Section(NSLocalizedString("friend_requests", comment: "Friend Requests")) {
                        ForEach(friendManager.friendRequests) { user in
                            FriendRequestRow(user: user)
                        }
                    }
                }
                
                Section(NSLocalizedString("my_friends", comment: "My Friends")) {
                    ForEach(friendManager.friends) { friend in
                        FriendRow(user: friend)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("friends", comment: "Friends"))
        }
    }
}

struct FriendRequestRow: View {
    let user: UserProfile
    @EnvironmentObject var friendManager: FriendSystemManager
    
    var body: some View {
        HStack {
            // Avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(user.displayName.prefix(1)))
                        .font(.title2)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                
                Text(user.bio ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    friendManager.acceptFriendRequest(from: user)
                }) {
                    Text(NSLocalizedString("accept", comment: "Accept"))
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    friendManager.declineFriendRequest(from: user)
                }) {
                    Text(NSLocalizedString("decline", comment: "Decline"))
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct FriendRow: View {
    let user: UserProfile
    @EnvironmentObject var friendManager: FriendSystemManager
    
    var body: some View {
        HStack {
            // Avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(user.displayName.prefix(1)))
                        .font(.title2)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                
                Text("Level \(user.stats.level) • \(user.stats.currentStreak) day streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                friendManager.removeFriend(user)
            }) {
                Image(systemName: "person.badge.minus")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct UserSearchView: View {
    @EnvironmentObject var friendManager: FriendSystemManager
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchQuery, onSearch: friendManager.searchUsers)
                
                if friendManager.isSearching {
                    ProgressView()
                        .padding()
                } else if searchQuery.isEmpty {
                    Text(NSLocalizedString("search_placeholder", comment: "Search for users..."))
                        .foregroundColor(.secondary)
                        .padding()
                } else if friendManager.searchResults.isEmpty {
                    Text(NSLocalizedString("no_results", comment: "No results found"))
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(friendManager.searchResults) { user in
                        SearchResultRow(user: user)
                    }
                }
                
                Spacer()
            }
            .navigationTitle(NSLocalizedString("search", comment: "Search"))
        }
    }
}

struct SearchResultRow: View {
    let user: UserProfile
    @EnvironmentObject var friendManager: FriendSystemManager
    
    var body: some View {
        HStack {
            // Avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(user.displayName.prefix(1)))
                        .font(.title2)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                
                Text("Level \(user.stats.level) • \(user.stats.friendsCount) friends")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Button(action: {
                friendManager.sendFriendRequest(to: user)
            }) {
                Text(NSLocalizedString("add_friend", comment: "Add Friend"))
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProfileView: View {
    @EnvironmentObject var friendManager: FriendSystemManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeader(user: friendManager.currentUser)
                    
                    // Stats Grid
                    StatsGrid(stats: friendManager.currentUser.stats)
                    
                    // Recent Activity
                    RecentActivitySection()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("profile", comment: "Profile"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
                    .environmentObject(friendManager)
            }
        }
    }
}

struct ProfileHeader: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(String(user.displayName.prefix(1)))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            // Name and Bio
            VStack(spacing: 8) {
                Text(user.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Text("Level \(user.stats.level)")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
}

struct StatsGrid: View {
    let stats: UserProfile.UserStats
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: NSLocalizedString("total_rituals", comment: "Total Rituals"),
                value: "\(stats.totalRituals)",
                icon: "star.fill",
                color: .blue
            )
            
            StatCard(
                title: NSLocalizedString("current_streak", comment: "Current Streak"),
                value: "\(stats.currentStreak)",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: NSLocalizedString("best_streak", comment: "Best Streak"),
                value: "\(stats.bestStreak)",
                icon: "crown.fill",
                color: .yellow
            )
            
            StatCard(
                title: NSLocalizedString("total_points", comment: "Total Points"),
                value: "\(stats.totalPoints)",
                icon: "trophy.fill",
                color: .purple
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("recent_activity", comment: "Recent Activity"))
                .font(.headline)
            
            // Mock recent activity
            VStack(spacing: 12) {
                ActivityRow(
                    icon: "star.fill",
                    title: NSLocalizedString("completed_ritual", comment: "Completed Ritual"),
                    description: "Knock on Wood",
                    time: "2 hours ago"
                )
                
                ActivityRow(
                    icon: "trophy.fill",
                    title: NSLocalizedString("unlocked_achievement", comment: "Unlocked Achievement"),
                    description: "Week Warrior",
                    time: "1 day ago"
                )
                
                ActivityRow(
                    icon: "flame.fill",
                    title: NSLocalizedString("streak_milestone", comment: "Streak Milestone"),
                    description: "7 Day Streak",
                    time: "2 days ago"
                )
            }
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let description: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct EditProfileView: View {
    @EnvironmentObject var friendManager: FriendSystemManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String
    @State private var bio: String
    
    init() {
        // We'll initialize these in the body
        _displayName = State(initialValue: "")
        _bio = State(initialValue: "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("profile_info", comment: "Profile Information"))) {
                    TextField(NSLocalizedString("display_name", comment: "Display Name"), text: $displayName)
                    TextField(NSLocalizedString("bio", comment: "Bio"), text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(NSLocalizedString("edit_profile", comment: "Edit Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "Save")) {
                        friendManager.updateProfile(displayName: displayName, bio: bio)
                        dismiss()
                    }
                    .disabled(displayName.isEmpty)
                }
            }
            .onAppear {
                displayName = friendManager.currentUser.displayName
                bio = friendManager.currentUser.bio ?? ""
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(NSLocalizedString("search_users", comment: "Search users..."), text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    onSearch(text)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
