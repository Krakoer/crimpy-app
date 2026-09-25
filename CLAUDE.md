# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Crimpy is a Flutter mobile application for climbing training and assessment using Bluetooth-connected force sensors. It tracks climbing performance through customizable workouts and standardized assessments like MVC and critical force.

## Shell Usage

Always source `~/.zshrc` before running commands.

## Code Style and Documentation

We value code that explains itself through clear class, method, and variable names. Comments may be used when necessary to explain tricky logic, but should otherwise be avoided. Write self-documenting code with descriptive names rather than relying on comments.

**Create atomic and comprehensive commits in the current branch to ease the code review. The commits messages should be 2 lines long maximum and should not contain any reference to Claude code.**

Never use unicode characters such as long dashes, triple dots, arrows or emojis, in the code or in the doc.

## Commands

### Development & Building
- `flutter run` - Run the app in development mode
- `flutter build apk --flavor prod --release` - Build production APK. Release artifacts ship obfuscated so Sentry can symbolicate them, see the README build recipes
- `flutter analyze` - Run static analysis
- `dart run build_runner build` - Generate code for Drift database and Riverpod
- `dart run build_runner build --delete-conflicting-outputs` - Regenerate all generated files

### Emulator
- `just emulator start` then `just emulator run` - Boot a headless emulator and run the app on it against a simulated sensor and the local API
- `just emulator screenshot <file>` - Save the emulator screen, for PR screenshots
- See "Running on an emulator" in the README for setup
- Every PR that changes something an athlete can see ships a screenshot from the emulator, posted as a PR comment. The review-app skill's "Screenshots on every PR" section has the procedure and the image hosting

### Testing & Debugging
- `adb install -r .\build\app\outputs\flutter-apk\app-prod-release.apk` - Install APK without losing data
- `adb -d shell "run-as com.crimpyclimbing.crimpy.beta.debug cat /data/user/0/com.crimpyclimbing.crimpy.beta.debug/app_flutter/<filename>" > data.json` - Debug data extraction (beta). `run-as` only works on debuggable builds, which carry the `.debug` suffix; drop it to read a release build's data through other means
- `adb -d shell "run-as com.crimpyclimbing.crimpy.debug cat /data/user/0/com.crimpyclimbing.crimpy.debug/app_flutter/<filename>" > data.json` - Debug data extraction (prod)

## Architecture Overview

### State Management
- **Riverpod** for state management with code generation (`@riverpod` annotations)
- ViewModels in `lib/viewmodels/` provide business logic and state
- Generated providers handle dependency injection

### Database Architecture
- **Drift** ORM for SQLite database with code generation
- Main database file: `lib/database/database.dart`
- Tables: Sessions, Assessments, Trainings, RepTemplates, RepDatas, Repeaters, SensorConfigs
- Builtin trainings/assessments seeded from `lib/database/builtins.dart`
- Session data stored as JSON files on filesystem, referenced by database

### Key Terminology
- **Training**: Available workout that can be performed
- **Session**: Completed workout (either Crimpy training or logged climbing/stretching)
- **Assessment**: Standardized test (MVC, Critical Force) stored separately from regular sessions
- **Repeater**: Structured interval training format

### Project Structure
```
lib/
├── database/        # Drift database and builtin configurations
├── models/         # Data models (BLE, Training, Assessment, etc.)
├── repositories/   # Data access layer
├── viewmodels/     # Riverpod providers and business logic
├── views/          # UI screens and widgets
│   ├── screens/    # Main application screens
│   └── widgets/    # Reusable UI components
├── theme/          # App theming and custom widgets
└── utils/          # Utility functions
```

### Bluetooth Integration
- Uses `flutter_blue_plus` for BLE communication
- BLE data models in `lib/models/ble_data_model.dart`
- Connection management in `lib/viewmodels/ble_view_model.dart`
- The transport sits behind `SensorLink` in `lib/services/sensor_link/`: `FlutterBluePlusSensorLink` for the hardware, `SimulatedSensorLink` when built with `CRIMPY_SIMULATED_SENSOR=true`
- Real-time force sensor data collection and storage

### Key Features
- Multi-platform (Android, iOS, Windows, macOS, Linux)
- Custom training creation with rep-by-rep configuration
- Repeater training templates
- Assessment protocols (MVC 3FD, Critical Force)
- Sensor calibration and configuration
- Session history and data visualization with Syncfusion charts
- Audio feedback during training

## Development Notes

- Pinned to Flutter 3.41.7 in `pubspec.yaml`, which bundles Dart 3.11.5
- Main app entry point: `lib/main.dart` with Riverpod ProviderScope
- Navigation through bottom tab bar in MainPage
- Custom lint rules enabled via `custom_lint` package
- Generated files (.g.dart, .freezed.dart) are committed to repository
- App uses flavors (beta/prod) for different build configurations