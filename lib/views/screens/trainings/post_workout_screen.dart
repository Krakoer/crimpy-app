import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:intl/intl.dart';
import 'package:crimpy/theme.dart';

class PostWorkoutScreen extends ConsumerStatefulWidget {
  final Training template;
  final List<RepDataModel> results;

  /// Category the session is logged under. Trainings run from the user's own
  /// library are hangboard sessions; program trainings carry the coach's label.
  final SessionActivity activity;

  /// What the run was started from, both null outside a program.
  final String? trainingId;
  final String? programSessionId;

  /// Show the results of the workout to the user, and allow them to add a note to the session.
  const PostWorkoutScreen({
    required this.results,
    required this.template,
    this.activity = SessionActivity.hangboard,
    this.trainingId,
    this.programSessionId,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostWorkoutScreenState();
}

class _PostWorkoutScreenState extends ConsumerState<PostWorkoutScreen> {
  final _trainingNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _trainingNameController.text =
        "${widget.template.title} - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}";
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
    // Success percentage, computed only from sensor reps that have a target.
    final sensorReps = widget.results
        .where((r) => !r.isRest && r.targetWeight > 0)
        .toList();
    final bool hasSensorData = sensorReps.isNotEmpty;
    final int percentageSuccess = hasSensorData
        ? (sensorReps
                      .where((rep) => rep.averageWeight >= rep.targetWeight)
                      .length /
                  sensorReps.length *
                  100)
              .round()
        : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (res, didPop) async {
        if (res) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leave without saving training?'),
            content: Text(
              'Are you sure you want to quit without saving this training to your history?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.template.title)),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 100),
              Text(
                "Well done! 💪",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              // Show the success percentage only when sensor data was captured.
              if (hasSensorData)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "you managed to do ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CrimpyTheme.gray500,
                        ),
                      ),
                      TextSpan(
                        text: "$percentageSuccess%",
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(fontSize: 12),
                      ),
                      TextSpan(
                        text: " of the reps",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CrimpyTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 25),
              // Form for session name and notes.
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
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            try {
              await ref
                  .read(sessionsProvider.notifier)
                  .saveSession(
                    SessionModel(
                      name: _trainingNameController.text,
                      date: DateTime.now(),
                      notes: _noteController.text,
                      isAssessment: false,
                      activity: widget.activity,
                      // This screen is only ever reached by finishing a run.
                      origin: SessionOrigin.played,
                      trainingId: widget.trainingId,
                      programSessionId: widget.programSessionId,
                    ),
                    widget.results,
                  );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving training: $e')),
                );
              }
              return;
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text("Save training"),
        ),
      ),
    );
  }
}
