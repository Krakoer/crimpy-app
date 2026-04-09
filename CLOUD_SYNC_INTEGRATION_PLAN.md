# Cloud Backend Integration Plan for Crimpy

## Table of Contents
1. [API Overview](#api-overview)
2. [Phase 1: Foundation & Authentication](#phase-1-foundation--authentication)
3. [Phase 2: Data Layer Enhancement](#phase-2-data-layer-enhancement)
4. [Phase 3: UI/UX Implementation](#phase-3-uiux-implementation)
5. [Phase 4: Sync Logic Implementation](#phase-4-sync-logic-implementation)
6. [Phase 5: Data Migration & Edge Cases](#phase-5-data-migration--edge-cases)
7. [Phase 6: Testing & Edge Cases](#phase-6-testing--edge-cases)
8. [Phase 7: Implementation Order](#phase-7-implementation-order)
9. [Key Technical Decisions](#key-technical-decisions)
10. [Future Enhancements](#future-enhancements)

---

## API Overview

The backend API is available at `https://api.portfolio-online.ovh`, with swagger at `https://api.portfolio-online.ovh/swagger/doc.json`

### Endpoints

#### Authentication
- **POST** `/auth/register` - Create new user account
  - Request: `{ email, password, firstname, lastname }`
  - Response: `{ token, user_id }`
- **POST** `/auth/login` - Authenticate user
  - Request: `{ email, password }`
  - Response: `{ token, user_id }`
- **PUT** `/api/auth/change-password` - Change password (requires auth)
  - Request: `{ old_password, new_password, user_id? }`

#### Sessions
- **GET** `/api/sessions` - Get all sessions for authenticated user
- **POST** `/api/sessions` - Create new session with rep data and assessments
- **GET** `/api/sessions/{id}` - Get session by ID with all related data
- **PUT** `/api/sessions/{id}` - Update session (name, notes, duration)
- **DELETE** `/api/sessions/{id}` - Delete session

#### Trainings
- **GET** `/api/trainings` - Get all trainings for authenticated user
- **POST** `/api/trainings` - Create new training with rep templates
- **GET** `/api/trainings/{id}` - Get training by ID
- **PUT** `/api/trainings/{id}` - Update training (name, is_favorite)
- **DELETE** `/api/trainings/{id}` - Delete training

#### Repeaters
- **POST** `/api/repeaters` - Create repeater configuration
- **GET** `/api/repeaters/{id}` - Get repeater by ID
- **PUT** `/api/repeaters/{id}` - Update repeater configuration
- **DELETE** `/api/repeaters/{id}` - Delete repeater

### Authentication
- Uses **Bearer Token** authentication (JWT)
- Token must be included in header: `Authorization: Bearer <token>`
- Token should be stored securely using `flutter_secure_storage`

### Data Models

#### CreateSessionRequest
```json
{
  "name": "string",
  "notes": "string",
  "duration": 0,
  "is_assessment": false,
  "session_type": 0,
  "repeater_sets": 0,
  "repeater_reps": 0,
  "repeater_work_time": 0,
  "repeater_rest_time": 0,
  "repeater_set_rest": 0,
  "repeater_split_hand": false,
  "rep_datas": [
    {
      "index": 0,
      "is_rest": false,
      "right_hand": true,
      "duration": 0,
      "target_weight": 0.0,
      "average_weight": 0.0,
      "grip_position": 0
    }
  ],
  "assessments": [
    {
      "type": 0,
      "right_value": 0.0,
      "left_value": 0.0,
      "grip_position": 0
    }
  ]
}
```

#### CreateTrainingRequest
```json
{
  "name": "string",
  "is_assessment": false,
  "is_favorite": false,
  "repeater_id": 0,
  "rep_templates": [
    {
      "index": 0,
      "is_rest": false,
      "right_hand": true,
      "duration": 0,
      "target_weight": 0.0,
      "grip_position": 0
    }
  ]
}
```

#### CreateRepeaterRequest
```json
{
  "sets": 0,
  "reps": 0,
  "worktime": 0,
  "resttime": 0,
  "set_rest": 0,
  "target_weight_right": 0.0,
  "target_weight_left": 0.0,
  "split_hand": false,
  "grip_position": 0
}
```

---

## Phase 1: Foundation & Authentication

### 1.1 Dependencies & Configuration

Add to `pubspec.yaml`:
```yaml
dependencies:
  dio: ^5.4.0  # HTTP client with interceptors
  flutter_secure_storage: ^9.0.0  # Secure token storage
  connectivity_plus: ^5.0.2  # Network monitoring
  json_annotation: ^4.8.1  # JSON serialization

dev_dependencies:
  json_serializable: ^6.7.1  # Code generation for JSON
```

### 1.2 API Service Layer

Create new directory structure:
```
lib/
├── services/
│   ├── api/
│   │   ├── api_client.dart           # Base HTTP client with interceptors
│   │   ├── auth_api_service.dart     # Authentication endpoints
│   │   ├── session_api_service.dart  # Session sync endpoints
│   │   ├── training_api_service.dart # Training sync endpoints
│   │   └── repeater_api_service.dart # Repeater sync endpoints
│   └── sync/
│       ├── sync_service.dart         # Main sync orchestration
│       ├── sync_queue.dart           # Offline operation queue
│       └── conflict_resolver.dart    # Backend-as-source-of-truth logic
├── models/
│   └── sync/
│       ├── auth_models.dart          # Login/Register request/response
│       ├── sync_state.dart           # Sync status model
│       └── api_models.dart           # API request/response models
```

### 1.3 API Client Implementation

Create `lib/services/api/api_client.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://api.portfolio-online.ovh';
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to all requests
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 unauthorized - token expired
        if (error.response?.statusCode == 401) {
          // Clear token and notify user to re-login
          await _storage.delete(key: 'auth_token');
          // TODO: Trigger logout in AuthViewModel
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

### 1.4 Authentication State Management

Create `lib/models/sync/auth_models.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    @JsonKey(name: 'user_id') required String userId,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isAuthenticated,
    String? userId,
    String? email,
    String? firstname,
    String? lastname,
  }) = _AuthState;
}
```

Create `lib/services/api/auth_api_service.dart`:
```dart
import 'package:crimpy/models/sync/auth_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Email already registered');
      }
      throw Exception('Registration failed: ${e.message}');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    String? userId,
  }) async {
    try {
      await _apiClient.dio.put(
        '/api/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          if (userId != null) 'user_id': userId,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid old password');
      }
      throw Exception('Password change failed: ${e.message}');
    }
  }
}
```

Create `lib/viewmodels/auth_view_model.dart`:
```dart
import 'package:crimpy/models/sync/auth_models.dart';
import 'package:crimpy/services/api/api_client.dart';
import 'package:crimpy/services/api/auth_api_service.dart';
import 'package:crimpy/services/sync/sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late final AuthApiService _authService;
  late final ApiClient _apiClient;
  late final SyncService _syncService;

  @override
  AuthState build() {
    _apiClient = ApiClient();
    _authService = AuthApiService(_apiClient);
    _syncService = ref.read(syncServiceProvider);

    // Check if user is already authenticated
    _checkAuthStatus();

    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _apiClient.getToken();
    if (token != null) {
      // TODO: Optionally verify token with backend
      // For now, assume valid if token exists
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );

      final response = await _authService.register(request);

      // Save token
      await _apiClient.saveToken(response.token);

      // Update state
      state = AuthState(
        isAuthenticated: true,
        userId: response.userId,
        email: email,
        firstname: firstname,
        lastname: lastname,
      );

      // Trigger initial sync (upload all local data)
      await _syncService.performInitialSync(isNewAccount: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      // Save token
      await _apiClient.saveToken(response.token);

      // Update state
      state = AuthState(
        isAuthenticated: true,
        userId: response.userId,
        email: email,
      );

      // Trigger initial sync (download backend data, then upload local-only)
      await _syncService.performInitialSync(isNewAccount: false);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    state = const AuthState();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }
}
```

---

## Phase 2: Data Layer Enhancement

### 2.1 Database Schema Updates

Update `lib/database/database.dart` to add sync tracking tables:

```dart
// New table for tracking sync status
class SyncMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()(); // 'sessions', 'trainings', 'repeaters'
  IntColumn get localId => integer()(); // Local database ID
  IntColumn get remoteId => integer().nullable()(); // Backend ID
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsUpload => boolean().withDefault(const Constant(false))();
  BoolColumn get needsDownload => boolean().withDefault(const Constant(false))();
  TextColumn get pendingOperation => text().nullable()(); // 'create', 'update', 'delete'

  @override
  Set<Column> get primaryKey => {tableName, localId};
}

