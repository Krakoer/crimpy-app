import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/training_name_field.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/repeater_parameters_section.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/weight_configuration_section.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen/widgets/split_hand_toggle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class RepeaterCreationScreen extends ConsumerStatefulWidget {
  final Training? originalTemplate;

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
  GripPosition _gripPosition = GripPosition.halfCrimp;

  @override
  void initState() {
    if (widget.originalTemplate != null) {
      _isEdit = true;
      _trainingNameController.text = widget.originalTemplate!.title;
      // Load repeater params from the first repeater item if available
      final repeaterItem = widget.originalTemplate!.items
          .where((i) => i.type.apiValue == 'repeater')
          .firstOrNull;
      if (repeaterItem != null) {
        _setNumberController.text = (repeaterItem.cycles ?? 3).toString();
        _repsNumberController.text = (repeaterItem.reps ?? 10).toString();
        worktime = Duration(seconds: repeaterItem.worktimeSeconds ?? 7);
        rest = Duration(seconds: repeaterItem.restSeconds ?? 3);
        setRest = Duration(seconds: repeaterItem.cycleRestSeconds ?? 480);
        _splitHand = repeaterItem.hand == 'split';
        final loads = repeaterItem.loads;
        final leftLoads = repeaterItem.leftLoads;
        if (loads != null && loads.isNotEmpty) {
          _rightHandWeightController.text = loads.first.value.toString();
        }
        if (leftLoads != null && leftLoads.isNotEmpty) {
          _leftHandWeightController.text = leftLoads.first.value.toString();
        }
      }
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
        gripPosition: _gripPosition,
      );

      final loadsPerRep = List.filled(
        repeaterModel.repsBySet,
        Load(value: repeaterModel.weightRight ?? 0, unit: 'kg'),
      );
      final leftLoads = repeaterModel.splitHand
          ? List.filled(
              repeaterModel.repsBySet,
              Load(value: repeaterModel.weightLeft ?? 0, unit: 'kg'),
            )
          : null;
      final positions = List.filled(
        repeaterModel.repsBySet,
        repeaterModel.gripPosition.name,
      );
      final training = Training(
        id: widget.originalTemplate?.id ?? '',
        title: _trainingNameController.text,
        isFavorite: widget.originalTemplate?.isFavorite ?? false,
        items: [
          TrainingItem(
            id: '',
            type: TrainingItemType.repeater,
            position: 0,
            cycles: repeaterModel.sets,
            reps: repeaterModel.repsBySet,
            worktimeSeconds: repeaterModel.workTime,
            restSeconds: repeaterModel.restTime,
            cycleRestSeconds: repeaterModel.restBteweenSets,
            hand: repeaterModel.splitHand ? 'split' : 'both',
            loads: loadsPerRep,
            leftLoads: leftLoads,
            handPositions: positions,
          ),
        ],
      );
      if (_isEdit) {
        ref.read(trainingsProvider.notifier).updateTraining(training).then((v) {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        ref.read(trainingsProvider.notifier).saveTraining(training).then((v) {
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
      builder: (BuildContext context) => Container(
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

  void _showSplitHandExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: CrimpyTheme.primaryOrange),
              const SizedBox(width: 8),
              Text('Split Hand Mode'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Non-Split Hand Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: CrimpyTheme.gray700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Each rep is performed with both hands: right hand, then left hand.',
                  style: TextStyle(color: CrimpyTheme.gray700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CrimpyTheme.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example: 2 sets, 2 reps/set',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: CrimpyTheme.gray700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rep 1:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CrimpyTheme.gray600,
                        ),
                      ),
                      _buildExampleStep(Icons.front_hand, 'Right hand', '7s'),
                      _buildExampleStep(Icons.pause, 'Rest', '3s'),
                      _buildExampleStep(Icons.back_hand, 'Left hand', '7s'),
                      _buildExampleStep(Icons.pause, 'Rest', '3s'),
                      Text(
                        'Rep 2:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CrimpyTheme.gray600,
                        ),
                      ),
                      _buildExampleStep(Icons.front_hand, 'Right hand', '7s'),
                      _buildExampleStep(Icons.pause, 'Rest', '3s'),
                      _buildExampleStep(Icons.back_hand, 'Left hand', '7s'),
                      _buildExampleStep(Icons.bedtime, 'Set rest', '1min'),
                      Text(
                        '... repeat for set 2',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: CrimpyTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Split Hand Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: CrimpyTheme.gray700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete all reps for one hand, then switch to the other hand.',
                  style: TextStyle(color: CrimpyTheme.gray700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CrimpyTheme.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example: 2 sets, 2 reps/set',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: CrimpyTheme.gray700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildExampleStep(Icons.front_hand, 'Right hand', '7s'),
                      _buildExampleStep(Icons.pause, 'Rest', '3s'),
                      _buildExampleStep(Icons.front_hand, 'Right hand', '7s'),
                      _buildExampleStep(Icons.swap_horiz, 'Hand switch', '~3s'),
                      _buildExampleStep(Icons.back_hand, 'Left hand', '7s'),
                      _buildExampleStep(Icons.pause, 'Rest', '3s'),
                      _buildExampleStep(Icons.back_hand, 'Left hand', '7s'),
                      _buildExampleStep(Icons.bedtime, 'Set rest', '1min'),
                      Text(
                        '... repeat for set 2',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: CrimpyTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExampleStep(IconData icon, String label, String duration) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: CrimpyTheme.gray600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: CrimpyTheme.gray700),
          ),
          const Spacer(),
          Text(
            duration,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CrimpyTheme.gray700,
            ),
          ),
        ],
      ),
    );
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
                  onWorktimeChanged: (newDur) => setState(() {
                    worktime = newDur;
                  }),
                  onRestChanged: (newDur) => setState(() {
                    rest = newDur;
                  }),
                  onSetRestChanged: (newDur) => setState(() {
                    setRest = newDur;
                  }),
                  showDurationPicker: _showDurationPicker,
                ),
                const SizedBox(height: 20),
                // Weight configuration
                WeightConfigurationSection(
                  rightHandWeightController: _rightHandWeightController,
                  leftHandWeightController: _leftHandWeightController,
                  weightValidator: _weightValidator,
                ),
                const SizedBox(height: 20),
                // Split hand toggle
                Row(
                  children: [
                    Expanded(
                      child: SplitHandToggle(
                        value: _splitHand,
                        onChanged: (newVal) => setState(() {
                          _splitHand = newVal;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.help_outline,
                        color: CrimpyTheme.gray600,
                      ),
                      onPressed: () => _showSplitHandExplanation(context),
                      tooltip: 'What is Split Hand mode?',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Grip position selector
                Container(
                  decoration: BoxDecoration(
                    color: CrimpyTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grip Position',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<GripPosition>(
                        initialValue: _gripPosition,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: GripPosition.values.map((position) {
                          return DropdownMenuItem(
                            value: position,
                            child: Text(position.displayName),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _gripPosition = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
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
