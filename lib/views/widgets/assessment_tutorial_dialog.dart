import 'package:flutter/material.dart';
import 'package:crimpy/models/tutorial_content.dart';
import 'package:crimpy/services/tutorial_service.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// Reusable tutorial dialog for assessments.
/// Shows important information before starting an assessment.
class AssessmentTutorialDialog extends StatefulWidget {
  final TutorialContent content;
  final String tutorialId;
  final bool showDontShowAgain;

  const AssessmentTutorialDialog({
    required this.content,
    required this.tutorialId,
    this.showDontShowAgain = true,
    super.key,
  });

  @override
  State<AssessmentTutorialDialog> createState() =>
      _AssessmentTutorialDialogState();
}

class _AssessmentTutorialDialogState extends State<AssessmentTutorialDialog> {
  bool _dontShowAgain = false;
  final TutorialService _tutorialService = TutorialService();
  int _currentSectionIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextSection() {
    if (_currentSectionIndex < widget.content.sections.length - 1) {
      _pageController.animateToPage(
        _currentSectionIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousSection() {
    if (_currentSectionIndex > 0) {
      _pageController.animateToPage(
        _currentSectionIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _isFirstSection => _currentSectionIndex == 0;
  bool get _isLastSection =>
      _currentSectionIndex == widget.content.sections.length - 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              decoration: BoxDecoration(
                color: CrimpyTheme.assessmentColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                      color: CrimpyTheme.textSecondary,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Close',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: CrimpyTheme.assessmentColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.content.assessmentName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.content.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CrimpyTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // PageView with horizontally scrollable sections
            Flexible(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentSectionIndex = index;
                  });
                },
                itemCount: widget.content.sections.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TutorialSectionWidget(
                          section: widget.content.sections[index],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicator (dots)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.content.sections.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentSectionIndex
                          ? CrimpyTheme.assessmentColor
                          : CrimpyTheme.textMuted.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

            // Footer with navigation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgSecondary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // "Don't show again" checkbox (only on last section)
                  if (_isLastSection && widget.showDontShowAgain)
                    CheckboxListTile(
                      value: _dontShowAgain,
                      onChanged: (value) {
                        setState(() {
                          _dontShowAgain = value ?? false;
                        });
                      },
                      title: Text(
                        "Don't show this again",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  if (_isLastSection && widget.showDontShowAgain)
                    const SizedBox(height: 4),

                  // Navigation buttons
                  Row(
                    children: [
                      // Back button
                      if (!_isFirstSection)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _previousSection,
                            icon: const Icon(Icons.arrow_back, size: 20),
                            label: const Text('Back'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: CrimpyTheme.textMuted,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      if (!_isFirstSection) const SizedBox(width: 12),

                      // Next/Got it button
                      Expanded(
                        flex: _isFirstSection ? 1 : 2,
                        child: ElevatedButton.icon(
                          onPressed: _isLastSection
                              ? () async {
                                  if (_dontShowAgain) {
                                    await _tutorialService.markTutorialAsSeen(
                                      widget.tutorialId,
                                    );
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              : _nextSection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CrimpyTheme.assessmentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            _isLastSection ? Icons.check : Icons.arrow_forward,
                            size: 20,
                          ),
                          label: Text(
                            _isLastSection ? 'Got it!' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a single tutorial section.
class _TutorialSectionWidget extends StatelessWidget {
  final TutorialSection section;

  const _TutorialSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (section.iconColor ?? CrimpyTheme.assessmentColor)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            section.icon,
            color: section.iconColor ?? CrimpyTheme.assessmentColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                section.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CrimpyTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Helper function to show tutorial dialog and handle auto-show logic.
/// Returns true if the user wants to proceed, false otherwise.
Future<bool> showTutorialIfNeeded({
  required BuildContext context,
  required TutorialContent content,
  required String tutorialId,
  bool forceShow = false,
}) async {
  final tutorialService = TutorialService();

  if (forceShow || !await tutorialService.hasSeenTutorial(tutorialId)) {
    if (context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AssessmentTutorialDialog(
          content: content,
          tutorialId: tutorialId,
          showDontShowAgain: !forceShow,
        ),
      );
      // Return true only if user explicitly clicked "Got it!", false otherwise
      return result == true;
    }
  }
  // If tutorial was already seen or context not mounted, proceed
  return true;
}