// New table for offline operation queue
class OfflineQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()(); // 'create_session', 'update_training', etc.
  TextColumn get payload => text()(); // JSON payload
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

// New table for auth user info
class UserProfile extends Table {
  TextColumn get id => text()(); // UUID from backend
  TextColumn get email => text()();
  TextColumn get firstname => text().nullable()();
  TextColumn get lastname => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

Update the `@DriftDatabase` annotation to include new tables:
```dart
@DriftDatabase(
  tables: [
    Sessions,
    Assessments,
    Trainings,
    RepTemplates,
    RepDatas,
    Repeaters,
    SensorConfigs,
    BuiltinTrainingWeights,
    PinnedBuiltinTrainings,
    SyncMetadata,          // NEW
    OfflineQueue,          // NEW
    UserProfile,           // NEW
  ],
)
```

Update `schemaVersion` and add migration:
```dart
@override
int get schemaVersion => 8; // Increment from 7

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    // ... existing migrations ...

    if (from <= 7 && to >= 8) {
      // Migration to schema version 8: Add cloud sync tables
      await m.createTable(syncMetadata);
      await m.createTable(offlineQueue);
      await m.createTable(userProfile);
    }
  },
);
```

### 2.2 Model Enhancements

Add JSON serialization to existing models. Create helper methods to convert between local models and API models.

Create `lib/models/sync/api_models.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_models.freezed.dart';
part 'api_models.g.dart';

// Session API models
@freezed
class SessionResponse with _$SessionResponse {
  const factory SessionResponse({
    required int id,
    required String name,
    required String notes,
    required String date,
    required int duration,
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    @JsonKey(name: 'session_type') required int sessionType,
    @JsonKey(name: 'repeater_sets') int? repeaterSets,
    @JsonKey(name: 'repeater_reps') int? repeaterReps,
    @JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,
    @JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,
    @JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,
    @JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,
    @JsonKey(name: 'user_id') required String userId,
  }) = _SessionResponse;

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);
}

@freezed
class CreateSessionRequest with _$CreateSessionRequest {
  const factory CreateSessionRequest({
    required String name,
    required String notes,
    required int duration,
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    @JsonKey(name: 'session_type') required int sessionType,
    @JsonKey(name: 'repeater_sets') int? repeaterSets,
    @JsonKey(name: 'repeater_reps') int? repeaterReps,
    @JsonKey(name: 'repeater_work_time') int? repeaterWorkTime,
    @JsonKey(name: 'repeater_rest_time') int? repeaterRestTime,
    @JsonKey(name: 'repeater_set_rest') int? repeaterSetRest,
    @JsonKey(name: 'repeater_split_hand') bool? repeaterSplitHand,
    @JsonKey(name: 'rep_datas') List<RepDataRequest>? repDatas,
    List<AssessmentRequest>? assessments,
  }) = _CreateSessionRequest;

  factory CreateSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionRequestFromJson(json);
}

@freezed
class RepDataRequest with _$RepDataRequest {
  const factory RepDataRequest({
    required int index,
    @JsonKey(name: 'is_rest') required bool isRest,
    @JsonKey(name: 'right_hand') required bool rightHand,
    required int duration,
    @JsonKey(name: 'target_weight') required double targetWeight,
    @JsonKey(name: 'average_weight') required double averageWeight,
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _RepDataRequest;

  factory RepDataRequest.fromJson(Map<String, dynamic> json) =>
      _$RepDataRequestFromJson(json);
}

@freezed
class AssessmentRequest with _$AssessmentRequest {
  const factory AssessmentRequest({
    required int type,
    @JsonKey(name: 'right_value') double? rightValue,
    @JsonKey(name: 'left_value') double? leftValue,
    @JsonKey(name: 'grip_position') int? gripPosition,
  }) = _AssessmentRequest;

  factory AssessmentRequest.fromJson(Map<String, dynamic> json) =>
      _$AssessmentRequestFromJson(json);
}

// Training API models
@freezed
class TrainingResponse with _$TrainingResponse {
  const factory TrainingResponse({
    required int id,
    required String name,
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    @JsonKey(name: 'is_favorite') required bool isFavorite,
    @JsonKey(name: 'repeater_id') int? repeaterId,
    @JsonKey(name: 'user_id') required String userId,
  }) = _TrainingResponse;

  factory TrainingResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingResponseFromJson(json);
}

@freezed
class CreateTrainingRequest with _$CreateTrainingRequest {
  const factory CreateTrainingRequest({
    required String name,
    @JsonKey(name: 'is_assessment') required bool isAssessment,
    @JsonKey(name: 'is_favorite') required bool isFavorite,
    @JsonKey(name: 'repeater_id') int? repeaterId,
    @JsonKey(name: 'rep_templates') List<RepTemplateRequest>? repTemplates,
  }) = _CreateTrainingRequest;

  factory CreateTrainingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTrainingRequestFromJson(json);
}

@freezed
class RepTemplateRequest with _$RepTemplateRequest {
  const factory RepTemplateRequest({
    required int index,
    @JsonKey(name: 'is_rest') required bool isRest,
    @JsonKey(name: 'right_hand') required bool rightHand,
    required int duration,
    @JsonKey(name: 'target_weight') required double targetWeight,
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _RepTemplateRequest;

  factory RepTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$RepTemplateRequestFromJson(json);
}

// Repeater API models
@freezed
class RepeaterResponse with _$RepeaterResponse {
  const factory RepeaterResponse({
    required int id,
    required int sets,
    required int reps,
    required int worktime,
    required int resttime,
    @JsonKey(name: 'set_rest') required int setRest,
    @JsonKey(name: 'target_weight_right') double? targetWeightRight,
    @JsonKey(name: 'target_weight_left') double? targetWeightLeft,
    @JsonKey(name: 'split_hand') required bool splitHand,
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _RepeaterResponse;

  factory RepeaterResponse.fromJson(Map<String, dynamic> json) =>
      _$RepeaterResponseFromJson(json);
}

@freezed
class CreateRepeaterRequest with _$CreateRepeaterRequest {
  const factory CreateRepeaterRequest({
    required int sets,
    required int reps,
    required int worktime,
    required int resttime,
    @JsonKey(name: 'set_rest') required int setRest,
    @JsonKey(name: 'target_weight_right') double? targetWeightRight,
    @JsonKey(name: 'target_weight_left') double? targetWeightLeft,
    @JsonKey(name: 'split_hand') required bool splitHand,
    @JsonKey(name: 'grip_position') required int gripPosition,
  }) = _CreateRepeaterRequest;

  factory CreateRepeaterRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRepeaterRequestFromJson(json);
}
```

### 2.3 Repository Pattern Updates

Add sync helper methods to the database class in `lib/database/database.dart`:

```dart
// ------------------------------------- SYNC METADATA -------------------------------------
/// Get sync metadata for a specific entity
Future<SyncMetadatum?> getSyncMetadata(String tableName, int localId) async {
  return await (select(syncMetadata)
    ..where((s) => s.tableName.equals(tableName) & s.localId.equals(localId)))
      .getSingleOrNull();
}

/// Save or update sync metadata
Future<void> upsertSyncMetadata({
  required String tableName,
  required int localId,
  int? remoteId,
  DateTime? lastSyncedAt,
  bool? needsUpload,
  bool? needsDownload,
  String? pendingOperation,
}) async {
  final existing = await getSyncMetadata(tableName, localId);

  if (existing != null) {
    await (update(syncMetadata)
      ..where((s) => s.tableName.equals(tableName) & s.localId.equals(localId)))
        .write(SyncMetadataCompanion(
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
      lastSyncedAt: lastSyncedAt != null ? Value(lastSyncedAt) : const Value.absent(),
      needsUpload: needsUpload != null ? Value(needsUpload) : const Value.absent(),
      needsDownload: needsDownload != null ? Value(needsDownload) : const Value.absent(),
      pendingOperation: pendingOperation != null ? Value(pendingOperation) : const Value.absent(),
    ));
  } else {
    await into(syncMetadata).insert(SyncMetadataCompanion.insert(
      tableName: tableName,
      localId: localId,
      remoteId: Value(remoteId),
      lastSyncedAt: Value(lastSyncedAt),
      needsUpload: Value(needsUpload ?? false),
      needsDownload: Value(needsDownload ?? false),
      pendingOperation: Value(pendingOperation),
    ));
  }
}

/// Get all entities that need upload
Future<List<SyncMetadatum>> getEntitiesNeedingUpload() async {
  return await (select(syncMetadata)..where((s) => s.needsUpload.equals(true))).get();
}

/// Mark entity for upload
Future<void> markForUpload(String tableName, int localId, String operation) async {
  await upsertSyncMetadata(
    tableName: tableName,
    localId: localId,
    needsUpload: true,
    pendingOperation: operation,
  );
}

// ------------------------------------- OFFLINE QUEUE -------------------------------------
/// Add operation to offline queue
Future<int> enqueueOfflineOperation({
  required String operation,
  required Map<String, dynamic> payload,
}) async {
  return await into(offlineQueue).insert(OfflineQueueCompanion.insert(
    operation: operation,
    payload: jsonEncode(payload),
  ));
}

/// Get all queued operations
Future<List<OfflineQueueEntry>> getQueuedOperations() async {
  return await (select(offlineQueue)
    ..orderBy([(o) => OrderingTerm.asc(o.createdAt)])).get();
}

/// Remove operation from queue
Future<void> dequeueOperation(int id) async {
  await (delete(offlineQueue)..where((o) => o.id.equals(id))).go();
}

/// Increment retry count
Future<void> incrementRetryCount(int id) async {
  final entry = await (select(offlineQueue)..where((o) => o.id.equals(id))).getSingle();
  await (update(offlineQueue)..where((o) => o.id.equals(id)))
      .write(OfflineQueueCompanion(retryCount: Value(entry.retryCount + 1)));
}

// ------------------------------------- USER PROFILE -------------------------------------
/// Save user profile
Future<void> saveUserProfile({
  required String id,
  required String email,
  String? firstname,
  String? lastname,
}) async {
  await into(userProfile).insert(
    UserProfileCompanion.insert(
      id: id,
      email: email,
      firstname: Value(firstname),
      lastname: Value(lastname),
      createdAt: DateTime.now(),
    ),
    mode: InsertMode.insertOrReplace,
  );
}

/// Get user profile
Future<UserProfileData?> getUserProfile() async {
  return await select(userProfile).getSingleOrNull();
}

/// Delete user profile (on logout)
Future<void> deleteUserProfile() async {
  await delete(userProfile).go();
}
```

---

## Phase 3: UI/UX Implementation

### 3.1 Profile Screen Enhancement

Update `lib/views/screens/profile_screen/widgets/profile_content.dart` to add cloud sync UI at the top:

```dart
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/sync_view_model.dart';
import 'package:crimpy/views/screens/assessments/pre_run_screen.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/stat_content.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/mvc_grip_position_stat_content.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/cloud_sync_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileContent extends ConsumerWidget {
  final List<AssessmentModel> assessments;
  final Color accentLeft;
  final Color accentRight;

  const ProfileContent({
    super.key,
    required this.assessments,
    required this.accentLeft,
    required this.accentRight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Split & sort
    final maxForce =
        assessments.where((a) => a.type == AssessmentType.mvc).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    // Group MVC assessments by grip position
    final Map<GripPosition, List<AssessmentModel>> mvcByGripPosition = {};
    for (var assessment in maxForce) {
      final grip = assessment.gripPosition ?? GripPosition.halfCrimp;
      mvcByGripPosition.putIfAbsent(grip, () => []);
      mvcByGripPosition[grip]!.add(assessment);
    }

    final criticalForce =
        assessments
            .where((a) => a.type == AssessmentType.criticalForce)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final endurance60 =
        assessments.where((a) => a.type == AssessmentType.endurance60).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Cloud Sync Section - NEW
          const CloudSyncCard(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Max Force Section with Grip Position Selection
          MvcGripPositionStatContent(
            mvcByGripPosition: mvcByGripPosition,
            accentLeft: accentLeft,
            accentRight: accentRight,
            onStartAssessment:
                ref.watch(connectionStateProvider) ==
                        BleConnectionState.connected
                    ? () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) => PreRunScreen(type: AssessmentType.mvc),
                        ),
                      );
                    }
                    : () => showDialog(
                      builder:
                          (context) => AlertDialog(
                            title: Text("No BLE device connected"),
                            content: Text(
                              "You must connect to a BLE device to run an assessment",
                            ),
                          ),
                      context: context,
                    ),
          ),

          const SizedBox(height: 32),

          // Critical Force Section
          StatContent(
            title: "Critical Force",
            maxLeft: criticalForce
                .map((a) => a.leftValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            maxRight: criticalForce
                .map((a) => a.rightValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            accentLeft: accentLeft,
            accentRight: accentRight,
            leftData:
                criticalForce
                    .where((a) => a.leftValue != null)
                    .map((a) => (a.date, a.leftValue!))
                    .toList(),
            rightData:
                criticalForce
                    .where((a) => a.rightValue != null)
                    .map((a) => (a.date, a.rightValue!))
                    .toList(),
            onStartAssessment:
                () =>
                    ref.watch(connectionStateProvider) ==
                            BleConnectionState.connected
                        ? () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (ctx) => PreRunScreen(
                                    type: AssessmentType.criticalForce,
                                  ),
                            ),
                          );
                        }
                        : () => showDialog(
                          builder:
                              (context) => AlertDialog(
                                title: Text("No BLE device connected"),
                                content: Text(
                                  "You must connect to a BLE device to run an assessment",
                                ),
                              ),
                          context: context,
                        ),
          ),

          SizedBox(height: 32),

          // 60% Endurance Section
          StatContent(
            title: "60% Endurance",
            maxLeft: endurance60
                .map((a) => a.leftValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            maxRight: endurance60
                .map((a) => a.rightValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            accentLeft: accentLeft,
            accentRight: accentRight,
            leftData:
                endurance60
                    .where((a) => a.leftValue != null)
                    .map((a) => (a.date, a.leftValue!))
                    .toList(),
            rightData:
                endurance60
                    .where((a) => a.rightValue != null)
                    .map((a) => (a.date, a.rightValue!))
                    .toList(),
            unit: AssessmentUnit.seconds,
            onStartAssessment:
                () =>
                    ref.watch(connectionStateProvider) ==
                            BleConnectionState.connected
                        ? () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (ctx) => PreRunScreen(
                                    type: AssessmentType.endurance60,
                                  ),
                            ),
                          );
                        }
                        : () => showDialog(
                          builder:
                              (context) => AlertDialog(
                                title: Text("No BLE device connected"),
                                content: Text(
                                  "You must connect to a BLE device to run an assessment",
                                ),
                              ),
                          context: context,
                        ),
          ),
        ],
      ),
    );
  }
}
```

### 3.2 Cloud Sync Card Widget

Create `lib/views/screens/profile_screen/widgets/cloud_sync_card.dart`:

```dart
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/sync_view_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/login_dialog.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/register_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudSyncCard extends ConsumerWidget {
  const CloudSyncCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: authState.isAuthenticated
            ? _buildAuthenticatedView(context, ref)
            : _buildUnauthenticatedView(context, ref),
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Local Only',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Backup your data to the cloud and sync across devices',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showRegisterDialog(context, ref),
                icon: const Icon(Icons.person_add),
                label: const Text('Create Account'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showLoginDialog(context, ref),
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthenticatedView(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final syncState = ref.watch(syncViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              syncState.isSyncing
                  ? Icons.cloud_sync
                  : Icons.cloud_done,
              color: syncState.isSyncing ? Colors.blue : Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.email ?? 'Signed In',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (syncState.lastSyncTime != null)
                    Text(
                      'Last synced: ${_formatLastSync(syncState.lastSyncTime!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (syncState.pendingChanges > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${syncState.pendingChanges} changes pending sync',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
        if (syncState.error != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syncState.error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: syncState.isSyncing
                  ? null
                  : () => ref.read(syncViewModelProvider.notifier).syncNow(),
              icon: syncState.isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(syncState.isSyncing ? 'Syncing...' : 'Sync Now'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showLogoutDialog(context, ref),
              child: const Text('Logout'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showLoginDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const LoginDialog(),
    );
  }

  void _showRegisterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const RegisterDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? Your local data will remain on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authViewModelProvider.notifier).logout();
              Navigator.of(context).pop();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
```

### 3.3 Authentication Dialogs

Create `lib/views/screens/profile_screen/widgets/login_dialog.dart`:

```dart
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginDialog extends ConsumerStatefulWidget {
  const LoginDialog({super.key});

  @override
  ConsumerState<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authViewModelProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Login'),
        ),
      ],
    );
  }
}
```

Create `lib/views/screens/profile_screen/widgets/register_dialog.dart`:

```dart
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterDialog extends ConsumerStatefulWidget {
  const RegisterDialog({super.key});

  @override
  ConsumerState<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends ConsumerState<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authViewModelProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstname: _firstnameController.text.trim().isEmpty
            ? null
            : _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim().isEmpty
            ? null
            : _lastnameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Syncing your data...'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Account'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstnameController,
                decoration: const InputDecoration(
                  labelText: 'First Name (optional)',
                  prefixIcon: Icon(Icons.person),
                ),
                autofillHints: const [AutofillHints.givenName],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name (optional)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                autofillHints: const [AutofillHints.familyName],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All your local data will be backed up to the cloud',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Account'),
        ),
      ],
    );
  }
}
```

---

## Phase 4: Sync Logic Implementation

### 4.1 Sync State Management

Create `lib/models/sync/sync_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    DateTime? lastSyncTime,
    @Default(0) int pendingChanges,
    String? error,
    @Default(SyncPhase.idle) SyncPhase phase,
  }) = _SyncState;
}

enum SyncPhase {
  idle,
  pushingSessions,
  pushingTrainings,
  pushingRepeaters,
  pullingSessions,
  pullingTrainings,
  pullingRepeaters,
}
```

### 4.2 Sync Service Implementation

Create `lib/services/sync/sync_service.dart`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/sync/sync_state.dart';
import 'package:crimpy/services/api/session_api_service.dart';
import 'package:crimpy/services/api/training_api_service.dart';
import 'package:crimpy/services/api/repeater_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_service.g.dart';

@riverpod
SyncService syncService(SyncServiceRef ref) {
  return SyncService(
    database: gDatabase,
    sessionApiService: ref.read(sessionApiServiceProvider),
    trainingApiService: ref.read(trainingApiServiceProvider),
    repeaterApiService: ref.read(repeaterApiServiceProvider),
  );
}

class SyncService {
  final AppDatabase database;
  final SessionApiService sessionApiService;
  final TrainingApiService trainingApiService;
  final RepeaterApiService repeaterApiService;

