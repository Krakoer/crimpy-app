import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';

// Export custom widgets
export 'widgets/widgets.dart';

/// What a run is doing, as far as its colour is concerned. [CrimpyTheme.phaseColor]
/// maps each one to its hue. See Krakoer/crimpy#158.
enum RunPhase {
  /// Resting, between sets, or paused.
  calm,

  /// Getting ready, or pulling and not yet on target.
  armed,

  /// On target.
  engaged,

  /// Something is wrong mid-run: the sensor is lost, or the load of a hang
  /// dropped below its target (Krakoer/crimpy#175).
  alarm,
}

/// Crimpy Theme - Radicle-inspired minimalist design system
/// Based on the clean, developer-focused aesthetic of Radicle.xyz
class CrimpyTheme {
  // ==================== CORE COLORS ====================

  /// Primary brand color - burnt orange from Radicle palette
  static const Color primaryOrange = Color(0xFFC6613F);

  /// Pure black for high contrast
  static const Color primaryBlack = Color(0xFF000000);

  /// Pure white for backgrounds
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // ==================== ACCENT COLORS ====================
  // Harmonious palette for categorizing different training types

  /// Strength training - Primary orange
  static const Color accentOrange = Color(0xFFC6613F);

  /// Endurance training - Muted forest green
  static const Color accentGreen = Color(0xFF5A8C5A);

  /// accentGreen is 3.94:1 on white and 3.43:1 on the tint [tintOf] builds from
  /// it, under the 4.5:1 floor at label sizes, so it is a mark rather than a
  /// typeface. This is the same hue carried far enough down to clear it: 4.80:1
  /// on that tint. It is also the green the web portal writes in.
  ///
  /// It is --gn-tx in crimpy-frontend/src/routes/layout.css. Every accent has
  /// one of these now; [textOn] is how a widget asks for the right one.
  static const Color accentGreenText = Color(0xFF4E7154);

  /// Power training - Warm golden yellow
  static const Color accentYellow = Color(0xFFD4A644);

  /// accentYellow reads 2.25:1 on white and 2.05:1 on the tint [tintOf] builds
  /// from it, far under the floor either way. This reads 4.98:1 on that tint.
  /// It is --gd-tx in crimpy-frontend/src/routes/layout.css and it is what
  /// [protocolColor] has always been.
  static const Color accentYellowText = Color(0xFF8A6220);

  /// Technique training - Soft purple
  static const Color accentPurple = Color(0xFF8B6B9E);

  /// accentPurple reads 3.87:1 on the tint [tintOf] builds from it, under the
  /// 4.5:1 floor. This reads 4.97:1 there. It is --pl-tx in
  /// crimpy-frontend/src/routes/layout.css, where the same value clears the
  /// portal's own --pl-lt ground at 4.77:1.
  static const Color accentPurpleText = Color(0xFF735F7B);

  /// Flexibility training - Dusty teal
  static const Color accentTeal = Color(0xFF5A8C8C);

  /// Everything that fits no other category - Slate blue
  static const Color accentBlue = Color(0xFF5B7FA6);

  /// accentBlue reads 3.64:1 on the tint [tintOf] builds from it, under the
  /// 4.5:1 floor. This reads 4.96:1 there. It is --bl-tx in
  /// crimpy-frontend/src/routes/layout.css, where the same value clears the
  /// portal's own --bl-lt ground at 4.79:1.
  static const Color accentBlueText = Color(0xFF4B698A);

  /// accentOrange reads 3.50:1 on the tint [tintOf] builds from it, under the
  /// 4.5:1 floor. This reads 5.15:1 there. It is --pr-tx in
  /// crimpy-frontend/src/routes/layout.css, where the same value clears the
  /// portal's own --pr-lt ground at 4.75:1.
  static const Color accentOrangeText = Color(0xFF965134);

  // ==================== RUN PHASE HUES ====================
  // The hues the run screen spends on its phases, and nothing else there. The
  // chrome of that screen is ink; a hue is kept for what has to be read at arm's
  // length mid-hang, and each one means a single thing:
  //
  //   steel  calm     resting, between sets, paused
  //   ink    armed    getting ready, pulling but not yet on target
  //   sage   engaged  on target
  //   red    alarm    something is wrong: the sensor is lost, or the load
  //                    dropped below the target mid-hang
  //
  // Red is spent once, on the alarm, and statusError already holds it. The
  // moment it is decorative it stops working, so a new meaning that wants to
  // escalate (the intensity of a training, Krakoer/crimpy#166) takes steel,
  // ink or sage from here, or a hue of its own, and never the alarm's red. The
  // roles that name these are the RUN PHASES in the ROLES section, and
  // [phaseColor] is the one map every part of the run screen reads, and the
  // assessment run screens read it too, so a colour means the same thing on
  // every screen the athlete pulls on. See Krakoer/crimpy#158 and #176.

  /// Sage, the green the web portal marks a rep that held its target with: it
  /// is --gn in crimpy-frontend/src/routes/layout.css. 3.63:1 on white, so it is
  /// a mark; its text form and the fill that carries white are both
  /// [accentGreenText], which is --gn-tx and reads 5.51:1 under white.
  static const Color accentSage = Color(0xFF6B8F71);

  /// Steel, the calm of the run screen: present but not shouting. A cool grey
  /// rather than a hue, so a rest never reads as a result. 6.24:1 on white and
  /// 5.76:1 on [accentSteelGround], so it is written in as it is.
  static const Color accentSteel = Color(0xFF56626E);

  /// The ground a calm run screen is laid on. As light as the pale green rest
  /// ground it replaces, so every label that read on that one reads on this.
  static const Color accentSteelGround = Color(0xFFF4F6F8);

