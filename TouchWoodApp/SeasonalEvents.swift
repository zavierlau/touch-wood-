import SwiftUI
import Foundation

// MARK: - Seasonal Events Models

struct SeasonalEvent: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let type: EventType
    let startDate: Date
    let endDate: Date
    let theme: EventTheme
    let specialRituals: [SpecialRitual]
    let rewards: [EventReward]
    let challenges: [EventChallenge]
    let isActive: Bool
    
    enum EventType: String, CaseIterable, Codable {
        case holiday = "holiday"
        case seasonal = "seasonal"
        case cultural = "cultural"
        case special = "special"
        
        var displayName: String {
            switch self {
            case .holiday: return NSLocalizedString("event_type_holiday", comment: "Holiday")
            case .seasonal: return NSLocalizedString("event_type_seasonal", comment: "Seasonal")
            case .cultural: return NSLocalizedString("event_type_cultural", comment: "Cultural")
            case .special: return NSLocalizedString("event_type_special", comment: "Special")
            }
        }
        
        var iconName: String {
            switch self {
            case .holiday: return "calendar.badge.plus"
            case .seasonal: return "leaf"
            case .cultural: return "globe"
            case .special: return "star.circle"
            }
        }
    }
    
    struct EventTheme: Codable {
        let primaryColor: String
        let secondaryColor: String
        let backgroundColor: String
        let accentColor: String
        let iconName: String
        let backgroundImage: String?
        
        var primaryUIColor: Color {
            Color(hex: primaryColor)
        }
        
        var secondaryUIColor: Color {
            Color(hex: secondaryColor)
        }
        
        var backgroundUIColor: Color {
            Color(hex: backgroundColor)
        }
        
        var accentUIColor: Color {
            Color(hex: accentColor)
        }
    }
    
    struct SpecialRitual: Identifiable, Codable {
        let id: UUID
        let name: String
        let description: String
        let icon: String
        let category: String
        let rarity: RitualRarity
        let effects: [RitualEffect]
        let unlockRequirement: UnlockRequirement?
        let isLimited: Bool
        let usageLimit: Int?
        let currentUsage: Int
        
        enum RitualRarity: String, CaseIterable, Codable {
            case common = "common"
            case uncommon = "uncommon"
            case rare = "rare"
            case epic = "epic"
            case legendary = "legendary"
            
            var displayName: String {
                switch self {
                case .common: return NSLocalizedString("rarity_common", comment: "Common")
                case .uncommon: return NSLocalizedString("rarity_uncommon", comment: "Uncommon")
                case .rare: return NSLocalizedString("rarity_rare", comment: "Rare")
                case .epic: return NSLocalizedString("rarity_epic", comment: "Epic")
                case .legendary: return NSLocalizedString("rarity_legendary", comment: "Legendary")
                }
            }
            
            var color: Color {
                switch self {
                case .common: return .gray
                case .uncommon: return .green
                case .rare: return .blue
                case .epic: return .purple
                case .legendary: return .orange
                }
            }
            
            var backgroundColor: Color {
                return color.opacity(0.2)
            }
        }
        
        struct RitualEffect: Codable {
            let type: EffectType
            let value: Double
            let duration: Int?
            let description: String
            
            enum EffectType: String, CaseIterable, Codable {
                case moodBoost = "mood_boost"
                case streakBonus = "streak_bonus"
                case doublePoints = "double_points"
                case luckyCharm = "lucky_charm"
                case protection = "protection"
                case prosperity = "prosperity"
                
                var displayName: String {
                    switch self {
                    case .moodBoost: return NSLocalizedString("effect_mood_boost", comment: "Mood Boost")
                    case .streakBonus: return NSLocalizedString("effect_streak_bonus", comment: "Streak Bonus")
                    case .doublePoints: return NSLocalizedString("effect_double_points", comment: "Double Points")
                    case .luckyCharm: return NSLocalizedString("effect_lucky_charm", comment: "Lucky Charm")
                    case .protection: return NSLocalizedString("effect_protection", comment: "Protection")
                    case .prosperity: return NSLocalizedString("effect_prosperity", comment: "Prosperity")
                    }
                }
                
                var iconName: String {
                    switch self {
                    case .moodBoost: return "heart.fill"
                    case .streakBonus: return "flame.fill"
                    case .doublePoints: return "star.fill"
                    case .luckyCharm: return "clover"
                    case .protection: return "shield.fill"
                    case .prosperity: return "dollarsign.circle.fill"
                    }
                }
            }
        }
        
        enum UnlockRequirement: Codable {
            case level(Int)
            case streak(Int)
            case achievement(String)
            case eventProgress(Double)
            case socialShare(Int)
            
            var description: String {
                switch self {
                case .level(let level):
                    return String(format: NSLocalizedString("unlock_level", comment: ""), level)
                case .streak(let days):
                    return String(format: NSLocalizedString("unlock_streak", comment: ""), days)
                case .achievement(let name):
                    return String(format: NSLocalizedString("unlock_achievement", comment: ""), name)
                case .eventProgress(let progress):
                    return String(format: NSLocalizedString("unlock_event_progress", comment: ""), Int(progress * 100))
                case .socialShare(let count):
                    return String(format: NSLocalizedString("unlock_social_share", comment: ""), count)
                }
            }
        }
    }
    
    struct EventReward: Identifiable, Codable {
        let id = UUID()
        let name: String
        let description: String
        let type: RewardType
        let value: String
        let isClaimed: Bool
        let claimDate: Date?
        
        enum RewardType: String, CaseIterable, Codable {
            case badge = "badge"
            case ritual = "ritual"
            case points = "points"
            case title = "title"
            case avatar = "avatar"
            case theme = "theme"
            
            var displayName: String {
                switch self {
                case .badge: return NSLocalizedString("reward_badge", comment: "Badge")
                case .ritual: return NSLocalizedString("reward_ritual", comment: "Ritual")
                case .points: return NSLocalizedString("reward_points", comment: "Points")
                case .title: return NSLocalizedString("reward_title", comment: "Title")
                case .avatar: return NSLocalizedString("reward_avatar", comment: "Avatar")
                case .theme: return NSLocalizedString("reward_theme", comment: "Theme")
                }
            }
            
            var iconName: String {
                switch self {
                case .badge: return "rosette"
                case .ritual: return "star.circle"
                case .points: return "plus.circle"
                case .title: return "textformat"
                case .avatar: return "person.crop.circle"
                case .theme: return "paintbrush"
                }
            }
        }
    }
    
    struct EventChallenge: Identifiable, Codable {
        let id = UUID()
        let title: String
        let description: String
        let type: ChallengeType
        let target: Int
        let progress: Int
        let reward: EventReward
        let isCompleted: Bool
        
        enum ChallengeType: String, CaseIterable, Codable {
            case rituals = "rituals"
            case specialRituals = "special_rituals"
            case streak = "streak"
            case social = "social"
            case collection = "collection"
            
            var displayName: String {
                switch self {
                case .rituals: return NSLocalizedString("challenge_rituals", comment: "Complete Rituals")
                case .specialRituals: return NSLocalizedString("challenge_special_rituals", comment: "Special Rituals")
                case .streak: return NSLocalizedString("challenge_streak", comment: "Maintain Streak")
                case .social: return NSLocalizedString("challenge_social", comment: "Social Activities")
                case .collection: return NSLocalizedString("challenge_collection", comment: "Collection")
                }
            }
        }
        
        var progressPercentage: Double {
            return min(Double(progress) / Double(target), 1.0)
        }
    }
    
    var isCurrentlyActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: endDate)
        return max(0, components.day ?? 0)
    }
    
    var progressPercentage: Double {
        let totalDuration = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        return min(elapsed / totalDuration, 1.0)
    }
}

