import 'package:crimpy/models/sync_models.dart';
import 'package:crimpy/viewmodels/sync_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStateAsync = ref.watch(syncViewModelProvider);

    return syncStateAsync.when(
      data: (syncState) => _buildSyncStatus(context, ref, syncState),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorStatus(context, error.toString()),
    );
  }

  Widget _buildSyncStatus(
    BuildContext context,
    WidgetRef ref,
    SyncState syncState,
  ) {
    final theme = Theme.of(context);
    final isSyncing = syncState.status == SyncStatus.syncing;
    final hasError = syncState.status == SyncStatus.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(syncState.status),
                  color: _getStatusColor(syncState.status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cloud Sync',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    _getStatusText(syncState.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(syncState.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            if (syncState.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last synced: ${_formatDateTime(syncState.lastSyncTime!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            if (syncState.pendingChanges > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${syncState.pendingChanges} pending change${syncState.pendingChanges == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            if (hasError) ...[
              if (syncState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: ${syncState.errorMessage}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(syncViewModelProvider.notifier).performSync();
                },
                icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 16),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStatus(BuildContext context, String error) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cloud Sync',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return FontAwesomeIcons.cloud;
      case SyncStatus.syncing:
        return FontAwesomeIcons.arrowsRotate;
      case SyncStatus.success:
        return FontAwesomeIcons.circleCheck;
      case SyncStatus.error:
        return FontAwesomeIcons.triangleExclamation;
    }
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.error:
        return 'Error';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
