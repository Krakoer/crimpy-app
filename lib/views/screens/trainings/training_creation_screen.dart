import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/hangboard_config.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
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

  // Manual mode state
  final List<TrainingItem> _items = [];

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
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one hang rep')),
        );
        return;
      }
      // copyWith keeps every field this editor does not expose (nested items,
      // coach comments, exercise names) instead of dropping them on save.
      items = _items.indexed.map((e) => e.$2.copyWith(position: e.$1)).toList();
    }

    final training = Training(
      id: widget.originalTraining?.id ?? '',
      title: _titleController.text.trim(),
      isFavorite: widget.originalTraining?.isFavorite ?? false,
      items: items,
    );

    if (_isEdit) {
      await ref.read(trainingsProvider.notifier).updateTraining(training);
    } else {
      await ref.read(trainingsProvider.notifier).saveTraining(training);
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _addHangboardRep() {
    final defaults = TrainingItem(
      id: '',
      type: TrainingItemType.hangboardRep,
      position: _items.length,
      worktimeSeconds: 7,
      restSeconds: 3,
      hand: HangboardHand.both,
      granularity: HangboardGranularity.uniform,
      loads: [const Load(value: 0, unit: 'kg')],
      handPositions: const [
        ['halfCrimp'],
      ],
    );
    showDialog<TrainingItem>(
      context: context,
      builder: (ctx) => _ItemEditorDialog(item: defaults),
    ).then((edited) {
      if (edited != null) setState(() => _items.add(edited));
    });
  }

  /// Stable list identity: saved items have an id, new ones fall back to the
  /// object identity assigned when they were added.
  Object _keyFor(TrainingItem item) =>
      item.id.isEmpty ? identityHashCode(item) : item.id;

  void _editItem(int index) {
    showDialog<TrainingItem>(
      context: context,
      builder: (ctx) => _ItemEditorDialog(item: _items[index]),
    ).then((edited) {
      if (edited != null) setState(() => _items[index] = edited);
    });
  }

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
              onPressed: _addHangboardRep,
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
      return const Center(child: Text('Tap + to add hangboard reps'));
    }
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _items.length,
      onReorder: (oldIdx, newIdx) {
        setState(() {
          if (oldIdx < newIdx) newIdx--;
          final item = _items.removeAt(oldIdx);
          _items.insert(newIdx, item);
        });
      },
      itemBuilder: (ctx, i) {
        final item = _items[i];
        return _TrainingItemCard(
          // Identity must survive a reorder, so key by the item, not its index.
          key: ValueKey(_keyFor(item)),
          item: item,
          // Only hangboard reps are editable here; other item types carry
          // fields this editor cannot represent.
          onEdit: item.type == TrainingItemType.hangboardRep
              ? () => _editItem(i)
              : null,
          onDelete: () => setState(() => _items.removeAt(i)),
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

class _TrainingItemCard extends StatelessWidget {
  final TrainingItem item;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _TrainingItemCard({
    required super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
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

  String get _title => switch (item.type) {
    TrainingItemType.hangboardRep => 'Hang Rep',
    TrainingItemType.repeater => 'Repeater',
    TrainingItemType.circuit => 'Circuit',
    TrainingItemType.group => item.groupTitle ?? 'Group',
    TrainingItemType.exercise => item.exerciseName ?? 'Exercise',
    TrainingItemType.free => item.freeText ?? 'Note',
  };

  String get _subtitle => switch (item.type) {
    TrainingItemType.hangboardRep || TrainingItemType.repeater =>
      '${item.worktimeSeconds ?? 7}s hang / ${item.restSeconds ?? 3}s rest  '
          '${_handLabel(item.hand)}',
    TrainingItemType.circuit ||
    TrainingItemType.group => '${item.items.length} item(s)',
    TrainingItemType.exercise =>
      item.effectiveReps != null
          ? '${item.effectiveReps} reps'
          : '${item.effectiveDuration ?? 0}s',
    TrainingItemType.free => '',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(_title),
        subtitle: Text(_subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
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
  late int _worktime;
  late int _rest;
  late String _hand;
  late double _loadRight;
  late bool _loadIsMax;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _worktime = item.worktimeSeconds ?? 7;
    _rest = item.restSeconds ?? 3;
    _hand = item.hand ?? HangboardHand.both;
    _loadRight = item.loads?.firstOrNull?.value ?? 0.0;
    _loadIsMax = item.loadIsMax;
  }

  TrainingItem _buildItem() {
    return widget.item.copyWith(
      worktimeSeconds: _worktime,
      restSeconds: _rest,
      hand: _hand,
      loads: [Load(value: _loadRight, unit: _loadIsMax ? 'max' : 'kg')],
      loadIsMax: _loadIsMax,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hang Rep'),
      content: SingleChildScrollView(child: _buildForm()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _buildItem()),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _intField(
          'Work time (s)',
          _worktime,
          (v) => setState(() => _worktime = v),
        ),
        _intField('Rest (s)', _rest, (v) => setState(() => _rest = v)),
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
        if (!_loadIsMax)
          _doubleField(
            'Load (kg)',
            _loadRight,
            (v) => setState(() => _loadRight = v),
          ),
      ],
    );
  }

  Widget _intField(String label, int value, void Function(int) onChanged) {
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

  Widget _doubleField(
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
