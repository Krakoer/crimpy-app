import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

class RepeaterCreationScreen extends ConsumerStatefulWidget {
  final TrainingWithReps? originalTemplate;

  /// Screen where the user can create a repeater training.
  /// To edit a training, fill the `originalTemplate` argument.
  const RepeaterCreationScreen({super.key, this.originalTemplate});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RepeaterCreationScreenState();
}

class _RepeaterCreationScreenState
    extends ConsumerState<RepeaterCreationScreen> {
  bool _isEdit = false;
  final _formKey = GlobalKey<FormState>();
  final _trainingNameController = TextEditingController();
  final _setNumberController = TextEditingController(text: "3");
  final _repsNumberController = TextEditingController(text: "10");
  final _rightHandWeightController = TextEditingController(text: "10");
  final _leftHandWeightController = TextEditingController(text: "10");
  Duration worktime = Duration(seconds: 7);
  Duration rest = Duration(seconds: 3);
  Duration setRest = Duration(minutes: 8);
  bool _splitHand = false;

  @override
  void initState() {
    if (widget.originalTemplate != null) {
      _isEdit = true;
      _trainingNameController.text = widget.originalTemplate!.name;
      _setNumberController.text =
          widget.originalTemplate!.repeater!.sets.toString();
      _repsNumberController.text =
          widget.originalTemplate!.repeater!.repsBySet.toString();
      _trainingNameController.text = widget.originalTemplate!.name;
      rest = Duration(seconds: widget.originalTemplate!.repeater!.restTime);
      worktime = Duration(seconds: widget.originalTemplate!.repeater!.workTime);
      setRest = Duration(
        seconds: widget.originalTemplate!.repeater!.restBteweenSets,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _trainingNameController.dispose();
    _setNumberController.dispose();
    _repsNumberController.dispose();
    _leftHandWeightController.dispose();
    _rightHandWeightController.dispose();
    super.dispose();
  }

  void _saveTraining() async {
    if (_formKey.currentState!.validate()) {
      if (worktime.inSeconds == 0 ||
          rest.inSeconds == 0 ||
          setRest.inSeconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Null durations are not allowed.')),
        );
        return;
      }

      var repeaterModel = RepeaterModel(
        sets: int.parse(_setNumberController.text),
        restBteweenSets: setRest.inSeconds,
        repsBySet: int.parse(_repsNumberController.text),
        workTime: worktime.inSeconds,
        restTime: rest.inSeconds,
        splitHand: _splitHand,
        weightRight: double.parse(_rightHandWeightController.text),
        weightLeft: double.parse(_leftHandWeightController.text),
      );

      if (_isEdit) {
        ref
            .read(trainingsProvider.notifier)
            .editRepeaterTraining(
              widget.originalTemplate!.id,
              newName: _trainingNameController.text,
              model: repeaterModel,
            )
            .then((v) {
              if (mounted) Navigator.of(context).pop();
            });
      } else {
        ref
            .read(trainingsProvider.notifier)
            .saveRepeaterTraining(_trainingNameController.text, repeaterModel)
            .then((v) {
              if (mounted) Navigator.of(context).pop();
            });
      }
    }
  }

  /// Show a duration picker.
  void _showDurationPicker(Function(Duration) onChange, Duration initDur) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            // The bottom margin is provided to align the popup above the system
            // navigation bar.
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // Provide a background color for the popup.
            color: CupertinoColors.systemBackground.resolveFrom(context),
            // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(
              top: false,
              child: CupertinoTimerPicker(
                onTimerDurationChanged: onChange,
                mode: CupertinoTimerPickerMode.ms,
                initialTimerDuration: initDur,
              ),
            ),
          ),
    );
  }

  String? _weightValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the target weight';
    }
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Please enter a valid non-negative number';
    }
    return null;
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Training name field
                TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
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
                // Big text to ask the user how many sets, reps, etc.
                Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      // Sets input
                      child: TextFormField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        keyboardType: TextInputType.number,
                        controller: _setNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of sets';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid non-negative number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Text("set(s) of "),
                    // Reps input
                    SizedBox(
                      width: 40,
                      child: TextFormField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        keyboardType: TextInputType.number,
                        controller: _repsNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of reps';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid non-negative number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Text("rep(s), with a work time of "),
                    // Workout duration picker
                    TextButton(
                      onPressed:
                          () => _showDurationPicker(
                            (newDur) => setState(() {
                              worktime = newDur;
                            }),
                            worktime,
                          ),
                      child: Text(formatDurationMinSec(worktime)),
                    ),
                    Text("and a rest time of "),
                    // Rest duration picker
                    TextButton(
                      onPressed:
                          () => _showDurationPicker(
                            (newDur) => setState(() {
                              rest = newDur;
                            }),
                            rest,
                          ),
                      child: Text(formatDurationMinSec(rest)),
                    ),
                    Text(", with a "),
                    // Set rest duration picker
                    TextButton(
                      onPressed:
                          () => _showDurationPicker(
                            (newDur) => setState(() {
                              setRest = newDur;
                            }),
                            setRest,
                          ),
                      child: Text(formatDurationMinSec(setRest)),
                    ),
                    Text("break between sets."),
                  ],
                ),
                const SizedBox(height: 16),
                // Form to chose the target weight.
                if (!_splitHand)
                  Row(
                    children: [
                      Text("Target weight: "),
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          keyboardType: TextInputType.number,
                          validator: _weightValidator,
                          controller: _rightHandWeightController,
                        ),
                      ),
                      Text("kg"),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Text("Right hand target weight: "),
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          keyboardType: TextInputType.number,
                          validator: _weightValidator,

                          controller: _rightHandWeightController,
                        ),
                      ),
                      Text("kg"),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Left hand target weight: "),
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          keyboardType: TextInputType.number,
                          validator: _weightValidator,

                          controller: _leftHandWeightController,
                        ),
                      ),
                      Text("kg"),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _splitHand,
                      onChanged:
                          (newVal) => setState(() {
                            _splitHand = newVal!;
                          }),
                    ),
                    Text("Enable split hand mode"),
                  ],
                ),
              ],
            ),
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