  // ==================== STATUS COLORS ====================

  /// Success state - Deep green
  static const Color statusSuccess = Color(0xFF4A7C4A);

  /// Error state - Muted red
  static const Color statusError = Color(0xFFB85450);

  /// statusError is 4.42:1 on [bgError], which is under the 4.5:1 floor rather
  /// than at it, so an error line set in it is not quite readable. This reads
  /// 5.22:1 there and 4.77:1 on the darker tint [tintOf] builds. It is --rd-tx
  /// in crimpy-frontend/src/routes/layout.css.
  static const Color statusErrorText = Color(0xFFAC4747);

  /// Warning state - Same as accent yellow
  static const Color statusWarning = Color(0xFFD4A644);

  /// Info state - Same as accent teal
  static const Color statusInfo = Color(0xFF5A8C8C);

  // ==================== STATUS BACKGROUNDS ====================

  /// Light success background
  static const Color bgSuccess = Color(0xFFF0F8F0);

  /// Light error background
  static const Color bgError = Color(0xFFFDF5F5);

  /// Light warning background
  static const Color bgWarning = Color(0xFFFFFAF0);

  /// Light info background
  static const Color bgInfo = Color(0xFFF0F8F8);

  // ==================== BACKGROUND COLORS ====================

  /// Primary background - Pure white
  static const Color bgPrimary = Color(0xFFFFFFFF);

  /// Secondary background - Very light gray
  static const Color bgSecondary = Color(0xFFFAFAFA);

  /// Hover state background
  static const Color bgHover = Color(0xFFF5F5F5);

  // ==================== TEXT COLORS ====================

  /// Primary text - Black
  static const Color textPrimary = Color(0xFF000000);

  /// Secondary text - Medium gray
  static const Color textSecondary = Color(0xFF666666);

  /// Muted grey. **Not a foreground.**
  ///
  /// 2.85:1 on white, which is under the 4.5:1 text floor and also under the
  /// 3:1 floor a mark answers to, so it cannot be written as a label, drawn as
  /// an icon, or used as the boundary of a control. WCAG 1.4.11 exempts
  /// decoration but covers "visual information required to identify user
  /// interface components", so a button outline is the covered case, not the
  /// exempt one.
  ///
  /// One use is left in lib/: the inactive step dot of the tutorial dialog,
  /// already faded to alpha 0.3 and carrying no information the numbered step
  /// beside it does not.
  ///
  /// Anything a reader has to read takes [textMutedSmall]. The palette guard
  /// scans this name for exactly that reason: a hand sweep found 13 of the
  /// foreground uses and the guard found the rest, 34 call sites in all.
  static const Color textMuted = Color(0xFF999999);

  /// The muted voice at a size that has to clear the 4.5:1 text floor.
  ///
  /// 4.74:1 on white and 4.54:1 on [bgSecondary]. It cannot be lighter: 4.5:1
  /// on a near white card admits nothing paler, which is why it lands close to
  /// [textSecondary] at 5.74:1. At these sizes the muted voice and the
  /// secondary one cannot be told apart by lightness and stay readable, so the
  /// difference between them has to be carried by size and weight. That is a
  /// real cost of the split rather than an oversight, and the portal's
  /// --tx3-sm in crimpy-frontend/src/routes/layout.css records the same one.
  ///
  /// It does not clear the floor on [bgHover] at 4.35:1. Nothing writes small
  /// muted text on a hover ground today; a caller that wants to takes
  /// [textSecondary]. See Krakoer/crimpy#137.
  static const Color textMutedSmall = Color(0xFF737373);

  /// Secondary text drawn over a filled surface - Translucent white
  static const Color textOnFillSecondary = Color(0xB3FFFFFF);

  /// Text a step darker than [textSecondary], for the numbers and headings of
  /// the history cards.
  static const Color textStrong = Color(0xFF404040);

  /// Text between [textStrong] and [textSecondary], for the labels of the
  /// history cards.
  static const Color textMedium = Color(0xFF525252);

  /// Grey for decoration only: chevrons, idle icons, empty placeholders. At
  /// 2.53:1 on white it is not a text colour; see Krakoer/crimpy#169.
  static const Color textFaint = Color(0xFFA3A3A3);

  /// Text and icons drawn over a filled surface.
  static const Color textOnFill = primaryWhite;

  // ==================== LINES AND GROUNDS ====================

  /// The line of a card, an input and a divider, and the colour of the hard
  /// offset shadow cards cast.
  static const Color outline = Color.fromARGB(255, 29, 29, 29);

  /// A quieter line, for separators inside a card and unselected controls.
  static const Color outlineSubtle = Color(0xFFCCCCCC);

  /// A ground set into a card, under a group of rows.
  static const Color bgSunken = Color(0xFFF5F5F5);

  /// What is laid over the screen behind a modal notice. Always faded.
  static const Color scrim = primaryBlack;

  // ==================== ROLES ====================
  // What a colour means where a widget paints it. Widgets name a role, never a
  // hue: several roles hold the same hue today, and giving each meaning its own
  // name is what lets one of them change without the others moving with it.
  // The values are the ones each meaning was painted in before the roles
  // existed. See Krakoer/crimpy#168.

  /// The primary action of a screen: a filled button, the FAB. With the brand,
  /// the only thing painted orange. See Krakoer/crimpy#170.
  static const Color action = primaryOrange;

  /// A control that is not the primary action: a selected tab or chip, a
  /// switch, a slider, a link, progress, a secondary button.
  static const Color control = textPrimary;

  /// The present: today on a calendar, this week in a program, a date filter.
  static const Color current = textPrimary;

