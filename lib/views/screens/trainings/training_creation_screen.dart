import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/hangboard_config.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TrainingCreationMode { repeater, manual }

class UnifiedTrainingCreationScreen extends ConsumerStatefulWidget {
  final Training? originalTraining;
  final TrainingCreationMode? mode;

  const UnifiedTrainingCreationScreen({
    super.key,
    this.originalTraining,
    this.mode,
  });

  @override
  ConsumerState<UnifiedTrainingCreationScreen> createState() =>
      _UnifiedTrainingCreationScreenState();
}

class _UnifiedTrainingCreationScreenState
    extends ConsumerState<UnifiedTrainingCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late final TrainingCreationMode _mode;

  // Repeater mode state
  int _worktime = 7;
  int _rest = 3;
  int _cycleRest = 180;
  HangboardConfig _config = HangboardConfig.initial();
  bool _showPerRepDetail = false;

  /// Bumped whenever a reshape moves values between rows, so the fields showing
  /// those rows are rebuilt instead of keeping the text they were seeded with.
  int _configGeneration = 0;

  // Manual mode state: the item tree, groups and cycles holding their children.
  List<TrainingItem> _items = [];

  bool get _isEdit => widget.originalTraining != null;

  @override
  void initState() {
    super.initState();
    final original = widget.originalTraining;
    if (original != null) {
      _titleController.text = original.title;
      final hasRepeater = original.items.any(
        (i) => i.type == TrainingItemType.repeater,
      );
      _mode = hasRepeater
          ? TrainingCreationMode.repeater
          : TrainingCreationMode.manual;
      if (_mode == TrainingCreationMode.repeater) {
        final r = original.items.firstWhere(
          (i) => i.type == TrainingItemType.repeater,
        );
        _worktime = r.worktimeSeconds ?? 7;
        _rest = r.restSeconds ?? 3;
        _cycleRest = r.cycleRestSeconds ?? 180;
        _config = HangboardConfig.fromItem(r);
        _showPerRepDetail = _config.granularity != HangboardGranularity.uniform;
      } else {
        _items.addAll(original.items);
      }
    } else {
      _mode = widget.mode ?? TrainingCreationMode.manual;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  TrainingItem _buildRepeaterItem() {
    final existingId = _isEdit
        ? widget.originalTraining!.items
              .firstWhere(
                (i) => i.type == TrainingItemType.repeater,
                orElse: () => const TrainingItem(
                  id: '',
                  type: TrainingItemType.repeater,
                  position: 0,
                ),
              )
              .id
        : '';
    return _config.toItem(
      id: existingId,
      position: 0,
      worktimeSeconds: _worktime,
      restSeconds: _rest,
      cycleRestSeconds: _cycleRest,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    List<TrainingItem> items;
    if (_mode == TrainingCreationMode.repeater) {
      items = [_buildRepeaterItem()];
    } else {
      items = _positioned(_items);
    }

    final training = Training(
      id: widget.originalTraining?.id ?? '',
      title: _titleController.text.trim(),
      isFavorite: widget.originalTraining?.isFavorite ?? false,
      items: items,
    );

    // Empty containers hold no step, so a tree can be non empty and still have
    // nothing to run. Judging the training on what it expands to catches both.
    if (_mode == TrainingCreationMode.manual &&
        expandTrainingItems(training, useSensor: false).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to perform')),
      );
      return;
    }

    if (_isEdit) {
      await ref.read(trainingsProvider.notifier).updateTraining(training);
    } else {
      await ref.read(trainingsProvider.notifier).saveTraining(training);
    }

    if (mounted) Navigator.of(context).pop();
  }

  /// Numbers the whole tree, so a nested item carries its rank among its
  /// siblings rather than the one it had before the last move.
  List<TrainingItem> _positioned(List<TrainingItem> items) => items.indexed
      // copyWith keeps every field this editor does not expose (coach comments,
      // exercise names) instead of dropping them on save.
      .map((e) => e.$2.copyWith(position: e.$1, items: _positioned(e.$2.items)))
      .toList();

  /// Stable list identity: saved items have an id, new ones fall back to the
  /// object identity assigned when they were added.
  Object _keyFor(TrainingItem item) =>
      item.id.isEmpty ? identityHashCode(item) : item.id;

  /// Rewrites the children of the container at [path], the empty path standing
  /// for the top level. Items are immutable, so every container on the way down
  /// is rebuilt around its new list.
  List<TrainingItem> _rewrite(
    List<TrainingItem> items,
    List<int> path,
    List<TrainingItem> Function(List<TrainingItem>) transform,
  ) {
    if (path.isEmpty) return transform(items);
    final container = items[path.first];
    return [...items]
      ..[path.first] = container.copyWith(
        items: _rewrite(container.items, path.sublist(1), transform),
      );
  }

  void _mutate(
    List<int> path,
    List<TrainingItem> Function(List<TrainingItem>) transform,
  ) => setState(() => _items = _rewrite(_items, path, transform));

  void _addItem(List<int> path, TrainingItem item) =>
      _mutate(path, (children) => [...children, item]);

  void _removeItem(List<int> path, int index) =>
      _mutate(path, (children) => [...children]..removeAt(index));

  /// Everything a container holds, at any depth.
  static int _subtreeSize(TrainingItem item) => item.items.fold(
    item.items.length,
    (total, child) => total + _subtreeSize(child),
  );

  /// Deleting a container takes everything inside it with it, which is a lot to
  /// lose to one tap, so only an empty item goes without asking.
  Future<void> _confirmRemoveItem(
    List<int> path,
    int index,
    TrainingItem item,
  ) async {
    final size = _subtreeSize(item);
    if (size > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete ${trainingItemTitle(item)}?'),
          content: Text('The $size item(s) it holds are deleted with it.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    _removeItem(path, index);
  }

  void _duplicateItem(List<int> path, int index) => _mutate(
    path,
    (children) => [...children]..insert(index + 1, children[index].duplicate()),
  );

  void _reorderItems(List<int> path, int oldIndex, int newIndex) =>
      _mutate(path, (children) {
        final reordered = [...children];
        if (oldIndex < newIndex) newIndex--;
        reordered.insert(newIndex, reordered.removeAt(oldIndex));
        return reordered;
      });

  static TrainingItem _newHangboardRep() => const TrainingItem(
    id: '',
    type: TrainingItemType.hangboardRep,
    position: 0,
    worktimeSeconds: 7,
    restSeconds: 3,
    hand: HangboardHand.both,
    granularity: HangboardGranularity.uniform,
    loads: [Load(value: 0, unit: 'kg')],
    handPositions: [
      ['halfCrimp'],
    ],
  );

  /// A new container. Circuits start on the same numbers the coach portal uses,
  /// so one built here and one built there run the same way out of the box.
  static TrainingItem _newContainer(TrainingItemType type) => TrainingItem(
    id: '',
    type: type,
    position: 0,
    cycles: type == TrainingItemType.circuit ? 3 : null,
    cycleRestSeconds: type == TrainingItemType.circuit ? 120 : null,
    restSeconds: type == TrainingItemType.circuit ? 0 : null,
  );

  /// What can be added inside the container at [path]: a group holds circuits
  /// and reps, a circuit holds reps. Nesting a circuit in a circuit has nothing
  /// to say that a longer one does not, so it is left out.
  static List<TrainingItemType> _addableIn(TrainingItemType? container) =>
      switch (container) {
        TrainingItemType.circuit => const [TrainingItemType.hangboardRep],
        TrainingItemType.group => const [
          TrainingItemType.hangboardRep,
          TrainingItemType.circuit,
        ],
        _ => const [
          TrainingItemType.hangboardRep,
          TrainingItemType.circuit,
          TrainingItemType.group,
        ],
      };

  static bool _isContainer(TrainingItemType type) =>
      type == TrainingItemType.circuit || type == TrainingItemType.group;

  /// Only the types this editor can fully represent are editable here: a
  /// repeater, an exercise or a coach note carries fields it has no form for.
  static bool _isEditable(TrainingItemType type) =>
      _isContainer(type) || type == TrainingItemType.hangboardRep;

  /// The add sheet names a type exactly as the card it produces will, so the
  /// option and the item that appears read the same.
  static String _typeLabel(TrainingItemType type) => switch (type) {
    TrainingItemType.hangboardRep => 'Hang rep',
    TrainingItemType.circuit => 'Circuit',
    TrainingItemType.group => 'Group',
    _ => 'Item',
  };

  Future<void> _showAddSheet(
    List<int> path,
    TrainingItemType? container,
  ) async {
    final type = await showModalBottomSheet<TrainingItemType>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in _addableIn(container))
              ListTile(
                leading: Icon(switch (option) {
                  TrainingItemType.circuit => Icons.repeat,
                  TrainingItemType.group => Icons.folder_outlined,
                  _ => Icons.pan_tool,
                }),
                title: Text(_typeLabel(option)),
                subtitle: Text(switch (option) {
                  TrainingItemType.circuit =>
                    'Repeat a set of items several times',
                  TrainingItemType.group => 'Gather items under a title',
                  _ => 'A single hang',
                }),
                onTap: () => Navigator.pop(ctx, option),
              ),
          ],
        ),
      ),
    );
    if (type == null || !mounted) return;

    final created = await _showEditor(
      type == TrainingItemType.hangboardRep
          ? _newHangboardRep()
          : _newContainer(type),
    );
    if (created != null) _addItem(path, created);
  }

  Future<void> _editItem(List<int> path, int index, TrainingItem item) async {
    final edited = await _showEditor(item);
    if (edited != null) {
      _mutate(path, (children) => [...children]..[index] = edited);
    }
  }

  Future<TrainingItem?> _showEditor(TrainingItem item) =>
      showDialog<TrainingItem>(
        context: context,
        builder: (ctx) => _isContainer(item.type)
            ? _ContainerEditorDialog(item: item)
            : _ItemEditorDialog(item: item),
      );

  String get _appBarTitle {
    if (_isEdit) return 'Edit Training';
    return _mode == TrainingCreationMode.repeater
        ? 'New Repeater'
        : 'New Manual Training';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _mode == TrainingCreationMode.repeater
                  ? _buildRepeaterBody()
                  : _buildManualBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: _mode == TrainingCreationMode.manual
          ? FloatingActionButton(
              onPressed: () => _showAddSheet(const [], null),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRepeaterBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _countRow('Sets', _config.sets, (v) => _reshape(sets: v)),
        _countRow('Reps / set', _config.reps, (v) => _reshape(reps: v)),
        _intRow(
          'Work time (s)',
          _worktime,
          (v) => setState(() => _worktime = v),
        ),
        _intRow('Rest (s)', _rest, (v) => setState(() => _rest = v)),
        _intRow(
          'Set rest (s)',
          _cycleRest,
          (v) => setState(() => _cycleRest = v),
        ),
        const SizedBox(height: 8),
        _buildHandSelector(),
        const Divider(height: 24),
        // The simple case stays on one screen: a single edge, load and grip.
        // Everything that varies rep by rep lives behind the detail switch.
        if (_config.granularity == HangboardGranularity.uniform)
          _buildRowEditor(0, showLabel: false),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vary per rep'),
          subtitle: const Text('Set a different edge, load or grip per rep'),
          value: _showPerRepDetail,
          onChanged: _onDetailToggled,
        ),
        if (_showPerRepDetail) ..._buildDetailSection(),
      ],
    );
  }

  /// Reshaping moves values between rows, so the fields showing those rows have
  /// to be rebuilt from the new state. A TextFormField seeds its controller from
  /// initialValue once and never follows it, so the row editors are keyed on
  /// this counter and every reshape goes through here to bump it.
  void _reshape({int? sets, int? reps, String? granularity, String? hand}) {
    setState(() {
      _config.reshape(
        sets: sets,
        reps: reps,
        granularity: granularity,
        hand: hand,
      );
      _configGeneration++;
    });
  }

  void _onDetailToggled(bool enabled) {
    setState(() => _showPerRepDetail = enabled);
    _reshape(
      granularity: enabled
          ? HangboardGranularity.perRep
          : HangboardGranularity.uniform,
    );
  }

  Widget _buildHandSelector() {
    const modes = [
      (HangboardHand.both, 'Both', 'Both hands on the board at once'),
      (HangboardHand.alternate, 'Alternate', 'Right then left within each rep'),
      (HangboardHand.split, 'Split', 'A whole set on one hand, then the other'),
      (HangboardHand.left, 'Left', 'Left hand only'),
      (HangboardHand.right, 'Right', 'Right hand only'),
    ];
    final selected = modes.firstWhere(
      (m) => m.$1 == _config.hand,
      orElse: () => modes.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hands'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: modes
              .map(
                (m) => ChoiceChip(
                  label: Text(m.$2),
                  selected: _config.hand == m.$1,
                  onSelected: (_) => _reshape(hand: m.$1),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        Text(selected.$3, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  List<Widget> _buildDetailSection() {
    return [
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: HangboardGranularity.perRep,
            label: Text('Per rep'),
          ),
          ButtonSegment(
            value: HangboardGranularity.perSet,
            label: Text('Per set'),
          ),
        ],
        selected: {
          _config.granularity == HangboardGranularity.perSet
              ? HangboardGranularity.perSet
              : HangboardGranularity.perRep,
        },
        onSelectionChanged: (s) => _reshape(granularity: s.first),
      ),
      const SizedBox(height: 8),
      for (int row = 0; row < _config.rowCount; row++) _buildRowEditor(row),
    ];
  }

  Widget _buildRowEditor(int row, {bool showLabel = true}) {
    const grips = ['halfCrimp', 'threeFinger', 'fullCrimp', 'openHand'];
    final separate = _config.worksHandsSeparately;

    Widget gripField(String label, List<String> values) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<String>(
        initialValue: values[row],
        decoration: InputDecoration(labelText: label),
        items: grips
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) =>
            setState(() => values[row] = v ?? HangboardConfig.defaultGrip),
      ),
    );

    Widget loadField(String label, List<Load> values) => _doubleRow(
      label,
      values[row].value,
      (v) => setState(() => values[row] = Load(value: v, unit: 'kg')),
    );

    final fields = Column(
      children: [
        _intRow(
          'Edge (mm)',
          _config.edgeSizesMm[row],
          (v) => setState(() => _config.edgeSizesMm[row] = v),
        ),
        if (!separate) ...[
          loadField('Load (kg)', _config.loads),
          gripField('Grip', _config.grips),
        ] else ...[
          loadField('Load right (kg)', _config.loads),
          loadField('Load left (kg)', _config.leftLoads),
          gripField('Grip right', _config.grips),
          gripField('Grip left', _config.leftGrips),
        ],
      ],
    );

    if (!showLabel) return KeyedSubtree(key: _rowKey(row), child: fields);

    return Card(
      key: _rowKey(row),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _config.labelOf(row),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (row < _config.rowCount - 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, size: 20),
                    tooltip: 'Copy to the rows below',
                    onPressed: () => setState(() {
                      _config.fillDown(row);
                      _configGeneration++;
                    }),
                  ),
              ],
            ),
            fields,
          ],
        ),
      ),
    );
  }

  Widget _buildManualBody() {
    if (_items.isEmpty) {
      return const Center(
        child: Text('Tap + to add reps, circuits and groups'),
      );
    }
    return _buildItemList(_items, const []);
  }

  /// The children of one container, or the top level for an empty path. Each
  /// level reorders on its own, so a rep is dragged among its siblings and a
  /// cycle among the items around it.
  Widget _buildItemList(List<TrainingItem> items, List<int> path) {
    final isNested = path.isNotEmpty;
    return ReorderableListView.builder(
      shrinkWrap: isNested,
      physics: isNested ? const NeverScrollableScrollPhysics() : null,
      // Dragging starts from the handle only, so the inner lists stay usable
      // and a tap on a card reaches its buttons.
      buildDefaultDragHandles: false,
      padding: isNested
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      onReorder: (oldIdx, newIdx) => _reorderItems(path, oldIdx, newIdx),
      itemBuilder: (ctx, i) {
        final item = items[i];
        final childPath = [...path, i];
        return _TrainingItemCard(
          // Identity must survive a reorder, so key by the item, not its index.
          key: ValueKey(_keyFor(item)),
          index: i,
          item: item,
          onEdit: _isEditable(item.type)
              ? () => _editItem(path, i, item)
              : null,
          onDuplicate: () => _duplicateItem(path, i),
          onDelete: () => _confirmRemoveItem(path, i, item),
          // A drag cannot scroll the list it is nested in, so a long container
          // stays reorderable through the menu.
          onMoveUp: i > 0 ? () => _reorderItems(path, i, i - 1) : null,
          onMoveDown: i < items.length - 1
              ? () => _reorderItems(path, i, i + 2)
              : null,
          nested: _isContainer(item.type)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.items.isNotEmpty)
                      _buildItemList(item.items, childPath),
                    TextButton.icon(
                      onPressed: () => _showAddSheet(childPath, item.type),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add item'),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Key _rowKey(int row) => ValueKey('hangboard-row-$row-$_configGeneration');

  /// A count field resizes the configuration grid, and a number input holds
  /// intermediate values while being retyped: going from 6 to 12 passes through
  /// 1, and resampling there would collapse every row into one and lose what
  /// the user typed. These commit on blur or on Enter instead.
  Widget _countRow(String label, int value, void Function(int) onCommit) {
    return _CountField(
      key: ValueKey('hangboard-count-$label-$_configGeneration'),
      label: label,
      value: value,
      onCommit: onCommit,
    );
  }

  Widget _intRow(String label, int value, void Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null && n > 0) onChanged(n);
        },
      ),
    );
  }

  Widget _doubleRow(
    String label,
    double value,
    void Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) {
          final n = double.tryParse(v);
          if (n != null && n >= 0) onChanged(n);
        },
      ),
    );
  }
}

