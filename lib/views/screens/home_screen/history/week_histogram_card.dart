import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/views/screens/home_screen/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/week_histogram_widget.dart';
import 'package:crimpy/views/screens/home_screen/history/session_history_screen/session_history_screen.dart';

class WeekHistogramCard extends ConsumerStatefulWidget {
  final double maxBarHeight;

  /// Draw a card with the week `WeekHistogramWidget` inside.
  const WeekHistogramCard({super.key, this.maxBarHeight = 200});

  @override
  ConsumerState<WeekHistogramCard> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<WeekHistogramCard> {
  int _weekOffset = 0; // 0 = current week, -1 = previous week, +1 = next week

  @override
  Widget build(BuildContext context) {
    final startOfTheWeek = getStartOfWeek(
      DateTime.now(),
    ).add(Duration(days: 7 * _weekOffset));
    // Get the sessions of the week
    final asyncSessions = ref.watch(
      filteredSessionsProvider(
        SessionFilter(
          startDate: startOfTheWeek,
          endDate: startOfTheWeek.add(Duration(days: 7)),
        ),
      ),
    );

    final endOfWeek = startOfTheWeek.add(Duration(days: 6));
    final String weekTitle = _weekOffset == 0
        ? "This Week"
        : "${startOfTheWeek.day}/${startOfTheWeek.month} - ${endOfWeek.day}/${endOfWeek.month}";

    return HomeCard(
      title: weekTitle,
      onTap: () => _navigateToSessionHistory(context),
      topLeft: Row(
        children: [
          // Navigation buttons
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () {
              setState(() {
                _weekOffset--;
              });
            },
            tooltip: 'Previous week',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: _weekOffset < 0
                ? () {
                    setState(() {
                      _weekOffset++;
                    });
                  }
                : null, // Disable if we're at current week or future
            tooltip: 'Next week',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      child: SizedBox(
        height: widget.maxBarHeight + 66, // Fixed height to prevent flickering
        child: switch (asyncSessions) {
          AsyncData(:final value) => WeekHistogramWidget(
            sessions: value,
            maxBarHeight: widget.maxBarHeight,
            startOfWeek: startOfTheWeek,
          ),
          AsyncError(:final error) => Center(child: Text('Error: $error')),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  void _navigateToSessionHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SessionHistoryScreen()),
    );
  }
}
