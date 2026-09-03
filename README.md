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
- Flutter SDK 3.41.7, the version pinned in `pubspec.yaml`
- Dart SDK 3.11.5, bundled with that Flutter release
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

Both artifacts are built obfuscated, because Sentry is initialized in every
release build and unobfuscated AOT Dart frames arrive as bare addresses that
cannot be symbolicated after the fact. `dart run sentry_dart_plugin` uploads the
`.symbols` files and the obfuscation map those flags produce, and needs
`SENTRY_AUTH_TOKEN` in the environment.

**Android APK (Production)**
```bash
flutter build apk --flavor prod --release --obfuscate --split-debug-info=build/debug-info --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json
dart run sentry_dart_plugin
```

**Android AAB (Store release)**
```bash
flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/debug-info --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json
dart run sentry_dart_plugin
```

**Android APK (Beta, for the pre-prod test)**

Same recipe with the beta flavor, but prefer the tag below over building this by
hand. It installs as `com.crimpyclimbing.crimpy.beta`, alongside production
rather than over it.

```bash
flutter build apk --flavor beta --release --obfuscate --split-debug-info=build/debug-info --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json
dart run sentry_dart_plugin
```

**Install without losing data**
```bash
adb install -r ./build/app/outputs/flutter-apk/app-prod-release.apk
```

### Releasing

Releases are cut from `dev`, with `main` acting as the promoted branch.

```bash
# Fast-forward main to dev, so the CI runs analyze and tests on it
just preprod-release

# Bump pubspec, tag the promoted commit, push
just prod-release patch    # or minor, major, or an explicit 2.1.0
```

`prod-release` refuses to run until `main` and `dev` match, so a tag can only
land on a commit that has already been promoted. It reads the current version
out of `pubspec.yaml`, which is the source of truth here rather than the tags:
it also carries the build number, and that has to keep going up for the stores.
The build number is incremented on every release. Pushing the tag triggers
`.github/workflows/release.yml`, which builds `--flavor prod --release`
obfuscated, checks the APK is not signed with the debug key, uploads the debug
symbols to Sentry, and publishes the APK on the GitHub release. The upload runs
before the release is created, so a tag never ships an APK whose crash reports
cannot be read.

Both scripts show what they are about to push and ask for confirmation; pass
`-y` to skip the prompt.

#### Beta releases

The same workflow builds the beta channel, off a `beta-v*` tag rather than `v*`:

```bash
git tag -a beta-v2.0.0-7 -m beta-v2.0.0-7
git push origin beta-v2.0.0-7
```

That builds `--flavor beta --release` through the same signing, obfuscation and
symbol upload as production, and publishes it as a GitHub prerelease.
`preprod-release.sh` prints the exact tag to push once it has promoted `main`.

Never hand testers a local `--flavor beta --debug` build. Sentry is initialized
only in release builds, so a debug build reports nothing for the whole test.

#### Release secrets

The workflow signs with the upload keystore, which it takes from four repository
secrets and writes back into `android/key.properties` for the build. Set them
once, from a checkout that has the keystore:

```bash
gh secret set ANDROID_KEYSTORE_BASE64 --repo Krakoer/crimpy-app < <(base64 -w0 android/app/upload-keystore.jks)
gh secret set ANDROID_KEYSTORE_PASSWORD --repo Krakoer/crimpy-app
gh secret set ANDROID_KEY_ALIAS --repo Krakoer/crimpy-app
gh secret set ANDROID_KEY_PASSWORD --repo Krakoer/crimpy-app
```

The symbol upload needs a fifth secret, an organization auth token from the
Sentry organization settings. It both creates a release and uploads debug
information files, which the `org:ci` scope an organization token carries covers:

```bash
gh secret set SENTRY_AUTH_TOKEN --repo Krakoer/crimpy-app
```

A tag pushed while any of the five is missing fails the workflow before the
build, rather than publishing an APK signed with the debug key or one Sentry
cannot symbolicate. Locally the keystore secrets live in the same file, which
drives the release build:

```properties
storeFile=upload-keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

`storeFile` is resolved from `android/app/`, and both files are gitignored. Without
`android/key.properties` the release build is left unsigned instead of falling back
to the debug key, so `flutter build apk --release` needs the keystore in place.

## Development

### Application ids and Sentry environments

| build                       | application id                        | Sentry            |
| --------------------------- | ------------------------------------- | ----------------- |
| `--flavor prod --release`   | `com.crimpyclimbing.crimpy`           | `prod`            |
| `--flavor beta --release`   | `com.crimpyclimbing.crimpy.beta`      | `beta`            |
| anything debug or profile   | the above plus `.debug`               | not initialized   |

The debug suffix is what keeps a run from the editor from uninstalling the beta
build a tester is carrying, along with the month of local data behind it. Sentry
is gated on `kReleaseMode`, so errors watched live in the debugger never reach
it, and `options.environment` comes from `appFlavor` so the beta test stays
separable from production.

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

### Migrations

When updating the database, after generating code with build_runner, you should:
1. Bump the database version in `database.dart`
2. Generate migration & tests with `dart run drift_dev make-migrations`
3. Write `MigrationStrategy` in `database.dart`
4. Optional: edit generated tests if necessary (type or constraints change typically)

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