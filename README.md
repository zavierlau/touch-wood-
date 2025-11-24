# Touch Wood App

A good luck rituals app for iOS that helps users track daily rituals, maintain streaks, and build positive habits.

## Features

- **Touch Wood Ritual**: Interactive wood-tapping with haptic feedback and animations
- **Custom Rituals**: Create personalized rituals with custom images and icons
- **Streak Tracking**: Visual streak animations with milestone celebrations
- **Daily Reminders**: Configurable notifications to maintain consistency
- **Journal**: Log mood and notes for each ritual completion
- **Offline-First**: Full functionality without internet connection

## Quick Start

1. Open `TouchWoodApp.xcodeproj` in Xcode
2. Select your target device (iPhone Simulator recommended)
3. Press `Cmd+R` to build and run

## Project Structure

```
TouchWoodApp/
├── TouchWoodApp.swift          # App entry point
├── OnboardingFlow.swift        # First-time user experience
├── CustomRitualSheet.swift     # Create custom rituals
├── StreakAnimation.swift       # Streak visualizations
├── NotificationScheduler.swift  # Reminder system
├── Models.swift               # Data models and helpers
├── Persistence.swift          # Core Data setup
├── Views.swift                # Main UI views
├── TouchWoodApp.xcdatamodeld/  # Core Data model
└── Info.plist                # App configuration
```

## Key Components

### Onboarding Flow
- 4-step guided setup
- Ritual selection, reminder time, sound/haptic preferences
- Stores defaults in UserDefaults

### Custom Ritual Creation
- Photo picker integration
- Icon selection grid
- Core Data persistence

### Streak Animations
- Confetti effects for milestones
- Progress rings and badges
- Pulse animations

### Notification System
- Daily ritual reminders
- Milestone celebrations
- Recovery alerts

## Dependencies

- SwiftUI for UI
- Core Data for persistence
- UserNotifications for reminders
- PhotosUI for image selection

## Testing on macOS

Since this is an iOS app, you'll need to use the iOS Simulator:

1. Open Xcode
2. Select "iPhone 15 Pro" (or any iOS Simulator)
3. Build and run (`Cmd+R`)

The app will run in the iOS Simulator on your Mac with full functionality including:
- Touch interactions (click/tap)
- Haptic feedback simulation
- Notifications
- Camera/photo picker (simulated)

## Customization

### Adding New Rituals
Edit `Models.swift` to add more default rituals:

```swift
static let newRitual = RitualModel(
    id: UUID(),
    name: "Ritual Name",
    description: "Description",
    icon: "icon.name",
    isCustom: false,
    isFavorite: false,
    customImageData: nil,
    createdAt: Date()
)
```

### Modifying Streak Milestones
Update `StreakAnimation.swift` milestone messages:

```swift
private var milestoneMessage: String {
    switch currentStreak {
    case 7: return "🔥 One Week Strong!"
    // Add your custom milestones here
    default: return ""
    }
}
```

### Notification Timing
Adjust default reminder times in `OnboardingFlow.swift`:

```swift
UserDefaults.standard.set(dailyReminderTime, forKey: "dailyReminderTime")
```

## Troubleshooting

### Build Issues
- Ensure Xcode 15.0+ is installed
- Clean build folder (`Cmd+Shift+K`)
- Restart Xcode if needed

### Simulator Issues
- Reset Simulator if notifications don't appear
- Check System Settings for notification permissions

### Core Data Issues
- Delete app from Simulator to reset database
- Check Core Data model for consistency

## Next Steps

1. Add sound effects for rituals
2. Implement data export functionality
3. Add social sharing features
4. Create Apple Watch companion app
5. Add widget support

## License

MIT License - feel free to use this code for your own projects.
# touch-wood-
