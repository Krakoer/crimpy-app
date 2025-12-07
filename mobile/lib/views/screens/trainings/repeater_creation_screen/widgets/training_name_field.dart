import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingNameField extends StatelessWidget {
  final TextEditingController controller;

  const TrainingNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: controller,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Training Name',
        labelStyle: TextStyle(
          fontSize: 16,
          color: CrimpyTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CrimpyTheme.primaryOrange, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a training name';
        }
        return null;
      },
    );
  }
}
