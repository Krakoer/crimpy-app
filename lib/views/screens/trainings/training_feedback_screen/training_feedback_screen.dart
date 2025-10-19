import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/training_feedback_screen/widgets/training_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

/// Future: Training feedback screen shown after completing a builtin training.
/// This screen will collect user feedback about training difficulty and suggest load adjustments.
class TrainingFeedbackScreen extends ConsumerStatefulWidget {
  final TrainingWithReps template;
  final List<RepDataModel> results;

  const TrainingFeedbackScreen({
    super.key,
    required this.results,
    required this.template,
  });

  @override
  ConsumerState<TrainingFeedbackScreen> createState() =>
      _TrainingFeedbackScreenState();
}

class _TrainingFeedbackScreenState
    extends ConsumerState<TrainingFeedbackScreen> {
  final _trainingNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _trainingNameController.text =
        "${widget.template.name} - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}";
    super.initState();
  }

  @override
  void dispose() {
    _trainingNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _newWeightRight = 0;
    double _newWeightLeft = 0;
    // Check if training concerns only one hand or both
    final handSide =
        widget.results.firstWhereOrNull((r) => r.handSide == HandSide.right) ==
                null
            ? HandSide.left
            : widget.results.firstWhereOrNull(
                  (r) => r.handSide == HandSide.left,
                ) ==
                null
            ? HandSide.right
            : HandSide.both;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Training Complete',
          style: Theme.of(
            context,
          ).appBarTheme.titleTextStyle!.copyWith(fontSize: 27),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (handSide == HandSide.both) ...[
              TrainingResultCard(
                reps:
                    widget.results
                        .where((r) => !r.isRest && r.handSide == HandSide.right)
                        .toList(),
                handSide: HandSide.right,
                loadAdjustmentFunction: widget.template.computeNewWeights!,
                onNewWeightChange:
                    (double newWeight) => _newWeightRight = newWeight,
              ),
              TrainingResultCard(
                reps:
                    widget.results
                        .where((r) => !r.isRest && r.handSide == HandSide.left)
                        .toList(),
                handSide: HandSide.left,
                loadAdjustmentFunction: widget.template.computeNewWeights!,
                onNewWeightChange:
                    (double newWeight) => _newWeightLeft = newWeight,
              ),
            ] else
              TrainingResultCard(
                reps: widget.results,
                handSide: handSide,
                loadAdjustmentFunction: widget.template.computeNewWeights!,
                onNewWeightChange:
                    (double newWeight) =>
                        handSide == HandSide.right
                            ? _newWeightRight = newWeight
                            : _newWeightLeft = newWeight,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _trainingNameController,
                      decoration: const InputDecoration(
                        labelText: 'Training Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a training name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: "How did you feel?",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 20,
                      minLines: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton(
        style: null,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ref
                .read(sessionsProvider(null).notifier)
                .saveSession(
                  SessionModel(
                    name: _trainingNameController.text,
                    date: DateTime.now(),
                    notes: _noteController.text,
                    isAssessment: false,
                  ),
                  widget.results,
                );
            // TODO: Update the training target weight.
            Navigator.of(context).pop();
          }
        },
        child: Text("Save training"),
      ),
    );
  }

  void _submitFeedback() {
    // Future: Create and save feedback
    // final feedback = TrainingFeedbackModel(
    //   builtinTrainingId: widget.builtinTrainingId,
    //   completionDate: DateTime.now(),
    //   result: _result!,
    //   difficulty: _difficulty,
    //   notes: _notesController.text.isEmpty ? null : _notesController.text,
    //   usedWeight: widget.usedWeight,
    // );

    // Future: Save feedback to repository and update training recommendations
    // ref.read(trainingFeedbackProvider.notifier).saveFeedback(feedback);

    Navigator.of(context).pop();

    // Show snackbar with load adjustment recommendation
    // if (_result == TrainingResult.success && _difficulty != null) {
    //   // final nextLoad = LoadAdjustmentService.calculateNextLoad(
    //   //   widget.usedWeight,
    //   //   _result!,
    //   //   _difficulty,
    //   // );
    //   final nextLoad = 70;

    //   // final recommendation = LoadAdjustmentService.getAdjustmentRecommendation(
    //   //   widget.usedWeight,
    //   //   nextLoad,
    //   // );

    //   final recommendation = "We recommend increasing your load by 10% to 8kg";

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(recommendation), duration: Duration(seconds: 5)),
    //   );
    // }
  }
}
