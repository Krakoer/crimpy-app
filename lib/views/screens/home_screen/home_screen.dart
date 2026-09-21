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
  /// Awaited through the derived providers the cards actually read, so the
  /// spinner is up until the slowest card has its answer rather than until the
  /// first one does.
  Future<void> _refresh() {
    ref.invalidate(programsProvider);
    ref.invalidate(weekDetailProvider);
    // The body of each prescribed training, which the week names but does not
    // carry. Kept alive by this dashboard watching it, so nothing else ever
    // disposes it and a coach's edit to today's session would never arrive.
    //
    // The only one not awaited below: which trainings are prescribed is what
    // the refreshed week answers, so there is no key to read here yet. The row
    // reads what it holds, so it keeps the old estimate for a round trip
    // rather than blanking.
    ref.invalidate(sessionsProvider);
    ref.invalidate(filteredSessionsProvider);
    // The one instance this dashboard reads, through assessmentResults. The
    // family holds an entry per assessment the other tabs show, and those tabs
    // are kept alive behind this one: invalidating it whole refetches lists
    // nothing here displays.
    ref.invalidate(assessmentsProvider(null));
    ref.invalidate(assessmentDefinitionsProvider);
    // The two reads both training cards are built from. They hold different
    // content, all builtins against pinned builtins, but they filter the same
    // library and the same builtin catalog: invalidating the cards one by one
    // would ask for both reads once each, and invalidating only one card would
    // leave the other showing what it had.
    ref.invalidate(trainingLibraryProvider);
    ref.invalidate(builtinTrainingCatalogProvider);
    ref.invalidate(coachEnrollmentProvider);
    ref.invalidate(myAvailabilityProvider);
    ref.invalidate(declaredWeekStartsProvider);

    return Future.wait([
      ref.read(activeProgramProvider.future),
      ref.read(activeProgramWeekProvider.future),
      ref.read(assessmentResultsProvider.future),
      ref.read(sessionsProvider.future),
      ref.read(allTrainingsProvider.future),
      ref.read(pinnedTrainingsProvider.future),
      ref.read(coachEnrollmentProvider.future),
      ref.read(myAvailabilityProvider.future),
      ref.read(declaredWeekStartsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PullToRefresh(
      onRefresh: _refresh,
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
