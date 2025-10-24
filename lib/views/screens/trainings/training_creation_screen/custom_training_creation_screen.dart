import 'package:crimpy/views/screens/trainings/training_creation_screen/widgets/add_rep_dialog.dart';
import 'package:crimpy/views/screens/trainings/training_creation_screen/widgets/rep_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

class TrainingCreationScreen extends ConsumerStatefulWidget {
  final TrainingWithReps? originalTraining;

  /// Screen to create a custom training.
  /// Set the `originalTraining` to edit a training.
  const TrainingCreationScreen({super.key, this.originalTraining});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TrainingCreationScreenState();
}

class _TrainingCreationScreenState
    extends ConsumerState<TrainingCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trainingNameController = TextEditingController();
  List<RepModel> _reps = [];
  bool _isEdit = false;

  @override
  void initState() {
    // Set the values in the form if we edit a training.
    if (widget.originalTraining != null) {
      _reps = widget.originalTraining!.reps;
      _trainingNameController.text = widget.originalTraining!.name;
      _isEdit = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    _trainingNameController.dispose();
    super.dispose();
  }

  /// Show the dialog to add or edit a rep.
  /// To edit a rep, pass the index as argument.
  void _addOrEditRep({int? index}) {
    showDialog(
      context: context,
      builder:
          (context) => RepFormDialog(
            initialRep: index == null ? null : _reps[index],
            onAddRep: (rep) {
              setState(() {
                if (index == null) {
                  _reps.add(rep);
                } else {
                  _reps[index] = rep;
                }
              });
            },
          ),
    );
  }

  /// Delete a rep from the list
  void _deleteRep(int index) {
    setState(() {
      _reps.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rep deleted')));
  }

  /// Reorder a rep in the list
  void _reorderRep(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final RepModel item = _reps.removeAt(oldIndex);
      _reps.insert(newIndex, item);
    });
  }

  /// Save the new training into DB.
  void _saveTraining() async {
    if (_formKey.currentState!.validate()) {
      if (_reps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one rep')),
        );
        return;
      }

      if (_isEdit) {
        ref
            .read(trainingsProvider.notifier)
            .editTraining(
              widget.originalTraining!.id,
              newName: _trainingNameController.text,
              newReps: _reps,
            )
            .then((v) {
              if (mounted) Navigator.of(context).pop();
            });
      } else {
        ref
            .read(trainingsProvider.notifier)
            .saveTraining(_trainingNameController.text, _reps)
            .then((v) {
              if (mounted) Navigator.of(context).pop();
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Training' : 'Create New Training',
          style: Theme.of(
            context,
          ).appBarTheme.titleTextStyle!.copyWith(fontSize: 27),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Training name field
              TextFormField(
                controller: _trainingNameController,
                decoration: const InputDecoration(
                  labelText: 'Training Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a training name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reps section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reps',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addOrEditRep,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Rep'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reps list
              Expanded(
                child:
                    _reps.isEmpty
                        ? const Center(
                          child: Text(
                            'No reps added yet. Tap "Add Rep" to create one.',
                          ),
                        )
                        : ReorderableListView.builder(
                          itemCount: _reps.length,
                          onReorder: _reorderRep,
                          itemBuilder: (context, index) {
                            final rep = _reps[index];
                            return RepListItem(
                              key: ValueKey(index),
                              rep: rep,
                              index: index,
                              onEdit: () => _addOrEditRep(index: index),
                              onDelete: () => _deleteRep(index),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: _saveTraining,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Save Training'),
        ),
      ],
    );
  }
}
