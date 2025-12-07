import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/training_feedback_screen/widgets/training_result.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Track new weights from feedback
  double _newWeightRight = 0;
  double _newWeightLeft = 0;

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
    // Check if this is a builtin training by looking up the training ID
    final isBuiltinTraining = builtinTrainings.any(
      (bt) => bt.id == widget.template.id,
    );
    final builtinTraining = builtinTrainings.firstWhereOrNull(
      (bt) => bt.id == widget.template.id,
    );

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

    // Calculate overall success percentage
    final workingReps = widget.results.where((r) => !r.isRest).toList();
    final int percentageSuccess =
        (workingReps
                    .where((rep) => rep.averageWeight >= rep.targetWeight)
                    .length /
                workingReps.length *
                100)
            .round();

    return Scaffold(
      backgroundColor: CrimpyTheme.bgSecondary,
      appBar: AppBar(
        backgroundColor: CrimpyTheme.bgSecondary,
        title: Text(
          'Training Complete',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section with celebration and stats
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: CrimpyTheme.bgPrimary,
                  border: Border.all(
                    color: CrimpyTheme.borderDefault,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CrimpyTheme.borderDefault,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TRAINING COMPLETE',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 2.0,
                        color: CrimpyTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.template.name,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Success percentage display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            percentageSuccess >= 80
                                ? CrimpyTheme.bgSuccess
                                : percentageSuccess >= 50
                                ? CrimpyTheme.bgWarning
                                : CrimpyTheme.bgError,
                        border: Border.all(
                          color:
                              percentageSuccess >= 80
                                  ? CrimpyTheme.statusSuccess
                                  : percentageSuccess >= 50
                                  ? CrimpyTheme.statusWarning
                                  : CrimpyTheme.statusError,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$percentageSuccess%',
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
                              color:
                                  percentageSuccess >= 80
                                      ? CrimpyTheme.statusSuccess
                                      : percentageSuccess >= 50
                                      ? CrimpyTheme.statusWarning
                                      : CrimpyTheme.statusError,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'completed',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Hand-specific feedback cards
              if (handSide == HandSide.both) ...[
                TrainingResultCard(
                  reps:
                      widget.results
                          .where(
                            (r) => !r.isRest && r.handSide == HandSide.right,
                          )
                          .toList(),
                  handSide: HandSide.right,
                  loadAdjustmentFunction: widget.template.computeNewWeights!,
                  onNewWeightChange: (double newWeight) {
                    setState(() {
                      _newWeightRight = newWeight;
                    });
                  },
                ),
                TrainingResultCard(
                  reps:
                      widget.results
                          .where(
                            (r) => !r.isRest && r.handSide == HandSide.left,
                          )
                          .toList(),
                  handSide: HandSide.left,
                  loadAdjustmentFunction: widget.template.computeNewWeights!,
                  onNewWeightChange: (double newWeight) {
                    setState(() {
                      _newWeightLeft = newWeight;
                    });
                  },
                ),
              ] else
                TrainingResultCard(
                  reps: widget.results,
                  handSide: handSide,
                  loadAdjustmentFunction: widget.template.computeNewWeights!,
                  onNewWeightChange: (double newWeight) {
                    setState(() {
                      if (handSide == HandSide.right) {
                        _newWeightRight = newWeight;
                      } else {
                        _newWeightLeft = newWeight;
                      }
                    });
                  },
                ),

              // Session details form
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: CrimpyTheme.bgPrimary,
                  border: Border.all(
                    color: CrimpyTheme.borderDefault,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CrimpyTheme.borderDefault,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SESSION DETAILS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 2.0,
                          color: CrimpyTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                        maxLines: 6,
                        minLines: 4,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final navigator = Navigator.of(context);

                // Save the session
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

                // Update target weights if this is a builtin training and new weights were calculated
                if (isBuiltinTraining && builtinTraining != null) {
                  final currentWeightRight =
                      widget.results
                          .firstWhereOrNull(
                            (r) => !r.isRest && r.handSide == HandSide.right,
                          )
                          ?.targetWeight ??
                      0.0;
                  final currentWeightLeft =
                      widget.results
                          .firstWhereOrNull(
                            (r) => !r.isRest && r.handSide == HandSide.left,
                          )
                          ?.targetWeight ??
                      0.0;

                  // Only update weights if they were actually changed (feedback was given)
                  if (_newWeightRight > 0 || _newWeightLeft > 0) {
                    final newWeightRight =
                        _newWeightRight > 0
                            ? _newWeightRight
                            : currentWeightRight;
                    final newWeightLeft =
                        _newWeightLeft > 0 ? _newWeightLeft : currentWeightLeft;

                    await ref
                        .read(builtinTrainingRepositoryProvider)
                        .updateTargetWeights(
                          training: builtinTraining,
                          currentWeightRight: currentWeightRight,
                          currentWeightLeft: currentWeightLeft,
                          newWeightRight: newWeightRight,
                          newWeightLeft: newWeightLeft,
                        );

                    // Invalidate builtin trainings to refresh with new weights
                    ref.invalidate(allTrainingsProvider);
                  }
                }

                if (mounted) {
                  navigator.pop();
                }
              }
            },
            child: const Text("SAVE TRAINING"),
          ),
        ),
      ),
    );
  }
}
