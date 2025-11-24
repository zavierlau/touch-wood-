//
//  WoodStyles.swift
//  TouchWoodApp
//
//  Created by zav on 24/11/2025.
//

import SwiftUI
import Foundation

// MARK: - Wood Style Models
struct WoodStyle: Identifiable, Codable {
    let id = UUID()
    let name: String
    let displayName: String
    let description: String
    let color: String
    let texture: String
    let soundEffect: String
    let hapticPattern: String
    let isUnlocked: Bool
    let unlockRequirement: String?
    let rarity: WoodRarity
    let previewImage: String
    
    enum WoodRarity: String, Codable, CaseIterable {
        case common = "common"
        case uncommon = "uncommon" 
        case rare = "rare"
        case epic = "epic"
        case legendary = "legendary"
        
        var displayName: String {
            switch self {
            case .common: return NSLocalizedString("rarity_common", comment: "")
            case .uncommon: return NSLocalizedString("rarity_uncommon", comment: "")
            case .rare: return NSLocalizedString("rarity_rare", comment: "")
            case .epic: return NSLocalizedString("rarity_epic", comment: "")
            case .legendary: return NSLocalizedString("rarity_legendary", comment: "")
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
    }
}

// MARK: - Wood Styles Manager
class WoodStylesManager: ObservableObject {
    @Published var selectedWoodStyle: WoodStyle
    @Published var availableStyles: [WoodStyle]
    @Published var unlockedStyles: Set<UUID>
    
    private let selectedStyleKey = "selected_wood_style"
    private let unlockedStylesKey = "unlocked_wood_styles"
    
    init() {
        // Initialize with default styles
        self.availableStyles = Self.createDefaultStyles()
        self.unlockedStyles = Self.loadUnlockedStyles()
        
        // Load selected style or use default
        if let selectedId = UserDefaults.standard.string(forKey: selectedStyleKey),
           let uuid = UUID(uuidString: selectedId),
           let style = availableStyles.first(where: { $0.id == uuid }) {
            self.selectedWoodStyle = style
        } else {
            self.selectedWoodStyle = availableStyles.first(where: { $0.name == "oak" }) ?? availableStyles[0]
        }
    }
    
