import 'package:flutter/material.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/sets_view_widget.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/rep_item_widget.dart';

/// How many reps a block shows before it has to be expanded. A block broken
/// into sets keeps all of them: the sets are the structure the athlete saw.
const int _repsPreview = 5;
const int _repsPreviewThreshold = 10;

class SessionRepsCard extends StatefulWidget {
  final SessionModel session;
  final Color sessionColor;

  /// The blocks the reps were played from, null for a session that names none,
  /// which falls back to the flat list. Resolved by the screen so this card and
  /// the performance stats above it read the same run.
  final List<RepBlock>? blocks;

  /// Whether one ratio stated for this whole session would pool across those
  /// blocks. Each block carries its own ratio regardless.
  final bool poolsBlocks;

  const SessionRepsCard({
    super.key,
    required this.session,
    required this.sessionColor,
    required this.blocks,
    required this.poolsBlocks,
  });

  @override
  State<SessionRepsCard> createState() => _SessionRepsCardState();
}

class _SessionRepsCardState extends State<SessionRepsCard> {
  bool _repsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final reps = widget.session.reps!;
    final blocks = widget.blocks;

    // One ratio over blocks graded against different targets says nothing about
    // which of them was missed, so a session that played more than one is read
    // through the ratio each block carries instead. A run the training never
    // gave a target counts none, which is why the ratio is left out there.
    final overall = widget.poolsBlocks ? null : onTargetCount(reps);

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
              if (overall != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: overall.onTarget == overall.total
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: overall.onTarget == overall.total
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${overall.onTarget}/${overall.total}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: overall.onTarget == overall.total
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
    final count = onTargetCount(block.reps);
    if (count == null) return null;
    final unmeasured = unmeasuredNote(count);
    return '${count.onTarget}/${count.total} on target'
        '${unmeasured == null ? '' : ' ($unmeasured)'}';
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
