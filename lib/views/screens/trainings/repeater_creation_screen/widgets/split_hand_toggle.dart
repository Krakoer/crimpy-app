import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class SplitHandToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SplitHandToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              value
                  ? CrimpyTheme.primaryOrange.withValues(alpha: 0.1)
                  : CrimpyTheme.bgSecondary,
          border: Border.all(
            color:
                value ? CrimpyTheme.primaryOrange : CrimpyTheme.borderDefault,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    value ? CrimpyTheme.primaryOrange : CrimpyTheme.bgPrimary,
                border: Border.all(
                  color:
                      value
                          ? CrimpyTheme.primaryOrange
                          : CrimpyTheme.borderDefault,
                  width: 2,
                ),
              ),
              child:
                  value
                      ? Icon(
                        Icons.check,
                        size: 16,
                        color: CrimpyTheme.primaryWhite,
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Text(
              'Split hand mode',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    value
                        ? CrimpyTheme.primaryOrange
                        : CrimpyTheme.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
