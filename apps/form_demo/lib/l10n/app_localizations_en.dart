// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Registration Demo';

  @override
  String get privacyNotice =>
      'Privacy Notice: This is a demonstration app. None of the information entered here is stored, transmitted, or shared.';

  @override
  String get dateOfBirthErrorRequired => 'Your date of birth is required.';

  @override
  String get dateOfBirthErrorInvalid => 'A valid date of birth is required.';

  @override
  String dateOfBirthErrorTooEarly(String min) {
    return 'Your date of birth cannot precede $min (you have to claim to be over 18 to submit the form).';
  }

  @override
  String dateOfBirthErrorTooLate(String max) {
    return 'You must claim to be over 18 to enable the form. Choose a date on or before $max.';
  }

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get nationalityErrorRequired => 'Your nationality is required.';

  @override
  String get nationalityLabel => 'Nationality';

  @override
  String get countryOfResidenceErrorRequired => 'Your country of residence is required.';

  @override
  String get countryOfResidenceLabel => 'Country of Residence';

  @override
  String get phoneNumberErrorRequired => 'Your phone number is required.';

  @override
  String get phoneNumberErrorInvalid => 'A valid phone number is required.';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get submitButton => 'Submit Demo Form';

  @override
  String get formValidated => 'Form Validated!';

  @override
  String get dateOfBirthPrefix => 'DoB';

  @override
  String get nationalityPrefix => 'Nationality';

  @override
  String get countryOfResidencePrefix => 'Country of Residence';

  @override
  String get phonePrefix => 'Phone';

  @override
  String get languageMenuTooltip => 'Language';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appTitle => 'Registration Demo';

  @override
  String get privacyNotice =>
      'Privacy Notice: This is a demonstration app. None of the information entered here is stored, transmitted, or shared.';

  @override
  String get dateOfBirthErrorRequired => 'Your date of birth is required.';

  @override
  String get dateOfBirthErrorInvalid => 'A valid date of birth is required.';

  @override
  String dateOfBirthErrorTooEarly(String min) {
    return 'Your date of birth cannot precede $min (you have to claim to be over 18 to submit the form).';
  }

  @override
  String dateOfBirthErrorTooLate(String max) {
    return 'You must claim to be over 18 to enable the form. Choose a date on or before $max.';
  }

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get nationalityErrorRequired => 'Your nationality is required.';

  @override
  String get nationalityLabel => 'Nationality';

  @override
  String get countryOfResidenceErrorRequired => 'Your country of residence is required.';

  @override
  String get countryOfResidenceLabel => 'Country of Residence';

  @override
  String get phoneNumberErrorRequired => 'Your phone number is required.';

  @override
  String get phoneNumberErrorInvalid => 'A valid phone number is required.';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get submitButton => 'Submit Demo Form';

  @override
  String get formValidated => 'Form Validated!';

  @override
  String get dateOfBirthPrefix => 'DoB';

  @override
  String get nationalityPrefix => 'Nationality';

  @override
  String get countryOfResidencePrefix => 'Country of Residence';

  @override
  String get phonePrefix => 'Phone';

  @override
  String get languageMenuTooltip => 'Language';
}
