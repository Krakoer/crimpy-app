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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CrimpyTheme.primaryOrange.withValues(alpha: 0.1),
        border: const Border(
          bottom: BorderSide(color: CrimpyTheme.primaryOrange, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: 16,
            color: CrimpyTheme.primaryOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing: ${DateFormat('EEEE, MMMM d, y').format(selectedDate)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CrimpyTheme.primaryOrange,
              ),
            ),
          ),
          TextButton(
            onPressed: onClearFilter,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Show All', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
