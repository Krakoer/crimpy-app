import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class DateFilterBanner extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onClearFilter;

  const DateFilterBanner({
    super.key,
    required this.selectedDate,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceLg,
        vertical: CrimpyTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: CrimpyTheme.current.withValues(alpha: 0.1),
        border: const Border(
          bottom: BorderSide(color: CrimpyTheme.current, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: CrimpyTheme.textOn(CrimpyTheme.current),
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Expanded(
            child: Text(
              'Showing: ${DateFormat('EEEE, MMMM d, y').format(selectedDate)}',
              style: CrimpyTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: CrimpyTheme.textOn(CrimpyTheme.current),
              ),
            ),
          ),
          TextButton(
            onPressed: onClearFilter,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: CrimpyTheme.spaceSm,
                vertical: CrimpyTheme.spaceXs,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Show All', style: CrimpyTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
