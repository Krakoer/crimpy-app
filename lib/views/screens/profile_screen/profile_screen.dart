import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/profile_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/crimpy_theme.dart';

class ClimbingProfileScreen extends ConsumerWidget {
  const ClimbingProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAssessments = ref.watch(assessmentsProvider(null));

    final Color accentLeft = CrimpyTheme.accentOrange;
    final Color accentRight = CrimpyTheme.accentYellow;

    return switch (asyncAssessments) {
        AsyncData(:final value) => ProfileContent(
          assessments: value,
          accentLeft: accentLeft,
          accentRight: accentRight,
        ),
      AsyncError(:final error) => Center(child: Text("Error: $error")),
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
    };
  }
}