  SyncService({
    required this.database,
    required this.sessionApiService,
    required this.trainingApiService,
    required this.repeaterApiService,
  });

  /// Perform initial sync after registration or login
  Future<void> performInitialSync({required bool isNewAccount}) async {
    if (isNewAccount) {
      // New account: upload all local data to backend
      await _uploadAllLocalData();
    } else {
      // Existing account: download backend data first (backend as source of truth)
      await _downloadAllBackendData();
      // Then upload any local-only data
      await _uploadLocalOnlyData();
    }
  }

  /// Main sync operation
  Future<void> sync() async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      AppLoggerHelper.warning('No internet connection, queuing operations');
      return;
    }

    try {
      // Phase 1: Push local changes
      await _pushLocalChanges();

      // Phase 2: Pull backend changes
      await _pullBackendChanges();

      // Phase 3: Process offline queue
      await _processOfflineQueue();
    } catch (e) {
      AppLoggerHelper.error('Sync failed: $e');
      rethrow;
    }
  }

  /// Upload all local data (for new accounts)
  Future<void> _uploadAllLocalData() async {
    // Upload all sessions
    final sessions = await database.getAllSessions();
    for (final session in sessions) {
      await _uploadSession(session.id);
    }

    // Upload all custom trainings (exclude builtins)
    final trainings = await database.getAllTrainingsWithoutAssessments();
    for (final training in trainings.where((t) => !t.isBuiltin)) {
      await _uploadTraining(training.id);
    }

    // Upload all repeaters
    // Note: Repeaters are linked to trainings, so we need to sync them carefully
    // This will be handled in the training upload process
  }

  /// Download all backend data (for existing accounts)
  Future<void> _downloadAllBackendData() async {
    // Pull all sessions
    await _pullSessions();

    // Pull all trainings
    await _pullTrainings();

    // Pull all repeaters (embedded in trainings)
  }

  /// Upload local-only data that doesn't exist on backend
  Future<void> _uploadLocalOnlyData() async {
    // Find sessions without remote ID
    final allSessions = await database.getAllSessions();
    for (final session in allSessions) {
      final syncMeta = await database.getSyncMetadata('sessions', session.id);
      if (syncMeta == null || syncMeta.remoteId == null) {
        await _uploadSession(session.id);
      }
    }

    // Find trainings without remote ID
    final allTrainings = await database.getAllTrainingsWithoutAssessments();
    for (final training in allTrainings.where((t) => !t.isBuiltin)) {
      final syncMeta = await database.getSyncMetadata('trainings', training.id);
      if (syncMeta == null || syncMeta.remoteId == null) {
        await _uploadTraining(training.id);
      }
    }
  }

  /// Push local changes to backend
  Future<void> _pushLocalChanges() async {
    final pendingUploads = await database.getEntitiesNeedingUpload();

    for (final meta in pendingUploads) {
      try {
        switch (meta.tableName) {
          case 'sessions':
            await _handleSessionPush(meta);
            break;
          case 'trainings':
            await _handleTrainingPush(meta);
            break;
          case 'repeaters':
            await _handleRepeaterPush(meta);
            break;
        }
      } catch (e) {
        AppLoggerHelper.error('Failed to push ${meta.tableName} ${meta.localId}: $e');
        // Queue for retry
        await database.enqueueOfflineOperation(
          operation: 'push_${meta.tableName}',
          payload: {
            'local_id': meta.localId,
            'operation': meta.pendingOperation,
          },
        );
      }
    }
  }

  /// Pull backend changes
  Future<void> _pullBackendChanges() async {
    await _pullSessions();
    await _pullTrainings();
  }

  /// Handle session push based on operation
  Future<void> _handleSessionPush(SyncMetadatum meta) async {
    switch (meta.pendingOperation) {
      case 'create':
        await _uploadSession(meta.localId);
        break;
      case 'update':
        await _updateSession(meta.localId, meta.remoteId!);
        break;
      case 'delete':
        await sessionApiService.deleteSession(meta.remoteId!);
        await database.upsertSyncMetadata(
          tableName: 'sessions',
          localId: meta.localId,
          needsUpload: false,
          pendingOperation: null,
        );
        break;
    }
  }

  /// Handle training push based on operation
  Future<void> _handleTrainingPush(SyncMetadatum meta) async {
    switch (meta.pendingOperation) {
      case 'create':
        await _uploadTraining(meta.localId);
        break;
      case 'update':
        await _updateTraining(meta.localId, meta.remoteId!);
        break;
      case 'delete':
        await trainingApiService.deleteTraining(meta.remoteId!);
        await database.upsertSyncMetadata(
          tableName: 'trainings',
          localId: meta.localId,
          needsUpload: false,
          pendingOperation: null,
        );
        break;
    }
  }

  /// Handle repeater push based on operation
  Future<void> _handleRepeaterPush(SyncMetadatum meta) async {
    switch (meta.pendingOperation) {
      case 'create':
        await _uploadRepeater(meta.localId);
        break;
      case 'update':
        await _updateRepeater(meta.localId, meta.remoteId!);
        break;
      case 'delete':
        await repeaterApiService.deleteRepeater(meta.remoteId!);
        await database.upsertSyncMetadata(
          tableName: 'repeaters',
          localId: meta.localId,
          needsUpload: false,
          pendingOperation: null,
        );
        break;
    }
  }

  /// Upload a session to backend
  Future<void> _uploadSession(int localSessionId) async {
    // Get session with all related data
    final sessionModel = await database.getSessionWithData(localSessionId);
    if (sessionModel == null) return;

    final reps = await database.getRepsForSession(localSessionId);

    // Convert to API request format
    final request = _sessionToCreateRequest(sessionModel, reps);

    // Upload to backend
    final response = await sessionApiService.createSession(request);

    // Save remote ID mapping
    await database.upsertSyncMetadata(
      tableName: 'sessions',
      localId: localSessionId,
      remoteId: response.id,
      lastSyncedAt: DateTime.now(),
      needsUpload: false,
      pendingOperation: null,
    );
  }

  /// Update a session on backend
  Future<void> _updateSession(int localId, int remoteId) async {
    final sessionModel = await database.getSessionWithData(localId);
    if (sessionModel == null) return;

    final request = _sessionToUpdateRequest(sessionModel);
    await sessionApiService.updateSession(remoteId, request);

    await database.upsertSyncMetadata(
      tableName: 'sessions',
      localId: localId,
      remoteId: remoteId,
      lastSyncedAt: DateTime.now(),
      needsUpload: false,
      pendingOperation: null,
    );
  }

  /// Upload a training to backend
  Future<void> _uploadTraining(int localTrainingId) async {
    // TODO: Implement similar to _uploadSession
    // Get training with rep templates
    // Handle repeater if present
    // Convert to API request
    // Upload and save mapping
  }

  /// Update a training on backend
  Future<void> _updateTraining(int localId, int remoteId) async {
    // TODO: Implement
  }

  /// Upload a repeater to backend
  Future<void> _uploadRepeater(int localRepeaterId) async {
    // TODO: Implement
  }

  /// Update a repeater on backend
  Future<void> _updateRepeater(int localId, int remoteId) async {
    // TODO: Implement
  }

  /// Pull all sessions from backend
  Future<void> _pullSessions() async {
    final sessions = await sessionApiService.getAllSessions();

    for (final sessionResponse in sessions) {
      // Check if we have this session locally
      final syncMeta = await database.getSyncMetadata('sessions', sessionResponse.id);

      if (syncMeta == null) {
        // New session from backend, create locally
        await _createLocalSession(sessionResponse);
      } else {
        // Existing session, backend wins in conflicts
        await _updateLocalSession(syncMeta.localId, sessionResponse);
      }
    }
  }

  /// Pull all trainings from backend
  Future<void> _pullTrainings() async {
    // TODO: Implement similar to _pullSessions
  }

  /// Create local session from backend data
  Future<void> _createLocalSession(SessionResponse response) async {
    // TODO: Convert SessionResponse to SessionModel and save locally
  }

  /// Update local session from backend data (backend wins)
  Future<void> _updateLocalSession(int localId, SessionResponse response) async {
    // TODO: Update local session with backend data
  }

  /// Process queued offline operations
  Future<void> _processOfflineQueue() async {
    final queue = await database.getQueuedOperations();

    for (final entry in queue) {
      try {
        // Process operation based on type
        // This is a simplified version - actual implementation would parse payload
        await _processQueuedOperation(entry);
        await database.dequeueOperation(entry.id);
      } catch (e) {
        AppLoggerHelper.error('Failed to process queued operation ${entry.id}: $e');
        await database.incrementRetryCount(entry.id);

        // Remove from queue if max retries exceeded
        if (entry.retryCount >= 3) {
          AppLoggerHelper.error('Max retries exceeded for operation ${entry.id}, removing from queue');
          await database.dequeueOperation(entry.id);
        }
      }
    }
  }

  Future<void> _processQueuedOperation(OfflineQueueEntry entry) async {
    // TODO: Implement based on operation type
  }

  // Helper methods for conversion between models
  CreateSessionRequest _sessionToCreateRequest(SessionModel session, List<RepData> reps) {
    // TODO: Implement conversion
    throw UnimplementedError();
  }

  UpdateSessionRequest _sessionToUpdateRequest(SessionModel session) {
    // TODO: Implement conversion
    throw UnimplementedError();
  }
}
```

### 4.3 Sync ViewModel

Create `lib/viewmodels/sync_view_model.dart`:

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/sync/sync_state.dart';
import 'package:crimpy/services/sync/sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_view_model.g.dart';

@riverpod
class SyncViewModel extends _$SyncViewModel {
  late final SyncService _syncService;
  Timer? _periodicSyncTimer;
  StreamSubscription? _connectivitySubscription;

  @override
  SyncState build() {
    _syncService = ref.read(syncServiceProvider);
    _setupConnectivityListener();
    _startPeriodicSync();

    return const SyncState();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // Connection restored, trigger sync
        syncNow();
      }
    });
  }

  void _startPeriodicSync() {
    // Sync every 30 minutes
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      syncNow();
    });
  }

  Future<void> syncNow() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true, error: null);

    try {
      await _syncService.sync();

      // Update pending changes count
      final pendingCount = await _getPendingChangesCount();

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        pendingChanges: pendingCount,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<int> _getPendingChangesCount() async {
    final pending = await gDatabase.getEntitiesNeedingUpload();
    final queued = await gDatabase.getQueuedOperations();
    return pending.length + queued.length;
  }

  @override
  void dispose() {
    _periodicSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
```

