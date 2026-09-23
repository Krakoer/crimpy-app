import 'package:crimpy/logger.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/profile_content.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/crimpy_theme.dart';

class ClimbingProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback goToAssessments;

  const ClimbingProfileScreen({required this.goToAssessments, super.key});

  @override
  ConsumerState<ClimbingProfileScreen> createState() =>
      _ClimbingProfileScreenState();
}

class _ClimbingProfileScreenState extends ConsumerState<ClimbingProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncAssessments = ref.watch(assessmentsProvider(null));

    final Color accentLeft = CrimpyTheme.accentOrange;
    final Color accentRight = CrimpyTheme.accentYellow;

    return PullToRefresh(
      // The root, not the view of it this screen watches: refreshing the view
      // would rebuild it from the history already in hand and never ask again.
      onRefresh: () => ref.refresh(assessmentHistoryProvider.future),
      // Matched on what the state holds rather than on which state it is, so a
      // pull leaves the profile on screen while it asks again.
      child: switch (asyncAssessments) {
        AsyncValue(:final value?) => ProfileContent(
          assessments: value,
          accentLeft: accentLeft,
          accentRight: accentRight,
          goToAssessments: widget.goToAssessments,
        ),
        AsyncValue(:final error?) => () {
          AppLoggerHelper.error('Failed to load assessments', error);
          return RefreshableColumn(child: Center(child: Text('Error: $error')));
        }(),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
