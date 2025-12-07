import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

class TrainingFooter extends StatelessWidget {
  final int timeLeftMilliseconds;
  final int currentRepIndex;
  final int numberReps;
  final RepeaterModel? repeater;

  const TrainingFooter({
    super.key,
    required this.currentRepIndex,
    required this.numberReps,
    required this.timeLeftMilliseconds,
    this.repeater,
  });

  // Calculate current set and rep within set for repeater trainings
  ({int currentSet, int currentRep, int totalSets, int totalRepsPerSet})?
  _calculateRepeaterProgress() {
    if (repeater == null) return null;

    final sets = repeater!.sets;
    final repsPerSet = repeater!.repsBySet;
    final splitHand = repeater!.splitHand;

    if (splitHand) {
      // For split hand, each "set" has:
      // - right hand set: repsPerSet work reps with (repsPerSet-1) rests between them
      // - rest between hands
      // - left hand set: repsPerSet work reps with (repsPerSet-1) rests between them
      // - rest between sets (if not last set)

      int elementsPerHandSet =
          repsPerSet + (repsPerSet - 1); // work reps + inter-rep rests
      int elementsPerFullSet =
          elementsPerHandSet + // right hand
          1 + // rest between hands
          elementsPerHandSet + // left hand
          1; // rest between sets

      // Find which set we're in
      int currentSetIndex = 0;
      int remainingIndex = currentRepIndex - 1; // Convert to 0-based

      while (remainingIndex >= elementsPerFullSet &&
          currentSetIndex < sets - 1) {
        remainingIndex -= elementsPerFullSet;
        currentSetIndex++;
      }

      // Check if we're in right or left hand set
      int positionInSet = remainingIndex;

      if (positionInSet >= elementsPerHandSet + 1) {
        // We're in the left hand set
        positionInSet -= (elementsPerHandSet + 1);
      }

      // Calculate rep within the hand set
      // Every 2 elements is a rep (work + rest), except last rep
      int repInHandSet = (positionInSet ~/ 2) + 1;

      return (
        currentSet: currentSetIndex + 1,
        currentRep: repInHandSet,
        totalSets: sets,
        totalRepsPerSet: repsPerSet,
      );
    } else {
      // For non-split hand:
      // Each set has: repsPerSet work reps + (repsPerSet-1) rests between reps + 1 rest after set
      int elementsPerSet =
          repsPerSet + (repsPerSet - 1) + 1; // work + inter-rep rest + set rest

      // Find which set we're in
      int currentSetIndex = 0;
      int remainingIndex = currentRepIndex - 1; // Convert to 0-based

      while (remainingIndex >= elementsPerSet && currentSetIndex < sets - 1) {
        remainingIndex -= elementsPerSet;
        currentSetIndex++;
      }

      // Calculate rep within set (every 2 elements is a rep: work + rest)
      int repInSet = (remainingIndex ~/ 2) + 1;

      return (
        currentSet: currentSetIndex + 1,
        currentRep: repInSet > repsPerSet ? repsPerSet : repInSet,
        totalSets: sets,
        totalRepsPerSet: repsPerSet,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = currentRepIndex / numberReps;
    final repeaterProgress = _calculateRepeaterProgress();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.borderDefault, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show sets/reps for repeater trainings, otherwise show regular progress
          if (repeaterProgress != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProgressItem(
                  label: 'SET',
                  value:
                      '${repeaterProgress.currentSet}/${repeaterProgress.totalSets}',
                ),
                Container(
                  width: 2,
                  height: 24,
                  color: CrimpyTheme.borderDefault,
                ),
                _ProgressItem(
                  label: 'REP',
                  value:
                      '${repeaterProgress.currentRep}/${repeaterProgress.totalRepsPerSet}',
                ),
                Container(
                  width: 2,
                  height: 24,
                  color: CrimpyTheme.borderDefault,
                ),
                _ProgressItem(
                  label: 'TOTAL',
                  value: '$currentRepIndex/$numberReps',
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PROGRESS',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: CrimpyTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  "$currentRepIndex / $numberReps",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: CrimpyTheme.bgPrimary,
                  border: Border.all(
                    color: CrimpyTheme.borderDefault,
                    width: 1,
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: CrimpyTheme.primaryOrange,
                    border: Border.all(
                      color: CrimpyTheme.primaryOrange,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: CrimpyTheme.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
