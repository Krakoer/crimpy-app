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
    // Split & sort
    final maxForce =
        assessments.where((a) => a.type == AssessmentType.mvc).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    // Group MVC assessments by grip position
    final Map<GripPosition, List<AssessmentModel>> mvcByGripPosition = {};
    for (var assessment in maxForce) {
      final grip = assessment.gripPosition ?? GripPosition.halfCrimp;
      mvcByGripPosition.putIfAbsent(grip, () => []);
      mvcByGripPosition[grip]!.add(assessment);
    }

    final criticalForce =
        assessments
            .where((a) => a.type == AssessmentType.criticalForce)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final endurance60 =
        assessments.where((a) => a.type == AssessmentType.endurance60).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final authState = ref.watch(authStateProvider);

    return SingleChildScrollView(
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

          const SizedBox(height: 32),

          // Critical Force Section
          StatContent(
            title: "Critical Force",
            maxLeft: criticalForce
                .map((a) => a.leftValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            maxRight: criticalForce
                .map((a) => a.rightValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            accentLeft: accentLeft,
            accentRight: accentRight,
            leftData: criticalForce
                .where((a) => a.leftValue != null)
                .map((a) => (a.date, a.leftValue!))
                .toList(),
            rightData: criticalForce
                .where((a) => a.rightValue != null)
                .map((a) => (a.date, a.rightValue!))
                .toList(),
            onStartAssessment: goToAssessments,
          ),

          SizedBox(height: 32),

          // 60% Endurance Section
          StatContent(
            title: "60% Endurance",
            maxLeft: endurance60
                .map((a) => a.leftValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            maxRight: endurance60
                .map((a) => a.rightValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            accentLeft: accentLeft,
            accentRight: accentRight,
            leftData: endurance60
                .where((a) => a.leftValue != null)
                .map((a) => (a.date, a.leftValue!))
                .toList(),
            rightData: endurance60
                .where((a) => a.rightValue != null)
                .map((a) => (a.date, a.rightValue!))
                .toList(),
            unit: AssessmentUnit.seconds,
            onStartAssessment: goToAssessments,
          ),
        ],
      ),
    );
  }
}
