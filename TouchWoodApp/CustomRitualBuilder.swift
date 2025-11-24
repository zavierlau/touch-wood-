import SwiftUI
import PhotosUI

// MARK: - Custom Ritual Models

struct CustomRitual: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var icon: String
    var iconColor: String
    var customImageData: Data?
    var category: RitualCategory
    var customSound: String?
    var hapticPattern: HapticPattern
    var duration: Int // seconds
    var isPublic: Bool
    var createdBy: String
    var createdAt: Date
    var tags: [String]
    var difficulty: RitualDifficulty
    
    enum RitualCategory: String, CaseIterable, Codable {
        case luck = "luck"
        case gratitude = "gratitude"
        case protection = "protection"
        case prosperity = "prosperity"
        case health = "health"
        case love = "love"
        case wisdom = "wisdom"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .luck: return NSLocalizedString("category_luck", comment: "Luck")
            case .gratitude: return NSLocalizedString("category_gratitude", comment: "Gratitude")
            case .protection: return NSLocalizedString("category_protection", comment: "Protection")
            case .prosperity: return NSLocalizedString("category_prosperity", comment: "Prosperity")
            case .health: return NSLocalizedString("category_health", comment: "Health")
            case .love: return NSLocalizedString("category_love", comment: "Love")
            case .wisdom: return NSLocalizedString("category_wisdom", comment: "Wisdom")
            case .custom: return NSLocalizedString("category_custom", comment: "Custom")
            }
        }
        
        var iconName: String {
            switch self {
            case .luck: return "clover"
            case .gratitude: return "heart"
            case .protection: return "shield"
            case .prosperity: return "dollarsign.circle"
            case .health: return "cross.circle"
            case .love: return "suit.heart.fill"
            case .wisdom: return "brain.head.profile"
            case .custom: return "star"
            }
        }
        
        var color: Color {
            switch self {
            case .luck: return .green
            case .gratitude: return .pink
            case .protection: return .blue
            case .prosperity: return .yellow
            case .health: return .red
            case .love: return .purple
            case .wisdom: return .indigo
            case .custom: return .gray
            }
        }
    }
    
    enum HapticPattern: String, CaseIterable, Codable {
        case light = "light"
        case medium = "medium"
        case heavy = "heavy"
        case pulse = "pulse"
        case wave = "wave"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .light: return NSLocalizedString("haptic_light", comment: "Light")
            case .medium: return NSLocalizedString("haptic_medium", comment: "Medium")
            case .heavy: return NSLocalizedString("haptic_heavy", comment: "Heavy")
            case .pulse: return NSLocalizedString("haptic_pulse", comment: "Pulse")
            case .wave: return NSLocalizedString("haptic_wave", comment: "Wave")
            case .custom: return NSLocalizedString("haptic_custom", comment: "Custom")
            }
        }
    }
    
    enum RitualDifficulty: String, CaseIterable, Codable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        case expert = "expert"
        
        var displayName: String {
            switch self {
            case .easy: return NSLocalizedString("difficulty_easy", comment: "Easy")
            case .medium: return NSLocalizedString("difficulty_medium", comment: "Medium")
            case .hard: return NSLocalizedString("difficulty_hard", comment: "Hard")
            case .expert: return NSLocalizedString("difficulty_expert", comment: "Expert")
            }
        }
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .yellow
            case .hard: return .orange
            case .expert: return .red
            }
        }
        
        var estimatedTime: Int {
            switch self {
            case .easy: return 30
            case .medium: return 60
            case .hard: return 120
            case .expert: return 180
            }
        }
    }
}

// MARK: - Custom Ritual Manager

class CustomRitualManager: ObservableObject {
    @Published var customRituals: [CustomRitual] = []
    @Published var publicRituals: [CustomRitual] = []
    @Published var downloadedRituals: [CustomRitual] = []
    
    private let userDefaults = UserDefaults.standard
    private let customRitualsKey = "customRituals"
    private let downloadedKey = "downloadedRituals"
    
    init() {
        loadCustomRituals()
        loadPublicRituals()
    }
    
    // MARK: - Ritual Management
    
    func createRitual(_ ritual: CustomRitual) {
        customRituals.append(ritual)
        saveCustomRituals()
        
        if ritual.isPublic {
            uploadRitual(ritual)
        }
    }
    
    func updateRitual(_ ritual: CustomRitual) {
        if let index = customRituals.firstIndex(where: { $0.id == ritual.id }) {
            customRituals[index] = ritual
            saveCustomRituals()
            
            if ritual.isPublic {
                updatePublicRitual(ritual)
            }
        }
    }
    
    func deleteRitual(_ ritual: CustomRitual) {
        customRituals.removeAll { $0.id == ritual.id }
        saveCustomRituals()
        
        if ritual.isPublic {
            removePublicRitual(ritual)
        }
    }
    
