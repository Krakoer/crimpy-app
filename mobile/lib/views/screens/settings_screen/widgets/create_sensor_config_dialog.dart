import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePresetDialog extends ConsumerStatefulWidget {
  final Function onSave;

  /// Dialog to allow the user to save a sensor config.
  const CreatePresetDialog({super.key, required this.onSave});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreatePresetDialogState();
}

class _CreatePresetDialogState extends ConsumerState<CreatePresetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Save a calibration preset"),
      actions: [
        TextButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_targetController.text);
              Navigator.of(context).pop();
            }
          },
          label: Text("Add"),
          icon: Icon(Icons.add),
        ),
      ],
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _targetController,
          decoration: const InputDecoration(
            hintText: 'Ground pull',
            labelText: 'Preset name',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return "Name cannot be empty";
            }
            return null;
          },
        ),
      ),
    );
  }
}