// MARK: - Seasonal Events Manager

class SeasonalEventManager: ObservableObject {
    @Published var currentEvents: [SeasonalEvent] = []
    @Published var upcomingEvents: [SeasonalEvent] = []
    @Published var pastEvents: [SeasonalEvent] = []
    @Published var unlockedRituals: [UUID] = []
    @Published var eventProgress: [UUID: Double] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let unlockedRitualsKey = "unlockedEventRituals"
    private let eventProgressKey = "eventProgress"
    
    init() {
        setupSeasonalEvents()
        loadEventData()
        updateEventStatus()
    }
    
    // MARK: - Event Setup
    
    private func setupSeasonalEvents() {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        // Chinese New Year Event
        let chineseNewYearStart = calendar.date(from: DateComponents(year: currentYear, month: 2, day: 1)) ?? now
        let chineseNewYearEnd = calendar.date(from: DateComponents(year: currentYear, month: 2, day: 15)) ?? now
        
        let chineseNewYear = SeasonalEvent(
            id: UUID(),
            name: NSLocalizedString("event_chinese_new_year", comment: "Chinese New Year"),
            description: NSLocalizedString("event_chinese_new_year_desc", comment: "Celebrate the Year of the Dragon with special rituals and rewards!"),
            type: .cultural,
            startDate: chineseNewYearStart,
            endDate: chineseNewYearEnd,
            theme: SeasonalEvent.EventTheme(
                primaryColor: "#DC143C",
                secondaryColor: "#FFD700",
                backgroundColor: "#FFF8DC",
                accentColor: "#FF6347",
                iconName: "dragon",
                backgroundImage: "chinese_new_year_bg"
            ),
            specialRituals: [
                SeasonalEvent.SpecialRitual(
                    id: UUID(),
                    name: NSLocalizedString("ritual_dragon_dance", comment: "Dragon Dance"),
                    description: NSLocalizedString("ritual_dragon_dance_desc", comment: "Perform the traditional dragon dance for prosperity and good fortune."),
                    icon: "dragon",
                    category: "prosperity",
                    rarity: .legendary,
                    effects: [
                        SeasonalEvent.SpecialRitual.RitualEffect(
                            type: .prosperity,
                            value: 2.0,
                            duration: 86400,
                            description: NSLocalizedString("effect_prosperity_desc", comment: "Double prosperity effects for 24 hours")
                        ),
                        SeasonalEvent.SpecialRitual.RitualEffect(
                            type: .streakBonus,
                            value: 2.0,
                            duration: nil,
                            description: NSLocalizedString("effect_streak_bonus_desc", comment: "Double streak bonus")
                        )
                    ],
                    unlockRequirement: .eventProgress(0.5),
                    isLimited: true,
                    usageLimit: 10,
                    currentUsage: 0
                ),
                SeasonalEvent.SpecialRitual(
                    id: UUID(),
                    name: NSLocalizedString("ritual_red_envelope", comment: "Red Envelope"),
                    description: NSLocalizedString("ritual_red_envelope_desc", comment: "Share luck and prosperity with the red envelope ritual."),
                    icon: "envelope.fill",
                    category: "luck",
                    rarity: .epic,
                    effects: [
                        SeasonalEvent.SpecialRitual.RitualEffect(
                            type: .luckyCharm,
                            value: 1.5,
                            duration: 43200,
                            description: NSLocalizedString("effect_lucky_charm_desc", comment: "Increased luck for 12 hours")
                        )
                    ],
                    unlockRequirement: .level(5),
                    isLimited: false,
                    usageLimit: nil,
                    currentUsage: 0
                ),
                SeasonalEvent.SpecialRitual(
                    id: UUID(),
                    name: NSLocalizedString("ritual_lantern_lighting", comment: "Lantern Lighting"),
                    description: NSLocalizedString("ritual_lantern_lighting_desc", comment: "Light lanterns to guide good fortune into your life."),
                    icon: "lightbulb.fill",
                    category: "guidance",
                    rarity: .rare,
                    effects: [
                        SeasonalEvent.SpecialRitual.RitualEffect(
                            type: .moodBoost,
                            value: 1.3,
                            duration: 21600,
                            description: NSLocalizedString("effect_mood_boost_desc", comment: "Boost mood by 30% for 6 hours")
                        )
                    ],
                    unlockRequirement: .streak(3),
                    isLimited: false,
                    usageLimit: nil,
                    currentUsage: 0
                )
            ],
            rewards: [
                SeasonalEvent.EventReward(
                    name: NSLocalizedString("reward_dragon_master", comment: "Dragon Master"),
                    description: NSLocalizedString("reward_dragon_master_desc", comment: "Complete all Chinese New Year challenges"),
                    type: .badge,
                    value: "dragon_master_badge",
                    isClaimed: false,
                    claimDate: nil
                ),
                SeasonalEvent.EventReward(
                    name: NSLocalizedString("reward_prosperity_title", comment: "Prosperity Bringer"),
                    description: NSLocalizedString("reward_prosperity_title_desc", comment: "Earned during Chinese New Year event"),
                    type: .title,
                    value: "prosperity_title",
                    isClaimed: false,
                    claimDate: nil
                )
            ],
            challenges: [
                SeasonalEvent.EventChallenge(
                    title: NSLocalizedString("challenge_dragon_dance", comment: "Dragon Dance Master"),
                    description: NSLocalizedString("challenge_dragon_dance_desc", comment: "Perform the Dragon Dance ritual 5 times"),
                    type: .specialRituals,
                    target: 5,
                    progress: 0,
                    reward: SeasonalEvent.EventReward(
                        name: NSLocalizedString("reward_dragon_essence", comment: "Dragon Essence"),
                        description: "",
                        type: .ritual,
                        value: "dragon_essence",
                        isClaimed: false,
                        claimDate: nil
                    ),
                    isCompleted: false
                ),
                SeasonalEvent.EventChallenge(
                    title: NSLocalizedString("challenge_lantern_collection", comment: "Lantern Collector"),
                    description: NSLocalizedString("challenge_lantern_collection_desc", comment: "Complete 10 rituals during the event"),
                    type: .rituals,
                    target: 10,
                    progress: 0,
                    reward: SeasonalEvent.EventReward(
                        name: NSLocalizedString("reward_lantern_avatar", comment: "Lantern Avatar"),
                        description: "",
                        type: .avatar,
                        value: "lantern_avatar",
                        isClaimed: false,
                        claimDate: nil
                    ),
                    isCompleted: false
                )
            ],
            isActive: false
        )
        
        // Spring Equinox Event
        let springEquinoxStart = calendar.date(from: DateComponents(year: currentYear, month: 3, day: 20)) ?? now
        let springEquinoxEnd = calendar.date(from: DateComponents(year: currentYear, month: 3, day: 23)) ?? now
        
        let springEquinox = SeasonalEvent(
            id: UUID(),
            name: NSLocalizedString("event_spring_equinox", comment: "Spring Equinox"),
            description: NSLocalizedString("event_spring_equinox_desc", comment: "Celebrate new beginnings and growth with spring rituals."),
            type: .seasonal,
            startDate: springEquinoxStart,
            endDate: springEquinoxEnd,
            theme: SeasonalEvent.EventTheme(
                primaryColor: "#90EE90",
                secondaryColor: "#FFB6C1",
                backgroundColor: "#F0FFF0",
                accentColor: "#32CD32",
                iconName: "leaf",
                backgroundImage: "spring_equinox_bg"
            ),
            specialRituals: [
                SeasonalEvent.SpecialRitual(
                    id: UUID(),
                    name: NSLocalizedString("ritual_seed_planting", comment: "Seed Planting"),
                    description: NSLocalizedString("ritual_seed_planting_desc", comment: "Plant seeds of intention for future growth."),
                    icon: "leaf.fill",
                    category: "growth",
                    rarity: .rare,
                    effects: [
                        SeasonalEvent.SpecialRitual.RitualEffect(
                            type: .moodBoost,
                            value: 1.5,
                            duration: 43200,
                            description: NSLocalizedString("effect_growth_mood", comment: "Enhanced mood for growth")
                        )
                    ],
                    unlockRequirement: .level(3),
                    isLimited: false,
                    usageLimit: nil,
                    currentUsage: 0
                )
            ],
            rewards: [
                SeasonalEvent.EventReward(
                    name: NSLocalizedString("reward_spring_guardian", comment: "Spring Guardian"),
                    description: "",
                    type: .badge,
                    value: "spring_guardian_badge",
                    isClaimed: false,
                    claimDate: nil
                )
            ],
            challenges: [
                SeasonalEvent.EventChallenge(
                    title: NSLocalizedString("challenge_spring_growth", comment: "Spring Growth"),
                    description: NSLocalizedString("challenge_spring_growth_desc", comment: "Maintain a 3-day streak during Spring Equinox"),
                    type: .streak,
                    target: 3,
                    progress: 0,
                    reward: SeasonalEvent.EventReward(
                        name: NSLocalizedString("reward_growth_charm", comment: "Growth Charm"),
                        description: "",
                        type: .ritual,
                        value: "growth_charm",
                        isClaimed: false,
                        claimDate: nil
                    ),
                    isCompleted: false
                )
            ],
            isActive: false
        )
        
        // Halloween Event
        let halloweenStart = calendar.date(from: DateComponents(year: currentYear, month: 10, day: 25)) ?? now
        let halloweenEnd = calendar.date(from: DateComponents(year: currentYear, month: 10, day: 31)) ?? now
        
        let halloween = SeasonalEvent(
            id: UUID(),
            name: NSLocalizedString("event_halloween", comment: "Halloween Mysteries"),
            description: NSLocalizedString("event_halloween_desc", comment: "Explore mysterious rituals and unlock spooky rewards!"),
            type: .holiday,
            startDate: halloweenStart,
            endDate: halloweenEnd,
            theme: SeasonalEvent.EventTheme(
                primaryColor: "#FF6600",
                secondaryColor: "#9932CC",
                backgroundColor: "#2F1B1D",
                accentColor: "#FF8C00",
                iconName: "moon.stars.fill",
                backgroundImage: "halloween_bg"
            ),
            specialRituals: [
                SeasonalEvent.SpecialRitual(
                    id: UUID(),
                    name: NSLocalizedString("ritual_pumpkin_carving", comment: "Pumpkin Carving"),
                    description: NSLocalizedString("ritual_pumpkin_carving_desc", comment: "Carve a pumpkin to ward off evil spirits."),
                    icon: "pumpkin.fill",
                    category: "protection",
                    rarity: .epic,
                    effects: [
                        SeasonalEvent.SpecialRitual.RitualEffect(
                            type: .protection,
                            value: 2.0,
                            duration: 86400,
                            description: NSLocalizedString("effect_protection_desc", comment: "Strong protection for 24 hours")
                        )
                    ],
                    unlockRequirement: .eventProgress(0.3),
                    isLimited: true,
                    usageLimit: 7,
                    currentUsage: 0
                )
            ],
            rewards: [
                SeasonalEvent.EventReward(
                    name: NSLocalizedString("reward_halloween_master", comment: "Halloween Master"),
                    description: "",
                    type: .badge,
                    value: "halloween_master_badge",
                    isClaimed: false,
                    claimDate: nil
                )
            ],
            challenges: [
                SeasonalEvent.EventChallenge(
                    title: NSLocalizedString("challenge_spooky_rituals", comment: "Spooky Rituals"),
                    description: NSLocalizedString("challenge_spooky_rituals_desc", comment: "Complete 15 rituals during Halloween"),
                    type: .rituals,
                    target: 15,
                    progress: 0,
                    reward: SeasonalEvent.EventReward(
                        name: NSLocalizedString("reward_ghost_charm", comment: "Ghost Charm"),
                        description: "",
                        type: .ritual,
                        value: "ghost_charm",
                        isClaimed: false,
                        claimDate: nil
                    ),
                    isCompleted: false
                )
            ],
            isActive: false
        )
        
        // Christmas Event
        let christmasStart = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 20)) ?? now
        let christmasEnd = calendar.date(from: DateComponents(year: currentYear, month: 12, day: 31)) ?? now
        
        let christmas = SeasonalEvent(
            id: UUID(),
            name: NSLocalizedString("event_christmas", comment: "Christmas Magic"),
            description: NSLocalizedString("event_christmas_desc", comment: "Experience the magic of Christmas with special rituals and rewards!"),
            type: .holiday,
            startDate: christmasStart,
            endDate: christmasEnd,
            theme: SeasonalEvent.EventTheme(
                primaryColor: "#DC143C",
                secondaryColor: "#228B22",
                backgroundColor: "#F0F8FF",
                accentColor: "#FFD700",
                iconName: "tree.fill",
                backgroundImage: "christmas_bg"
            ),
            specialRituals: [
                SeasonalEvent.SpecialRitual(
                    id: UUID(),
                    name: NSLocalizedString("ritual_bell_ringing", comment: "Bell Ringing"),
                    description: NSLocalizedString("ritual_bell_ringing_desc", comment: "Ring bells to spread joy and peace."),
                    icon: "bell.fill",
                    category: "joy",
                    rarity: .rare,
                    effects: [
                        SeasonalEvent.SpecialRitual.RitualEffect(
                            type: .moodBoost,
                            value: 2.0,
                            duration: 43200,
                            description: NSLocalizedString("effect_joy_boost", comment: "Double joy and happiness")
                        )
                    ],
                    unlockRequirement: .level(2),
                    isLimited: false,
                    usageLimit: nil,
                    currentUsage: 0
                )
            ],
            rewards: [
                SeasonalEvent.EventReward(
                    name: NSLocalizedString("reward_christmas_angel", comment: "Christmas Angel"),
                    description: "",
                    type: .badge,
                    value: "christmas_angel_badge",
                    isClaimed: false,
                    claimDate: nil
                )
            ],
            challenges: [
                SeasonalEvent.EventChallenge(
                    title: NSLocalizedString("challenge_twelve_days", comment: "Twelve Days of Rituals"),
                    description: NSLocalizedString("challenge_twelve_days_desc", comment: "Complete at least one ritual each day for 12 days"),
                    type: .streak,
                    target: 12,
                    progress: 0,
                    reward: SeasonalEvent.EventReward(
                        name: NSLocalizedString("reward_holiday_spirit", comment: "Holiday Spirit"),
                        description: "",
                        type: .ritual,
                        value: "holiday_spirit",
                        isClaimed: false,
                        claimDate: nil
                    ),
                    isCompleted: false
                )
            ],
            isActive: false
        )
        
        allEvents = [chineseNewYear, springEquinox, halloween, christmas]
        updateEventStatus()
    }
    
    private var allEvents: [SeasonalEvent] = [] {
        didSet {
            updateEventStatus()
        }
    }
    
    private func updateEventStatus() {
        let now = Date()
        
        currentEvents = allEvents.filter { $0.isCurrentlyActive }
        upcomingEvents = allEvents.filter { $0.startDate > now }.sorted { $0.startDate < $1.startDate }
        pastEvents = allEvents.filter { $0.endDate < now }.sorted { $0.endDate > $1.endDate }
    }
    
    // MARK: - Event Progress Tracking
    
    func updateEventProgress(eventId: UUID, progress: Double) {
        eventProgress[eventId] = progress
        saveEventData()
        
        // Check for ritual unlocks
        if let event = currentEvents.first(where: { $0.id == eventId }) {
            checkRitualUnlocks(event: event)
        }
    }
    
    func completeRitual(_ ritualId: UUID) {
        // Update progress for relevant challenges
        for event in currentEvents {
            for i in 0..<event.challenges.count {
                var challenge = event.challenges[i]
                
                if !challenge.isCompleted {
                    if challenge.type == .rituals {
                        challenge.progress += 1
                    } else if challenge.type == .specialRituals {
                        // Check if it's a special ritual
                        if event.specialRituals.contains(where: { $0.id == ritualId }) {
                            challenge.progress += 1
                        }
                    }
                    
                    if challenge.progress >= challenge.target {
                        challenge.isCompleted = true
                        unlockReward(challenge.reward)
                    }
                    
                    event.challenges[i] = challenge
                }
            }
            
            // Update overall event progress
            let totalChallenges = event.challenges.count
            let completedChallenges = event.challenges.filter { $0.isCompleted }.count
            let progress = Double(completedChallenges) / Double(totalChallenges)
            
            updateEventProgress(eventId: event.id, progress: progress)
        }
    }
    
    private func checkRitualUnlocks(event: SeasonalEvent) {
        let progress = eventProgress[event.id] ?? 0.0
        
        for ritual in event.specialRituals {
            if !unlockedRituals.contains(ritual.id) {
                if let requirement = ritual.unlockRequirement {
                    let shouldUnlock: Bool
                    
                    switch requirement {
                    case .eventProgress(let requiredProgress):
                        shouldUnlock = progress >= requiredProgress
                    case .level(let requiredLevel):
                        shouldUnlock = true // This would check user level
                    case .streak(let requiredStreak):
                        shouldUnlock = true // This would check current streak
                    case .achievement(let achievementName):
                        shouldUnlock = true // This would check achievements
                    case .socialShare(let requiredShares):
                        shouldUnlock = true // This would check share count
                    }
                    
                    if shouldUnlock {
                        unlockRitual(ritual.id)
                    }
                }
            }
        }
    }
    
    func unlockRitual(_ ritualId: UUID) {
        unlockedRituals.append(ritualId)
        saveEventData()
        
        // Show unlock notification
        if let event = currentEvents.first(where: { event in
            event.specialRituals.contains { $0.id == ritualId }
        }) {
            if let ritual = event.specialRituals.first(where: { $0.id == ritualId }) {
                showRitualUnlockNotification(ritual: ritual, event: event)
            }
        }
    }
    
    private func unlockReward(_ reward: SeasonalEvent.EventReward) {
        // This would handle reward unlocking
        print("Unlocked reward: \(reward.name)")
    }
    
    private func showRitualUnlockNotification(ritual: SeasonalEvent.SpecialRitual, event: SeasonalEvent) {
        // This would show a notification
        print("Unlocked ritual: \(ritual.name) from event: \(event.name)")
    }
    
    // MARK: - Data Persistence
    
    private func loadEventData() {
        if let data = userDefaults.data(forKey: unlockedRitualsKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            unlockedRituals = decoded
        }
        
        if let data = userDefaults.data(forKey: eventProgressKey),
           let decoded = try? JSONDecoder().decode([UUID: Double].self, from: data) {
            eventProgress = decoded
        }
    }
    
    private func saveEventData() {
        if let encoded = try? JSONEncoder().encode(unlockedRituals) {
            userDefaults.set(encoded, forKey: unlockedRitualsKey)
        }
        
        if let encoded = try? JSONEncoder().encode(eventProgress) {
            userDefaults.set(encoded, forKey: eventProgressKey)
        }
    }
    
    // MARK: - Helper Methods
    
    func getEvent(by id: UUID) -> SeasonalEvent? {
        return allEvents.first { $0.id == id }
    }
    
    func isRitualUnlocked(_ ritualId: UUID) -> Bool {
        return unlockedRituals.contains(ritualId)
    }
    
    func getAvailableRituals() -> [SeasonalEvent.SpecialRitual] {
        var availableRituals: [SeasonalEvent.SpecialRitual] = []
        
        for event in currentEvents {
            for ritual in event.specialRituals {
                if isRitualUnlocked(ritual.id) {
                    // Check usage limits
                    if !ritual.isLimited || ritual.currentUsage < (ritual.usageLimit ?? 0) {
                        availableRituals.append(ritual)
                    }
                }
            }
        }
        
        return availableRituals
    }
}