---

## Phase 5: Data Migration & Edge Cases

### 5.1 Session Data Points Handling

**Decision**: For MVP, do NOT sync raw BLE data points (the JSON files on filesystem).

**Rationale**:
- Backend API doesn't have endpoints for raw data storage
- Large file sizes would consume bandwidth
- Rep data (aggregated) is sufficient for most use cases

**Implementation**:
- Only sync `RepData` (average weights, durations, etc.)
- Keep `dataPath` as empty string for synced sessions
- Future enhancement: Add cloud storage (S3) for raw data points

### 5.2 Builtin Trainings

**Decision**: Do NOT sync builtin trainings to backend.

**What to sync**:
- Custom weights for builtin trainings (`BuiltinTrainingWeights` table)
- Pinned status (`PinnedBuiltinTrainings` table)

**Note**: Backend API doesn't currently support these. Consider adding:
- `GET/POST /api/builtin-weights` endpoint
- `GET/POST /api/pinned-trainings` endpoint

### 5.3 Sensor Configurations

**Decision**: Keep sensor configs local-only for now.

**Rationale**:
- Backend API doesn't have sensor config endpoints
- Sensor calibration is device-specific

**Future**: Add backend support if multi-device sensor sharing is needed.

### 5.4 ID Mapping Strategy

