import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/profile_content.dart';
import 'package:flutter/material.dart';
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

    return switch (asyncAssessments) {
      AsyncData(:final value) => ProfileContent(
        assessments: value,
        accentLeft: accentLeft,
        accentRight: accentRight,
        goToAssessments: widget.goToAssessments,
      ),
      AsyncError(:final error) => Center(child: Text("Error: $error")),
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
    };
  }
}
