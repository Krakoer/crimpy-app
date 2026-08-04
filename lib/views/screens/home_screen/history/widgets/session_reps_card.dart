import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/sets_view_widget.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/rep_item_widget.dart';

class SessionRepsCard extends StatefulWidget {
  final SessionModel session;
  final Color sessionColor;

  const SessionRepsCard({
    super.key,
    required this.session,
    required this.sessionColor,
  });

  @override
  State<SessionRepsCard> createState() => _SessionRepsCardState();
}

class _SessionRepsCardState extends State<SessionRepsCard> {
  bool _repsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final reps = widget.session.reps!;
    final workReps = reps.where((r) => !r.isRest).toList();

    // Calculate success rate
    int successCount = 0;
    for (final rep in workReps) {
      if (rep.targetWeight > 0) {
        final successRate = rep.averageWeight / rep.targetWeight;
        if (successRate >= 0.9) {
          successCount++;
        }
      }
    }

    // Use set-based view only if this is a repeater workout
    final bool isRepeater = widget.session.repeaterConfig != null;

    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRepeater ? 'Sets Overview' : 'Repetitions Breakdown',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (workReps.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: successCount == workReps.length
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: successCount == workReps.length
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$successCount/${workReps.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: successCount == workReps.length
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Display sets view for repeaters, individual reps for everything else
          if (isRepeater)
            SetsViewWidget(
              sets: _groupRepsIntoSets(reps),
              sessionColor: widget.sessionColor,
              isSplitHand: widget.session.repeaterConfig!.splitHand,
            )
          else
            _buildIndividualRepsView(reps),
        ],
      ),
    );
  }

  Widget _buildIndividualRepsView(List<RepDataModel> reps) {
    // Determine if we should show collapse/expand functionality
    final bool hasMany = reps.length > 10;
    final int displayCount = hasMany && !_repsExpanded ? 5 : reps.length;

    return Column(
      children: [
        Column(
          children: List.generate(displayCount, (index) {
            final rep = reps[index];
            return RepItemWidget(
              rep: rep,
              index: index,
              sessionColor: widget.sessionColor,
            );
          }),
        ),
        // Show expand/collapse button if there are many reps
        if (hasMany) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _repsExpanded = !_repsExpanded;
                });
              },
              icon: Icon(
                _repsExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              label: Text(
                _repsExpanded ? 'Show less' : 'Show all ${reps.length} reps',
                style: const TextStyle(fontSize: 14),
              ),
              style: TextButton.styleFrom(foregroundColor: widget.sessionColor),
            ),
          ),
        ],
      ],
    );
  }

  /// Group reps into sets using the stored repeater configuration.
  /// For split-hand repeaters, each hand portion is shown as a separate sub-set.
  List<List<RepDataModel>> _groupRepsIntoSets(List<RepDataModel> reps) {
    final repeaterConfig = widget.session.repeaterConfig!;
    final List<List<RepDataModel>> sets = [];
    int repIndex = 0;

    if (repeaterConfig.splitHand) {
      // For split hand, group each hand separately
      for (int set = 0; set < repeaterConfig.sets; set++) {
        // Right hand portion
        final List<RepDataModel> rightHandSet = [];
        int rightWorkReps = 0;

        while (repIndex < reps.length &&
            rightWorkReps < repeaterConfig.repsPerSet) {
          final rep = reps[repIndex];
          rightHandSet.add(rep);
          if (!rep.isRest) rightWorkReps++;
          repIndex++;
        }

        // Add rest between hands if present
        if (repIndex < reps.length &&
            reps[repIndex].isRest &&
            reps[repIndex].duration < repeaterConfig.setRest) {
          rightHandSet.add(reps[repIndex]);
          repIndex++;
        }

        if (rightHandSet.isNotEmpty) {
          sets.add(rightHandSet);
        }

        // Left hand portion
        final List<RepDataModel> leftHandSet = [];
        int leftWorkReps = 0;

        while (repIndex < reps.length &&
            leftWorkReps < repeaterConfig.repsPerSet) {
          final rep = reps[repIndex];
          leftHandSet.add(rep);
          if (!rep.isRest) leftWorkReps++;
          repIndex++;
        }

        // Add rest between hands if present (only for transitions between sets)
        if (repIndex < reps.length &&
            reps[repIndex].isRest &&
            reps[repIndex].duration < repeaterConfig.setRest) {
          leftHandSet.add(reps[repIndex]);
          repIndex++;
        }

        if (leftHandSet.isNotEmpty) {
          sets.add(leftHandSet);
        }

        // Skip the long set rest
        if (repIndex < reps.length &&
            reps[repIndex].isRest &&
            reps[repIndex].duration >= repeaterConfig.setRest) {
          repIndex++;
        }
      }
    } else {
      // Non-split hand: separate right and left hand reps within each set
      // In the actual workout, they alternate (R, L, R, L...), but we display them grouped
      for (int set = 0; set < repeaterConfig.sets; set++) {
        final List<RepDataModel> rightHandReps = [];
        final List<RepDataModel> leftHandReps = [];
        int workRepsCollected = 0;
        final int expectedTotalWorkReps =
            repeaterConfig.repsPerSet * 2; // Both hands

        // Collect all reps for this set
        while (repIndex < reps.length &&
            workRepsCollected < expectedTotalWorkReps) {
          final rep = reps[repIndex];

          // Stop if we hit the long set rest
          if (rep.isRest && rep.duration >= repeaterConfig.setRest) {
            break;
          }

          // Separate by hand
          if (rep.handSide.isRightHand) {
            rightHandReps.add(rep);
          } else {
            leftHandReps.add(rep);
          }

          if (!rep.isRest) {
            workRepsCollected++;
          }

          repIndex++;
        }

        // Add right hand reps as first sub-set
        if (rightHandReps.isNotEmpty) {
          sets.add(rightHandReps);
        }

        // Add left hand reps as second sub-set
        if (leftHandReps.isNotEmpty) {
          sets.add(leftHandReps);
        }

        // Skip the long set rest
        if (repIndex < reps.length &&
            reps[repIndex].isRest &&
            reps[repIndex].duration >= repeaterConfig.setRest) {
          repIndex++;
        }
      }
    }

    return sets;
  }
}