    // MARK: - Default Styles
    static func createDefaultStyles() -> [WoodStyle] {
        return [
            // Common Woods (3 styles)
            WoodStyle(
                name: "oak",
                displayName: NSLocalizedString("wood_oak", comment: ""),
                description: NSLocalizedString("wood_oak_desc", comment: ""),
                color: "#8B4513",
                texture: "wood_texture_oak",
                soundEffect: "knock_wood_1",
                hapticPattern: "medium",
                isUnlocked: true,
                unlockRequirement: nil,
                rarity: .common,
                previewImage: "oak_wood"
            ),
            WoodStyle(
                name: "pine",
                displayName: NSLocalizedString("wood_pine", comment: ""),
                description: NSLocalizedString("wood_pine_desc", comment: ""),
                color: "#DEB887",
                texture: "wood_texture_pine",
                soundEffect: "knock_wood_2",
                hapticPattern: "light",
                isUnlocked: true,
                unlockRequirement: nil,
                rarity: .common,
                previewImage: "pine_wood"
            ),
            WoodStyle(
                name: "maple",
                displayName: NSLocalizedString("wood_maple", comment: ""),
                description: NSLocalizedString("wood_maple_desc", comment: ""),
                color: "#A0522D",
                texture: "wood_texture_maple",
                soundEffect: "knock_wood_3",
                hapticPattern: "medium",
                isUnlocked: true,
                unlockRequirement: nil,
                rarity: .common,
                previewImage: "maple_wood"
            ),
            
            // Uncommon Woods (2 styles)
            WoodStyle(
                name: "cherry",
                displayName: NSLocalizedString("wood_cherry", comment: ""),
                description: NSLocalizedString("wood_cherry_desc", comment: ""),
                color: "#8B3A3A",
                texture: "wood_texture_cherry",
                soundEffect: "knock_wood_4",
                hapticPattern: "medium",
                isUnlocked: false,
                unlockRequirement: "complete_5_rituals",
                rarity: .uncommon,
                previewImage: "cherry_wood"
            ),
            WoodStyle(
                name: "walnut",
                displayName: NSLocalizedString("wood_walnut", comment: ""),
                description: NSLocalizedString("wood_walnut_desc", comment: ""),
                color: "#654321",
                texture: "wood_texture_walnut",
                soundEffect: "knock_wood_5",
                hapticPattern: "heavy",
                isUnlocked: false,
                unlockRequirement: "maintain_3_day_streak",
                rarity: .uncommon,
                previewImage: "walnut_wood"
            ),
            
            // Rare Woods (2 styles)
            WoodStyle(
                name: "ebony",
                displayName: NSLocalizedString("wood_ebony", comment: ""),
                description: NSLocalizedString("wood_ebony_desc", comment: ""),
                color: "#1C1C1C",
                texture: "wood_texture_ebony",
                soundEffect: "knock_wood_6",
                hapticPattern: "heavy",
                isUnlocked: false,
                unlockRequirement: "complete_25_rituals",
                rarity: .rare,
                previewImage: "ebony_wood"
            ),
            WoodStyle(
                name: "bamboo",
                displayName: NSLocalizedString("wood_bamboo", comment: ""),
                description: NSLocalizedString("wood_bamboo_desc", comment: ""),
                color: "#6B8E23",
                texture: "wood_texture_bamboo",
                soundEffect: "knock_bamboo",
                hapticPattern: "pulse",
                isUnlocked: false,
                unlockRequirement: "unlock_3_achievements",
                rarity: .rare,
                previewImage: "bamboo_wood"
            ),
            
            // Epic Woods (2 styles)
            WoodStyle(
                name: "sandalwood",
                displayName: NSLocalizedString("wood_sandalwood", comment: ""),
                description: NSLocalizedString("wood_sandalwood_desc", comment: ""),
                color: "#CD853F",
                texture: "wood_texture_sandalwood",
                soundEffect: "knock_sandalwood",
                hapticPattern: "wave",
                isUnlocked: false,
                unlockRequirement: "maintain_14_day_streak",
                rarity: .epic,
                previewImage: "sandalwood_wood"
            ),
            WoodStyle(
                name: "rosewood",
                displayName: NSLocalizedString("wood_rosewood", comment: ""),
                description: NSLocalizedString("wood_rosewood_desc", comment: ""),
                color: "#8B4513",
                texture: "wood_texture_rosewood",
                soundEffect: "knock_rosewood",
                hapticPattern: "wave",
                isUnlocked: false,
                unlockRequirement: "share_5_times",
                rarity: .epic,
                previewImage: "rosewood_wood"
            ),
            
            // Legendary Wood (1 style)
            WoodStyle(
                name: "dragonwood",
                displayName: NSLocalizedString("wood_dragonwood", comment: ""),
                description: NSLocalizedString("wood_dragonwood_desc", comment: ""),
                color: "#B22222",
                texture: "wood_texture_dragonwood",
                soundEffect: "knock_dragonwood",
                hapticPattern: "custom",
                isUnlocked: false,
                unlockRequirement: "complete_seasonal_event",
                rarity: .legendary,
                previewImage: "dragonwood_wood"
            )
        ]
    }
    
    // MARK: - Data Management
    private static func loadUnlockedStyles() -> Set<UUID> {
        if let data = UserDefaults.standard.data(forKey: "unlocked_wood_styles"),
           let styles = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            return styles
        }
        
        // Unlock common styles by default
        let defaultUnlocked = Set<UUID>()
        let defaultStyles = createDefaultStyles()
        for style in defaultStyles {
            if style.rarity == .common {
                var unlocked = defaultUnlocked
                unlocked.insert(style.id)
                return unlocked
            }
        }
        return defaultUnlocked
    }
    
    private func saveUnlockedStyles() {
        if let data = try? JSONEncoder().encode(unlockedStyles) {
            UserDefaults.standard.set(data, forKey: unlockedStylesKey)
        }
    }
    
