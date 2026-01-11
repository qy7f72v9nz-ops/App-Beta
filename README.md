# Overtime Tracker - iOS App for Postmen and Women

A beautifully designed iOS app built with SwiftUI to help postal workers track their daily overtime hours. Track overtime before and after contracted hours, view weekly summaries, and export your data.

## Features

### 📅 Week Overview
- Clean, organized week view showing Monday through Sunday
- Daily overtime totals at a glance
- Running weekly total prominently displayed
- Current day highlighted for easy reference
- Week date range display (e.g., Jan 6 - Jan 12)

### ⏰ Daily Tracking
- Track overtime **before contracted hours**
- Track overtime **after contracted hours**
- 1-minute increment precision using intuitive hour/minute pickers
- Individual save button for each day
- Visual confirmation when entries are saved
- Beautiful card-based layout for each day

### 📊 History View
- View all past weeks' overtime records
- Expandable week cards showing detailed daily breakdowns
- See before/after contracted hours for each entry
- Organized chronologically (most recent first)
- Clean, professional interface

### 📤 Export & Management
- **Export to CSV**: Share your overtime data via email, messages, or save to files
- **Clear All Records**: Remove all saved data with confirmation prompt
- Automatic data persistence using UserDefaults

## Technical Details

### Requirements
- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Architecture
- **SwiftUI** for modern, declarative UI
- **MVVM pattern** for clean code organization
- **Combine** for reactive data management
- **UserDefaults** for local data persistence

### Project Structure
```
OvertimeTracker/
├── OvertimeTracker/
│   ├── OvertimeTrackerApp.swift      # App entry point
│   ├── Models/
│   │   └── OvertimeEntry.swift       # Data models
│   ├── ViewModels/
│   │   └── OvertimeDataManager.swift # Business logic & data management
│   ├── Views/
│   │   ├── ContentView.swift         # Main screen
│   │   ├── WeekOverviewView.swift    # Week summary component
│   │   ├── DayEntryCard.swift        # Daily entry card with time pickers
│   │   └── HistoryView.swift         # Historical data view
│   ├── Utilities/
│   │   └── ShareSheet.swift          # CSV export functionality
│   ├── Assets.xcassets/              # App icons and colors
│   └── Info.plist                    # App configuration
└── OvertimeTracker.xcodeproj/        # Xcode project files
```

## How to Use

### 1. Opening the Project
1. Open `OvertimeTracker.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

### 2. Tracking Overtime
1. The app opens to the current week (Monday - Sunday)
2. For each day, you'll see two input fields:
   - **Before Contracted Hours**: Overtime worked before your shift
   - **After Contracted Hours**: Overtime worked after your shift
3. Tap the **pencil icon** to set time using the picker (hours and minutes)
4. Tap **Save** to store the entry
5. The week overview automatically updates with your totals

### 3. Viewing History
1. Tap **View History** button
2. See all past weeks with total overtime
3. Tap any week card to expand and view daily details
4. Tap **Done** to return to the main screen

### 4. Exporting Data
1. Tap **Export to CSV** button
2. Choose how to share (Email, Messages, Files, etc.)
3. CSV format includes: Date, Day, Before (mins), After (mins), Total (mins)

### 5. Managing Data
- **Clear All Records**: Removes all saved overtime data
- Confirmation prompt prevents accidental deletion
- All data is automatically saved when you tap "Save" on each day

## Data Format

### CSV Export Format
```csv
Date,Day,Before Contracted (mins),After Contracted (mins),Total (mins)
2026-01-13,Monday,30,45,75
2026-01-14,Tuesday,0,60,60
```

### Time Display
- Times shown in `Xh XXm` format (e.g., 1h 30m)
- Minutes only if under 1 hour (e.g., 45m)
- Zero minutes shown as `-` in week overview

## Key Features Explained

### Week Start on Monday
The app is configured to start weeks on Monday and end on Sunday, as requested. This is handled automatically by the `OvertimeDataManager` using the `getMondayOfWeek()` method.

### Automatic Data Persistence
All entries are automatically saved to UserDefaults when you tap the Save button. Your data persists between app launches without any additional action required.

### 1-Minute Increment Precision
The time picker allows selection of:
- Hours: 0-23
- Minutes: 0-59

This provides precise tracking down to the minute for your overtime records.

### Beautiful UI Design
- Clean, modern SwiftUI interface
- Card-based layouts for easy reading
- Color-coded elements (blue for overtime totals)
- Today's date highlighted in week view
- Smooth animations and transitions
- Professional typography and spacing

## Customization

### Changing the Week Start Day
While the app is configured for Monday-Sunday weeks, you can modify this in `OvertimeDataManager.swift` by adjusting the `getMondayOfWeek()` method.

### Modifying Colors
The accent color can be changed in `Assets.xcassets/AccentColor.colorset/Contents.json` or by modifying color values in the SwiftUI views.

### Bundle Identifier
Update the bundle identifier in the Xcode project settings under:
- Target > General > Bundle Identifier
- Currently set to: `com.overtime.tracker`

## Building for Production

### 1. Update App Information
- Set your development team in Xcode
- Configure signing certificates
- Update version and build numbers in project settings

### 2. Build for Device
1. Connect your iPhone
2. Select your device from the device dropdown
3. Press `Cmd + R` to build and install

### 3. Archive for App Store
1. Select "Any iOS Device" as the target
2. Product > Archive
3. Follow Xcode's distribution workflow

## Support & Contributions

This app was designed specifically for postal workers to track overtime hours efficiently. The clean interface and simple workflow make it easy to log hours at the end of each day.

### Future Enhancement Ideas
- Widget support for quick entry
- Notifications for end-of-day logging reminders
- Dark mode optimization
- Multiple week view options
- Graphical overtime trends
- PDF export in addition to CSV
- iCloud sync for multiple devices

## License

This project is provided as-is for personal and commercial use.

---

**Built with ❤️ using SwiftUI**

*Track your overtime. Know your worth. Get paid fairly.*