import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// What the app hands MaterialApp, ahead of Material's own defaults, so the
/// first delegate for each type wins: weeks open on Monday in every Material
/// calendar, whatever the device's locale.
const crimpyLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  MondayFirstMaterialLocalizations.delegate,
];

/// Material's English strings with weeks opening on Monday.
///
/// Every week in Crimpy runs Monday to Sunday, whatever the device's locale.
/// The Material date picker lays its grid out from [firstDayOfWeekIndex], which
/// the default English localizations set to Sunday, as en_US has it, so
/// without this the picker would be the one calendar in the app that does not.
class MondayFirstMaterialLocalizations extends DefaultMaterialLocalizations {
  const MondayFirstMaterialLocalizations();

  /// Counted from Sunday, as Material counts it: 1 is Monday.
  @override
  int get firstDayOfWeekIndex => DateTime.monday % DateTime.daysPerWeek;

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _MondayFirstMaterialLocalizationsDelegate();
}

class _MondayFirstMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MondayFirstMaterialLocalizationsDelegate();

  // English only, like the default localizations it extends: the app ships no
  // other language, so every locale resolves to English and lands here.
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
        const MondayFirstMaterialLocalizations(),
      );

  @override
  bool shouldReload(_MondayFirstMaterialLocalizationsDelegate old) => false;
}
