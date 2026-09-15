import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/edit_session_screen.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_overview_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_performance_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_reps_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_reported_items_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_feedback_card.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_raw_data_card.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Opening the session is what reads the coach's answer, so the receipt is
    // sent from here rather than from the card: the card is rebuilt whenever
    // anything on the screen changes.
    final id = widget.session.id;
    if (id != null && widget.session.hasUnreadCoachReply) {
      ref.read(sessionsProvider.notifier).markCoachReplyRead(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
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
        // A coach answers the notes on a session after the athlete has opened
        // it, so the reply arrives on a screen that has already resolved. The
        // session read from the list carries no reps, and only that one has
        // something to ask again for.
        child: asyncFullSession != null
            ? PullToRefresh(
                onRefresh: () =>
                    ref.refresh(sessionWithDataProvider(session.id!).future),
                // Matched on holding a value rather than on the value being
                // non-null, since this provider resolves to null for a session
                // the store no longer has: `value?` would read that as nothing
                // resolved yet and show a spinner over a session that is gone.
                child: switch (asyncFullSession) {
                  AsyncValue(:final value, hasValue: true) =>
                    value != null
                        ? _buildSessionDetails(context, ref, value)
                        : RefreshableColumn(
                            child: _buildNotFoundError(context),
                          ),
                  AsyncValue(:final error?) => RefreshableColumn(
                    child: _buildErrorState(context, error.toString()),
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              )
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
    final reported = _resolveReportedItems(ref, session);
    final resolvedBlocks = _resolveBlocks(ref, session);
    final blocks = resolvedBlocks.value;
    // A session whose blocks are still resolving has no answer to give yet, and
    // the pooled numbers are the wrong ones to show while it waits for one.
    final poolsBlocks = resolvedBlocks.isLoading || spansMultipleBlocks(blocks);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session overview card
          SessionOverviewCard(session: session),
          const SizedBox(height: 16),

          // Performance stats (if available)
          if (session.hasReps) ...[
            SessionPerformanceCard(
              reps: session.reps!,
              poolsBlocks: poolsBlocks,
            ),
            const SizedBox(height: 16),
          ],

          // Repetitions breakdown (if available)
          if (session.hasReps) ...[
            SessionRepsCard(
              session: session,
              sessionColor: sessionColor,
              blocks: blocks,
              poolsBlocks: poolsBlocks,
            ),
            const SizedBox(height: 16),
          ],

          // What the athlete reported on the prescribed items. No rep carries
          // any of it, so this is the only place it shows up.
          if (reported.isNotEmpty) ...[
            SessionReportedItemsCard(items: reported),
            const SizedBox(height: 16),
          ],

          // What the athlete wrote about the session and what their coach
          // answered, read as one exchange.
          if (SessionFeedbackCard.hasContent(
            notes: session.notes,
            coachReply: session.coachReply,
          )) ...[
            SessionFeedbackCard(
              notes: session.notes,
              coachReply: session.coachReply,
              coachReplyAt: session.coachReplyAt,
              // The receipt was sent when the screen opened, so the badge is
              // read off the session as it arrived rather than as it stands.
              unread: widget.session.hasUnreadCoachReply,
            ),
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

  /// What the athlete reported, read against the items it answers. Those items
  /// come from the frozen prescription when the session carries one, and from
  /// the athlete's own training otherwise, which is the same fallback
  /// [_resolveBlocks] makes and the only one a guest-mode session has.
  List<ReportedItem> _resolveReportedItems(
    WidgetRef ref,
    SessionModel session,
  ) {
    if (session.itemResults.isEmpty) return const [];
    final frozen = session.prescriptionItems;
    if (frozen != null) return reportedItems(session.itemResults, frozen);
    return ref
            .watch(sessionTrainingItemsProvider(session.trainingId))
            // The live training, as below. Read only by a session carrying no frozen
            // prescription, which is a guest run or one played before the snapshot.
            // ignore: keep_the_held_value
            .whenData((items) => reportedItems(session.itemResults, items))
            .value ??
        const [];
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
  ///
  /// Kept as an [AsyncValue] rather than flattened to null, so a training that
  /// has not loaded yet is told apart from one that resolved to no blocks. Both
  /// fall back to the flat list, but only the second may state a session-wide
  /// number: the first does not know yet whether that number would pool.
  AsyncValue<List<RepBlock>?> _resolveBlocks(
    WidgetRef ref,
    SessionModel session,
  ) {
    final reps = session.reps;
    if (reps == null) return const AsyncValue.data(null);
    final workReps = reps.where((r) => !r.isRest).toList();
    final frozen = session.prescriptionItems;
    if (frozen != null) {
      return AsyncValue.data(groupRepsByTrainingItem(workReps, frozen));
    }
    return ref
        .watch(sessionTrainingItemsProvider(session.trainingId))
        // The live training, read once per session opened. No pull invalidates it,
        // and the caller tells a training still loading from one that resolved to no
        // blocks, which is the distinction whenData is being used for here.
        // ignore: keep_the_held_value
        .whenData((items) => groupRepsByTrainingItem(workReps, items));
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
            builder: (context) => EditSessionScreen(session: widget.session),
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
                        .deleteSession(widget.session.id!);
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
