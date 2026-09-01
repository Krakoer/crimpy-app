import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One day of the declared week. The duration only appears once the day is on,
/// but the note never hides: "travelling" is worth telling a coach about a day
/// the athlete cannot train, and the coach reads it beside the week either way.
class DayAvailabilityRow extends StatefulWidget {
  final String label;
  final DayAvailability day;
  final bool enabled;
  final ValueChanged<DayAvailability> onChanged;

  const DayAvailabilityRow({
    super.key,
    required this.label,
    required this.day,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<DayAvailabilityRow> createState() => _DayAvailabilityRowState();
}

class _DayAvailabilityRowState extends State<DayAvailabilityRow> {
  late final TextEditingController _durationController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(
      text: widget.day.durationMinutes?.toString() ?? '',
    );
    _noteController = TextEditingController(text: widget.day.note ?? '');
  }

  @override
  void dispose() {
    _durationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setAvailable(bool value) {
    widget.onChanged(widget.day.copyWith(isAvailable: value));
  }

  void _setDuration(String raw) {
    final minutes = int.tryParse(raw.trim());
    widget.onChanged(
      minutes == null || minutes <= 0
          ? widget.day.copyWith(clearDuration: true)
          : widget.day.copyWith(durationMinutes: minutes),
    );
  }

  void _setNote(String raw) {
    final note = raw.trim();
    widget.onChanged(
      note.isEmpty
          ? widget.day.copyWith(clearNote: true)
          : widget.day.copyWith(note: note),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: widget.day.isAvailable,
                onChanged: widget.enabled ? _setAvailable : null,
              ),
            ],
          ),
          if (widget.day.isAvailable)
            SizedBox(
              width: 120,
              child: TextField(
                controller: _durationController,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'How long',
                  suffixText: 'min',
                  isDense: true,
                ),
                onChanged: _setDuration,
              ),
            ),
          TextField(
            controller: _noteController,
            enabled: widget.enabled,
            maxLines: 2,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Anything worth saying',
              hintText: widget.day.isAvailable
                  ? 'gym after work, no fingerboard'
                  : 'travelling',
              isDense: true,
            ),
            onChanged: _setNote,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
