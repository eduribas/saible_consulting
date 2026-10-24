// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Registrierungs-Demo';

  @override
  String get privacyNotice =>
      'Datenschutzhinweis: Dies ist eine Demo-App. Keine der hier eingegebenen Informationen wird gespeichert, übertragen oder weitergegeben.';

  @override
  String get dateOfBirthErrorRequired => 'Ihr Geburtsdatum ist erforderlich.';

  @override
  String get dateOfBirthErrorInvalid => 'Ein gültiges Geburtsdatum ist erforderlich.';

  @override
  String dateOfBirthErrorTooEarly(String min) {
    return 'Ihr Geburtsdatum darf nicht vor dem $min liegen (Sie müssen angeben, über 18 Jahre alt zu sein, um das Formular abzusenden).';
  }

  @override
  String dateOfBirthErrorTooLate(String max) {
    return 'Sie müssen angeben, über 18 Jahre alt zu sein, um das Formular zu aktivieren. Wählen Sie ein Datum am oder vor dem $max.';
  }

  @override
  String get dateOfBirthLabel => 'Geburtsdatum';

  @override
  String get nationalityErrorRequired => 'Ihre Staatsangehörigkeit ist erforderlich.';

  @override
  String get nationalityLabel => 'Staatsangehörigkeit';

  @override
  String get countryOfResidenceErrorRequired => 'Ihr Wohnsitzland ist erforderlich.';

  @override
  String get countryOfResidenceLabel => 'Wohnsitzland';

  @override
  String get phoneNumberErrorRequired => 'Ihre Telefonnummer ist erforderlich.';

  @override
  String get phoneNumberErrorInvalid => 'Eine gültige Telefonnummer ist erforderlich.';

  @override
  String get phoneNumberLabel => 'Telefonnummer';

  @override
  String get submitButton => 'Demo-Formular absenden';

  @override
  String get formValidated => 'Formular validiert!';

  @override
  String get dateOfBirthPrefix => 'Geburtsdatum';

  @override
  String get nationalityPrefix => 'Staatsangehörigkeit';

  @override
  String get countryOfResidencePrefix => 'Wohnsitzland';

  @override
  String get phonePrefix => 'Telefon';

  @override
  String get languageMenuTooltip => 'Sprache';
}