    func downloadRitual(_ ritual: CustomRitual) {
        var downloadedRitual = ritual
        downloadedRitual.isPublic = false
        downloadedRitual.createdBy = "Downloaded"
        
        if !downloadedRituals.contains(where: { $0.id == ritual.id }) {
            downloadedRituals.append(downloadedRitual)
            saveDownloadedRituals()
        }
    }
    
    // MARK: - Public Rituals
    
    private func loadPublicRituals() {
        // In a real app, this would fetch from a backend
        // For now, we'll create mock public rituals
        publicRituals = [
            CustomRitual(
                id: UUID(),
                name: NSLocalizedString("public_ritual_morning_sun", comment: ""),
                description: NSLocalizedString("public_ritual_morning_sun_desc", comment: ""),
                icon: "sun.max.fill",
                iconColor: "#FFD700",
                customImageData: nil,
                category: .gratitude,
                customSound: nil,
                hapticPattern: .pulse,
                duration: 60,
                isPublic: true,
                createdBy: "SunshineGuru",
                createdAt: Date().addingTimeInterval(-86400),
                tags: ["morning", "gratitude", "sun"],
                difficulty: .easy
            ),
            CustomRitual(
                id: UUID(),
                name: NSLocalizedString("public_ritual_full_moon", comment: ""),
                description: NSLocalizedString("public_ritual_full_moon_desc", comment: ""),
                icon: "moon.fill",
                iconColor: "#C0C0C0",
                customImageData: nil,
                category: .wisdom,
                customSound: nil,
                hapticPattern: .wave,
                duration: 120,
                isPublic: true,
                createdBy: "MoonWalker",
                createdAt: Date().addingTimeInterval(-172800),
                tags: ["night", "wisdom", "moon"],
                difficulty: .medium
            ),
            CustomRitual(
                id: UUID(),
                name: NSLocalizedString("public_ritual_lucky_charm", comment: ""),
                description: NSLocalizedString("public_ritual_lucky_charm_desc", comment: ""),
                icon: "dice.fill",
                iconColor: "#00FF00",
                customImageData: nil,
                category: .luck,
                customSound: nil,
                hapticPattern: .custom,
                duration: 90,
                isPublic: true,
                createdBy: "LuckyStar",
                createdAt: Date().addingTimeInterval(-259200),
                tags: ["luck", "charm", "dice"],
                difficulty: .medium
            )
        ]
    }
    
    private func uploadRitual(_ ritual: CustomRitual) {
        // In a real app, this would upload to a backend
        print("Uploading ritual: \(ritual.name)")
    }
    
    private func updatePublicRitual(_ ritual: CustomRitual) {
        // In a real app, this would update on backend
        print("Updating public ritual: \(ritual.name)")
    }
    
    private func removePublicRitual(_ ritual: CustomRitual) {
        // In a real app, this would remove from backend
        print("Removing public ritual: \(ritual.name)")
    }
    
    // MARK: - Search and Filter
    
