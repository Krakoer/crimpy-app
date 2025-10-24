import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/session_detail_screen.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class SessionHistoryScreen extends ConsumerStatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  ConsumerState<SessionHistoryScreen> createState() =>
      _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  SessionFilter? _currentFilter;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSessions = ref.watch(sessionsProvider(_currentFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => _applyFilter(value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('All Sessions'),
                  ),
                  const PopupMenuItem(
                    value: 'assessments',
                    child: Text('Assessments Only'),
                  ),
                  const PopupMenuItem(
                    value: 'trainings',
                    child: Text('Trainings Only'),
                  ),
                  const PopupMenuItem(value: 'week', child: Text('This Week')),
                  const PopupMenuItem(
                    value: 'month',
                    child: Text('This Month'),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: switch (asyncSessions) {
          AsyncData(:final value) => _buildSessionList(value),
          AsyncError(:final error) => _buildErrorState(error.toString()),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _buildSessionList(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: CrimpyTheme.gray500),
            SizedBox(height: 16),
            Text(
              'No sessions found',
              style: TextStyle(fontSize: 18, color: CrimpyTheme.gray500),
            ),
          ],
        ),
      );
    }

    // Group sessions by date
    final Map<String, List<SessionModel>> groupedSessions = {};
    for (final session in sessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.date);
      if (!groupedSessions.containsKey(dateKey)) {
        groupedSessions[dateKey] = [];
      }
      groupedSessions[dateKey]!.add(session);
    }

    // Sort dates in descending order
    final sortedDates =
        groupedSessions.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateSessions = groupedSessions[dateKey]!;
        final date = DateTime.parse(dateKey);

        return _buildDateGroup(date, dateSessions);
      },
    );
  }

  Widget _buildDateGroup(DateTime date, List<SessionModel> sessions) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isYesterday = DateUtils.isSameDay(
      date,
      DateTime.now().subtract(const Duration(days: 1)),
    );

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('EEEE, MMMM d, y').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: CrimpyTheme.gray700,
            ),
          ),
        ),
        ...sessions.map((session) => _buildSessionCard(session)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    final duration = Duration(seconds: session.duration);
    final formattedTime = DateFormat('HH:mm').format(session.date);

    return session.isAssessment
        ? CrimpyCards.assessment(
          margin: const EdgeInsets.only(bottom: 8),
          onTap: () => _onSessionTap(session),
          child: Row(
            children: [
              // Session type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CrimpyTheme.assessmentColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: CrimpyTheme.assessmentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.assessment,
                  color: CrimpyTheme.assessmentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Session details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: CrimpyTheme.gray600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: CrimpyTheme.gray600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.timer, size: 14, color: CrimpyTheme.gray600),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: CrimpyTheme.gray600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (session.notes != null && session.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.notes!,
                        style: TextStyle(
                          color: CrimpyTheme.gray700,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow indicator
              Icon(Icons.chevron_right, color: CrimpyTheme.gray400),
            ],
          ),
        )
        : CrimpyCards.training(
          margin: const EdgeInsets.only(bottom: 8),
          onTap: () => _onSessionTap(session),
          child: Row(
            children: [
              // Session type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CrimpyTheme.trainingColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: CrimpyTheme.trainingColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: CrimpyTheme.trainingColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Session details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: CrimpyTheme.gray600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: CrimpyTheme.gray600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.timer, size: 14, color: CrimpyTheme.gray600),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: CrimpyTheme.gray600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (session.notes != null && session.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.notes!,
                        style: TextStyle(
                          color: CrimpyTheme.gray700,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow indicator
              Icon(Icons.chevron_right, color: CrimpyTheme.gray400),
            ],
          ),
        );
  }

  Widget _buildErrorState(String error) {
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
            'Error loading sessions',
            style: TextStyle(fontSize: 18, color: CrimpyTheme.gray700),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: CrimpyTheme.gray600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _applyFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'all':
          _currentFilter = null;
          break;
        case 'assessments':
          _currentFilter = const SessionFilter(isAssessment: true);
          break;
        case 'trainings':
          _currentFilter = const SessionFilter(isAssessment: false);
          break;
        case 'week':
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          _currentFilter = SessionFilter(
            startDate: DateTime(
              startOfWeek.year,
              startOfWeek.month,
              startOfWeek.day,
            ),
            endDate: DateTime(
              startOfWeek.year,
              startOfWeek.month,
              startOfWeek.day + 7,
            ),
          );
          break;
        case 'month':
          final now = DateTime.now();
          _currentFilter = SessionFilter(
            startDate: DateTime(now.year, now.month, 1),
            endDate: DateTime(now.year, now.month + 1, 1),
          );
          break;
      }
    });
  }

  void _onSessionTap(SessionModel session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(session: session),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
