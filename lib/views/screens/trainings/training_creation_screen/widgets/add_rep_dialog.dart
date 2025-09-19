import 'dart:math' as math;

import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class RepFormDialog extends StatefulWidget {
  final Function(RepModel) onAddRep;
  final RepModel? initialRep;

  const RepFormDialog({super.key, required this.onAddRep, this.initialRep});

  @override
  RepFormDialogState createState() => RepFormDialogState();
}

class RepFormDialogState extends State<RepFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isRest = false;
  late HandSide _handSide = HandSide.left;

  @override
  void initState() {
    super.initState();
    // If editing an existing rep, load its values
    if (widget.initialRep != null) {
      _durationController.text =
          widget.initialRep!.durationInSeconds.toString();
      _weightController.text = widget.initialRep!.targetWeight.toString();
      _isRest = widget.initialRep!.isRest;
      _handSide = widget.initialRep!.handSide;
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialRep == null ? 'Add New Rep' : 'Edit Rep'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds)',
                  hintText: 'e.g., 30',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                enabled: !_isRest,
                decoration: const InputDecoration(
                  labelText: 'Target Weight (kg)',
                  hintText: 'e.g., 10.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the target weight';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Please enter a valid non-negative number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Rest Period?'),
                value: _isRest,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _weightController.text = "0";
                    }
                    _isRest = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Hand: '),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentedButton<bool>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: CrimpyTheme.gray200,
                      ),
                      segments: [
                        ButtonSegment<bool>(
                          enabled: !_isRest,
                          value: false,
                          label: Text('Left'),
                          icon: Transform(
                            transform: Matrix4.rotationY(math.pi),
                            alignment: Alignment.center,
                            child: Icon(FontAwesomeIcons.hand),
                          ),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          enabled: !_isRest,
                          label: Text('Right'),
                          icon: Icon(FontAwesomeIcons.hand),
                        ),
                      ],
                      selected: {_handSide.isRightHand},
                      onSelectionChanged: (Set<bool> selected) {
                        setState(() {
                          _handSide =
                              selected.first ? HandSide.right : HandSide.left;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final rep = RepModel(
                durationInSeconds: int.parse(_durationController.text),
                isRest: _isRest,
                handSide: _handSide,
                targetWeight:
                    _isRest ? 0 : double.parse(_weightController.text),
                index: -1,
              );
              widget.onAddRep(rep);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.initialRep == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