**Implementation**:
- Local app always uses `localId` for all operations
- `SyncMetadata` table maintains `(localId, remoteId)` mapping
- Sync layer translates IDs when communicating with backend
- When pulling data from backend with unknown `remoteId`:
  - Create new local entity
  - Store mapping in `SyncMetadata`

---

## Phase 6: Testing & Edge Cases

### 6.1 Test Scenarios

1. **New User Registration**
   - Register account
   - Verify all local sessions uploaded
   - Verify all local trainings uploaded
   - Verify sync metadata created

2. **Existing User Login**
   - Login with account that has backend data
   - Verify backend data downloaded
   - Verify local-only data uploaded
   - Verify conflicts resolved (backend wins)

3. **Offline Session Creation**
   - Disconnect internet
   - Create new session
   - Verify queued for upload
   - Reconnect internet
   - Verify session uploaded

4. **Conflict Resolution**
   - Modify session on device A
   - Modify same session on device B
   - Sync both devices
   - Verify last-to-sync wins (backend as source of truth)

5. **Large Dataset Sync**
   - Create 1000+ sessions locally
   - Register account
   - Verify all sessions sync without errors
   - Monitor performance

6. **Network Interruption**
   - Start sync
   - Disconnect internet mid-sync
   - Verify operations queued
   - Reconnect
   - Verify retry logic works

