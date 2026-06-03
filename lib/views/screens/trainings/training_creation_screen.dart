import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unified screen for creating and editing trainings.
/// Supports repeater, hangboard_rep, and free item types.
class UnifiedTrainingCreationScreen extends ConsumerStatefulWidget {
  final Training? originalTraining;

  const UnifiedTrainingCreationScreen({super.key, this.originalTraining});

  @override
  ConsumerState<UnifiedTrainingCreationScreen> createState() =>
      _UnifiedTrainingCreationScreenState();
}

class _UnifiedTrainingCreationScreenState
    extends ConsumerState<UnifiedTrainingCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<TrainingItem> _items = [];
  bool get _isEdit => widget.originalTraining != null;

  @override
  void initState() {
    super.initState();
    if (widget.originalTraining != null) {
      _titleController.text = widget.originalTraining!.title;
      _items.addAll(widget.originalTraining!.items);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddItemSheet() {
    showModalBottomSheet<TrainingItemType>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repeater'),
              subtitle: const Text('Sets x reps of timed hangs'),
              onTap: () => Navigator.pop(ctx, TrainingItemType.repeater),
            ),
            ListTile(
              leading: const Icon(Icons.pan_tool),
              title: const Text('Hangboard Rep'),
              subtitle: const Text('Single timed hang'),
              onTap: () => Navigator.pop(ctx, TrainingItemType.hangboardRep),
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Free Note'),
              subtitle: const Text('Text note with optional duration'),
              onTap: () => Navigator.pop(ctx, TrainingItemType.free),
            ),
          ],
        ),
      ),
    ).then((type) {
      if (type != null) _addItem(type);
    });
  }

  void _addItem(TrainingItemType type) {
    final defaults = switch (type) {
      TrainingItemType.repeater => TrainingItem(
        id: '',
        type: type,
        position: _items.length,
        cycles: 3,
        reps: 6,
        worktimeSeconds: 7,
        restSeconds: 3,
        cycleRestSeconds: 180,
        hand: 'both',
        loads: [const Load(value: 0, unit: 'kg')],
        handPositions: ['halfCrimp'],
      ),
      TrainingItemType.hangboardRep => TrainingItem(
        id: '',
        type: type,
        position: _items.length,
        worktimeSeconds: 7,
        restSeconds: 3,
        hand: 'both',
        loads: [const Load(value: 0, unit: 'kg')],
        handPositions: ['halfCrimp'],
      ),
      _ => TrainingItem(
        id: '',
        type: type,
        position: _items.length,
        freeText: '',
      ),
    };
    _showItemEditor(defaults, isNew: true);
  }

  void _showItemEditor(TrainingItem item, {bool isNew = false}) {
    showDialog<TrainingItem>(
      context: context,
      builder: (ctx) => _ItemEditorDialog(item: item),
    ).then((edited) {
      if (edited != null) {
        setState(() {
          if (isNew) {
            _items.add(edited);
          } else {
            final idx = _items.indexWhere((i) => i.position == item.position);
            if (idx >= 0) _items[idx] = edited;
          }
        });
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    final training = Training(
      id: widget.originalTraining?.id ?? '',
      title: _titleController.text.trim(),
      isFavorite: widget.originalTraining?.isFavorite ?? false,
      items: _items.indexed
          .map(
            (e) => TrainingItem(
              id: e.$2.id,
              type: e.$2.type,
              position: e.$1,
              parentId: e.$2.parentId,
              cycles: e.$2.cycles,
              cycleRestSeconds: e.$2.cycleRestSeconds,
              reps: e.$2.reps,
              duration: e.$2.duration,
              restSeconds: e.$2.restSeconds,
              worktimeSeconds: e.$2.worktimeSeconds,
              hand: e.$2.hand,
              loads: e.$2.loads,
              leftLoads: e.$2.leftLoads,
              handPositions: e.$2.handPositions,
              edgeSizesMm: e.$2.edgeSizesMm,
              loadIsMax: e.$2.loadIsMax,
              freeText: e.$2.freeText,
              exerciseId: e.$2.exerciseId,
              sectionTitle: e.$2.sectionTitle,
            ),
          )
          .toList(),
    );

    if (_isEdit) {
      await ref.read(trainingsProvider.notifier).updateTraining(training);
    } else {
      await ref.read(trainingsProvider.notifier).saveTraining(training);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Training' : 'New Training'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Tap + to add items'))
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          key: ValueKey(i),
                          item: item,
                          onEdit: () => _showItemEditor(item),
                          onDelete: () => setState(() => _items.removeAt(i)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TrainingItemCard extends StatelessWidget {
  final TrainingItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TrainingItemCard({
    required super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  String get _subtitle => switch (item.type) {
    TrainingItemType.repeater =>
      '${item.cycles ?? 1} sets x ${item.reps ?? 1} reps, '
          '${item.worktimeSeconds ?? 7}s on / ${item.restSeconds ?? 3}s off',
    TrainingItemType.hangboardRep =>
      '${item.worktimeSeconds ?? 7}s hang, ${item.restSeconds ?? 3}s rest, '
          '${item.hand ?? 'both'} hand',
    TrainingItemType.free => item.freeText ?? '',
    _ => item.type.apiValue,
  };

  String get _typeLabel => switch (item.type) {
    TrainingItemType.repeater => 'Repeater',
    TrainingItemType.hangboardRep => 'Hang Rep',
    TrainingItemType.free => 'Free',
    _ => item.type.apiValue,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(_typeLabel),
        subtitle: Text(_subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
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

/// Dialog for editing a single training item.
class _ItemEditorDialog extends StatefulWidget {
  final TrainingItem item;
  const _ItemEditorDialog({required this.item});

  @override
  State<_ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<_ItemEditorDialog> {
  late int _cycles;
  late int _reps;
  late int _worktime;
  late int _rest;
  late int _cycleRest;
  late String _hand;
  late double _loadRight;
  late double _loadLeft;
  late bool _splitHand;
  late bool _loadIsMax;
  late String _freeText;
  late int? _duration;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _cycles = item.cycles ?? 3;
    _reps = item.reps ?? 6;
    _worktime = item.worktimeSeconds ?? 7;
    _rest = item.restSeconds ?? 3;
    _cycleRest = item.cycleRestSeconds ?? 180;
    _hand = item.hand ?? 'both';
    _splitHand = _hand == 'split';
    _loadRight = item.loads?.firstOrNull?.value ?? 0.0;
    _loadLeft = item.leftLoads?.firstOrNull?.value ?? 0.0;
    _loadIsMax = item.loadIsMax;
    _freeText = item.freeText ?? '';
    _duration = item.duration;
  }

  TrainingItem _buildItem() {
    final item = widget.item;
    switch (item.type) {
      case TrainingItemType.repeater:
        final hand = _splitHand ? 'split' : _hand;
        final loadsPerRep = List.filled(
          _reps,
          Load(value: _loadRight, unit: 'kg'),
        );
        final leftLoads = _splitHand
            ? List.filled(_reps, Load(value: _loadLeft, unit: 'kg'))
            : null;
        return TrainingItem(
          id: item.id,
          type: item.type,
          position: item.position,
          cycles: _cycles,
          reps: _reps,
          worktimeSeconds: _worktime,
          restSeconds: _rest,
          cycleRestSeconds: _cycleRest,
          hand: hand,
          loads: loadsPerRep,
          leftLoads: leftLoads,
          handPositions: List.filled(
            _reps,
            item.handPositions?.firstOrNull ?? 'halfCrimp',
          ),
        );
      case TrainingItemType.hangboardRep:
        return TrainingItem(
          id: item.id,
          type: item.type,
          position: item.position,
          worktimeSeconds: _worktime,
          restSeconds: _rest,
          hand: _hand,
          loads: [Load(value: _loadRight, unit: _loadIsMax ? 'max' : 'kg')],
          loadIsMax: _loadIsMax,
          handPositions: [item.handPositions?.firstOrNull ?? 'halfCrimp'],
        );
      default:
        return TrainingItem(
          id: item.id,
          type: item.type,
          position: item.position,
          freeText: _freeText,
          duration: _duration,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.item.type.apiValue}'),
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
    return switch (widget.item.type) {
      TrainingItemType.repeater => _repeaterForm(),
      TrainingItemType.hangboardRep => _hangboardRepForm(),
      _ => _freeForm(),
    };
  }

  Widget _repeaterForm() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _intField('Sets', _cycles, (v) => setState(() => _cycles = v)),
      _intField('Reps / set', _reps, (v) => setState(() => _reps = v)),
      _intField(
        'Work time (s)',
        _worktime,
        (v) => setState(() => _worktime = v),
      ),
      _intField('Rest (s)', _rest, (v) => setState(() => _rest = v)),
      _intField(
        'Set rest (s)',
        _cycleRest,
        (v) => setState(() => _cycleRest = v),
      ),
      SwitchListTile(
        title: const Text('Split hand'),
        subtitle: const Text('Alternate R/L sets'),
        value: _splitHand,
        onChanged: (v) => setState(() {
          _splitHand = v;
          _hand = v ? 'split' : 'both';
        }),
      ),
      _doubleField(
        _splitHand ? 'Load right (kg)' : 'Load (kg)',
        _loadRight,
        (v) => setState(() => _loadRight = v),
      ),
      if (_splitHand)
        _doubleField(
          'Load left (kg)',
          _loadLeft,
          (v) => setState(() => _loadLeft = v),
        ),
    ],
  );

  Widget _hangboardRepForm() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _intField(
        'Work time (s)',
        _worktime,
        (v) => setState(() => _worktime = v),
      ),
      _intField('Rest (s)', _rest, (v) => setState(() => _rest = v)),
      DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: _hand,
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

  Widget _freeForm() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        initialValue: _freeText,
        decoration: const InputDecoration(labelText: 'Text'),
        onChanged: (v) => _freeText = v,
      ),
      _intField(
        'Duration (s, optional)',
        _duration ?? 0,
        (v) => setState(() => _duration = v > 0 ? v : null),
      ),
    ],
  );

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