    // MARK: - Style Management
    func selectWoodStyle(_ style: WoodStyle) {
        guard unlockedStyles.contains(style.id) else { return }
        
        selectedWoodStyle = style
        UserDefaults.standard.set(style.id.uuidString, forKey: selectedStyleKey)
        
        // Trigger haptic feedback for selection
        HapticFeedback.shared.light()
    }
    
    func unlockStyle(_ style: WoodStyle) {
        unlockedStyles.insert(style.id)
        saveUnlockedStyles()
        
        // Trigger celebration haptic
        HapticFeedback.shared.celebration()
    }
    
    func isStyleUnlocked(_ style: WoodStyle) -> Bool {
        return unlockedStyles.contains(style.id) || style.isUnlocked
    }
    
    func canUnlockStyle(_ style: WoodStyle) -> Bool {
        guard !isStyleUnlocked(style),
              let requirement = style.unlockRequirement else { return false }
        
        switch requirement {
        case "complete_5_rituals":
            return UserProgress.shared.totalRitualsCompleted >= 5
        case "maintain_3_day_streak":
            return UserProgress.shared.bestStreak >= 3
        case "complete_25_rituals":
            return UserProgress.shared.totalRitualsCompleted >= 25
        case "unlock_3_achievements":
            return AchievementSystem.shared.unlockedAchievements.count >= 3
        case "maintain_14_day_streak":
            return UserProgress.shared.bestStreak >= 14
        case "share_5_times":
            return SocialSharingManager.shared.shareCount >= 5
        case "complete_seasonal_event":
            return SeasonalEventManager.shared.completedEventsCount >= 1
        default:
            return false
        }
    }
    
    func getUnlockRequirementText(_ style: WoodStyle) -> String {
        guard let requirement = style.unlockRequirement else { return "" }
        
        switch requirement {
        case "complete_5_rituals":
            return NSLocalizedString("unlock_complete_5_rituals", comment: "")
        case "maintain_3_day_streak":
            return NSLocalizedString("unlock_maintain_3_day_streak", comment: "")
        case "complete_25_rituals":
            return NSLocalizedString("unlock_complete_25_rituals", comment: "")
        case "unlock_3_achievements":
            return NSLocalizedString("unlock_3_achievements", comment: "")
        case "maintain_14_day_streak":
            return NSLocalizedString("unlock_maintain_14_day_streak", comment: "")
        case "share_5_times":
            return NSLocalizedString("unlock_share_5_times", comment: "")
        case "complete_seasonal_event":
            return NSLocalizedString("unlock_complete_seasonal_event", comment: "")
        default:
            return ""
        }
    }
    
    // MARK: - Progress Tracking
    func getProgressForRequirement(_ requirement: String) -> (current: Int, total: Int) {
        switch requirement {
        case "complete_5_rituals":
            return (UserProgress.shared.totalRitualsCompleted, 5)
        case "maintain_3_day_streak":
            return (UserProgress.shared.bestStreak, 3)
        case "complete_25_rituals":
            return (UserProgress.shared.totalRitualsCompleted, 25)
        case "unlock_3_achievements":
            return (AchievementSystem.shared.unlockedAchievements.count, 3)
        case "maintain_14_day_streak":
            return (UserProgress.shared.bestStreak, 14)
        case "share_5_times":
            return (SocialSharingManager.shared.shareCount, 5)
        case "complete_seasonal_event":
            let completed = SeasonalEventManager.shared.completedEventsCount
            return (completed, 1)
        default:
            return (0, 1)
        }
    }
    
    // MARK: - Preview Helper
    static var preview: WoodStylesManager {
        let manager = WoodStylesManager()
        // Unlock some styles for preview
        manager.unlockedStyles.insert(manager.availableStyles[3].id) // cherry
        manager.unlockedStyles.insert(manager.availableStyles[5].id) // ebony
        return manager
    }
}

// MARK: - User Progress Extension
extension UserProgress {
    var level: Int {
        // Simple level calculation based on total rituals and achievements
        let baseLevel = totalRitualsCompleted / 10
        let achievementBonus = AchievementSystem.shared.unlockedAchievements.count / 3
        return baseLevel + achievementBonus + 1
    }
}

// MARK: - Seasonal Events Extension
extension SeasonalEventManager {
    var completedAllEvents: Bool {
        return completedEventsCount >= totalEventsCount && totalEventsCount > 0
    }
    
