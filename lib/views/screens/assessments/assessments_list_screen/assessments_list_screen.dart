import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/widgets/truncated_library_notice.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/assessment_card.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/select_hand_dialog.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/select_grip_position_dialog.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/confirm_redo_assessment_dialog.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/screens/assessments/endurance_60/endurance_60_run_screen.dart';
import 'package:crimpy/views/widgets/ble/connection_dialog.dart';
import 'package:crimpy/views/widgets/ble/tare_dialog.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/assessment_history.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/widgets/start_training_run.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/mvc_run_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Screen to show and run the available assessments.
class AssessmentsScreen extends ConsumerStatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  ConsumerState<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends ConsumerState<AssessmentsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final assessmentTemplates = ref.watch(assessmentTrainingsProvider);

    /// Run the assessment given its type and hand.
    void runAssessment(
      AssessmentTrainingModel model,
      HandSide? handSide, {
      double? mvcValue,
      GripPosition? gripPosition,
    }) {
      ref.read(bleSessionProvider.notifier).reset();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => switch (model.type) {
            AssessmentType.mvc => MvcRunScreen(
              reps: model.training.reps,
              type: model.type,
            ),
            AssessmentType.criticalForce => CriticalForceRunScreen(
              reps: model.training.reps,
              hand: handSide!,
            ),
            AssessmentType.endurance60 => Endurance60RunScreen(
              hand: handSide!,
              mvcValue: mvcValue!,
              gripPosition: gripPosition ?? model.getGripPosition()!,
            ),
          },
        ),
      );
    }

    /// Check if an assessment of the same type (and hand if provided) hs been done on the same day.
    /// If so, ask the user before running it.
    void checkAndRunAssessment(
      AssessmentTrainingModel model, {
      HandSide? handSide,
      double? mvcValue,
      GripPosition? gripPosition,
    }) async {
      // First check if the assessment has been done today.
      // If so, show the dialog
      if (await ref
              .read(
                assessmentsProvider(
                  BuiltinAssessmentIds.idOf(model.type),
                ).notifier,
              )
              .getSameDayAssessment(
                handSide: handSide,
                gripPosition: gripPosition,
              ) !=
          null) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => ConfirmRedoAssessmentDialog(
              runAssessment: () => runAssessment(
                model,
                handSide,
                mvcValue: mvcValue,
                gripPosition: gripPosition,
              ),
            ),
          );
        }
      } else {
        runAssessment(
          model,
          handSide,
          mvcValue: mvcValue,
          gripPosition: gripPosition,
        );
      }
    }

    final isConnected =
        ref.watch(connectionStateProvider) == BleConnectionState.connected;

    // Everything the athlete may record against beyond the three protocols the
    // app implements: their own assessments, and a coach's whose training a
    // program prescribed to them. Read off what the state holds, so a failed
    // refresh keeps the cards rather than emptying the tab.
    final recordableTrainings =
        ref.watch(recordableAssessmentTrainingsProvider).value ??
        const <Training>[];

    // One history for every card, grouped the way the profile groups it. The
    // definitions of the cards on screen are passed as always shown, so an
    // assessment that has never been measured still resolves its unit from the
    // definition rather than from the kilograms fallback a result carries.
    final history = groupAssessmentHistory(
      ref.watch(assessmentsProvider(null)).value ?? const [],
      alwaysShown: [
        for (final template in assessmentTemplates)
          BuiltinAssessmentIds.definitionOf(template.type),
        for (final training in recordableTrainings) training.assessment!,
      ],
    );

    String? lastResultFor(String assessmentId) {
      final assessed = history[assessmentId];
      final last = assessed?.records.lastOrNull;
      if (assessed == null || last == null) return null;
      final diff = DateTime.now().difference(last.date);
      final timeAgo = diff.inDays == 0
          ? 'today'
          : diff.inDays == 1
          ? '1d ago'
          : '${diff.inDays}d ago';
      final unit = assessed.definition.unit;
      // An assessment that is not measured per hand stores its single number on
      // the right, so it reads back without a hand in front of it: "R: 12 reps"
      // would claim a right hand for a test that has no sides.
      final parts = assessed.definition.perHand
          ? <String>[
              if (last.rightValue != null)
                'R: ${formatAssessmentValue(last.rightValue!, unit)}',
              if (last.leftValue != null)
                'L: ${formatAssessmentValue(last.leftValue!, unit)}',
            ]
          : <String>[
              if (last.rightValue != null)
                formatAssessmentValue(last.rightValue!, unit),
            ];
      return parts.isEmpty ? timeAgo : '${parts.join('  ')}  $timeAgo';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isConnected)
          GestureDetector(
            onTap: () =>
                showDialog(
                  context: context,
                  builder: (ctx) => const ConnectionDialog(),
                ).then((isConnected) {
                  if (isConnected == true && context.mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => const TareDialog(),
                      barrierDismissible: false,
                    );
                  }
                }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgWarning,
                border: Border(
                  bottom: BorderSide(
                    color: CrimpyTheme.statusWarning,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 12,
                    color: CrimpyTheme.textOn(CrimpyTheme.statusWarning),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No sensor connected - tap to connect',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CrimpyTheme.textOn(CrimpyTheme.statusWarning),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          // The results shown against each assessment are the athlete's own
          // history, which their coach can add to from the portal.
          child: PullToRefresh(
            // Awaited for everything the screen renders: the history behind
            // every card, and the list of what the athlete may record against,
            // so an assessment their coach scheduled since the last pull shows
            // up rather than resolving after the spinner has gone.
            onRefresh: () async {
              ref.invalidate(assessmentHistoryProvider);
              ref.invalidate(trainingLibraryProvider);
              ref.invalidate(prescribedAssessmentTrainingsProvider);
              await Future.wait([
                ref.read(assessmentsProvider(null).future),
                ref.read(recordableAssessmentTrainingsProvider.future),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // The athlete's own recordable assessments come off the same
                // capped library read as the trainings list, so one that sorts
                // past the ceiling loses its card here and with it the only way
                // to measure it.
                const TruncatedLibraryNotice(),
                ...assessmentTemplates.map(
                  (template) => AssessmentCard(
                    title: template.training.name,
                    icon: template.icon,
                    description: template.description,
                    lastResult: lastResultFor(
                      BuiltinAssessmentIds.idOf(template.type),
                    ),
                    onTap: !isConnected
                        ? null
                        : () async {
                            // Ask the hand to test for the assessment types that need it.
                            // Otherwise, just run the assessment.
                            switch (template.type) {
                              case AssessmentType.mvc:
                                // First get the grip position
                                final GripPosition? gripPosition =
                                    await showDialog(
                                      context: context,
                                      builder: (ctx) =>
                                          SelectGripPositionDialog(),
                                    );
                                if (gripPosition != null && context.mounted) {
                                  // Show tutorial before running assessment
                                  final shouldProceed =
                                      await showTutorialIfNeeded(
                                        context: context,
                                        content:
                                            AssessmentTutorials.getMvcTutorial(
                                              gripPosition,
                                            ),
                                        tutorialId:
                                            AssessmentTutorials.getMvcTutorialId(
                                              gripPosition,
                                            ),
                                      );

                                  if (shouldProceed && context.mounted) {
                                    // Generate the assessment with the selected grip position
                                    final builtinModel = builtinAssessments
                                        .firstWhere(
                                          (a) => a.type == AssessmentType.mvc,
                                        );
                                    final assessmentWithGrip = builtinModel
                                        .generateAssessment(
                                          gripPosition: gripPosition,
                                        );
                                    checkAndRunAssessment(
                                      assessmentWithGrip,
                                      gripPosition: gripPosition,
                                    );
                                  }
                                }
                                break;
                              case AssessmentType.criticalForce:
                                // First get the hand to test
                                final HandSide? hand = await showDialog(
                                  context: context,
                                  builder: (ctx) => SelectHandDialog(),
                                );
                                if (hand != null && context.mounted) {
                                  // Get the grip position from the assessment
                                  final gripPosition = template
                                      .getGripPosition();
                                  if (gripPosition == null) break;

                                  // Show tutorial before running assessment
                                  final shouldProceed = await showTutorialIfNeeded(
                                    context: context,
                                    content:
                                        AssessmentTutorials.getCriticalForceTutorial(
                                          hand,
                                          gripPosition,
                                        ),
                                    tutorialId:
                                        AssessmentTutorials.getCriticalForceTutorialId(
                                          gripPosition,
                                        ),
                                  );

                                  if (shouldProceed && context.mounted) {
                                    checkAndRunAssessment(
                                      template,
                                      handSide: hand,
                                    );
                                  }
                                }
                                break;
                              case AssessmentType.endurance60:
                                // Force half crimp grip position for 60% assessment
                                const gripPosition = GripPosition.halfCrimp;

                                // Get the hand to test
                                final HandSide? hand = await showDialog(
                                  context: context,
                                  builder: (ctx) => SelectHandDialog(),
                                );
                                if (hand == null) break;

                                // Check if MVC has been done for this hand and grip position
                                final mvcValue = await ref
                                    .read(
                                      assessmentsProvider(
                                        BuiltinAssessmentIds.maxForce,
                                      ).notifier,
                                    )
                                    .getLastValueForHand(
                                      hand,
                                      gripPosition: gripPosition,
                                    );

                                if (mvcValue == null || mvcValue <= 0) {
                                  // Show error dialog - no MVC available
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text("MVC Required"),
                                        content: Text(
                                          "You must complete an MVC assessment for your ${hand.isRightHand ? 'right' : 'left'} hand with ${gripPosition.displayName} grip before running this assessment.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else if (context.mounted) {
                                  // Generate the assessment with the half crimp grip position
                                  final builtinModel = builtinAssessments
                                      .firstWhere(
                                        (a) =>
                                            a.type ==
                                            AssessmentType.endurance60,
                                      );
                                  final assessmentWithGrip = builtinModel
                                      .generateAssessment(
                                        gripPosition: gripPosition,
                                      );

                                  // Show tutorial before running assessment
                                  final shouldProceed = await showTutorialIfNeeded(
                                    context: context,
                                    content:
                                        AssessmentTutorials.get60PercentTutorial(
                                          hand,
                                          gripPosition,
                                        ),
                                    tutorialId:
                                        AssessmentTutorials.get60PercentTutorialId(),
                                  );

                                  if (shouldProceed && context.mounted) {
                                    checkAndRunAssessment(
                                      assessmentWithGrip,
                                      handSide: hand,
                                      mvcValue: mvcValue,
                                      gripPosition: gripPosition,
                                    );
                                  }
                                }
                                break;
                            }
                          },
                  ),
                ),
                // A coach's assessment, or one the athlete wrote: there is no
                // protocol screen for it, it is measured by running the
                // training it hangs off and answering its question at the end.
                ...recordableTrainings.map(
                  (training) => AssessmentCard(
                    title: training.assessment!.label,
                    icon: Icons.assessment,
                    description: _describe(training),
                    lastResult: lastResultFor(training.assessment!.id),
                    onTap: () => startTrainingRun(
                      context,
                      ref,
                      training,
                      // The activity a training is logged under travels with
                      // the prescription, not with the training itself, so a
                      // run started here takes the same default every run
                      // outside a program takes.
                      activity: SessionActivity.hangboard,
                      trainingId: training.id,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// What a recordable assessment card says under its name: the question the
/// coach asks at the end of the run when there is one, and otherwise the
/// training the result is measured by.
String _describe(Training training) {
  final prompt = training.assessment?.prompt?.trim() ?? '';
  return prompt.isEmpty ? training.title : prompt;
}
