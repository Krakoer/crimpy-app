# Cloud Sync Usage Guide

This guide explains how to use the cloud sync feature in your Crimpy app.

## Integration

### 1. Add Cloud Sync Card to Settings

Add the `CloudSyncCard` widget to your settings or profile screen:

```dart
import 'package:crimpy/views/widgets/sync/cloud_sync_card.dart';

// In your settings screen
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: SingleChildScrollView(
      child: Column(
        children: [
          const CloudSyncCard(),
          // Other settings widgets...
        ],
      ),
    ),
  );
}
```

### 2. Show Login Dialog Anywhere

```dart
import 'package:crimpy/views/widgets/sync/login_dialog.dart';

// Show login dialog
final success = await showDialog<bool>(
  context: context,
  builder: (context) => const LoginDialog(),
);

if (success == true) {
  print('User logged in successfully');
}
```

### 3. Access Auth State

```dart
import 'package:crimpy/viewmodels/auth_view_model.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    if (authState.isAuthenticated) {
      return Text('Welcome ${authState.email}');
    } else {
      return const Text('Please login');
    }
  }
}
```

### 4. Trigger Sync Manually

```dart
import 'package:crimpy/viewmodels/sync_view_model.dart';

// Sync all data
await ref.read(syncViewModelProvider.notifier).syncAll();

// Push only
await ref.read(syncViewModelProvider.notifier).pushChanges();

// Pull only
await ref.read(syncViewModelProvider.notifier).pullChanges();

// Retry offline queue
await ref.read(syncViewModelProvider.notifier).retryOfflineQueue();

// Check connectivity
final isOnline = await ref.read(syncViewModelProvider.notifier).checkConnectivity();
```

### 5. Listen to Sync State

```dart
final syncState = ref.watch(syncViewModelProvider);

if (syncState.isSyncing) {
  // Show loading indicator
}

if (syncState.error != null) {
  // Show error message
}

if (syncState.pendingChanges > 0) {
  // Show badge with pending changes count
}
```

## Features

### Authentication
- **Login**: Email/password authentication
- **Register**: Create new account with optional first/last name
- **Logout**: Clear local auth token and user profile
- **Change Password**: Update password while logged in

### Synchronization
- **Bidirectional Sync**: Push local changes, pull remote changes
- **Offline Queue**: Queues operations when offline, retries when online
- **Conflict Detection**: Tracks last sync time per entity
- **Progress Tracking**: Real-time sync status with phases

### Data Synced
- ✅ Sessions (with rep data and assessments)
- ✅ Custom Trainings (with rep templates)
- ✅ Repeater configurations
- ❌ Builtin trainings (not synced)
- ❌ Sensor configs (local only)

## API Endpoints

The app connects to: `https://api.portfolio-online.ovh`

### Auth Endpoints
- `POST /auth/register` - Create account
- `POST /auth/login` - Get auth token
- `PUT /api/auth/change-password` - Update password

### Data Endpoints
- `GET/POST/PUT/DELETE /api/sessions/:id`
- `GET/POST/PUT/DELETE /api/trainings/:id`
- `GET/POST/PUT/DELETE /api/repeaters/:id`

## Database Tables

Three new tables support cloud sync:

### sync_metadata
Tracks sync status for each local entity:
- `entity_table`: 'sessions', 'trainings', etc.
- `local_id`: Local database ID
- `remote_id`: Backend ID (after first sync)
- `last_synced_at`: Last successful sync timestamp
- `needs_upload`: Flag for pending changes
- `pending_operation`: 'create', 'update', or 'delete'

### offline_queue
Stores failed operations for retry:
- `operation`: Type of operation
- `payload`: JSON data
- `retry_count`: Number of retry attempts
- `created_at`: When queued

### user_profile
Local cache of authenticated user:
- `id`: User ID from backend
- `email`: User email
- `firstname/lastname`: Optional names
- `created_at`: Registration timestamp

## Testing

Run the included tests:

```bash
flutter test test/models/sync/
```

All 9 model serialization tests should pass.

## Security

- Tokens stored in `flutter_secure_storage`
- Auto-injected Bearer token in all API requests
- Auto-logout on 401 errors
- No sensitive data in logs (production mode)

## Troubleshooting

### "No internet connection"
Check device connectivity. Sync requires wifi/mobile data.

### "Invalid credentials"
Verify email/password. Try password reset on backend.

### "Email already registered"
Use login instead, or try different email.

### Pending changes stuck
Run retry offline queue or force sync again.
