import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/sets_view_widget.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/rep_item_widget.dart';

/// How many reps a block shows before it has to be expanded. A block broken
/// into sets keeps all of them: the sets are the structure the athlete saw.
const int _repsPreview = 5;
const int _repsPreviewThreshold = 10;

class SessionRepsCard extends ConsumerStatefulWidget {
  final SessionModel session;
  final Color sessionColor;

  const SessionRepsCard({
    super.key,
    required this.session,
    required this.sessionColor,
  });

  @override
  ConsumerState<SessionRepsCard> createState() => _SessionRepsCardState();
}

class _SessionRepsCardState extends ConsumerState<SessionRepsCard> {
  bool _repsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final reps = widget.session.reps!;
    final workReps = reps.where((r) => !r.isRest).toList();

    int successCount = 0;
    for (final rep in workReps) {
      if (rep.targetWeight > 0 && rep.averageWeight / rep.targetWeight >= 0.9) {
        successCount++;
      }
    }

    // A rep names the training item it was played from, so the card reads the
    // run block by block. The prescription frozen on the session is the copy
    // that cannot have drifted since, and the only one readable for a coach's
    // training, so it is preferred; a guest-mode run has none and resolves its
    // own local training instead. Neither resolving falls back to the flat
    // list, as does a run that named no item the training still holds.
    final items =
        widget.session.prescriptionItems ??
        ref
            .watch(sessionTrainingItemsProvider(widget.session.trainingId))
            .value;
    final blocks = items == null
        ? null
        : groupRepsByTrainingItem(workReps, items);

    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                blocks != null ? 'Blocks' : 'Repetitions Breakdown',
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
          if (blocks != null)
            _buildBlocksView(blocks)
          else
            _buildIndividualRepsView(reps),
        ],
      ),
    );
  }

  Widget _buildBlocksView(List<RepBlock> blocks) {
    return Column(
      children: [
        for (final (index, block) in blocks.indexed) ...[
          _BlockCard(
            block: block,
            sessionColor: widget.sessionColor,
            expanded: _repsExpanded,
          ),
          if (index < blocks.length - 1) const SizedBox(height: 12),
        ],
        if (blocks.any(_blockIsCapped)) ...[
          const SizedBox(height: 8),
          Center(child: _buildExpandButton(_countedReps(blocks))),
        ],
      ],
    );
  }

  /// A block holding a whole repeater is as long as the flat list ever was, so
  /// it earns the same cap. Blocks broken into sets keep all of them.
  static bool _blockIsCapped(RepBlock block) =>
      block.sets == null && block.reps.length > _repsPreviewThreshold;

  int _countedReps(List<RepBlock> blocks) =>
      blocks.fold(0, (sum, block) => sum + block.reps.length);

  Widget _buildIndividualRepsView(List<RepDataModel> reps) {
    final bool hasMany = reps.length > _repsPreviewThreshold;
    final int displayCount = hasMany && !_repsExpanded
        ? _repsPreview
        : reps.length;

    return Column(
      children: [
        Column(
          children: List.generate(displayCount, (index) {
            return RepItemWidget(
              rep: reps[index],
              index: index,
              sessionColor: widget.sessionColor,
            );
          }),
        ),
        if (hasMany) ...[
          const SizedBox(height: 8),
          Center(child: _buildExpandButton(reps.length)),
        ],
      ],
    );
  }

  Widget _buildExpandButton(int total) {
    return TextButton.icon(
      onPressed: () => setState(() => _repsExpanded = !_repsExpanded),
      icon: Icon(
        _repsExpanded ? Icons.expand_less : Icons.expand_more,
        size: 20,
      ),
      label: Text(
        _repsExpanded ? 'Show less' : 'Show all $total reps',
        style: const TextStyle(fontSize: 14),
      ),
      style: TextButton.styleFrom(foregroundColor: widget.sessionColor),
    );
  }
}

/// One run of reps played from a single training item, headed with the item and
/// broken into its sets when it played a repeater.
class _BlockCard extends StatelessWidget {
  final RepBlock block;
  final Color sessionColor;
  final bool expanded;

  const _BlockCard({
    required this.block,
    required this.sessionColor,
    required this.expanded,
  });

  /// Each block is graded on its own reps, so two blocks of different intensity
  /// are not read through one pooled ratio.
  String? get _onTarget {
    final targeted = block.reps.where((r) => r.targetWeight > 0);
    if (targeted.isEmpty) return null;
    final onTarget = block.reps
        .where(
          (r) => r.targetWeight > 0 && r.averageWeight / r.targetWeight >= 0.9,
        )
        .length;
    return '$onTarget/${block.reps.length} on target';
  }

  List<RepDataModel> get _shownReps {
    if (expanded || block.reps.length <= _repsPreviewThreshold) {
      return block.reps;
    }
    return block.reps.sublist(0, _repsPreview);
  }

  @override
  Widget build(BuildContext context) {
    final sets = block.sets;
    final onTarget = _onTarget;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.borderDefault),
        borderRadius: BorderRadius.circular(CrimpyTheme.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  block.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onTarget != null)
                Text(
                  onTarget,
                  style: TextStyle(
                    fontSize: 12,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (sets != null)
            SetsViewWidget(sets: sets, sessionColor: sessionColor)
          else
            Column(
              children: [
                for (final (index, rep) in _shownReps.indexed)
                  RepItemWidget(
                    rep: rep,
                    index: index,
                    sessionColor: sessionColor,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