enum _ItemAction { edit, duplicate, moveUp, moveDown, delete }

/// One item of the manual editor. A group or a circuit also renders its own
/// children in [nested], so the tree is read at a glance.
class _TrainingItemCard extends StatelessWidget {
  final TrainingItem item;
  final int index;
  final VoidCallback? onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final Widget? nested;

  const _TrainingItemCard({
    required super.key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
    this.nested,
  });

  /// The stored hand value is a wire code, so the card shows the label the
  /// editor uses rather than printing the raw value.
  static String _handLabel(String? hand) =>
      switch (hand ?? HangboardHand.both) {
        HangboardHand.alternate => 'alternating hands',
        HangboardHand.split => 'split hands',
        HangboardHand.left => 'left hand',
        HangboardHand.right => 'right hand',
        _ => 'both hands',
      };

  String get _subtitle => switch (item.type) {
    TrainingItemType.hangboardRep || TrainingItemType.repeater =>
      '${item.worktimeSeconds ?? 7}s hang / ${item.restSeconds ?? 3}s rest  '
          '${_handLabel(item.hand)}',
    TrainingItemType.circuit => trainingItemDetail(item),
    TrainingItemType.group => '${item.items.length} item(s)',
    TrainingItemType.exercise =>
      item.effectiveReps() != null
          ? '${item.effectiveReps()} reps'
          : '${item.effectiveDuration() ?? 0}s',
    TrainingItemType.free => '',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(trainingItemTitle(item)),
            // The numbers a circuit carries take more than one line on a phone,
            // and they are the point of the card, so they are not cut short.
            subtitle: Text(
              _subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // The actions live in a menu rather than in a row of buttons, which
            // at phone width left the title and its numbers no room.
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<_ItemAction>(
                  tooltip: 'Actions',
                  onSelected: (action) {
                    switch (action) {
                      case _ItemAction.edit:
                        onEdit?.call();
                      case _ItemAction.duplicate:
                        onDuplicate();
                      case _ItemAction.moveUp:
                        onMoveUp?.call();
                      case _ItemAction.moveDown:
                        onMoveDown?.call();
                      case _ItemAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: _ItemAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                        ),
                      ),
                    const PopupMenuItem(
                      value: _ItemAction.duplicate,
                      child: ListTile(
                        leading: Icon(Icons.copy),
                        title: Text('Duplicate'),
                      ),
                    ),
                    if (onMoveUp != null)
                      const PopupMenuItem(
                        value: _ItemAction.moveUp,
                        child: ListTile(
                          leading: Icon(Icons.arrow_upward),
                          title: Text('Move up'),
                        ),
                      ),
                    if (onMoveDown != null)
                      const PopupMenuItem(
                        value: _ItemAction.moveDown,
                        child: ListTile(
                          leading: Icon(Icons.arrow_downward),
                          title: Text('Move down'),
                        ),
                      ),
                    const PopupMenuItem(
                      value: _ItemAction.delete,
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              ],
            ),
          ),
          if (nested != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: nested,
            ),
        ],
      ),
    );
  }
}

