import 'package:flutter/material.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingProgressInfo extends StatelessWidget {
  final int currentRepIndex;
  final int totalReps;
  final RepeaterModel? repeater;

  const TrainingProgressInfo({
    super.key,
    required this.currentRepIndex,
    required this.totalReps,
    this.repeater,
  });

  ({int currentSet, int currentRep, int totalSets, int totalRepsPerSet})?
  _calculateRepeaterProgress() {
    if (repeater == null) return null;

    final sets = repeater!.sets;
    final repsPerSet = repeater!.repsBySet;
    final splitHand = repeater!.splitHand;

    int elementsPerSet;
    if (splitHand) {
      int elementsPerHandSet = repsPerSet + (repsPerSet - 1);
      elementsPerSet = elementsPerHandSet + 1 + elementsPerHandSet + 1;
    } else {
      elementsPerSet = repsPerSet + (repsPerSet - 1) + 1;
    }

    int currentSetIndex = 0;
    int remainingIndex = currentRepIndex;

    while (remainingIndex >= elementsPerSet && currentSetIndex < sets - 1) {
      remainingIndex -= elementsPerSet;
      currentSetIndex++;
    }

    int positionInSet = remainingIndex;
    if (splitHand && positionInSet >= (repsPerSet + repsPerSet - 1 + 1)) {
      positionInSet -= (repsPerSet + repsPerSet - 1 + 1);
    }

    int repInSet = (positionInSet ~/ 2) + 1;
    if (repInSet > repsPerSet) repInSet = repsPerSet;

    return (
      currentSet: currentSetIndex + 1,
      currentRep: repInSet,
      totalSets: sets,
      totalRepsPerSet: repsPerSet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repeaterProgress = _calculateRepeaterProgress();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child:
          repeaterProgress != null
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProgressText(
                    'Set ${repeaterProgress.currentSet}/${repeaterProgress.totalSets}',
                  ),
                  _ProgressText(
                    'Rep ${repeaterProgress.currentRep}/${repeaterProgress.totalRepsPerSet}',
                  ),
                  _ProgressText('${currentRepIndex + 1}/$totalReps'),
                ],
              )
              : Center(
                child: _ProgressText('${currentRepIndex + 1}/$totalReps'),
              ),
    );
  }
}

class _ProgressText extends StatelessWidget {
  final String text;

  const _ProgressText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: CrimpyTheme.primaryBlack,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}