  /// What a coach wrote to the athlete.
  static const Color coachNote = textPrimary;

  /// The mark of what a block is for. [goalColor] is its text form.
  static const Color goalMark = accentGreen;

  /// The mark of the rule a block is resolved by. [protocolColor] is its text
  /// form.
  static const Color protocolMark = accentYellow;

  /// A value this week's program set differently from the training.
  static const Color overrideMark = accentYellow;

  /// A scheduled training that was done.
  static const Color done = statusSuccess;

  /// A day of the consistency strip whose training was kept. Filled, and read
  /// by its shape as much as by its colour.
  static const Color dayKept = done;

  /// A day of the consistency strip that owed training and got none: drawn
  /// hollow, and never in a colour that scolds.
  static const Color dayOwed = textSecondary;

  /// A day of the consistency strip before the plan existed. Kept quiet by its
  /// shape, a short line, rather than by a pale grey: it has to read as
  /// something other than an empty cell, since what it says is that the day
  /// was not missed.
  static const Color dayUntracked = textSecondary;

  /// A rep that held its target load. The portal's sage, so a rep reads the
  /// same on the phone and in the coach's session detail; the run screen's
  /// [phaseEngaged] is this same meaning live.
  static const Color onTarget = accentSage;

  /// A rep that missed its target load.
  static const Color offTarget = statusWarning;

  /// A rep that fell well short of its target load, where a view grades a miss
  /// in two tiers: [offTarget] is then the milder one.
  static const Color farOffTarget = statusError;

  /// A result better than the previous one.
  static const Color improvement = accentYellow;

  /// What the athlete reported achieving on a step.
  static const Color achieved = textPrimary;

  /// The mark of a precaution to take before a test, such as warming up.
  static const Color caution = accentYellowText;

  // ---- RUN PHASES ----
  // One map from what the run is doing to the hue it is painted in, read by
  // every part of the run screen through [phaseColor], so the tank, the
  // countdown and the words under it move together. The hues are the RUN PHASE
  // HUES above. See Krakoer/crimpy#158.

  /// Resting, between sets, or paused: nothing is asked of the fingers.
  static const Color phaseCalm = accentSteel;

  /// The ground of the run screen while it is calm.
  static const Color phaseCalmGround = accentSteelGround;

  /// Getting ready, or pulling and not yet on target. Ink, and the one phase
  /// without a hue: it is the working baseline the others stand out from.
  static const Color phaseArmed = textMedium;

  /// On target: the load holds what the step prescribed. The same meaning as
  /// [onTarget], and the only green the run screen has.
  static const Color phaseEngaged = onTarget;

  /// Something is wrong mid-run: the sensor is lost, or the load dropped below
  /// the target. The only red on the run screen; nothing that is not an alarm
  /// may take it.
  static const Color phaseAlarm = statusError;

  /// The run screen's instruction: which hand, which step, what load.
  static const Color runPrompt = textPrimary;

  /// The hue of [phase]. Every part of the run screen that paints a phase asks
  /// here rather than naming a role, so no two of them can drift apart.
  static Color phaseColor(RunPhase phase) => switch (phase) {
    RunPhase.calm => phaseCalm,
    RunPhase.armed => phaseArmed,
    RunPhase.engaged => phaseEngaged,
    RunPhase.alarm => phaseAlarm,
  };

  // ---- TRAINING INTENSITY ----
  // How hard a training is against the athlete's max, on its card. It escalates
  // by weight and fill rather than by hue: light is the quiet voice, moderate
  // the working ink, and near max is inverted, ink filled under white. Red is
  // the alarm's alone and orange the primary action's, green already means on
  // target, and steel means resting, so a hue here would say one of those. The
  // percentage is always written out, so the tier survives greyscale. See
  // Krakoer/crimpy#166.

  /// A training at or under 30% of max: its outline and its figure.
  static const Color intensityLight = textSecondary;

  /// A training between 30% and 80% of max: its outline and its figure.
  static const Color intensityModerate = textPrimary;

  /// A training from 80% of max: the ground its figure is written on in
  /// [textOnFill].
  static const Color intensityNearMax = textPrimary;

  /// A reading not yet where the test wants it: still settling, not started,
  /// or outside its zone.
  static const Color measuring = accentYellow;

  /// A reading where the test wants it: settled, started, inside its zone.
  static const Color measureSettled = accentGreen;

  /// The band a test asks the load to stay inside. It is where the load is on
  /// target, so it holds the engaged phase's sage. See Krakoer/crimpy#176.
  static const Color targetZone = phaseEngaged;

  /// A sensor that is connected.
  static const Color sensorConnected = accentYellow;

  /// A sensor that is being connected to.
  static const Color sensorConnecting = textPrimary;

  /// The live force trace of an assessment run with no target to hold. It is
  /// the working ink of the armed phase: sage would claim a target that is not
  /// there. See Krakoer/crimpy#176.
  static const Color forceTrace = phaseArmed;

  // ---- ASSESSMENT SERIES ----
  // One hue per metric on the profile's assessment charts, with the two hands
  // of one metric told apart by line style: the left hand solid, the right
  // dashed. The hands used to take the hangboard orange and the climbing
  // yellow, two categories that mean something else everywhere else in the
  // app. Max force is ink, the working baseline. Critical force is the blue,
  // so the two stay apart wherever they are read together. The blue is only
  // spent where no activity or training type colour shares the view, since it
  // also means the "other" activity and the news mark: the profile shows
  // neither. Anywhere that does, every metric takes ink. The portal follows the
  // same rule with --tx and --bl. See Krakoer/crimpy#164.