    func searchRituals(query: String, category: CustomRitual.RitualCategory? = nil) -> [CustomRitual] {
        var filtered = publicRituals
        
        if !query.isEmpty {
            filtered = filtered.filter { ritual in
                ritual.name.localizedCaseInsensitiveContains(query) ||
                ritual.description.localizedCaseInsensitiveContains(query) ||
                ritual.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    func getRitualsByCategory(_ category: CustomRitual.RitualCategory) -> [CustomRitual] {
        return publicRituals.filter { $0.category == category }
    }
    
    func getPopularRituals(limit: Int = 10) -> [CustomRitual] {
        // In a real app, this would be based on download count or ratings
        return Array(publicRituals.shuffled().prefix(limit))
    }
    
    func getRecentRituals(limit: Int = 10) -> [CustomRitual] {
        return Array(publicRituals.sorted { $0.createdAt > $1.createdAt }.prefix(limit))
    }
    
    // MARK: - Data Persistence
    
    private func loadCustomRituals() {
        if let data = userDefaults.data(forKey: customRitualsKey),
           let decoded = try? JSONDecoder().decode([CustomRitual].self, from: data) {
            customRituals = decoded
        }
    }
    
    private func saveCustomRituals() {
        if let encoded = try? JSONEncoder().encode(customRituals) {
            userDefaults.set(encoded, forKey: customRitualsKey)
        }
    }
    
    private func loadDownloadedRituals() {
        if let data = userDefaults.data(forKey: downloadedKey),
           let decoded = try? JSONDecoder().decode([CustomRitual].self, from: data) {
            downloadedRituals = decoded
        }
    }
    
    private func saveDownloadedRituals() {
        if let encoded = try? JSONEncoder().encode(downloadedRituals) {
            userDefaults.set(encoded, forKey: downloadedKey)
        }
    }
    
    // MARK: - Statistics
    
    var totalCustomRituals: Int {
        return customRituals.count
    }
    
    var totalPublicRituals: Int {
        return customRituals.filter { $0.isPublic }.count
    }
    
    var totalDownloaded: Int {
        return downloadedRituals.count
    }
    
    func getRitualsByCategoryCount() -> [CustomRitual.RitualCategory: Int] {
        var counts: [CustomRitual.RitualCategory: Int] = [:]
        
        for ritual in customRituals {
            counts[ritual.category, default: 0] += 1
        }
        
        return counts
    }
}

// MARK: - Ritual Builder View

struct CustomRitualBuilder: View {
    @StateObject private var ritualManager = CustomRitualManager()
    @State private var ritual = CustomRitual(
        id: UUID(),
        name: "",
        description: "",
        icon: "star.fill",
        iconColor: "#007AFF",
        customImageData: nil,
        category: .custom,
        customSound: nil,
        hapticPattern: .medium,
        duration: 60,
        isPublic: false,
        createdBy: "User",
        createdAt: Date(),
        tags: [],
        difficulty: .easy
    )
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingPreview = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information
                Section(header: Text(NSLocalizedString("builder_basic_info", comment: "Basic Information"))) {
                    TextField(NSLocalizedString("builder_ritual_name", comment: "Ritual Name"), text: $ritual.name)
                    TextField(NSLocalizedString("builder_ritual_description", comment: "Description"), text: $ritual.description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Category and Difficulty
                Section(header: Text(NSLocalizedString("builder_category_difficulty", comment: "Category & Difficulty"))) {
                    Picker(NSLocalizedString("builder_category", comment: "Category"), selection: $ritual.category) {
                        ForEach(CustomRitual.RitualCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                    
                    Picker(NSLocalizedString("builder_difficulty", comment: "Difficulty"), selection: $ritual.difficulty) {
                        ForEach(CustomRitual.RitualDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.displayName)
                                .tag(difficulty)
                        }
                    }
                }
                
                // Appearance
                Section(header: Text(NSLocalizedString("builder_appearance", comment: "Appearance"))) {
                    HStack {
                        Text(NSLocalizedString("builder_icon", comment: "Icon"))
                        Spacer()
                        Image(systemName: ritual.icon)
                            .foregroundColor(Color(hex: ritual.iconColor))
                    }
                    
                    HStack {
                        Text(NSLocalizedString("builder_color", comment: "Color"))
                        Spacer()
                        Color(hex: ritual.iconColor)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                    
                    if let imageData = ritual.customImageData,
                       let uiImage = UIImage(data: imageData) {
                        HStack {
                            Text(NSLocalizedString("builder_custom_image", comment: "Custom Image"))
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Experience Settings
                Section(header: Text(NSLocalizedString("builder_experience", comment: "Experience"))) {
                    HStack {
                        Text(NSLocalizedString("builder_duration", comment: "Duration"))
                        Spacer()
                        Text("\(ritual.duration) \(NSLocalizedString("seconds", comment: "seconds"))")
                    }
                    
                    Picker(NSLocalizedString("builder_haptic", comment: "Haptic Pattern"), selection: $ritual.hapticPattern) {
                        ForEach(CustomRitual.HapticPattern.allCases, id: \.self) { pattern in
                            Text(pattern.displayName).tag(pattern)
                        }
                    }
                }
                
                // Sharing
                Section(header: Text(NSLocalizedString("builder_sharing", comment: "Sharing"))) {
                    Toggle(NSLocalizedString("builder_public", comment: "Make Public"), isOn: $ritual.isPublic)
                    
                    if ritual.isPublic {
                        Text(NSLocalizedString("builder_public_desc", comment: "Others can download and use your ritual"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tags
                Section(header: Text(NSLocalizedString("builder_tags", comment: "Tags"))) {
                    TextField(NSLocalizedString("builder_tags_placeholder", comment: "Enter tags separated by commas"), text: binding(for: \.tags))
                }
            }
            .navigationTitle(NSLocalizedString("builder_title", comment: "Create Ritual"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("create", comment: "Create")) {
                        createRitual()
                    }
                    .disabled(ritual.name.isEmpty || ritual.description.isEmpty)
                }
            }
        }
    }
    
    private func binding(for keyPath: WritableKeyPath<CustomRitual, [String]>) -> Binding<String> {
        return Binding(
            get: { ritual.tags.joined(separator: ", ") },
            set: { newValue in
                ritual[keyPath: keyPath] = newValue.split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
            }
        )
    }
    
    private func createRitual() {
        ritualManager.createRitual(ritual)
        dismiss()
    }
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
