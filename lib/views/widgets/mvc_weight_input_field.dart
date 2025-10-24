import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// A reusable weight input field that allows users to enter weight manually
/// or base it on a percentage of their MVC score.
class MvcWeightInputField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final HandSide handSide;
  final String label;
  final bool enabled;
  final bool compactLayout;

  const MvcWeightInputField({
    super.key,
    required this.controller,
    required this.handSide,
    this.validator,
    this.label = 'Weight',
    this.enabled = true,
    this.compactLayout = false,
  });

  @override
  ConsumerState<MvcWeightInputField> createState() =>
      _MvcWeightInputFieldState();
}

class _MvcWeightInputFieldState extends ConsumerState<MvcWeightInputField> {
  bool _showMvcOptions = false;

  @override
  Widget build(BuildContext context) {
    // Watch the MVC assessments for the specific hand
    final mvcAssessmentsAsync = ref.watch(
      assessmentsProvider(AssessmentType.mvc),
    );

    return mvcAssessmentsAsync.when(
      data: (assessments) {
        // Get the last MVC value for the specific hand
        double? mvcValue;
        if (assessments.isNotEmpty) {
          final lastAssessment = assessments.last;
          mvcValue =
              widget.handSide.isRightHand
                  ? lastAssessment.rightValue
                  : lastAssessment.leftValue;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.compactLayout)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          enabled: widget.enabled,
                          keyboardType: TextInputType.number,
                          controller: widget.controller,
                          decoration: InputDecoration(
                            hintText: 'e.g., 10.5',
                            suffixText: 'kg',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          validator: widget.validator,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      enabled: widget.enabled,
                      keyboardType: TextInputType.number,
                      controller: widget.controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CrimpyTheme.borderDefault,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CrimpyTheme.borderDefault,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CrimpyTheme.primaryOrange,
                            width: 2,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CrimpyTheme.borderDefault.withValues(
                              alpha: 0.5,
                            ),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: widget.validator,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'kg',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            // Show MVC-based options if MVC value is available
            if (mvcValue != null && mvcValue > 0) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _showMvcOptions = !_showMvcOptions;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _showMvcOptions ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: CrimpyTheme.primaryOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showMvcOptions
                          ? 'Hide MVC options'
                          : 'Set based on MVC (${mvcValue.toStringAsFixed(1)} kg)',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: CrimpyTheme.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showMvcOptions) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [50, 60, 70, 80, 90].map((percentage) {
                        final calculatedWeight = (mvcValue! * percentage / 100);
                        return OutlinedButton(
                          onPressed: () {
                            widget.controller.text = calculatedWeight
                                .toStringAsFixed(1);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            side: BorderSide(
                              color: CrimpyTheme.primaryOrange,
                              width: 1.5,
                            ),
                            foregroundColor: CrimpyTheme.primaryOrange,
                          ),
                          child: Text(
                            '$percentage% (${calculatedWeight.toStringAsFixed(1)} kg)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ],
        );
      },
      loading: () => _buildLoadingField(),
      error: (_, __) => _buildErrorField(),
    );
  }

  Widget _buildLoadingField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            controller: widget.controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CrimpyTheme.borderDefault,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CrimpyTheme.borderDefault,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CrimpyTheme.primaryOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: widget.validator,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'kg',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorField() {
    // On error, just show the basic input field
    return _buildLoadingField();
  }
}
