import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/edit_session_screen.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_overview_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_performance_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_reps_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_notes_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_raw_data_card.dart';

class SessionDetailScreen extends ConsumerWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get full session data if we only have basic info
    final asyncFullSession = session.reps == null
        ? ref.watch(sessionWithDataProvider(session.id!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: [
          // Show edit button for all sessions
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _handleMenuAction(context, 'edit', ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, ref),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: asyncFullSession != null
            ? switch (asyncFullSession) {
                AsyncData(:final value) =>
                  value != null
                      ? _buildSessionDetails(context, ref, value)
                      : _buildNotFoundError(context),
                AsyncError(:final error) => _buildErrorState(
                  context,
                  error.toString(),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              }
            : _buildSessionDetails(context, ref, session),
      ),
    );
  }

  Widget _buildSessionDetails(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
  ) {
    final sessionColor = CrimpyTheme.activityColor(session.activity);
    final blocks = _resolveBlocks(ref, session);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session overview card
          SessionOverviewCard(session: session),
          const SizedBox(height: 16),

          // Performance stats (if available)
          if (session.hasReps) ...[
            SessionPerformanceCard(reps: session.reps!, blocks: blocks),
            const SizedBox(height: 16),
          ],

          // Repetitions breakdown (if available)
          if (session.hasReps) ...[
            SessionRepsCard(
              session: session,
              sessionColor: sessionColor,
              blocks: blocks,
            ),
            const SizedBox(height: 16),
          ],

          // Notes section
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            SessionNotesCard(notes: session.notes!),
            const SizedBox(height: 16),
          ],

          // Raw data section (if available)
          if (session.dataPoints != null && session.dataPoints!.isNotEmpty) ...[
            SessionRawDataCard(dataPoints: session.dataPoints!),
          ],
        ],
      ),
    );
  }

  /// A rep names the training item it was played from, so the session reads
  /// block by block. The prescription frozen on the session is the copy that
  /// cannot have drifted since, and the only one readable for a coach's
  /// training, so it is preferred; a guest-mode run has none and resolves its
  /// own local training instead. Neither resolving falls back to the flat list,
  /// as does a run that named no item the training still holds.
  ///
  /// Resolved once here rather than in each card, so the stats and the
  /// breakdown below them never disagree about how many blocks were played.
  List<RepBlock>? _resolveBlocks(WidgetRef ref, SessionModel session) {
    final reps = session.reps;
    if (reps == null) return null;
    final items =
        session.prescriptionItems ??
        ref.watch(sessionTrainingItemsProvider(session.trainingId)).value;
    if (items == null) return null;
    return groupRepsByTrainingItem(
      reps.where((r) => !r.isRest).toList(),
      items,
    );
  }

  Widget _buildNotFoundError(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: CrimpyTheme.gray500),
          SizedBox(height: 16),
          Text(
            'Session not found',
            style: TextStyle(fontSize: 18, color: CrimpyTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: CrimpyTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading session details',
            style: TextStyle(fontSize: 18, color: CrimpyTheme.gray700),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: CrimpyTheme.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, WidgetRef ref) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditSessionScreen(session: session),
          ),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Session'),
            content: Text(
              'Are you sure you want to delete this session?\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ref
                        .read(sessionsProvider.notifier)
                        .deleteSession(session.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting session: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality coming soon!')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export functionality coming soon!')),
        );
        break;
    }
  }
}
