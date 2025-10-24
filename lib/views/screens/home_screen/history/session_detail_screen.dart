import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class SessionDetailScreen extends ConsumerWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get full session data if we only have basic info
    final asyncFullSession =
        session.reps == null
            ? ref.watch(sessionWithDataProvider(session.id!))
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder:
                (context) => [
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
      body:
          asyncFullSession != null
              ? switch (asyncFullSession) {
                AsyncData(:final value) =>
                  value != null
                      ? _buildSessionDetails(context, value)
                      : _buildNotFoundError(context),
                AsyncError(:final error) => _buildErrorState(
                  context,
                  error.toString(),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              }
              : _buildSessionDetails(context, session),
    );
  }

  Widget _buildSessionDetails(BuildContext context, SessionModel session) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session overview card
          _buildOverviewCard(context, session),
          const SizedBox(height: 16),

          // Performance stats (if available)
          if (session.reps != null && session.reps!.isNotEmpty) ...[
            _buildPerformanceCard(context, session),
            const SizedBox(height: 16),
          ],

          // Repetitions breakdown (if available)
          if (session.reps != null && session.reps!.isNotEmpty) ...[
            _buildRepsCard(context, session),
            const SizedBox(height: 16),
          ],

          // Notes section
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            _buildNotesCard(context, session),
            const SizedBox(height: 16),
          ],

          // Raw data section (if available)
          if (session.dataPoints != null && session.dataPoints!.isNotEmpty) ...[
            _buildRawDataCard(context, session),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, SessionModel session) {
    final duration = Duration(seconds: session.duration);

    return session.isAssessment
        ? CrimpyCards.assessment(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CrimpyTheme.assessmentColor.withValues(alpha: 0.2),
                        border: Border.all(color: CrimpyTheme.assessmentColor.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Icon(
                        Icons.assessment,
                        color: CrimpyTheme.assessmentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assessment',
                            style: TextStyle(
                              color: CrimpyTheme.gray600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            session.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Date',
                        DateFormat('MMM d, yyyy').format(session.date),
                        Icons.calendar_today,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Time',
                        DateFormat('HH:mm').format(session.date),
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Duration',
                        _formatDuration(duration),
                        Icons.timer,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Reps',
                        session.reps?.length.toString() ?? 'N/A',
                        Icons.repeat,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : CrimpyCards.training(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CrimpyTheme.trainingColor.withValues(alpha: 0.2),
                        border: Border.all(color: CrimpyTheme.trainingColor.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: CrimpyTheme.trainingColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Training',
                            style: TextStyle(
                              color: CrimpyTheme.gray600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            session.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Date',
                        DateFormat('MMM d, yyyy').format(session.date),
                        Icons.calendar_today,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Time',
                        DateFormat('HH:mm').format(session.date),
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Duration',
                        _formatDuration(duration),
                        Icons.timer,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Reps',
                        session.reps?.length.toString() ?? 'N/A',
                        Icons.repeat,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: CrimpyTheme.gray600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: CrimpyTheme.gray600, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(BuildContext context, SessionModel session) {
    final reps = session.reps!;
    final workReps = reps.where((r) => !r.isRest).toList();

    if (workReps.isEmpty) {
      return const SizedBox.shrink();
    }

    final avgWeight =
        workReps.fold<double>(0, (sum, r) => sum + r.averageWeight) /
        workReps.length;
    final maxWeight = workReps.fold<double>(
      0,
      (max, r) => r.averageWeight > max ? r.averageWeight : max,
    );
    final totalWorkTime = workReps.fold(0, (sum, r) => sum + r.duration);

    return CrimpyCards.stats(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Stats',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Avg Weight',
                  '${avgWeight.toStringAsFixed(1)} kg',
                ),
              ),
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Max Weight',
                  '${maxWeight.toStringAsFixed(1)} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Work Time',
                  '${totalWorkTime}s',
                ),
              ),
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Work Reps',
                  '${workReps.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: CrimpyTheme.gray600, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRepsCard(BuildContext context, SessionModel session) {
    final reps = session.reps!;

    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repetitions Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: reps.length,
              itemBuilder: (context, index) {
                final rep = reps[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        rep.isRest ? CrimpyTheme.gray300 : CrimpyTheme.trainingColor.withValues(alpha: 0.6),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    rep.isRest
                        ? 'Rest'
                        : rep.rightHand
                        ? 'Right Hand'
                        : 'Left Hand',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    '${rep.duration}s${rep.isRest ? '' : ' • ${rep.averageWeight.toStringAsFixed(1)} kg avg'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing:
                      rep.isRest
                          ? Icon(
                            Icons.pause,
                            size: 16,
                            color: CrimpyTheme.gray600,
                          )
                          : Icon(
                            Icons.fitness_center,
                            size: 16,
                            color: CrimpyTheme.trainingColor,
                          ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, SessionModel session) {
    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(session.notes!, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRawDataCard(BuildContext context, SessionModel session) {
    final dataPoints = session.dataPoints!;

    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Raw Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${dataPoints.length} data points',
                style: TextStyle(color: CrimpyTheme.gray600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Data collection period: ${DateFormat('HH:mm:ss').format(dataPoints.first.timestamp)} - ${DateFormat('HH:mm:ss').format(dataPoints.last.timestamp)}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Sample rate: ${(dataPoints.length / (dataPoints.last.timestamp.difference(dataPoints.first.timestamp).inSeconds)).toStringAsFixed(1)} Hz',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
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
          const Icon(Icons.error_outline, size: 64, color: CrimpyTheme.errorColor),
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

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
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

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
