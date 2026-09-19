import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Writes one activity of one day, as a sheet rather than inline fields.
///
/// A day holds as many activities as the athlete wants, each with four fields.
/// Laid out inline that is a wall of text boxes the moment a day holds two, so
/// the day card stays a readable list and the writing happens here.
///
/// Pops with the activity, or with null when the athlete backs out. Deleting
/// is the day card's job: this sheet never answers "remove me".
class ActivityEditorSheet extends StatefulWidget {
  /// The activity being changed, or null when a new one is being added.
  final DayActivity? activity;

  /// The day it belongs to, spelled out, so the sheet says what it is editing.
  final String dayLabel;

  const ActivityEditorSheet({super.key, this.activity, required this.dayLabel});

  /// Opens the sheet over [context] and answers what the athlete wrote.
  static Future<DayActivity?> show(
    BuildContext context, {
    DayActivity? activity,
    required String dayLabel,
  }) => showModalBottomSheet<DayActivity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CrimpyTheme.bgPrimary,
    builder: (ctx) =>
        ActivityEditorSheet(activity: activity, dayLabel: dayLabel),
  );

  @override
  State<ActivityEditorSheet> createState() => _ActivityEditorSheetState();
}

class _ActivityEditorSheetState extends State<ActivityEditorSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _durationController;
  late final TextEditingController _whenController;
  late final TextEditingController _whereController;
  bool _labelMissing = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.activity?.label);
    _durationController = TextEditingController(
      text: widget.activity?.durationMinutes?.toString(),
    );
    _whenController = TextEditingController(text: widget.activity?.when);
    _whereController = TextEditingController(text: widget.activity?.where);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _durationController.dispose();
    _whenController.dispose();
    _whereController.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _save() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      // The API refuses a blank label, and an activity with no name says
      // nothing to a coach either.
      setState(() => _labelMissing = true);
      return;
    }
    final minutes = int.tryParse(_durationController.text.trim());
    Navigator.of(context).pop(
      DayActivity(
        label: label,
        durationMinutes: minutes != null && minutes > 0 ? minutes : null,
        when: _optional(_whenController),
        where: _optional(_whereController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The sheet is as tall as the keyboard leaves it, so the field being
      // typed into is never under the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: CrimpyTheme.borderDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.activity == null
                    ? 'Add to ${widget.dayLabel}'
                    : 'Edit ${widget.dayLabel}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CrimpyTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Say what you are doing. Everything but the name is optional.',
                style: TextStyle(
                  fontSize: 12,
                  color: CrimpyTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _labelController,
                autofocus: widget.activity == null,
                textCapitalization: TextCapitalization.sentences,
                maxLength: maxActivityTextLength,
                buildCounter: _noCounter,
                onChanged: (_) {
                  if (_labelMissing) setState(() => _labelMissing = false);
                },
                decoration: InputDecoration(
                  labelText: 'What',
                  hintText: 'bouldering session',
                  errorText: _labelMissing ? 'This one needs a name' : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'How long',
                  suffixText: 'min',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _whenController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: maxActivityTextLength,
                buildCounter: _noCounter,
                decoration: const InputDecoration(
                  labelText: 'When',
                  hintText: 'after work',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _whereController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: maxActivityTextLength,
                buildCounter: _noCounter,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'Where',
                  hintText: 'the gym',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: Text(widget.activity == null ? 'Add' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The length cap is there to keep the field inside what the API accepts, not
/// to put a running count under every box.
Widget? _noCounter(
  BuildContext context, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) => null;
