import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/training_name_field.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/repeater_parameters_section.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/weight_configuration_section.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/split_hand_toggle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

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
  Duration worktime = const Duration(seconds: 7);
  Duration rest = const Duration(seconds: 3);
  Duration setRest = const Duration(minutes: 8);
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
  void _showDurationPicker(
    BuildContext context,
    Function(Duration) onChange,
    Duration initDur,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
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
      backgroundColor: CrimpyTheme.bgPrimary,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Training' : 'Create Training'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Training name
                TrainingNameField(controller: _trainingNameController),
                const SizedBox(height: 20),
                // Workout parameters
                RepeaterParametersSection(
                  setNumberController: _setNumberController,
                  repsNumberController: _repsNumberController,
                  worktime: worktime,
                  rest: rest,
                  setRest: setRest,
                  onWorktimeChanged:
                      (newDur) => setState(() {
                        worktime = newDur;
                      }),
                  onRestChanged:
                      (newDur) => setState(() {
                        rest = newDur;
                      }),
                  onSetRestChanged:
                      (newDur) => setState(() {
                        setRest = newDur;
                      }),
                  showDurationPicker: _showDurationPicker,
                ),
                const SizedBox(height: 20),
                // Weight configuration
                WeightConfigurationSection(
                  splitHand: _splitHand,
                  rightHandWeightController: _rightHandWeightController,
                  leftHandWeightController: _leftHandWeightController,
                  weightValidator: _weightValidator,
                ),
                const SizedBox(height: 20),
                // Split hand toggle
                SplitHandToggle(
                  value: _splitHand,
                  onChanged:
                      (newVal) => setState(() {
                        _splitHand = newVal;
                      }),
                ),
                const SizedBox(height: 32),
                // Save button
                ElevatedButton(
                  onPressed: _saveTraining,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: CrimpyTheme.primaryOrange,
                    foregroundColor: CrimpyTheme.primaryWhite,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'SAVE TRAINING',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: CrimpyTheme.primaryWhite,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
