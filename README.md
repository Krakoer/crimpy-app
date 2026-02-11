# Crimpy

A Flutter mobile application for climbing training and performance assessment using Bluetooth-connected force sensors.

See the other repo of the project for more info:
- https://github.com/Krakoer/crimpy-firmware: An ESP32c3 firmware for the open source force sensor
- https://github.com/Krakoer/crimpy-simulator: Windows app to emulate BLE data
- TODO: 3D models & PCB KiCad blueprints

## Overview

Crimpy helps climbers track and improve their performance through:
- **Custom Training Programs**: Create personalized workouts with precise rep-by-rep configuration
- **Standardized Assessments**: MVC 3FD and Critical Force testing protocols
- **Real-time Data Collection**: Bluetooth force sensor integration
- **Performance Analytics**: Session history and data visualization
- **Repeater Training**: Structured interval training templates

## Features

### Training & Workouts
- Custom training creation with configurable reps, sets, and rest periods
- Repeater training templates for systematic finger strength development
- Split-hand training support for targeted improvement
- Audio feedback during sessions
- Training favorites and organization

### Assessments
- **MVC 3FD**: Maximum Voluntary Contraction assessment
- **Critical Force**: Endurance capacity evaluation
- Hand-specific testing (left/right or combined)
- Historical assessment tracking and comparison

### Data Management
- Real-time force data collection via Bluetooth sensors
- Session history with detailed performance metrics
- Data export capabilities
- Sensor calibration and configuration management

### User Experience
- Cross-platform support (Android, iOS, Windows, macOS, Linux)
- Material Design UI with custom theming
- Profile management and settings
- Intuitive navigation and training flow

## Getting Started

### Prerequisites
- Flutter SDK ^3.7.2
- Dart SDK ^3.7.2
- Android Studio / VS Code with Flutter extensions
- Compatible Bluetooth force sensor device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd crimpy-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK (Production)**
```bash
flutter build apk --flavor prod --release
```

**Android AAB (Store release)**
```bash
flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/debug-info --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json
dart run sentry_dart_plugin
```

**Install without losing data**
```bash
adb install -r ./build/app/outputs/flutter-apk/app-prod-release.apk
```

## Development

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

### Key Technologies
- **Flutter**: Cross-platform mobile framework
- **Riverpod**: State management with code generation
- **Drift**: Type-safe SQLite ORM with code generation
- **Flutter Blue Plus**: Bluetooth Low Energy communication
- **Syncfusion Charts**: Data visualization

### Code Generation

The project uses code generation for database models and state management:

```bash
# Generate all code
dart run build_runner build

# Clean and regenerate
dart run build_runner build --delete-conflicting-outputs
```

### Static Analysis
```bash
flutter analyze
```

## Terminology

- **Training**: An available workout that can be performed using the app
- **Session**: A completed workout (either Crimpy training or logged climbing/stretching session)
- **Assessment**: Standardized performance test stored separately from regular sessions
- **Repeater**: Structured interval training format with configurable work/rest periods

## Bluetooth Integration

Crimpy connects to external force sensors via Bluetooth Low Energy for real-time data collection during training sessions and assessments. The app handles:
- Device discovery and pairing
- Sensor calibration and tare functionality
- Real-time data streaming
- Connection state management

## Data Storage

- **Local Database**: SQLite via Drift ORM for training templates, sessions, and assessments
- **File System**: JSON files for detailed session force data
- **Configuration**: Sensor settings and user preferences

## Roadmap

### Current Version (V1)
- [x] Custom training creation and editing
- [x] Repeater training support
- [x] MVC 3FD and Critical Force assessments
- [x] Bluetooth sensor integration
- [x] Session history and data visualization
- [x] Profile management
- [x] Training favorites
- [x] Training recommendations based on user profile

### Future Features
- [ ] Session planning and scheduling
- [ ] Advanced analytics and progress tracking
- [ ] Cloud synchronization
- [ ] Coach accounts and shared training programs
- [ ] Injury prevention features

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the terms specified by Crimpy Climbing.

## Support

For support, bug reports, or feature requests, please contact crimpyclimbing@proton.me