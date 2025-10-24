import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/pre_run_screen.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/stat_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileContent extends ConsumerWidget {
  final List<AssessmentModel> assessments;
  final Color accentLeft;
  final Color accentRight;

  const ProfileContent({
    super.key,
    required this.assessments,
    required this.accentLeft,
    required this.accentRight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Split & sort
    final maxForce =
        assessments.where((a) => a.type == AssessmentType.mvc).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final maxForce3fd =
        assessments.where((a) => a.type == AssessmentType.mvc3fd).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final criticalForce =
        assessments
            .where((a) => a.type == AssessmentType.criticalForce)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Max Force Section
          StatContent(
            title: "Max Force - Half Crimp",
            maxLeft: maxForce.map((a) => a.leftValue ?? 0).lastOrNull ?? 0,
            maxRight: maxForce.map((a) => a.rightValue ?? 0).lastOrNull ?? 0,
            accentLeft: accentLeft,
            accentRight: accentRight,
            leftData:
                maxForce
                    .where((a) => a.leftValue != null)
                    .map((a) => (a.date, a.leftValue!))
                    .toList(),
            rightData:
                maxForce
                    .where((a) => a.rightValue != null)
                    .map((a) => (a.date, a.rightValue!))
                    .toList(),
            onStartAssessment:
                ref.watch(connectionStateProvider) ==
                        BleConnectionState.connected
                    ? () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) => PreRunScreen(type: AssessmentType.mvc),
                        ),
                      );
                    }
                    : () => showDialog(
                      builder:
                          (context) => AlertDialog(
                            title: Text("No BLE device connected"),
                            content: Text(
                              "You must connect to a BLE device to run an assessment",
                            ),
                          ),
                      context: context,
                    ),
          ),

          const SizedBox(height: 32),

          StatContent(
            title: "Max Force - 3FD",
            maxLeft: maxForce3fd
                .map((a) => a.leftValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            maxRight: maxForce3fd
                .map((a) => a.rightValue ?? 0)
                .fold<double>(0, (prev, el) => el > prev ? el : prev),
            accentLeft: accentLeft,
            accentRight: accentRight,
            leftData:
                maxForce3fd
                    .where((a) => a.leftValue != null)
                    .map((a) => (a.date, a.leftValue!))
                    .toList(),
            rightData:
                maxForce3fd
                    .where((a) => a.rightValue != null)
                    .map((a) => (a.date, a.rightValue!))
                    .toList(),
            onStartAssessment:
                ref.watch(connectionStateProvider) ==
                        BleConnectionState.connected
                    ? () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) =>
                                  PreRunScreen(type: AssessmentType.mvc3fd),
                        ),
                      );
                    }
                    : () => showDialog(
                      builder:
                          (context) => AlertDialog(
                            title: Text("No BLE device connected"),
                            content: Text(
                              "You must connect to a BLE device to run an assessment",
                            ),
                          ),
                      context: context,
                    ),
          ),

          SizedBox(height: 32),

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
            leftData:
                criticalForce
                    .where((a) => a.leftValue != null)
                    .map((a) => (a.date, a.leftValue!))
                    .toList(),
            rightData:
                criticalForce
                    .where((a) => a.rightValue != null)
                    .map((a) => (a.date, a.rightValue!))
                    .toList(),
            onStartAssessment:
                () =>
                    ref.watch(connectionStateProvider) ==
                            BleConnectionState.connected
                        ? () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (ctx) => PreRunScreen(
                                    type: AssessmentType.criticalForce,
                                  ),
                            ),
                          );
                        }
                        : () => showDialog(
                          builder:
                              (context) => AlertDialog(
                                title: Text("No BLE device connected"),
                                content: Text(
                                  "You must connect to a BLE device to run an assessment",
                                ),
                              ),
                          context: context,
                        ),
          ),
        ],
      ),
    );
  }
}
