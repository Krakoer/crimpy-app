import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/session_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'widgets/calendar_card.dart';
import 'widgets/date_group.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/utils/datetimes.dart';

class SessionHistoryScreen extends ConsumerStatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  ConsumerState<SessionHistoryScreen> createState() =>
      _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final CalendarController _calendarController = CalendarController();
  SessionFilter? _currentFilter;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSessions = ref.watch(filteredSessionsProvider(_currentFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History', style: TextStyle(fontSize: 32)),
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: 'Clear date filter',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => _applyFilter(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Sessions')),
              const PopupMenuItem(
                value: 'assessments',
                child: Text('Assessments Only'),
              ),
              const PopupMenuItem(
                value: 'trainings',
                child: Text('Trainings Only'),
              ),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: PullToRefresh(
          onRefresh: () =>
              ref.refresh(filteredSessionsProvider(_currentFilter).future),
          // Matched on what the state holds rather than on which state it is,
          // so a pull keeps the history on screen instead of replacing it with
          // the spinner the indicator is already showing.
          child: switch (asyncSessions) {
            AsyncValue(:final value?) => _buildSessionList(value),
            AsyncValue(:final error?) => RefreshableColumn(
              child: ErrorState(
                error: error.toString(),
                onRetry: () => setState(() {}),
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Widget _buildSessionList(List<SessionModel> sessions) {
    // Filter sessions by selected date if one is selected
    final filteredSessions = _selectedDate != null
        ? sessions.where((session) {
            return DateUtils.isSameDay(session.date, _selectedDate);
          }).toList()
        : sessions;

    if (filteredSessions.isEmpty) {
      // Scrollable although it fits: an empty history is the state a pull is
      // most worth making, and a column that cannot move cannot be pulled.
      return RefreshableColumn(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CalendarCard(
              sessions: sessions,
              calendarController: _calendarController,
              selectedDate: _selectedDate,
              onClearFilter: _clearDateFilter,
              onDateTap: (date) => setState(() => _selectedDate = date),
            ),
            EmptyState(selectedDate: _selectedDate),
          ],
        ),
      );
    }

    // Group sessions by date
    final Map<String, List<SessionModel>> groupedSessions = {};
    for (final session in filteredSessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.date);
      if (!groupedSessions.containsKey(dateKey)) {
        groupedSessions[dateKey] = [];
      }
      groupedSessions[dateKey]!.add(session);
    }

    // Sort dates in descending order
    final sortedDates = groupedSessions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return CalendarCard(
            sessions: sessions,
            calendarController: _calendarController,
            selectedDate: _selectedDate,
            onClearFilter: _clearDateFilter,
            onDateTap: (date) => setState(() => _selectedDate = date),
          );
        }

        final dateKey = sortedDates[index - 1];
        final dateSessions = groupedSessions[dateKey]!;
        final date = DateTime.parse(dateKey);

        return DateGroup(
          date: date,
          sessions: dateSessions,
          onSessionTap: _onSessionTap,
        );
      },
    );
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
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
          final startOfWeek = getStartOfWeek(DateTime.now());
          _currentFilter = SessionFilter(
            startDate: startOfWeek,
            endDate: addCalendarDays(startOfWeek, 7),
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
}