7. **Token Expiration**
   - Wait for token to expire
   - Make API request
   - Verify 401 handled
   - Verify user prompted to re-login

### 6.2 Error Handling

```dart
// Network errors
try {
  await apiCall();
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.connectionError) {
    // Queue for retry
    await database.enqueueOfflineOperation(...);
  }
}

// 401 Unauthorized
if (response.statusCode == 401) {
  await apiClient.clearToken();
  ref.read(authViewModelProvider.notifier).logout();
  // Show login dialog
}

// 409 Conflict
if (response.statusCode == 409) {
  // Backend wins, pull latest data
  await _pullBackendData();
}

// 500 Server Error
if (response.statusCode == 500) {
  // Queue for retry with exponential backoff
  await database.enqueueOfflineOperation(...);
}
```

### 6.3 Performance Considerations

- **Batch Operations**: Upload/download in batches of 50
- **Pagination**: Use pagination for large datasets
- **Background Sync**: Use `WorkManager` for Android background sync
- **Delta Sync**: Only fetch changes since last sync (future enhancement)

---

## Phase 7: Implementation Order

### Week 1: Foundation
- [ ] Add dependencies to `pubspec.yaml`
- [ ] Create `ApiClient` with interceptors
- [ ] Create authentication models and API service
- [ ] Implement `AuthViewModel` with secure token storage
- [ ] Update database schema (add `SyncMetadata`, `OfflineQueue`, `UserProfile`)
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Test database migration