// MARK: - Seasonal Events Views

struct SeasonalEventsView: View {
    @StateObject private var eventManager = SeasonalEventManager()
    @State private var selectedEvent: SeasonalEvent?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Events
                    if !eventManager.currentEvents.isEmpty {
                        SectionView(
                            title: NSLocalizedString("current_events", comment: "Current Events"),
                            events: eventManager.currentEvents,
                            onTap: { selectedEvent = $0 }
                        )
                    }
                    
                    // Upcoming Events
                    if !eventManager.upcomingEvents.isEmpty {
                        SectionView(
                            title: NSLocalizedString("upcoming_events", comment: "Upcoming Events"),
                            events: eventManager.upcomingEvents,
                            onTap: { selectedEvent = $0 }
                        )
                    }
                    
                    // Past Events
                    if !eventManager.pastEvents.isEmpty {
                        SectionView(
                            title: NSLocalizedString("past_events", comment: "Past Events"),
                            events: eventManager.pastEvents,
                            onTap: { selectedEvent = $0 }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("seasonal_events", comment: "Seasonal Events"))
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
                .environmentObject(eventManager)
        }
    }
}

struct SectionView: View {
    let title: String
    let events: [SeasonalEvent]
    let onTap: (SeasonalEvent) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(events) { event in
                EventCard(event: event, onTap: onTap)
            }
        }
    }
}

