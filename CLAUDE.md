# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StudyValue is an iOS-only Flutter application that gamifies study time by converting it into monetary value. Students set target universities, and the app calculates an hourly "wage" based on projected lifetime earnings from their target school's deviation value. The app displays real-time earnings while studying and provides motivational warnings when students fall behind their goals.

## Development Commands

### Setup
```bash
# Initial setup
flutter pub get
cd ios && pod install && cd ..

# Font files are already in place at assets/fonts/
# - NotoSansJP-Regular.ttf, NotoSansJP-Medium.ttf, NotoSansJP-Bold.ttf
```

### Build & Run
```bash
# Run on iOS simulator/device
flutter run

# Run specific target
flutter run -d "iPhone 15"  # Replace with your device/simulator name

# iOS builds
flutter build ios --debug          # Development build
flutter build ios --release        # Production build  
flutter build ios --simulator      # Simulator build

# Open in Xcode
open ios/Runner.xcworkspace
```

### Testing & Quality
```bash
# Run all tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage

# Lint checking
flutter analyze

# Auto-fix lint issues
dart fix --apply
```

### Code Generation
```bash
# Generate Hive adapters (when models change)
flutter packages pub run build_runner build

# Force regenerate (if conflicts)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter packages pub run build_runner watch
```

### Troubleshooting
```bash
# Clean everything
flutter clean
flutter pub get
cd ios && pod clean && pod install && cd ..

# Reset Hive database (development only)
# In code: await DatabaseManager.clearAllData()

# Fix "pod install" issues
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

## Architecture

### Data Flow Pattern
```
User Input → UI Widget → Riverpod Provider → Service/Calculator → Hive Database
                ↑                    ↓
                └──── State Update ←─┘
```

### Core Components

**State Management (Riverpod)**
- `userProfileProvider`: User settings and configuration
- `studySessionProvider`: Active study session with real-time Timer updates
- `studySessionListProvider`: All sessions sorted by date
- `todayStudySessionsProvider`: Filtered sessions for today
- `todayTotalStudyTimeProvider`: Aggregated study time
- `dailyProgressProvider`: Achievement percentage calculation

**Services**
- `DatabaseManager`: Hive initialization and box management (singleton pattern)
- `SalaryCalculator`: Pure functions for wage/earnings calculations
- `WarningSystem`: 3-tier motivational message generation

**Data Models (Hive TypeIds)**
- `UserProfile` (0): Target university, study hours, exam date, streak tracking
- `StudySession` (1): Study records with start/end times and earnings
- `SalaryData` (2): Deviation value to annual salary mapping
- `NotificationSettings` (3): User notification preferences

### Key Business Logic

**Earnings Calculation**
1. Annual salary derived from university deviation value (50-75)
2. Lifetime earnings = Annual salary × 43 years (age 22-65)
3. Hourly wage = Lifetime earnings ÷ Total study hours until exam
4. Per-second earnings = Hourly wage ÷ 3600

**Warning System Thresholds**
- Level 1 (Green): ≥80% daily goal achieved
- Level 2 (Yellow): 60-79% achieved  
- Level 3 (Red): <60% achieved

### UI Architecture
- iOS-only using Cupertino widgets exclusively
- ConsumerWidget/ConsumerStatefulWidget for Riverpod integration
- Gradient themes with CupertinoColors
- Widget composition pattern for reusability

## Platform Configuration

### iOS Settings
- **Bundle ID**: `com.example.stadyvalue` (typo - should be updated)
- **Deployment Target**: iOS 12.0 - 18.5
- **Orientations**: Portrait only
- **Encryption**: ITSAppUsesNonExemptEncryption = false
- **Category**: Education

### Dependencies
- Flutter SDK: >=3.0.0 <4.0.0, Flutter: >=3.27.0
- flutter_riverpod: ^2.6.1
- hive/hive_flutter: ^2.2.3/^1.1.0
- cupertino_icons: ^1.0.8
- flutter_localizations (SDK), intl: ^0.19.0
- Build tools: hive_generator, build_runner

### Font Configuration
NotoSansJP fonts are configured and enabled in pubspec.yaml (lines 63-71):
- Regular (400), Medium (500), Bold (700) weights
- Font family: 'NotoSansJP' used throughout the app

## Code Generation & Database Schema

### Hive Models
Hive adapters are generated for all models. When modifying models:
1. Update the model class (add `defaultValue` for new fields to avoid migration issues)
2. Increment adapter version if needed
3. Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
4. Test database migration

**Important**: New @HiveField entries should include `defaultValue` parameter to prevent null cast errors:
```dart
@HiveField(9, defaultValue: 0)
int newField;
```

### Database Migration
- Development: Database is cleared on app startup (see DatabaseManager.clearAllData())
- Migration logic handles schema changes gracefully with default values
- Production apps should implement proper migration strategies

## Localization & Platform Support

### Internationalization
- Japanese (ja_JP) primary locale with English (en_US) fallback
- Full Cupertino localization support via GlobalCupertinoLocalizations
- All UI text uses Japanese with NotoSansJP font family
- String interpolation warnings resolved for proper formatting

## Privacy & Offline Design
- Completely offline - no network calls
- All data stored locally via Hive
- No analytics or external services
- Database cleared on app uninstall

## Common Issues & Solutions

### Database Schema Changes
If you encounter "type 'Null' is not a subtype of type 'int'" errors:
1. Add `defaultValue` to new @HiveField entries
2. Regenerate Hive adapters with build_runner
3. Clear database in development: `await DatabaseManager.clearAllData()`

### Localization Errors
If you see "No CupertinoLocalizations found":
1. Ensure `flutter_localizations` is in dependencies
2. Import `package:flutter_localizations/flutter_localizations.dart`
3. Add all three delegates: GlobalMaterialLocalizations, GlobalCupertinoLocalizations, GlobalWidgetsLocalizations

### Build Issues
- Always run `flutter clean && flutter pub get` after dependency changes
- For iOS pod issues: `cd ios && rm -rf Pods Podfile.lock && pod install`
- Code generation conflicts: Use `--delete-conflicting-outputs` flag