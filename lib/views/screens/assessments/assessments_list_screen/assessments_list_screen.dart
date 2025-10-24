import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/assessment_card.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/select_hand_dialog.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/select_grip_position_dialog.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/widgets/confirm_redo_assessment_dialog.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_run_screen.dart';
import 'package:crimpy/views/screens/assessments/endurance_60/endurance_60_run_screen.dart';
import 'package:crimpy/views/widgets/ble/connection_dialog.dart';
import 'package:crimpy/views/widgets/ble/tare_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/mvc_run_screen.dart';

/// Screen to show and run the available assessments.
class AssessmentsScreen extends ConsumerWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentTemplates = ref.watch(assessmentTrainingsProvider);

    /// Run the assessment given its type and hand.
    void runAssessment(
      AssessmentTrainingModel model,
      HandSide? handSide, {
      double? mvcValue,
    }) {
      ref.read(bleSessionProvider.notifier).reset();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (ctx) => switch (model.type) {
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
              .read(assessmentsProvider(model.type).notifier)
              .getSameDayAssessment(
                handSide: handSide,
                gripPosition: gripPosition,
              ) !=
          null) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder:
                (ctx) => ConfirmRedoAssessmentDialog(
                  runAssessment:
                      () => runAssessment(model, handSide, mvcValue: mvcValue),
                ),
          );
        }
      } else {
        runAssessment(model, handSide, mvcValue: mvcValue);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: switch (assessmentTemplates) {
        AsyncData(:final value) => ListView(
          children: [
            ...value.map(
              (template) => AssessmentCard(
                title: template.training.name,
                icon: template.icon,
                description: template.description,
                onTap:
                    // Check if a BLE device is connected
                    ref.watch(connectionStateProvider) ==
                            BleConnectionState.connected
                        ? () async {
                          // Ask the hand to test for the assessment types that need it.
                          // Otherwise, just run the assessment.
                          switch (template.type) {
                            case AssessmentType.mvc:
                              // First get the grip position
                              final GripPosition? gripPosition =
                                  await showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => SelectGripPositionDialog(),
                                  );
                              if (gripPosition != null) {
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
                              break;
                            case AssessmentType.criticalForce:
                              // First get the hand to test
                              final HandSide? hand = await showDialog(
                                context: context,
                                builder: (ctx) => SelectHandDialog(),
                              );
                              if (hand != null) {
                                checkAndRunAssessment(template, handSide: hand);
                              }
                              break;
                            case AssessmentType.endurance60:
                              // First get the hand to test
                              final HandSide? hand = await showDialog(
                                context: context,
                                builder: (ctx) => SelectHandDialog(),
                              );
                              if (hand == null) break;

                              // Check if MVC has been done for this hand
                              final mvcValue = await ref
                                  .read(
                                    assessmentsProvider(
                                      AssessmentType.mvc,
                                    ).notifier,
                                  )
                                  .getLastValueForHand(hand);

                              if (mvcValue == null || mvcValue <= 0) {
                                // Show error dialog - no MVC available
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: Text("MVC Required"),
                                          content: Text(
                                            "You must complete an MVC assessment for your ${hand.isRightHand ? 'right' : 'left'} hand before running this assessment.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: Text("OK"),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              } else {
                                checkAndRunAssessment(
                                  template,
                                  handSide: hand,
                                  mvcValue: mvcValue,
                                );
                              }
                              break;
                          }
                        }
                        // No BLE device connected dialog
                        : () => showDialog(
                          builder:
                              (ctx) => AlertDialog(
                                title: Text("No BLE device connected"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                        top: 4,
                                        bottom: 16,
                                      ),
                                      child: Text(
                                        "You must connect to a BLE device to run an assessment",
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) =>
                                                  const ConnectionDialog(),
                                        ).then((isConnected) {
                                          if (isConnected != null &&
                                              isConnected &&
                                              context.mounted) {
                                            showDialog(
                                              // Use scaffold context, not dialog because it has been popped.
                                              context: context,
                                              builder:
                                                  (ctx) => const TareDialog(),
                                              barrierDismissible: false,
                                            );
                                          }
                                        });
                                      },
                                      child: Text("Connect"),
                                    ),
                                  ],
                                ),
                              ),
                          context: context,
                        ),
              ),
            ),
          ],
        ),
        AsyncError() => const Text('Oops, something unexpected happened'),
        _ => const CircularProgressIndicator(),
      },
    );
  }
}