    var completedEventsCount: Int {
        return eventProgress.values.filter { $0 >= 1.0 }.count
    }
    
    var totalEventsCount: Int {
        return events.count
    }
}

// MARK: - SwiftUI Views
struct WoodStylesView: View {
    @StateObject private var woodStylesManager = WoodStylesManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("Style Category", selection: $selectedTab) {
                    Text(NSLocalizedString("my_styles", comment: "")).tag(0)
                    Text(NSLocalizedString("all_styles", comment: "")).tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    // My Styles
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(myStyles) { style in
                                WoodStyleCard(
                                    style: style,
                                    isSelected: woodStylesManager.selectedWoodStyle.id == style.id,
                                    isUnlocked: woodStylesManager.isStyleUnlocked(style),
                                    onSelect: { woodStylesManager.selectWoodStyle(style) }
                                )
                            }
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    // All Styles
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(allStyles) { style in
                                WoodStyleCard(
                                    style: style,
                                    isSelected: woodStylesManager.selectedWoodStyle.id == style.id,
                                    isUnlocked: woodStylesManager.isStyleUnlocked(style),
                                    canUnlock: woodStylesManager.canUnlockStyle(style),
                                    onUnlock: { woodStylesManager.unlockStyle(style) },
                                    onSelect: { woodStylesManager.selectWoodStyle(style) }
                                )
                            }
                        }
                        .padding()
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle(NSLocalizedString("wood_styles", comment: ""))
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var myStyles: [WoodStyle] {
        woodStylesManager.availableStyles.filter { woodStylesManager.isStyleUnlocked($0) }
    }
    
    private var allStyles: [WoodStyle] {
        woodStylesManager.availableStyles
    }
}

struct WoodStyleCard: View {
    let style: WoodStyle
    let isSelected: Bool
    let isUnlocked: Bool
    var canUnlock: Bool = false
    var onUnlock: (() -> Void)? = nil
    var onSelect: () -> Void
    
    @State private var showingUnlockAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: style.color))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "tree.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(style.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Rarity Badge
                        Text(style.rarity.displayName.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(style.rarity.color.opacity(0.2))
                            .foregroundColor(style.rarity.color)
                            .cornerRadius(4)
                    }
                    
                    Text(style.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            // Status
            if isUnlocked {
                if isSelected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("currently_selected", comment: ""))
                            .font(.caption)
                            .foregroundColor(.green)
                        Spacer()
                    }
                } else {
                    Button(action: onSelect) {
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("select_style", comment: ""))
                                .font(.caption)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else if canUnlock {
                // Unlock requirement with progress
                VStack(alignment: .leading, spacing: 4) {
                    Text(woodStylesManager.getUnlockRequirementText(style))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    let progress = woodStylesManager.getProgressForRequirement(style.unlockRequirement ?? "")
                    
                    ProgressView(value: Double(progress.current), total: Double(progress.total))
                        .progressViewStyle(LinearProgressViewStyle(tint: style.rarity.color))
                    
                    HStack {
                        Text("\(progress.current)/\(progress.total)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if progress.current >= progress.total {
                            Button(NSLocalizedString("unlock", comment: "")) {
                                showingUnlockAlert = true
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(style.rarity.color)
                            .cornerRadius(8)
                        }
                    }
                }
            } else {
                // Locked
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary)
                    Text(NSLocalizedString("locked", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .alert(NSLocalizedString("unlock_style_title", comment: ""), isPresented: $showingUnlockAlert) {
            Button(NSLocalizedString("unlock", comment: "")) {
                onUnlock?()
            }
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("unlock_style_confirm", comment: ""))
        }
    }
    
    private var woodStylesManager: WoodStylesManager {
        .shared
    }
}

// MARK: - Wood Styles Manager Singleton
extension WoodStylesManager {
    static let shared = WoodStylesManager()
}

// MARK: - Color Extension
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

// MARK: - Preview
struct WoodStylesView_Previews: PreviewProvider {
    static var previews: some View {
        WoodStylesView()
            .environmentObject(WoodStylesManager.preview)
    }
}