### Week 2: Authentication UI
- [ ] Create `CloudSyncCard` widget
- [ ] Create `LoginDialog` widget
- [ ] Create `RegisterDialog` widget
- [ ] Update `ProfileContent` to include cloud sync card
- [ ] Test login/register flow
- [ ] Verify token storage and retrieval

### Week 3: Model & Repository Layer
- [ ] Create API model classes (freezed/json_serializable)
- [ ] Run code generation for models
- [ ] Create `SessionApiService`
- [ ] Create `TrainingApiService`
- [ ] Create `RepeaterApiService`
- [ ] Add sync helper methods to database class
- [ ] Test API services with mock data

### Week 4: Sync Logic - Sessions
- [ ] Create `SyncState` model
- [ ] Create `SyncService` class
- [ ] Implement session upload (`_uploadSession`)
- [ ] Implement session pull (`_pullSessions`)
- [ ] Implement conflict resolution (backend wins)
- [ ] Create `SyncViewModel`
- [ ] Test session sync end-to-end

### Week 5: Sync Logic - Trainings & Repeaters
- [ ] Implement training upload/pull
- [ ] Implement repeater upload/pull
- [ ] Implement offline queue processing
- [ ] Add connectivity monitoring
- [ ] Test full sync cycle with all data types

### Week 6: Polish & Testing
- [ ] Add loading indicators
- [ ] Add error toasts/snackbars
- [ ] Add sync progress UI
- [ ] Implement periodic background sync
- [ ] Comprehensive error handling
- [ ] End-to-end testing with real backend
- [ ] Performance optimization
- [ ] User acceptance testing