/// A whole-number field of an editor dialog. It keeps its text rather than
/// reporting each keystroke, so a value cleared to be retyped is never lost and
/// what the field shows is what the dialog saves. [min] is 0 for the rests,
/// which a user is allowed to switch off entirely.
Widget _intField(
  String label,
  TextEditingController controller, {
  int min = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        final n = int.tryParse((v ?? '').trim());
        if (n == null) return 'Enter a number';
        return n < min ? 'Minimum $min' : null;
      },
    ),
  );
}

/// The decimal counterpart of [_intField], for the loads.
Widget _doubleField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        final n = double.tryParse((v ?? '').trim());
        if (n == null) return 'Enter a number';
        return n < 0 ? 'Cannot be negative' : null;
      },
    ),
  );
}

/// Editor of a group or a circuit. Both carry an optional title; a circuit also
/// carries how many times it runs and the rests it inserts.
class _ContainerEditorDialog extends StatefulWidget {
  final TrainingItem item;
  const _ContainerEditorDialog({required this.item});

  @override
  State<_ContainerEditorDialog> createState() => _ContainerEditorDialogState();
}

class _ContainerEditorDialogState extends State<_ContainerEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _cyclesController;
  late final TextEditingController _cycleRestController;
  late final TextEditingController _itemRestController;

  bool get _isCircuit => widget.item.type == TrainingItemType.circuit;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _titleController = TextEditingController(text: item.groupTitle ?? '');
    _cyclesController = TextEditingController(
      text: (item.cycles ?? 3).toString(),
    );
    _cycleRestController = TextEditingController(
      text: (item.cycleRestSeconds ?? 120).toString(),
    );
    _itemRestController = TextEditingController(
      text: (item.restSeconds ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cyclesController.dispose();
    _cycleRestController.dispose();
    _itemRestController.dispose();
    super.dispose();
  }

  TrainingItem _buildItem() => widget.item.copyWith(
    groupTitle: _titleController.text,
    cycles: _isCircuit ? int.parse(_cyclesController.text.trim()) : null,
    cycleRestSeconds: _isCircuit
        ? int.parse(_cycleRestController.text.trim())
        : null,
    restSeconds: _isCircuit ? int.parse(_itemRestController.text.trim()) : null,
  );

  /// The fields are only read once they validate, so the parses above cannot
  /// throw and OK never saves a number the dialog is not showing.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _buildItem());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isCircuit ? 'Circuit' : 'Group'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                ),
              ),
              if (_isCircuit) ...[
                _intField('Cycles', _cyclesController),
                _intField(
                  'Rest between items (s)',
                  _itemRestController,
                  min: 0,
                ),
                _intField(
                  'Rest between cycles (s)',
                  _cycleRestController,
                  min: 0,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }
}

