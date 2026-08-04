import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';
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
  int _cycles = 3;
  int _reps = 6;
  int _worktime = 7;
  int _rest = 3;
  int _cycleRest = 180;
  bool _splitHand = false;
  double _loadRight = 0;
  double _loadLeft = 0;
  String _grip = 'halfCrimp';

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
        _cycles = r.cycles ?? 3;
        _reps = r.reps ?? 6;
        _worktime = r.worktimeSeconds ?? 7;
        _rest = r.restSeconds ?? 3;
        _cycleRest = r.cycleRestSeconds ?? 180;
        _splitHand = r.hand == 'split';
        _loadRight = r.loads?.firstOrNull?.value ?? 0;
        _loadLeft = r.leftLoads?.firstOrNull?.value ?? 0;
        _grip = r.handPositions?.firstOrNull ?? 'halfCrimp';
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
    final hand = _splitHand ? 'split' : 'both';
    return TrainingItem(
      id: existingId,
      type: TrainingItemType.repeater,
      position: 0,
      cycles: _cycles,
      reps: _reps,
      worktimeSeconds: _worktime,
      restSeconds: _rest,
      cycleRestSeconds: _cycleRest,
      hand: hand,
      loads: List.filled(_reps, Load(value: _loadRight, unit: 'kg')),
      leftLoads: _splitHand
          ? List.filled(_reps, Load(value: _loadLeft, unit: 'kg'))
          : null,
      handPositions: List.filled(_reps, _grip),
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
      hand: 'both',
      loads: [const Load(value: 0, unit: 'kg')],
      handPositions: ['halfCrimp'],
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
    const grips = ['halfCrimp', 'threeFinger', 'fullCrimp', 'openHand'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _intRow('Sets', _cycles, (v) => setState(() => _cycles = v)),
        _intRow('Reps / set', _reps, (v) => setState(() => _reps = v)),
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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Split hand'),
          subtitle: const Text('Alternate R/L sets'),
          value: _splitHand,
          onChanged: (v) => setState(() => _splitHand = v),
        ),
        _doubleRow(
          _splitHand ? 'Load right (kg)' : 'Load (kg)',
          _loadRight,
          (v) => setState(() => _loadRight = v),
        ),
        if (_splitHand)
          _doubleRow(
            'Load left (kg)',
            _loadLeft,
            (v) => setState(() => _loadLeft = v),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: DropdownButtonFormField<String>(
            initialValue: _grip,
            decoration: const InputDecoration(labelText: 'Grip'),
            items: grips
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => _grip = v ?? 'halfCrimp'),
          ),
        ),
      ],
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
          '${item.hand ?? 'both'} hand',
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
    _hand = item.hand ?? 'both';
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
          items: const [
            DropdownMenuItem(value: 'both', child: Text('Both')),
            DropdownMenuItem(value: 'left', child: Text('Left')),
            DropdownMenuItem(value: 'right', child: Text('Right')),
          ],
          onChanged: (v) => setState(() => _hand = v ?? 'both'),
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
          if (n != null) onChanged(n);
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
          if (n != null) onChanged(n);
        },
      ),
    );
  }
}