  /// The series of a max force chart, and its stat cards' swatches.
  static const Color maxForceSeries = textPrimary;

  /// The series of a critical force chart, and its stat cards' swatches.
  static const Color criticalForceSeries = accentBlue;

  /// The series of any other assessment's chart, and its stat cards' swatches.
  static const Color assessmentSeries = textPrimary;

  /// A day the athlete planned to train on.
  static const Color planned = accentGreen;

  /// The mark of what changed in a new release.
  static const Color newsMark = accentBlue;

  // ==================== CATEGORIES ====================

  /// Assessment activities
  static const Color assessmentColor = accentOrange;

  /// Training activities
  static const Color trainingColor = accentYellow;

  /// Stretching/flexibility activities
  static const Color stretchingColor = accentTeal;

  /// What a block is for. Green splits it from the comment's orange, and the
  /// readable green is what a goal is set in: it clears 4.5:1 on white and on
  /// bgSuccess alike at the label sizes a goal uses.
  static const Color goalColor = accentGreenText;

  /// The rule the athlete resolves while performing a block. Gold, a third
  /// colour beside the goal's green and the comment's orange, so the three
  /// notes on a card are told apart without reading them. accentYellow is about
  /// 2.3:1 on white, so the label takes this hue carried far enough down to
  /// clear the 4.5:1 floor, on white and on bgWarning alike. It is --gd-tx in
  /// crimpy-frontend/src/routes/layout.css.
  static const Color protocolColor = accentYellowText;

  /// An action that throws away what the athlete did, or cuts off what they
  /// are using: deleting a training or a session, leaving a run or a review
  /// before it is saved, disconnecting the sensor. It fills the
  /// primary action of a dialog that asks for one, and carries white at
  /// 4.75:1 without a darker form.
  static const Color destructive = statusError;

  // ==================== SHAPE ====================

  /// The one corner of the app. Cards, buttons, fields, chips, dialogs, sheets,
  /// menus, tiles and chart bars are all square; a dot or a ring is a circle,
  /// which is a shape rather than a corner. A widget that wants a corner takes
  /// this rather than naming a radius, and test/theme/shape_tokens_test.dart
  /// fails on any file outside the theme that names one. See
  /// Krakoer/crimpy#171.
  static const Radius corner = Radius.zero;

  /// [corner] on all four sides, for a BoxDecoration or a ClipRRect.
  static const BorderRadius corners = BorderRadius.all(corner);

