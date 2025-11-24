import SwiftUI
import CoreData

// MARK: - Main Views

struct TouchWoodView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var appState = AppState()
    @State private var tapCount = 0
    @State private var showingRipple = false
    @State private var currentStreak = 7
    @State private var showingNoteSheet = false
    @State private var ritualNote = ""
    @State private var selectedMood: Int = 3
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Touch Wood")
                .font(.largeTitle.bold())
                .padding(.top)

            Button(action: performRitual) {
                ZStack {
                    Image(systemName: "tree.fill")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.brown)
                        .scaleEffect(showingRipple ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: showingRipple)
                    
                    Circle()
                        .stroke(.brown.opacity(0.3), lineWidth: 4)
                        .scaleEffect(showingRipple ? 1.4 : 1.0)
                        .opacity(showingRipple ? 0 : 1)
                        .animation(.easeOut(duration: 0.6), value: showingRipple)
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: 8) {
                Text("Today's Touches: \(tapCount)")
                    .font(.title2)
                
                StreakAnimationView(currentStreak: currentStreak, previousStreak: currentStreak - 1)
            }

            Button(action: { showingNoteSheet = true }) {
                Text("Add Note")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)

            Spacer()
        }
        .sheet(isPresented: $showingNoteSheet) {
            RitualNoteSheet(note: $ritualNote, selectedMood: $selectedMood) {
                saveRitualLog()
                showingNoteSheet = false
            }
        }
    }

    private func performRitual() {
        showingRipple = true
        tapCount += 1
        
        // Haptic feedback
        HapticFeedback.trigger(appState.userPreferences.hapticStyle)
        
        // Sound effect (if enabled)
        if appState.userPreferences.soundEnabled {
            // Play wood-knock sound
        }
        
        // Update streak
        currentStreak += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingRipple = false
        }
    }
    
    private func saveRitualLog() {
        let log = RitualLog(context: viewContext)
        log.id = UUID()
        log.timestamp = Date()
        log.note = ritualNote.isEmpty ? nil : ritualNote
        log.mood = Int16(selectedMood)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving ritual log: \(error)")
        }
        
        // Reset form
        ritualNote = ""
        selectedMood = 3
    }
}

struct RitualLibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ritual.createdAt, ascending: true)],
        animation: .default)
    private var rituals: FetchedResults<Ritual>
    
    @State private var showingCustomRitualSheet = false

    var body: some View {
        NavigationView {
            List {
                Section("Favorites") {
                    ForEach(rituals.filter { $0.isFavorite }) { ritual in
                        RitualRow(ritual: ritual)
                    }
                }
                
                Section("All Rituals") {
                    ForEach(rituals) { ritual in
                        RitualRow(ritual: ritual)
                    }
                }
            }
            .navigationTitle("Rituals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddRitualButton()
                }
            }
        }
        .sheet(isPresented: $showingCustomRitualSheet) {
            CustomRitualSheet()
        }
    }
}

struct RitualRow: View {
    let ritual: Ritual
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageData = ritual.customImageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Image(systemName: ritual.icon ?? "star.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ritual.name ?? "Unnamed Ritual")
                    .font(.headline)
                Text(ritual.ritualDescription ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: toggleFavorite) {
                Image(systemName: ritual.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(ritual.isFavorite ? .red : .gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
    
    private func toggleFavorite() {
        ritual.isFavorite.toggle()
        do {
            try viewContext.save()
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
}

struct JournalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RitualLog.timestamp, ascending: false)],
        animation: .default)
    private var logs: FetchedResults<RitualLog>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(logs) { log in
                    JournalRow(log: log)
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        exportJournal()
                    }
                }
            }
        }
    }
    
    private func exportJournal() {
        // Export functionality
    }
}

struct JournalRow: View {
    let log: RitualLog
    
    var moodEmoji: String {
        switch log.mood {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.timestamp ?? Date(), style: .date)
                    .font(.headline)
                Spacer()
                Text(moodEmoji)
                    .font(.title2)
            }
            
            if let note = log.note, !note.isEmpty {
                Text(note)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView: View {
    @StateObject private var appState = AppState()
    @State private var showingTimePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    HStack {
                        Text("Daily Reminder")
                        Spacer()
                        Text(appState.userPreferences.dailyReminderTime, style: .time)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingTimePicker = true
                    }
                    
                    Toggle("Sound Effects", isOn: $appState.userPreferences.soundEnabled)
                        .onChange(of: appState.userPreferences.soundEnabled) { _ in
                            appState.saveUserPreferences()
                        }
                }
                
                Section("Haptic Feedback") {
                    Picker("Style", selection: $appState.userPreferences.hapticStyle) {
                        Text("Light").tag("light")
                        Text("Medium").tag("medium")
                        Text("Heavy").tag("heavy")
                    }
                    .onChange(of: appState.userPreferences.hapticStyle) { _ in
                        appState.saveUserPreferences()
                        HapticFeedback.trigger(appState.userPreferences.hapticStyle)
                    }
                }
                
                Section("Privacy") {
                    Toggle("Share anonymous stats", isOn: $appState.userPreferences.shareAnonymously)
                        .onChange(of: appState.userPreferences.shareAnonymously) { _ in
                            appState.saveUserPreferences()
                        }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingTimePicker) {
            NavigationView {
                VStack {
                    DatePicker("Reminder Time", selection: $appState.userPreferences.dailyReminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    
                    Spacer()
                    
                    Button("Done") {
                        appState.saveUserPreferences()
                        NotificationScheduler.shared.updateDailyReminderTime(
                            newTime: appState.userPreferences.dailyReminderTime,
                            ritualName: "Knock on Wood"
                        )
                        showingTimePicker = false
                    }
                    .padding()
                }
                .padding()
                .navigationTitle("Set Reminder Time")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingTimePicker = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct RitualNoteSheet: View {
    @Binding var note: String
    @Binding var selectedMood: Int
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("How are you feeling?") {
                    HStack {
                        ForEach(1...5, id: \.self) { mood in
                            Button(action: { selectedMood = mood }) {
                                Text(moodEmoji(for: mood))
                                    .font(.largeTitle)
                                    .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Section("Note (optional)") {
                    TextField("Add a note about this ritual...", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Ritual Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") { onSave() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { onSave() }
                }
            }
        }
    }
    
    private func moodEmoji(for mood: Int) -> String {
        switch mood {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
}
