import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// Future: Training feedback screen shown after completing a builtin training.
/// This screen will collect user feedback about training difficulty and suggest load adjustments.
class TrainingFeedbackScreen extends ConsumerStatefulWidget {
  final int builtinTrainingId;
  final String trainingName;
  final double usedWeight;

  const TrainingFeedbackScreen({
    super.key,
    required this.builtinTrainingId,
    required this.trainingName,
    required this.usedWeight,
  });

  @override
  ConsumerState<TrainingFeedbackScreen> createState() =>
      _TrainingFeedbackScreenState();
}

class _TrainingFeedbackScreenState
    extends ConsumerState<TrainingFeedbackScreen> {
  TrainingResult? _result;
  TrainingDifficulty? _difficulty;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Training Complete')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How did your ${widget.trainingName} session go?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 24),

            // Success/Failure selection
            Text(
              'Did you complete the training successfully?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TrainingResult>(
                    title: Text('Success'),
                    value: TrainingResult.success,
                    groupValue: _result,
                    onChanged: (value) => setState(() => _result = value),
                  ),
                ),
                Expanded(
                  child: RadioListTile<TrainingResult>(
                    title: Text('Failed'),
                    value: TrainingResult.failure,
                    groupValue: _result,
                    onChanged: (value) => setState(() => _result = value),
                  ),
                ),
              ],
            ),

            // Difficulty selection (only if successful)
            if (_result == TrainingResult.success) ...[
              SizedBox(height: 24),
              Text(
                'How did it feel?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              ...TrainingDifficulty.values.map(
                (difficulty) => RadioListTile<TrainingDifficulty>(
                  title: Text(
                    LoadAdjustmentService.getDifficultyDescription(difficulty),
                  ),
                  value: difficulty,
                  groupValue: _difficulty,
                  onChanged: (value) => setState(() => _difficulty = value),
                ),
              ),
            ],

            SizedBox(height: 24),

            // Notes
            Text(
              'Additional notes (optional):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'How did you feel? Any observations?',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 24),

            // Load adjustment preview (if successful)
            if (_result == TrainingResult.success && _difficulty != null)
              _buildLoadAdjustmentPreview(),

            Spacer(),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _result != null ? _submitFeedback : null,
                child: Text('Save Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadAdjustmentPreview() {
    final nextLoad = LoadAdjustmentService.calculateNextLoad(
      widget.usedWeight,
      _result!,
      _difficulty,
    );

    final recommendation = LoadAdjustmentService.getAdjustmentRecommendation(
      widget.usedWeight,
      nextLoad,
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next Time', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Text(recommendation),
        ],
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
    if (_result == TrainingResult.success && _difficulty != null) {
      final nextLoad = LoadAdjustmentService.calculateNextLoad(
        widget.usedWeight,
        _result!,
        _difficulty,
      );

      final recommendation = LoadAdjustmentService.getAdjustmentRecommendation(
        widget.usedWeight,
        nextLoad,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(recommendation), duration: Duration(seconds: 5)),
      );
    }
  }
}