  /// [corners] as a Material shape, for a widget that takes an OutlinedBorder.
  /// A side, when one is wanted, goes on with copyWith.
  static const RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: corners,
  );

  /// [shape] on the 2px line of a raised card, for a surface that stands over
  /// the screen: a dialog, a sheet, a menu, a picker.
  static const RoundedRectangleBorder framed = RoundedRectangleBorder(
    borderRadius: corners,
    side: BorderSide(color: outline, width: 2),
  );

  // ==================== SPACING ====================
  // One scale for the room between and inside things, so two cards that do
  // the same job are as roomy as each other. A widget takes a step off it
  // rather than a number of its own. See Krakoer/crimpy#169.

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;

  /// Between spaceLg and spaceXl: the room a dialog, a sheet or a result
  /// screen gives its content.
  static const double spaceLgPlus = 20;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;

  /// Inside a card: the same on every card, whatever it holds.
  static const EdgeInsets cardPadding = EdgeInsets.all(spaceLg);

  /// Between a card and what is stacked above and below it.
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: spaceSm);

  /// Between a section heading and what it heads.
  static const double headingGap = spaceSm;

  // ==================== SURFACES ====================
  // Two surfaces, picked by role. The 2px line with a hard offset shadow is the
  // app's identity, and it only stands out while few things wear it: what can
  // be tapped, and the one element that matters most on a screen. Grouped,
  // read-only content sits flat and is held together by spacing and a thin
  // line. A widget takes [raised] or [flat] rather than building its own
  // shadow; test/theme/shadow_tokens_test.dart fails on any file outside the
  // theme that names one. See Krakoer/crimpy#173.

  /// How far a raised surface's shadow falls, right and down.
  static const double raisedOffset = 3;

  /// The hard offset shadow a raised surface casts.
  static const List<BoxShadow> raisedShadow = [
    BoxShadow(color: outline, offset: Offset(raisedOffset, raisedOffset)),
  ];

  /// What can be tapped, and the one element that matters most on a screen.
  /// A raised surface on its own ground takes this with copyWith(color:).
  static const BoxDecoration raised = BoxDecoration(
    color: bgPrimary,
    border: Border.fromBorderSide(BorderSide(color: outline, width: 2)),
    borderRadius: corners,
    boxShadow: raisedShadow,
  );

  /// Grouped, read-only content: a stat tile, a chart, a section of a form or
  /// a detail screen. A thin quiet line, no shadow.
  static const BoxDecoration flat = BoxDecoration(
    color: bgPrimary,
    border: Border.fromBorderSide(BorderSide(color: outlineSubtle, width: 1)),
    borderRadius: corners,
  );

  /// [flat] as a Material shape, for the card theme.
  static const RoundedRectangleBorder flatShape = RoundedRectangleBorder(
    borderRadius: corners,
    side: BorderSide(color: outlineSubtle, width: 1),
  );

  /// The primary action of a dialog that throws something away, filled with
  /// [destructive] rather than the brand orange. The theme's FilledButton is
  /// the primary action everywhere else.
  static final ButtonStyle destructiveButton = FilledButton.styleFrom(
    backgroundColor: destructive,
    foregroundColor: textOnFill,
  );

  /// The borders of a field, shared by the app's inputs and the time picker's
  /// keyboard mode so the two cannot drift apart.
  static const OutlineInputBorder _fieldBorder = OutlineInputBorder(
    borderRadius: corners,
    borderSide: BorderSide(color: outline, width: 1),
  );
  static const OutlineInputBorder _fieldFocusedBorder = OutlineInputBorder(
    borderRadius: corners,
    borderSide: BorderSide(color: control, width: 1),
  );
  static const OutlineInputBorder _fieldErrorBorder = OutlineInputBorder(
    borderRadius: corners,
    borderSide: BorderSide(color: statusError, width: 1),
  );

  /// A picker's OK. The pickers take a style for a TextButton rather than a
  /// button of their own, so the fill the theme's FilledButton carries is
  /// spelled out here.
  static final ButtonStyle _pickerConfirmButton = TextButton.styleFrom(
    backgroundColor: fillOn(action),
    foregroundColor: textOnFill,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: shape,
  );

  // ==================== TYPE ====================
  //
  // The face is the platform's own sans: Roboto on Android, SF Pro on iOS. No
  // font is bundled and none is named, so nothing here sets a family. Sizes,
  // leading, weights and tracking follow Get a Grip's scale, and tracking
  // follows size: open for small text and caps, tight for large text, since
  // letterforms read further apart as they grow.
  //
  // A widget takes one of these rather than naming a size, a family or a
  // tracking of its own, and test/theme/type_tokens_test.dart fails on any
  // file outside the theme that does. A weight may still be set on top, to
  // pick out a word, up to w700. A screen that scales its type with its
  // layout, as the run screen does, scales these with TextStyle.apply. See
  // Krakoer/crimpy#172.

  /// A screen's title, in the app bar. The heaviest words on a screen and
  /// still lighter than the numbers a screen exists to show.
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    height: 33 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  /// A heading inside a screen: a result, a section of a long page, a big
  /// state word.
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    height: 29 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );

  /// [headline] for a word set in capitals: a state word such as "REST" or
  /// "PAUSED", a hand. Tracked open rather than tight, since capitals crowd at
  /// any size where lower case does not.
  static const TextStyle capsHeadline = TextStyle(
    fontSize: 24,
    height: 29 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// A prominent line that is not a heading: a step name, a figure with its
  /// unit.
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    height: 27 / 22,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
  );

  /// The title of a card, a dialog, a list row.
  static const TextStyle title = TextStyle(
    fontSize: 17,
    height: 23 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
  );

  /// A secondary title: a subheading in a card, a row's second line when it
  /// names something.
  static const TextStyle titleSmall = TextStyle(
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Reading text given room: a note, a prescription.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// Running text, and anything that has no reason to be another size.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// Supporting text: a caption, a detail line, a chart axis.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// A control's label: a button, a tab.
  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// A small label in mixed case: a chip, a badge, a tab under an icon.
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// A label set in capitals over what it names: "ELAPSED", "PROTOCOL",
  /// "NEXT". Open by a little, as small caps want, and no more: spacing them
  /// wide reads as a word spelled out. The caller writes the capitals.
  static const TextStyle capsLabel = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static const TextStyle _labelMedium = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  /// Figures that change while they are read: a timer, a force reading.
  /// Tabular, so each digit keeps its width and the number does not jitter as
  /// it counts.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  /// [style] with [tabularFigures], for a figure at a text size that changes
  /// while it is read: a clock in a row, a live value in a card.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: tabularFigures);

  /// A display number: the force, the countdown, a result a screen exists to
  /// show. Light, tabular, and tracked at -0.02 em so large figures sit
  /// together rather than float apart. [size] is the one size a widget may
  /// state, since a display number is sized to the room it has.
  static TextStyle numerals(
    double size, {
    FontWeight weight = FontWeight.w300,
    double height = 1.1,
  }) => TextStyle(
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: size * -0.02,
    fontFeatures: tabularFigures,
  );

  // ==================== THEME DATA ====================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: control,
      secondary: accentGreen,
      tertiary: accentPurple,
      surface: bgPrimary,
      error: statusError,
      onPrimary: primaryWhite,
      onSecondary: primaryWhite,
      onSurface: textPrimary,
      onError: primaryWhite,
      outline: outline,
      outlineVariant: outlineSubtle,
    ),

    // Scaffold
    scaffoldBackgroundColor: bgPrimary,

    // AppBar with minimalist styling
    appBarTheme: AppBarTheme(
      backgroundColor: bgPrimary,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: pageTitle.copyWith(color: textPrimary),
      iconTheme: const IconThemeData(color: textPrimary),
      actionsIconTheme: const IconThemeData(color: textPrimary),
    ),

    // A Material Card holds a section of a form or a detail screen, so it is
    // flat. Anything tapped as a whole is a raised CrimpyCard instead.
    cardTheme: const CardThemeData(
      color: bgPrimary,
      elevation: 0,
      shape: flatShape,
      margin: EdgeInsets.symmetric(vertical: 8),
    ),

    // Primary button - Orange with sharp edges
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Darkened so the white label the line below sets clears 4.5:1.
        // primaryOrange itself reads 4.05:1 under white, and this theme is
        // what every ElevatedButton that names no ground inherits.
        backgroundColor: fillOn(action),
        foregroundColor: primaryWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: shape,
        textStyle: label,
      ),
    ),

    // Outlined button: a secondary action, so ink rather than the primary
    // action's orange. See Krakoer/crimpy#170.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: control,
        backgroundColor: bgPrimary,
        side: const BorderSide(color: control, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: shape,
        textStyle: label,
      ),
    ),

    // Text button: sixty odd call sites inherit this one entry, dialog actions
    // and links among them, and none of them is a screen's primary action, so
    // they are ink. foregroundColor paints a TextButton.icon's icon too.
    // See Krakoer/crimpy#170.
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: control,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: shape,
        textStyle: label,
      ),
    ),

    // Filled button: the primary action of a dialog or a sheet, beside a
    // TextButton that dismisses it. It is the same orange as the
    // ElevatedButton a screen's primary action takes, so a choice reads the
    // same wherever it is offered. A dialog whose primary action throws
    // something away takes destructiveButton on top. See Krakoer/crimpy#171.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: fillOn(action),
        foregroundColor: textOnFill,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: shape,
        textStyle: label,
      ),
    ),

    // A choice between a few exclusive options: selected is filled with ink,
    // as a selected chip is.
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        foregroundColor: textPrimary,
        backgroundColor: bgPrimary,
        selectedForegroundColor: textOnFill,
        selectedBackgroundColor: control,
        side: const BorderSide(color: outline, width: 1),
        shape: shape,
        textStyle: label,
      ),
    ),

    // Dialogs are cards laid over the screen: square, on the card's line,
    // without the tint Material 3 washes a raised surface with.
    dialogTheme: DialogThemeData(
      backgroundColor: bgPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: framed,
      titleTextStyle: title.copyWith(color: textPrimary),
      contentTextStyle: body.copyWith(color: textPrimary),
    ),

    // Bottom sheets rise from the screen's edge on the same line as a dialog.
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: bgPrimary,
      modalBackgroundColor: bgPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: framed,
    ),

    // Overflow menus, on the line of a field.
    popupMenuTheme: PopupMenuThemeData(
      color: bgPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: corners,
        side: BorderSide(color: outline, width: 1),
      ),
      textStyle: body.copyWith(color: textPrimary),
    ),

    // The date and time pickers are dialogs too. Their OK is the primary
    // action, filled the way a dialog's is; a picked day or time is a
    // selection, so it is ink, as colorScheme.primary already paints it.
    datePickerTheme: DatePickerThemeData(
      backgroundColor: bgPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: framed,
      dayShape: const WidgetStatePropertyAll(shape),
      yearShape: const WidgetStatePropertyAll(shape),
      confirmButtonStyle: _pickerConfirmButton,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: bgPrimary,
      elevation: 0,
      shape: framed,
      hourMinuteShape: shape,
      dayPeriodShape: shape,
      dayPeriodBorderSide: const BorderSide(color: outline, width: 1),
      // AM or PM is a selection, so it is ink, as a selected chip is. Left
      // unset, Material fills it from the scheme's tertiary, which is purple.
      dayPeriodColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? control : bgPrimary,
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? textOnFill : textPrimary,
      ),
      dialBackgroundColor: bgSunken,
      // The keyboard mode's hour and minute fields. Left unset, the picker
      // draws them with its own 8px rounded decoration rather than the app's.
      // The dial mode's hour and minute boxes take the same ground, so the
      // two modes read as one picker.
      hourMinuteColor: bgSunken,
      inputDecorationTheme: const InputDecorationThemeData(
        filled: true,
        fillColor: bgSunken,
        contentPadding: EdgeInsets.zero,
        border: _fieldBorder,
        enabledBorder: _fieldBorder,
        focusedBorder: _fieldFocusedBorder,
        errorBorder: _fieldErrorBorder,
        focusedErrorBorder: _fieldErrorBorder,
      ),
      confirmButtonStyle: _pickerConfirmButton,
    ),

    tooltipTheme: TooltipThemeData(
      decoration: const BoxDecoration(
        color: primaryBlack,
        borderRadius: corners,
      ),
      textStyle: bodySmall.copyWith(color: textOnFill),
    ),

    // Input fields with sharp borders
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgPrimary,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: _fieldBorder,
      enabledBorder: _fieldBorder,
      focusedBorder: _fieldFocusedBorder,
      errorBorder: _fieldErrorBorder,
      focusedErrorBorder: _fieldErrorBorder,
      disabledBorder: OutlineInputBorder(
        borderRadius: corners,
        borderSide: BorderSide(color: outlineSubtle, width: 1),
      ),
      labelStyle: _labelMedium.copyWith(color: textSecondary),
      hintStyle: TextStyle(color: textMutedSmall),
    ),

    // Chip theme with minimal styling
    chipTheme: ChipThemeData(
      // Resolved from the chip's state rather than from backgroundColor,
      // selectedColor and disabledColor, which Material leaves ambiguous for a
      // chip that is both selected and disabled. Selected is filled with ink;
      // disabled is never as dark as selected, so it cannot pass for it, and a
      // disabled choice that is still on reads as muted ink. See
      // Krakoer/crimpy#170.
      color: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        if (states.contains(WidgetState.disabled)) {
          return selected ? textMedium : bgSunken;
        }
        return selected ? control : bgSecondary;
      }),
      checkmarkColor: textOnFill,
      // Material paints a disabled chip's label and checkmark at 38% opacity
      // on top of whatever this resolves to, so a disabled label renders
      // lighter than textSecondary: #BEBEBE on bgSunken. Disabled controls
      // are exempt from the text floor.
      labelStyle: TextStyle(
        color: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return textOnFill;
          if (states.contains(WidgetState.disabled)) return textSecondary;
          return textPrimary;
        }),
        fontSize: labelSmall.fontSize,
        height: labelSmall.height,
        fontWeight: FontWeight.w500,
        letterSpacing: labelSmall.letterSpacing,
      ),
      side: const BorderSide(color: outline, width: 1),
      shape: shape,
    ),

    // Bottom navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgSecondary,
      selectedItemColor: control,
      unselectedItemColor: textPrimary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: bgSecondary,
      indicatorColor: control,
      indicatorShape: shape,
      elevation: 0,
    ),

    // FAB with sharp corners
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: action,
      foregroundColor: primaryWhite,
      elevation: 0,
      shape: shape,
    ),

    // Get a Grip's scale, on the platform's sans. Only Material's own widgets
    // read these slots: a widget in lib/ takes a style from the TYPE section
    // above, and test/theme/type_tokens_test.dart fails on one that reads
    // textTheme instead.
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 57,
        height: 60 / 57,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.4,
        color: textPrimary,
      ),
      displayMedium: const TextStyle(
        fontSize: 45,
        height: 49 / 45,
        fontWeight: FontWeight.w300,
        letterSpacing: -1,
        color: textPrimary,
      ),
      displaySmall: const TextStyle(
        fontSize: 36,
        height: 40 / 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.9,
        color: textPrimary,
      ),
      headlineLarge: const TextStyle(
        fontSize: 32,
        height: 37 / 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.7,
        color: textPrimary,
      ),
      headlineMedium: pageTitle.copyWith(color: textPrimary),
      headlineSmall: headline.copyWith(color: textPrimary),
      titleLarge: titleLarge.copyWith(color: textPrimary),
      titleMedium: title.copyWith(color: textPrimary),
      titleSmall: titleSmall.copyWith(color: textPrimary),
      bodyLarge: bodyLarge.copyWith(color: textPrimary),
      bodyMedium: body.copyWith(color: textPrimary),
      bodySmall: bodySmall.copyWith(color: textSecondary),
      labelLarge: label.copyWith(color: textSecondary),
      labelMedium: _labelMedium.copyWith(color: textSecondary),
      labelSmall: labelSmall.copyWith(color: textMutedSmall),
    ),

    // Divider with minimal styling
    dividerTheme: const DividerThemeData(
      color: outline,
      thickness: 1,
      space: 16,
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryWhite;
        }
        return outlineSubtle;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return control;
        }
        return bgSecondary;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return control;
        }
        return bgPrimary;
      }),
      checkColor: WidgetStateProperty.all(primaryWhite),
      side: const BorderSide(color: outline, width: 1),
      shape: shape,
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return control;
        }
        return outline;
      }),
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: control,
      inactiveTrackColor: outline,
      thumbColor: control,
      overlayColor: control.withAlpha(0x1F),
      valueIndicatorColor: control,
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: control,
      linearTrackColor: outline,
      circularTrackColor: outline,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: control,
      unselectedLabelColor: textSecondary,
      indicatorColor: control,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: label,
      unselectedLabelStyle: label.copyWith(fontWeight: FontWeight.w500),
    ),

    // Snack bar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryBlack,
      contentTextStyle: body.copyWith(color: primaryWhite),
      shape: shape,
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ==================== CATEGORY HELPERS ====================

  /// Accent color a session is drawn with, from what was trained.
  ///
  /// The web portal paints the same activities with the same values, so these
  /// are a contract across the two clients rather than a local styling choice.
  static Color activityColor(SessionActivity activity) => switch (activity) {
    SessionActivity.hangboard => accentOrange,
    SessionActivity.climbing => accentYellow,
    SessionActivity.stretching => accentGreen,
    SessionActivity.workout => accentPurple,
    SessionActivity.other => accentBlue,
  };

  /// The text form of a session's accent, for a label set on a tint of that
  /// same accent. Mirrors [activityColor] one to one, and the `text` field of
  /// SESSION_ACTIVITIES in crimpy-frontend/src/lib/sessions.ts.
  static Color activityTextColor(SessionActivity activity) =>
      textOn(activityColor(activity));

  /// Every accent that has a darker form to be read as text in, keyed by the
  /// accent itself so a widget holding only a [Color] can ask for it.
  ///
  /// The accents are marks: each one is under the 4.5:1 floor on a light tint
  /// of itself, which is what Krakoer/crimpy#119 measured. accentTeal and
  /// statusInfo are absent on purpose: the web portal has no teal accent, so
  /// giving one a text token here would put the two palettes out of step.
  static final Map<Color, Color> _accentTextColors = Map.unmodifiable({
    // accentOrange and primaryOrange hold the same value, as do accentYellow
    // and statusWarning, so one entry answers both names.
    accentOrange: accentOrangeText,
    accentYellow: accentYellowText,
    accentGreen: accentGreenText,
    statusSuccess: accentGreenText,
    // The portal's own pair: --gn written in --gn-tx.
    accentSage: accentGreenText,
    accentPurple: accentPurpleText,
    accentBlue: accentBlueText,
    statusError: statusErrorText,
    // Not an accent, and here for the same reason the mark map's entry is: no
    // caller passes textMuted today, because every foreground use moved to
    // textMutedSmall directly. ScheduleStatusTag used to route it through
    // textOn and now passes the readable form itself. The entry answers a
    // future caller correctly instead of handing back 2.85:1.
    // See Krakoer/crimpy#137.
    textMuted: textMutedSmall,
  });

  /// Every accent too pale to stand as a mark on a neutral ground, keyed by the
  /// accent itself the way [_accentTextColors] is.
  ///
  /// An icon, or a figure large enough for the WCAG large text exemption,
  /// answers to 3:1 rather than 4.5:1, and every accent in this palette clears
  /// that on white except gold, which reads 2.25:1. The accents are the brand
  /// marks, so the ones that clear it keep their colour and only gold moves.
  ///
  /// A border, a fill and a decorative rule are none of this widget's business
  /// and stay on the accent: they carry no information a label beside them does
  /// not already carry. See Krakoer/crimpy#128.
  static final Map<Color, Color> _accentMarkColors = Map.unmodifiable({
    // accentYellow and statusWarning hold the same value, so one entry answers
    // both names, the way [_accentTextColors] answers accentOrange and
    // primaryOrange with one.
    accentYellow: accentYellowText,
    // textMuted misses the mark floor too, at 2.85:1 against 3:1, so an icon
    // drawn in it is as unreadable as the label beside it was. No caller passes
    // it today: every foreground use moved to textMutedSmall directly rather
    // than through this map. The entry is here so that a future caller routing
    // a muted mark through markOn is answered correctly instead of being handed
    // back a colour under the floor, which is what this map is for.
    textMuted: textMutedSmall,
  });

  /// Every accent darkened far enough to carry a white label, keyed by the
  /// accent itself the way [_accentTextColors] is.
  ///
  /// The mirror of that map. [textOn] answers "what do I write on a tint of this
  /// accent"; this answers "what do I fill with when the label on top is white".
  /// Every accent in this palette is under the 4.5:1 floor beneath white except
  /// statusError and statusSuccess, and gold is at 2.25:1, which fails even the
  /// 3:1 floor a large label would answer to. A 16px w600 label is not large by
  /// WCAG, which asks 18.66px of a bold one, so the session buttons that fill
  /// with an activity colour were unreadable at every size they are used.
  ///
  /// These are the accents themselves darkened, not new hues, so a filled button
  /// still reads as its activity.
  ///
  /// The portal took the same decision with its own hues, in --pr-dk and
  /// --rd-dk of crimpy-frontend/src/routes/layout.css. Those are not these
  /// values and are not meant to match: the two palettes start from different
  /// reds and terracottas, and the app needs no fill for statusError because it
  /// already carries white. Unlike the tokens named in mirroredWebTokens, these
  /// are a shared decision rather than a shared number. See Krakoer/crimpy#137.
  static const Color accentOrangeFill = Color(0xFFB25739);
  static const Color accentYellowFill = Color(0xFF8A6C2C);
  static const Color accentGreenFill = Color(0xFF4F7B4F);
  static const Color accentPurpleFill = Color(0xFF846696);
  static const Color accentBlueFill = Color(0xFF537497);
  static const Color statusInfoFill = Color(0xFF4D7878);

  // Several accents answer under a name they share a value with, the way the
  // two maps above do: accentTeal and statusInfo hold one colour, as do
  // statusWarning and accentYellow, and trainingColor, assessmentColor and
  // stretchingColor are aliases of three of these. One entry answers every
  // name. Splitting any of those pairs means adding the entry the split
  // orphans, or fillOn quietly hands back a colour under the floor.
  static final Map<Color, Color> _accentFillColors = Map.unmodifiable({
    accentOrange: accentOrangeFill,
    accentYellow: accentYellowFill,
    accentGreen: accentGreenFill,
    // --gn-tx carries white at 5.51:1, so the portal's text green is the fill
    // too rather than a darker sage of the app's own.
    accentSage: accentGreenText,
    accentPurple: accentPurpleFill,
    accentBlue: accentBlueFill,
    statusInfo: statusInfoFill,
    // Not an accent, and answered anyway. fillOn hands an unmapped colour back
    // unchanged, so without this a surface filled with fillOn(textMuted) would
    // render white on #999999 at 2.85:1 and pass every check: the ground scan
    // cuts a resolved fillOn(...) out before it looks for an accent, which is
    // the one hole an otherwise closed contract had.
    textMuted: textMutedSmall,
  });

  /// The colour a surface is filled with when a white label sits on it. An
  /// accent that already carries white at 4.5:1 is answered with itself, so a
  /// caller is never handed a darker form of something that did not need one.
  ///
  /// Only for a ground under a neutral label. A border, a rule or an icon fill
  /// carries no text and keeps the accent.
  static Color fillOn(Color accent) => _accentFillColors[accent] ?? accent;

  /// The colour a mark is drawn in when it sits on a neutral ground: an icon,
  /// or text large enough to answer to the 3:1 floor. Mirrors the `mark` field
  /// of SESSION_ACTIVITIES in crimpy-frontend/src/lib/sessions.ts. An accent
  /// that already clears the mark floor is answered with itself, so a caller
  /// asking for a mark is never handed the text form of an accent that did not
  /// need one.
  static Color markOn(Color accent) => _accentMarkColors[accent] ?? accent;

  /// The strongest an accent ground may be tinted when the same accent is
  /// written on it. It is a ceiling rather than the only value in the app: a
  /// handful of surfaces tint at 0.10 or 0.06 on purpose and are lighter still,
  /// which only helps. Past this strength the ground darkens beyond what the
  /// shared text tokens were chosen for and the label stops being readable, so
  /// a new tinted surface takes [tintOf] rather than picking its own alpha.
  static const double tintAlpha = 0.12;

  /// A light ground of [accent], the app's counterpart to the --*-lt tokens of
  /// crimpy-frontend/src/routes/layout.css.
  static Color tintOf(Color accent) => accent.withValues(alpha: tintAlpha);

  /// The colour a label is written in when it sits on a tint of [accent].
  /// An accent with no entry of its own is answered with itself, so a caller is
  /// never handed something that is not a darker form of what it asked for.
  /// [statusSuccess] is the one entry whose answer comes from a neighbouring
  /// base, [accentGreen]: the two greens are close enough to share a readable
  /// form, and giving the status green its own would be a seventh token with no
  /// counterpart in the portal palette.
  static Color textOn(Color accent) => _accentTextColors[accent] ?? accent;
}
