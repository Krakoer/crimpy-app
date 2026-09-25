---
name: review-app
description: Architecture, design and style knowledge for reviewing changes in crimpy-app (Flutter, Riverpod 3 codegen, Drift, BLE force sensor). Use when reviewing a PR, branch or diff in crimpy-app.
---

# Reviewing crimpy-app

Flutter (Dart SDK 3.11+, Flutter 3.41.7) climbing training app that talks to a BLE
force sensor. Riverpod 3 with code generation, Drift for local SQLite, Dio for
the backend API, Sentry, flavors `beta` and `prod`. Read `crimpy-app/CLAUDE.md`
for commands; this file is what to check in a diff.

## Layering

    lib/models/         data models (BLE, training, session, assessment)
    lib/database/       Drift database, builtins seed data
    lib/services/       api_client, auth, notifications, migrations, tutorial
    lib/repositories/   data access, abstract interface + Local/Remote impls
    lib/viewmodels/     Riverpod providers and business logic
    lib/views/screens/  screens, one folder per screen with a widgets/ subfolder
    lib/views/widgets/  cross-screen reusable widgets
    lib/theme/          CrimpyTheme constants and themed widgets
    lib/utils/          helpers

The dependency direction is views -> viewmodels -> repositories -> database and
services. Findings to raise:

- A widget or screen importing `database/database.dart` or `services/api_client.dart`
  directly, instead of going through a repository behind a provider.
- Business logic (calculations, persistence decisions, BLE parsing) living in a
  `build()` method instead of a viewmodel or repository.
- A repository that reaches into another repository's storage rather than its API.

## Repositories

Established shape: an abstract class declaring the contract, then implementations,
with the dependency injected through an optional constructor argument that falls
back to the global instance. This is what makes them testable.

```dart
abstract class TrainingRepository {
  Future<List<Training>> getAllTrainings({bool onlyFavs = false});
}

class LocalTrainingRepository extends TrainingRepository {
  final AppDatabase _database;
  LocalTrainingRepository({AppDatabase? database})
    : _database = database ?? gDatabase;
}
```

A new concrete repository with a hardcoded, non-injectable dependency is a
finding. Where both a local and a remote implementation exist (assessments), check
the new code did not silently pick one and bypass the abstraction.

## Riverpod

Riverpod 3 with `riverpod_annotation` code generation.

- Providers are `@riverpod` / `@Riverpod(keepAlive: true)` annotated functions or
  Notifier classes, with `part 'x_view_model.g.dart';` at the top of the file.
  Manually constructed `Provider(...)`, `StateNotifierProvider`, `ChangeNotifier`
  are findings: this repo is fully on codegen and Notifier/AsyncNotifier.
- Widgets read providers via `ConsumerWidget` / `ConsumerStatefulWidget` /
  `Consumer`, never by constructing a container.
- `ref.watch` in `build`, `ref.read` in callbacks. `ref.watch` inside an
  `onPressed` is a finding.
- `keepAlive: true` should be deliberate. Query it on a provider holding
  per-screen state, since that state will now outlive the screen.
- Async work that can be abandoned (BLE reads, network) should clean up in
  `ref.onDispose`.

For deeper checks the repo-independent Riverpod skills are available and worth
loading when a diff is provider-heavy: `riverpod-providers`, `riverpod-refs`,
`riverpod-auto-dispose`, `riverpod-testing`, `riverpod-3-0-migration`.

## Generated code

`.g.dart` and `.freezed.dart` files are committed. A diff that changes a `@riverpod`
provider, a `freezed` model or a Drift table without the regenerated files is a
finding: the build will break for everyone else. `dart run build_runner build
--delete-conflicting-outputs` fixes it.

Drift schema changes also need a matching entry under `drift_schemas/` and a
migration step; check `lib/database/database.steps.dart` moved if tables changed.

## Theme

All colors, radii and spacing come from `CrimpyTheme` in
`lib/theme/crimpy_theme.dart`: `primaryOrange`, `accentGreen`, `statusError`,
`bgSecondary`, `textSecondary`, `borderDefault`, `radiusSmall`, and the semantic
aliases `assessmentColor` / `trainingColor` / `stretchingColor`.

A raw `Color(0xFF...)` or `Colors.grey` in a widget is a finding: use or add a
theme constant. Prefer the semantic alias over the raw accent when one exists.
Keep parity with the web portal's Alpine palette in
`crimpy-frontend/src/lib/.../layout.css`.

## Domain vocabulary

Get these right in naming, they are load-bearing:

- **Training**: a workout that can be performed.
- **Session**: a completed workout (Crimpy training, or logged climbing/stretching).
- **Assessment**: a standardized test (MVC 3FD, critical force), stored separately
  from sessions.
- **Repeater**: structured interval training format.

Session sample data lives as JSON files on the filesystem referenced by the
database row, not as a blob column. Check new session-writing code follows that.

## BLE

`flutter_blue_plus`, models in `lib/models/ble_data_model.dart`, connection state
in `lib/viewmodels/ble_view_model.dart` and `lib/repositories/ble_repository.dart`.
Review BLE diffs for: subscription cancellation on dispose, behaviour when the
sensor disconnects mid-training, and no direct `flutter_blue_plus` imports in
screens.

The transport sits behind `SensorLink` in `lib/services/sensor_link/`. Only
`FlutterBluePlusSensorLink` imports `flutter_blue_plus`; the repository and
everything above it speak `SensorDevice` and raw frames. A `flutter_blue_plus`
type reaching the repository, a viewmodel or a widget is a finding, since
`SimulatedSensorLink` cannot provide it and the emulator path breaks. Decoding,
tare and calibration stay in the repository, so the simulated sensor exercises
them too: logic added to one link that the other lacks is a finding.
`useSimulatedSensor` must stay false in release builds.

## Screenshots on every PR

Every PR that changes something an athlete can see ships a screenshot, posted as
a comment on the PR. A PR that changes the UI and shows none is itself a finding.
Take it from the real app on the emulator, not from a golden test or a mockup:

    just emulator start
    just emulator run
    just emulator screenshot shot.png

`android layout --flat` lists the elements on screen with a center to tap, and
`adb shell input tap X Y` drives the app to the screen that shows the change.
The README's "Running on an emulator" section covers setup.

The sensor is simulated: 3 s of rest then 7 s of hang at about 20 kg, repeating.
Say so in the comment whenever a force reading is in the shot, so nobody reads it
as a real hang. The app points at the local API on the host, which runs `dev`;
sign in with an account the workspace `docs/DEVELOPMENT.md` lists when the screen
needs one.

**Hosting.** GitHub has no API that attaches an image to a comment. The repo is
public, so push the file to a branch of its own and link the raw URL. Keep it off
the PR branch, or the screenshot merges into `dev`:

    BLOB=$(git hash-object -w shot.png)
    TREE=$(printf '100644 blob %s\tshot.png\n' "$BLOB" | git mktree)
    COMMIT=$(git commit-tree "$TREE" -m "Screenshot for ticket NN")
    REF='refs/heads/assets/NN-screenshot'
    git push origin "$COMMIT":"$REF"

Then link
`https://raw.githubusercontent.com/Krakoer/crimpy-app/<branch>/shot.png` from the
comment. That branch has to stay: deleting it breaks the image.

## Before merge

`flutter analyze` clean (custom_lint is enabled via the analyzer plugin), tests in
`test/` pass, generated files regenerated and committed.

## Style

Self-documenting names over comments. No unicode anywhere in code or docs: no
long dashes, ellipsis characters, arrows or emojis. Atomic commits, message at
most 2 lines, no reference to Claude Code.
