import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/tutorial_content.dart';
import 'package:crimpy/services/tutorial_service.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// Provides tutorial content for different assessment types.
class AssessmentTutorials {
  /// Get tutorial content for MVC assessment based on grip position.
  static TutorialContent getMvcTutorial(GripPosition gripPosition) {
    return TutorialContent(
      assessmentName: 'MVC Assessment',
      subtitle: '${gripPosition.displayName} - Maximum Voluntary Contraction',
      sections: [
        const TutorialSection(
          icon: Icons.info_outline,
          title: 'What is this test?',
          content:
              'The MVC (Maximum Voluntary Contraction) test measures your maximum force production. You\'ll perform brief maximal efforts with each hand.',
        ),
        const TutorialSection(
          icon: Icons.fitness_center,
          title: 'Warm-up Required',
          content:
              'Make sure you are properly warmed up before starting! Perform light hangs and gradually increase intensity to prepare your fingers.',
          iconColor: CrimpyTheme.accentYellowText,
        ),
        TutorialSection(
          icon: Icons.pan_tool,
          title: 'Grip Position',
          content:
              'You will be using the ${gripPosition.displayName} grip. Maintain good form throughout each test.',
        ),
        const TutorialSection(
          icon: Icons.timer,
          title: 'Protocol',
          content:
              'You\'ll perform 3 maximal efforts per hand (5 seconds each) with rest periods in between. Give maximum effort on each attempt!',
        ),
        const TutorialSection(
          icon: Icons.trending_up,
          title: 'Tips for Success',
          content:
              'Pull as hard as you can from the start. Maintain full body tension. Breathe normally during efforts.',
        ),
      ],
    );
  }

  /// Get tutorial content for Critical Force assessment.
  static TutorialContent getCriticalForceTutorial(
    HandSide hand,
    GripPosition gripPosition,
  ) {
    return TutorialContent(
      assessmentName: 'Critical Force Assessment',
      subtitle:
          '${gripPosition.displayName} - ${hand.isRightHand ? 'Right' : 'Left'} Hand',
      sections: [
        const TutorialSection(
          icon: Icons.info_outline,
          title: 'What is this test?',
          content:
              'The Critical Force test determines your sustainable climbing intensity. You\'ll perform 4 efforts at different percentages of your MVC.',
        ),
        const TutorialSection(
          icon: Icons.fitness_center,
          title: 'Warm-up Required',
          content:
              'This is a demanding test! Ensure you are thoroughly warmed up with progressive hangs before starting.',
          iconColor: CrimpyTheme.accentYellowText,
        ),
        TutorialSection(
          icon: Icons.schedule,
          title: 'Duration',
          content:
              'This test takes approximately 15-20 minutes. Make sure you have enough time and energy to complete all 4 efforts.',
        ),
        const TutorialSection(
          icon: Icons.timer,
          title: 'Protocol',
          content:
              'You\'ll hang at 20%, 35%, 50%, and 60% of your MVC until failure. Hang as long as possible at each intensity with adequate rest between efforts.',
        ),
        const TutorialSection(
          icon: Icons.psychology,
          title: 'Mental Preparation',
          content:
              'This test is mentally challenging. Stay focused and push through discomfort, especially on the later efforts.',
        ),
      ],
    );
  }

  /// Get tutorial content for 60% Endurance assessment.
  static TutorialContent get60PercentTutorial(
    HandSide hand,
    GripPosition gripPosition,
  ) {
    return TutorialContent(
      assessmentName: '60% Endurance Assessment',
      subtitle:
          '${gripPosition.displayName} - ${hand.isRightHand ? 'Right' : 'Left'} Hand',
      sections: [
        const TutorialSection(
          icon: Icons.info_outline,
          title: 'What is this test?',
          content:
              'This test measures your endurance at 60% of your MVC. It\'s a great indicator of your finger endurance capacity.',
        ),
        const TutorialSection(
          icon: Icons.fitness_center,
          title: 'Warm-up Required',
          content:
              'Complete a thorough warm-up including progressive hangs before starting this endurance test.',
          iconColor: CrimpyTheme.accentYellowText,
        ),
        const TutorialSection(
          icon: Icons.timer,
          title: 'Protocol',
          content:
              'You\'ll pull at 60% of your MVC for as long as possible. The goal is to maximize your time under tension.',
        ),
        const TutorialSection(
          icon: Icons.psychology,
          title: 'Pacing Strategy',
          content:
              'Start controlled and maintain good form. The burn will build gradually - stay mentally strong and push through!',
        ),
      ],
    );
  }

  /// Get tutorial ID for MVC assessment.
  static String getMvcTutorialId(GripPosition gripPosition) {
    return switch (gripPosition) {
      GripPosition.threeFinger => TutorialIds.mvcThreeFinger,
      GripPosition.openHand => TutorialIds.mvcOpenHand,
      GripPosition.halfCrimp => TutorialIds.mvcHalfCrimp,
      GripPosition.fullCrimp =>
        TutorialIds.mvcHalfCrimp, // Use halfCrimp ID for fullCrimp
    };
  }

  /// Get tutorial ID for Critical Force assessment.
  static String getCriticalForceTutorialId(GripPosition gripPosition) {
    return switch (gripPosition) {
      GripPosition.threeFinger => TutorialIds.criticalForceThreeFinger,
      GripPosition.openHand => TutorialIds.criticalForceOpenHand,
      GripPosition.halfCrimp => TutorialIds.criticalForceHalfCrimp,
      GripPosition.fullCrimp =>
        TutorialIds.criticalForceHalfCrimp, // Use halfCrimp ID for fullCrimp
    };
  }

  /// Get tutorial ID for 60% assessment.
  static String get60PercentTutorialId() {
    return TutorialIds.assessment60;
  }
}
