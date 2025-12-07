import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/views/screens/home_screen/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/week_histogram_widget.dart';
import 'package:crimpy/views/screens/home_screen/history/session_history_screen.dart';

class WeekHistogramCard extends ConsumerStatefulWidget {
  final double maxBarHeight;

  /// Draw a card with the week `WeekHistogramWidget` inside.
  const WeekHistogramCard({super.key, this.maxBarHeight = 200});

  @override
  ConsumerState<WeekHistogramCard> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<WeekHistogramCard> {
  @override
  Widget build(BuildContext context) {
    final startOfTheWeek = getStartOfWeek(DateTime.now());
    // Get the sessions of the week
    final asyncSessions = ref.watch(
      sessionsProvider(
        SessionFilter(
          startDate: startOfTheWeek,
          endDate: startOfTheWeek.add(Duration(days: 7)),
        ),
      ),
    );
    return HomeCard(
      title: "This Week",
      onTap: () => _navigateToSessionHistory(context),
      topLeft: Row(
        children: [
          Text('View All', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
      child: switch (asyncSessions) {
        AsyncData(:final value) => WeekHistogramWidget(
          sessions: value,
          maxBarHeight: widget.maxBarHeight,
        ),
        AsyncError(:final error) => Text('Error: $error'),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  void _navigateToSessionHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SessionHistoryScreen()),
    );
  }
}
