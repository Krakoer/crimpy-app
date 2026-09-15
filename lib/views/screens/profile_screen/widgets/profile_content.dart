import 'package:crimpy/models/assessment_history.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/views/screens/auth/login_screen.dart';
import 'package:crimpy/views/screens/auth/registration_screen.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/bodyweight_card.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/stat_content.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/mvc_grip_position_stat_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileContent extends ConsumerWidget {
  final List<AssessmentModel> assessments;
  final Color accentLeft;
  final Color accentRight;
  final VoidCallback goToAssessments;

  const ProfileContent({
    super.key,
    required this.assessments,
    required this.accentLeft,
    required this.accentRight,
    required this.goToAssessments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The assessments Crimpy ships keep their section whether or not the athlete
    // has done them, since that section is what invites them to.
    final history = groupAssessmentHistory(
      assessments,
      alwaysShown: [
        for (final type in AssessmentType.values)
          BuiltinAssessmentIds.definitionOf(type),
      ],
    );

    // Max Force keeps a section of its own: it is the one assessment read one
    // grip at a time, which no generic section can show.
    final maxForce =
        history[BuiltinAssessmentIds.maxForce]?.records ?? const [];
    final Map<GripPosition, List<AssessmentModel>> mvcByGripPosition = {};
    for (var assessment in maxForce) {
      final grip = assessment.gripPosition ?? GripPosition.halfCrimp;
      mvcByGripPosition.putIfAbsent(grip, () => []);
      mvcByGripPosition[grip]!.add(assessment);
    }

    // Everything else gets the same section, whether Crimpy ships it or a coach
    // wrote it, so a new assessment appears the moment it is first measured.
    final otherAssessments = history.values
        .where((h) => h.definition.id != BuiltinAssessmentIds.maxForce)
        .toList();

    final authState = ref.watch(authStateProvider);

    return SingleChildScrollView(
      // Scrollable although the sections may fit: this is what the profile is
      // pulled by, and a view that cannot move accepts no drag to pull it with.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          authState.when(
            data: (user) {
              if (user == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Cloud Sync',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Sign in to sync your data across devices'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Login'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Register'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            user.firstname[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user.firstname} ${user.lastname}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (!user.emailVerified)
                                Text(
                                  'Email not verified',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.orange),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () async {
                            await ref.read(authStateProvider.notifier).logout();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $error'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // The bodyweight is dropped on sign out, so offering to set it while
          // signed out would hand back a value that the next launch deletes.
          if (!isSignedOut(authState)) ...[
            const BodyweightCard(),
            const SizedBox(height: 16),
          ],

          // Max Force Section with Grip Position Selection
          MvcGripPositionStatContent(
            mvcByGripPosition: mvcByGripPosition,
            accentLeft: accentLeft,
            accentRight: accentRight,
            onStartAssessment: goToAssessments,
          ),

          for (final assessed in otherAssessments) ...[
            const SizedBox(height: 32),
            StatContent(
              title: assessed.definition.label,
              maxLeft: assessed.best((a) => a.leftValue),
              // A single value assessment stores its number on the right, so
              // the one card and the one series read it from there.
              maxRight: assessed.best((a) => a.rightValue),
              accentLeft: accentLeft,
              accentRight: accentRight,
              leftData: assessed.series((a) => a.leftValue),
              rightData: assessed.series((a) => a.rightValue),
              unit: assessed.definition.unit,
              perHand: assessed.definition.perHand,
              onStartAssessment: goToAssessments,
            ),
          ],
        ],
      ),
    );
  }
}