class _ItemEditorDialog extends StatefulWidget {
  final TrainingItem item;
  const _ItemEditorDialog({required this.item});

  @override
  State<_ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<_ItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _worktimeController;
  late final TextEditingController _restController;
  late final TextEditingController _loadController;
  late String _hand;
  late bool _loadIsMax;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _worktimeController = TextEditingController(
      text: (item.worktimeSeconds ?? 7).toString(),
    );
    _restController = TextEditingController(
      text: (item.restSeconds ?? 3).toString(),
    );
    _loadController = TextEditingController(
      text: (item.loads?.firstOrNull?.value ?? 0.0).toString(),
    );
    _hand = item.hand ?? HangboardHand.both;
    _loadIsMax = item.loadIsMax;
  }

  @override
  void dispose() {
    _worktimeController.dispose();
    _restController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  TrainingItem _buildItem() {
    // A max load has no number to read, so the hidden field is not parsed.
    final load = _loadIsMax ? 0.0 : double.parse(_loadController.text.trim());
    return widget.item.copyWith(
      worktimeSeconds: int.parse(_worktimeController.text.trim()),
      restSeconds: int.parse(_restController.text.trim()),
      hand: _hand,
      loads: [Load(value: load, unit: _loadIsMax ? 'max' : 'kg')],
      loadIsMax: _loadIsMax,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _buildItem());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hang rep'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(child: _buildForm()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _intField('Work time (s)', _worktimeController),
        _intField('Rest (s)', _restController, min: 0),
        DropdownButtonFormField<String>(
          initialValue: _hand,
          decoration: const InputDecoration(labelText: 'Hand'),
          // A single hang is one hand or both together: the modes that order
          // the two hands across reps only mean something on a repeater.
          items: const [
            DropdownMenuItem(
              value: HangboardHand.both,
              child: Text('Both hands'),
            ),
            DropdownMenuItem(value: HangboardHand.left, child: Text('Left')),
            DropdownMenuItem(value: HangboardHand.right, child: Text('Right')),
          ],
          onChanged: (v) => setState(() => _hand = v ?? HangboardHand.both),
        ),
        SwitchListTile(
          title: const Text('As hard as possible'),
          value: _loadIsMax,
          onChanged: (v) => setState(() => _loadIsMax = v),
        ),
        if (!_loadIsMax) _doubleField('Load (kg)', _loadController),
      ],
    );
  }
}

/// A whole-number field that resizes the configuration grid. It commits on blur
/// or on Enter rather than on every keystroke, so retyping a count never passes
/// through an intermediate value that would resample the rows.
class _CountField extends StatefulWidget {
  const _CountField({
    super.key,
    required this.label,
    required this.value,
    required this.onCommit,
  });

  final String label;
  final int value;
  final void Function(int) onCommit;

  @override
  State<_CountField> createState() => _CountFieldState();
}

class _CountFieldState extends State<_CountField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value.toString(),
  );
  late final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text);
    final committed = (parsed == null || parsed < 1) ? widget.value : parsed;
    if (_controller.text != committed.toString()) {
      _controller.text = committed.toString();
    }
    if (committed != widget.value) widget.onCommit(committed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(labelText: widget.label),
        keyboardType: TextInputType.number,
        onEditingComplete: _commit,
      ),
    );
  }
}
