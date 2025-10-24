import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/assessment_chart.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/stat_card.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

class MvcGripPositionStatContent extends StatefulWidget {
  final Map<GripPosition, List<AssessmentModel>> mvcByGripPosition;
  final Color accentLeft;
  final Color accentRight;
  final VoidCallback onStartAssessment;

  const MvcGripPositionStatContent({
    super.key,
    required this.mvcByGripPosition,
    required this.accentLeft,
    required this.accentRight,
    required this.onStartAssessment,
  });

  @override
  State<MvcGripPositionStatContent> createState() =>
      _MvcGripPositionStatContentState();
}

class _MvcGripPositionStatContentState
    extends State<MvcGripPositionStatContent> {
  GripPosition? _selectedGripPosition;

  @override
  void initState() {
    super.initState();
    // Select the first available grip position
    if (widget.mvcByGripPosition.isNotEmpty) {
      _selectedGripPosition = widget.mvcByGripPosition.keys.first;
    }
  }

  @override
  void didUpdateWidget(MvcGripPositionStatContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the selected grip position is no longer available, select the first available one
    if (_selectedGripPosition != null &&
        !widget.mvcByGripPosition.containsKey(_selectedGripPosition)) {
      if (widget.mvcByGripPosition.isNotEmpty) {
        _selectedGripPosition = widget.mvcByGripPosition.keys.first;
      } else {
        _selectedGripPosition = null;
      }
    }
    // If no grip position is selected but there are options, select the first one
    if (_selectedGripPosition == null && widget.mvcByGripPosition.isNotEmpty) {
      _selectedGripPosition = widget.mvcByGripPosition.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mvcByGripPosition.isEmpty) {
      // Empty state - no assessments yet
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Max Force",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard("Left Hand", "--", widget.accentLeft)),
              const SizedBox(width: 12),
              Expanded(child: StatCard("Right Hand", "--", widget.accentRight)),
            ],
          ),
          const SizedBox(height: 16),
          ForceChart(
            leftData: [],
            rightData: [],
            accentLeft: widget.accentLeft,
            accentRight: widget.accentRight,
            onStartAssessment: widget.onStartAssessment,
          ),
        ],
      );
    }

    final selectedAssessments =
        _selectedGripPosition != null
            ? widget.mvcByGripPosition[_selectedGripPosition]!
            : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with inline grip position selector
        Row(
          children: [
            Text(
              "Max Force",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.mvcByGripPosition.length > 1) ...[
              const SizedBox(width: 8),
              Text(
                "·",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CrimpyTheme.gray400,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showGripPositionPicker(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedGripPosition?.displayName ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: CrimpyTheme.gray400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: CrimpyTheme.gray400,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (widget.mvcByGripPosition.length == 1) ...[
              const SizedBox(width: 8),
              Text(
                "·",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CrimpyTheme.gray400,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedGripPosition?.displayName ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: CrimpyTheme.gray400),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                "Left Hand",
                selectedAssessments.map((a) => a.leftValue ?? 0).lastOrNull ==
                            null ||
                        selectedAssessments
                                .map((a) => a.leftValue ?? 0)
                                .lastOrNull ==
                            0
                    ? "--"
                    : formatAssessmentValue(
                      selectedAssessments
                              .map((a) => a.leftValue ?? 0)
                              .lastOrNull ??
                          0,
                      AssessmentUnit.kilograms,
                    ),
                widget.accentLeft,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                "Right Hand",
                selectedAssessments.map((a) => a.rightValue ?? 0).lastOrNull ==
                            null ||
                        selectedAssessments
                                .map((a) => a.rightValue ?? 0)
                                .lastOrNull ==
                            0
                    ? "--"
                    : formatAssessmentValue(
                      selectedAssessments
                              .map((a) => a.rightValue ?? 0)
                              .lastOrNull ??
                          0,
                      AssessmentUnit.kilograms,
                    ),
                widget.accentRight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ForceChart(
          leftData:
              selectedAssessments
                  .where((a) => a.leftValue != null)
                  .map<(DateTime, double)>((a) => (a.date, a.leftValue!))
                  .toList(),
          rightData:
              selectedAssessments
                  .where((a) => a.rightValue != null)
                  .map<(DateTime, double)>((a) => (a.date, a.rightValue!))
                  .toList(),
          accentLeft: widget.accentLeft,
          accentRight: widget.accentRight,
          onStartAssessment: widget.onStartAssessment,
        ),
      ],
    );
  }

  void _showGripPositionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                widget.mvcByGripPosition.keys.map((position) {
                  return ListTile(
                    title: Text(position.displayName),
                    selected: position == _selectedGripPosition,
                    onTap: () {
                      setState(() {
                        _selectedGripPosition = position;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