---

## Key Technical Decisions

### Recommended Packages
```yaml
dependencies:
  dio: ^5.4.0  # HTTP client with interceptors
  flutter_secure_storage: ^9.0.0  # Secure token storage
  connectivity_plus: ^5.0.2  # Network monitoring
  json_annotation: ^4.8.1  # JSON serialization
  freezed_annotation: ^2.4.1  # Immutable models

dev_dependencies:
  json_serializable: ^6.7.1  # Code generation for JSON
  freezed: ^2.4.6  # Code generation for models
```

### Code Generation Commands
After adding models or changing database schema:
```bash
# Generate JSON serialization and Freezed models
dart run build_runner build --delete-conflicting-outputs

# Or watch for changes
dart run build_runner watch --delete-conflicting-outputs
```

### API Client Architecture
- Use `Dio` for HTTP client (supports interceptors)
- Add `AuthInterceptor` to inject Bearer token
- Add `LoggingInterceptor` for debugging
- Handle 401 globally in error interceptor
- Use `flutter_secure_storage` for token (encrypted on device)

### Sync Strategy
- **Offline-first**: Local database is primary, sync is secondary
- **Backend-as-source-of-truth**: Backend always wins in conflicts
- **Operation queue**: Queue operations when offline
- **Periodic sync**: Every 30 minutes + on app resume
- **Manual sync**: User can trigger via "Sync Now" button

### Conflict Resolution
- Pull before push on initial login
- Backend data overwrites local on conflict
- No merge logic (too complex for MVP)
- Future: Add conflict UI to let user choose

---

## Future Enhancements

### 1. Delta Sync
Instead of fetching all data, only fetch changes since last sync:
```dart
// Add lastSyncTimestamp to API calls
final sessions = await api.getSessions(since: lastSyncTime);
```

### 2. Raw Data Points Sync
Upload session JSON files to cloud storage (S3):
```dart
// Upload file to S3
final s3Url = await s3Service.uploadFile(sessionDataPath);
// Store URL in session
await api.updateSession(id, dataUrl: s3Url);
```

### 3. Multi-Device Notifications
Notify user when data changes on another device:
```dart
// Use WebSockets or Firebase Cloud Messaging
onDataChanged(String entity, int id) {
  showNotification('Your $entity was updated on another device');
  syncNow();
}
```

### 4. Conflict Resolution UI
Let user choose which version to keep:
```dart
showConflictDialog(
  localVersion: localSession,
  remoteVersion: remoteSession,
  onResolve: (choice) => choice == 'local' ? keepLocal() : keepRemote(),
);
```

### 5. Export/Import
Allow manual backup:
```dart
// Export all data to JSON file
final backup = await database.exportToJson();
await shareFile(backup);

// Import from JSON file
await database.importFromJson(file);
```

### 6. Selective Sync
Let user choose what to sync:
```dart
// Settings screen
SyncSettings(
  syncSessions: true,
  syncTrainings: true,
  syncAssessments: false, // Keep private
);
```

---

## Summary

This plan provides a complete implementation roadmap for cloud sync in Crimpy:

1. **Authentication**: Secure login/register with JWT token storage
2. **Sync Architecture**: Offline-first with backend-as-source-of-truth
3. **UI/UX**: Seamless cloud integration in profile screen
4. **Data Layer**: Enhanced database with sync tracking
5. **Sync Logic**: Push/pull with conflict resolution
6. **Testing**: Comprehensive test scenarios
7. **Timeline**: 6-week phased implementation

The implementation maintains the existing app architecture (Drift, Riverpod, Repository pattern) while adding cloud capabilities.
