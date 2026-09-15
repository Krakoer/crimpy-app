import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/viewmodels/coach_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/week_histogram_card.dart';
import 'package:crimpy/views/screens/home_screen/favorite_training.dart';
import 'package:crimpy/views/screens/home_screen/widgets/log_session_buttons.dart';
import 'package:crimpy/views/screens/home_screen/widgets/next_week_availability_card.dart';
import 'package:crimpy/views/screens/home_screen/widgets/today_training_card.dart';
import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// The dashboard reads nothing itself: each card below asks for what it
  /// shows. A pull here has to refresh all of them, or it would answer for the
  /// card that happens to be on top and leave the rest as they were.
  ///
  /// Awaited together, so the spinner is up until the slowest card has its
  /// answer rather than until the first one does.
  Future<void> _refresh() => Future.wait([
    ref.refresh(activeProgramProvider.future),
    ref.refresh(activeProgramWeekProvider.future),
    ref.refresh(assessmentResultsProvider.future),
    ref.refresh(sessionsProvider.future),
    ref.refresh(allTrainingsProvider.future),
    ref.refresh(pinnedTrainingsProvider.future),
    ref.refresh(coachEnrollmentProvider.future),
    ref.refresh(myAvailabilityProvider.future),
  ]);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // The histogram reads a session list per week, so the family is invalidated
    // whole: refreshing one week would leave every other one stale, and the
    // card scrolls through them.
    return PullToRefresh(
      onRefresh: () async {
        ref.invalidate(filteredSessionsProvider);
        await _refresh();
      },
      child: RefreshableColumn(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Today's scheduled training from the active program.
            TodayTrainingCard(),
            // Ask for next week before the coach has to guess it.
            NextWeekAvailabilityCard(),
            // Weekly session histogram.
            WeekHistogramCard(maxBarHeight: 75),
            // Log session buttons.
            LogSessionButtons(),
            // Favorite training list.
            FavoriteTrainingList(),
          ],
        ),
      ),
    );
  }
}