struct EventCard: View {
    let event: SeasonalEvent
    let onTap: (SeasonalEvent) -> Void
    
    var body: some View {
        Button(action: {
            onTap(event)
        }) {
            HStack {
                // Event Icon
                Image(systemName: event.theme.iconName)
                    .font(.title2)
                    .foregroundColor(event.theme.primaryUIColor)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(event.type.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(event.theme.primaryUIColor.opacity(0.2))
                            .foregroundColor(event.theme.primaryUIColor)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        if event.isCurrentlyActive {
                            Text("\(event.daysRemaining) days left")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else {
                            Text(formatDate(event.startDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(event.isCurrentlyActive ? event.theme.backgroundUIColor : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct EventDetailView: View {
    let event: SeasonalEvent
    @EnvironmentObject var eventManager: SeasonalEventManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Overview
                EventOverviewView(event: event)
                    .environmentObject(eventManager)
                    .tabItem {
                        Label(NSLocalizedString("overview", comment: "Overview"), systemImage: "info.circle")
                    }
                    .tag(0)
                
                // Special Rituals
                EventRitualsView(event: event)
                    .environmentObject(eventManager)
                    .tabItem {
                        Label(NSLocalizedString("rituals", comment: "Rituals"), systemImage: "star.circle")
                    }
                    .tag(1)
                
                // Challenges
                EventChallengesView(event: event)
                    .environmentObject(eventManager)
                    .tabItem {
                        Label(NSLocalizedString("challenges", comment: "Challenges"), systemImage: "target")
                    }
                    .tag(2)
                
                // Rewards
                EventRewardsView(event: event)
                    .environmentObject(eventManager)
                    .tabItem {
                        Label(NSLocalizedString("rewards", comment: "Rewards"), systemImage: "gift")
                    }
                    .tag(3)
            }
            .navigationTitle(event.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text(NSLocalizedString("done", comment: "Done"))
                    }
                }
            }
        }
    }
}

struct EventOverviewView: View {
    let event: SeasonalEvent
    @EnvironmentObject var eventManager: SeasonalEventManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Event Header
                VStack(spacing: 16) {
                    Image(systemName: event.theme.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(event.theme.primaryUIColor)
                    
                    Text(event.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(event.theme.backgroundUIColor)
                .cornerRadius(16)
                
                // Event Stats
                VStack(spacing: 16) {
                    if event.isCurrentlyActive {
                        // Progress Bar
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("event_progress", comment: "Event Progress"))
                                .font(.headline)
                            
                            ProgressView(value: event.progressPercentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: event.theme.primaryUIColor))
                                .scaleEffect(y: 2)
                            
                            Text("\(Int(event.progressPercentage * 100))% Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Time Remaining
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(event.theme.accentUIColor)
                            
                            Text("\(event.daysRemaining) days remaining")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Event Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("event_details", comment: "Event Details"))
                            .font(.headline)
                        
                        DetailRow(
                            title: NSLocalizedString("event_type", comment: "Type"),
                            value: event.type.displayName
                        )
                        
                        DetailRow(
                            title: NSLocalizedString("event_duration", comment: "Duration"),
                            value: "\(formatDate(event.startDate)) - \(formatDate(event.endDate))"
                        )
                        
                        DetailRow(
                            title: NSLocalizedString("special_rituals", comment: "Special Rituals"),
                            value: "\(event.specialRituals.count)"
                        )
                        
                        DetailRow(
                            title: NSLocalizedString("total_challenges", comment: "Total Challenges"),
                            value: "\(event.challenges.count)"
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

struct EventRitualsView: View {
    let event: SeasonalEvent
    @EnvironmentObject var eventManager: SeasonalEventManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(event.specialRituals) { ritual in
                    SpecialRitualCard(ritual: ritual, event: event)
                        .environmentObject(eventManager)
                }
            }
            .padding()
        }
    }
}

struct SpecialRitualCard: View {
    let ritual: SeasonalEvent.SpecialRitual
    let event: SeasonalEvent
    @EnvironmentObject var eventManager: SeasonalEventManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: ritual.icon)
                    .font(.title2)
                    .foregroundColor(event.theme.primaryUIColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(ritual.name)
                        .font(.headline)
                    
                    Text(ritual.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Rarity Badge
                Text(ritual.rarity.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(ritual.rarity.backgroundColor)
                    .foregroundColor(ritual.rarity.color)
                    .cornerRadius(4)
            }
            
            // Description
            Text(ritual.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            // Effects
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("ritual_effects", comment: "Effects"))
                    .font(.caption)
                    .fontWeight(.medium)
                
                ForEach(ritual.effects, id: \.type) { effect in
                    HStack {
                        Image(systemName: effect.type.iconName)
                            .font(.caption)
                            .foregroundColor(event.theme.accentUIColor)
                        
                        Text(effect.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Unlock Requirement
            if let requirement = ritual.unlockRequirement {
                HStack {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(requirement.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if eventManager.isRitualUnlocked(ritual.id) {
                        Text(NSLocalizedString("unlocked", comment: "Unlocked"))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Usage Limit
            if ritual.isLimited {
                HStack {
                    Image(systemName: "number.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: NSLocalizedString("usage_limit", comment: "Uses: %d/%d"), ritual.currentUsage, ritual.usageLimit ?? 0))
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
}

struct EventChallengesView: View {
    let event: SeasonalEvent
    @EnvironmentObject var eventManager: SeasonalEventManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(event.challenges) { challenge in
                    EventChallengeCard(challenge: challenge, event: event)
                }
            }
            .padding()
        }
    }
}

struct EventChallengeCard: View {
    let challenge: SeasonalEvent.EventChallenge
    let event: SeasonalEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(challenge.title)
                    .font(.headline)
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(challenge.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(challenge.progress)/\(challenge.target)")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(challenge.progressPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: challenge.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: event.theme.primaryUIColor))
                    .scaleEffect(y: 1.5)
            }
            
            // Reward
            HStack {
                Image(systemName: challenge.reward.type.iconName)
                    .font(.caption)
                    .foregroundColor(event.theme.accentUIColor)
                
                Text(challenge.reward.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if challenge.isCompleted && !challenge.reward.isClaimed {
                    Button(NSLocalizedString("claim", comment: "Claim")) {
                        // Claim reward
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(event.theme.primaryUIColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct EventRewardsView: View {
    let event: SeasonalEvent
    @EnvironmentObject var eventManager: SeasonalEventManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(event.rewards) { reward in
                    EventRewardCard(reward: reward, event: event)
                }
            }
            .padding()
        }
    }
}

struct EventRewardCard: View {
    let reward: SeasonalEvent.EventReward
    let event: SeasonalEvent
    
    var body: some View {
        HStack {
            Image(systemName: reward.type.iconName)
                .font(.title2)
                .foregroundColor(event.theme.primaryUIColor)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.name)
                    .font(.headline)
                
                Text(reward.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if reward.isClaimed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(NSLocalizedString("claim", comment: "Claim")) {
                    // Claim reward
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(event.theme.primaryUIColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Color Extension for hex support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
