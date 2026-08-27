import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen/widgets/assessment_answer_fields.dart';
import 'package:intl/intl.dart';
import 'package:crimpy/theme.dart';

class PostWorkoutScreen extends ConsumerStatefulWidget {
  final Training template;
  final List<RepDataModel> results;

  /// What the run answered the open items with: the reps an AMRAP turned out
  /// to be, and the rounds of an emom the athlete dropped out of. Empty for a
  /// run that had none.
  final List<SessionItemResultModel> itemResults;

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
    this.itemResults = const [],
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
  final _rightAnswerController = TextEditingController();
  final _leftAnswerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// The assessment this run answers, when the training played is one.
  AssessmentDefinition? get _assessment => widget.template.assessment;

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
    _rightAnswerController.dispose();
    _leftAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // How the run went, read the way the history card reads it once the session
    // is saved: block by block, and against the same on-target threshold. One
    // ratio over blocks hung at different targets grades them all through a
    // single number and hides which of them was missed.
    final workReps = widget.results.where((rep) => !rep.isRest).toList();
    final blocks = groupRepsByTrainingItem(workReps, widget.template.items);
    final overall = spansMultipleBlocks(blocks)
        ? null
        : onTargetCount(workReps);
    final blockCounts = blocks == null
        ? const <_BlockOnTarget>[]
        : [
            for (final block in blocks)
              if (onTargetCount(block.reps) case final count?)
                (label: block.label, count: count),
          ];

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 100),
                Text(
                  "Well done! 💪",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                // Stated only for a run the training gave loads to grade against.
                if (overall != null)
                  _OverallOnTarget(count: overall)
                else if (blockCounts.isNotEmpty)
                  _BlocksOnTarget(counts: blockCounts),
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
                        if (_assessment case final assessment?) ...[
                          AssessmentAnswerFields(
                            definition: assessment,
                            rightController: _rightAnswerController,
                            leftController: _leftAnswerController,
                          ),
                          const SizedBox(height: 16),
                        ],
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
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ElevatedButton(
          style: null,
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            final assessment = _assessment;
            final session = SessionModel(
              name: _trainingNameController.text,
              date: DateTime.now(),
              notes: _noteController.text,
              // What marks the session as measuring something, which is how the
              // history and the coach portal label it.
              isAssessment: assessment != null,
              activity: widget.activity,
              // This screen is only ever reached by finishing a run.
              origin: SessionOrigin.played,
              trainingId: widget.trainingId,
              programSessionId: widget.programSessionId,
              // Frozen onto the session, the way the server freezes its own
              // copy: the reps and the open counts name items of this tree, so
              // it is what still heads them once the training is edited or
              // deleted. The template played is the copy taken, not the one the
              // library holds now, since only the first is what ran.
              prescriptionItems: widget.template.items,
            );
            try {
              if (assessment == null) {
                await ref
                    .read(sessionsProvider.notifier)
                    .saveSession(
                      session,
                      widget.results,
                      itemResults: widget.itemResults,
                    );
              } else {
                // Goes through the assessment notifier rather than saving the
                // session alone: it writes the session first and the result
                // against it, replaces an answer given earlier the same day, and
                // refreshes what the next prescribed run resolves against.
                final right = parseAnswer(_rightAnswerController.text);
                final left = assessment.perHand
                    ? parseAnswer(_leftAnswerController.text)
                    : null;
                await ref
                    .read(assessmentsProvider(assessment.id).notifier)
                    .saveAssessment(
                      AssessmentResultModel(
                        assessmentId: assessment.id,
                        rightValue: right,
                        leftValue: left,
                      ),
                      session,
                      widget.results,
                      itemResults: widget.itemResults,
                    );
              }
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
          child: Text(_assessment == null ? "Save training" : "Save result"),
        ),
      ),
    );
  }
}

/// One block of a run and how it was graded, named the way the athlete saw it
/// played.
typedef _BlockOnTarget = ({String label, OnTargetCount count});

/// How the whole run went, for a session that played a single block: one ratio
/// over one target grades exactly what it says it does. Counted rather than
/// stated as a percentage, so the athlete reads the same figure here and in the
/// history card of the session they just saved.
class _OverallOnTarget extends StatelessWidget {
  final OnTargetCount count;

  const _OverallOnTarget({required this.count});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.gray500);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "you hit your target on ", style: muted),
          TextSpan(
            text: "${count.onTarget} of ${count.total}",
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontSize: 12),
          ),
          TextSpan(text: " reps", style: muted),
          // The reps the sensor never measured are graded by nothing, so they
          // are named apart rather than counted into the ratio above.
          if (unmeasuredNote(count) case final note?)
            TextSpan(text: " ($note)", style: muted),
        ],
      ),
    );
  }
}

/// One ratio per block, the way the history card reads the same run. A block
/// hung at 34 kg and one hung at 24 kg are graded against what each of them
/// prescribed, so a missed block is not averaged away by a met one.
class _BlocksOnTarget extends StatelessWidget {
  final List<_BlockOnTarget> counts;

  const _BlocksOnTarget({required this.counts});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.gray500);

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 32, right: 32),
      child: Column(
        children: [
          for (final block in counts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(block.label, style: muted)),
                  Text(
                    "${block.count.onTarget}/${block.count.total} on target",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontSize: 12),
                  ),
                  if (unmeasuredNote(block.count) case final note?)
                    Text(" ($note)", style: muted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
