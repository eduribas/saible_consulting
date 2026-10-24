// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Welsh (`cy`).
class AppLocalizationsCy extends AppLocalizations {
  AppLocalizationsCy([String locale = 'cy']) : super(locale);

  @override
  String get appTitle => 'Demo Cofrestru';

  @override
  String get privacyNotice =>
      'Rhybudd Preifatrwydd: Mae hwn yn ap arddangos. Ni chair unrhyw un o\'r wybodaeth a nodir yma ei storio, ei throsglwyddo na\'i rhannu.';

  @override
  String get dateOfBirthErrorRequired => 'Mae angen eich dyddiad geni.';

  @override
  String get dateOfBirthErrorInvalid => 'Mae angen dyddiad geni dilys.';

  @override
  String dateOfBirthErrorTooEarly(String min) {
    return 'Ni all eich dyddiad geni fod cyn $min (mae\'n rhaid i chi honni eich bod dros 18 oed i gyflwyno\'r ffurflen).';
  }

  @override
  String dateOfBirthErrorTooLate(String max) {
    return 'Mae\'n rhaid i chi honni eich bod dros 18 oed i alluogi\'r ffurflen. Dewiswch ddyddiad ar neu cyn $max.';
  }

  @override
  String get dateOfBirthLabel => 'Dyddiad Geni';

  @override
  String get nationalityErrorRequired => 'Mae angen eich cenedligrwydd.';

  @override
  String get nationalityLabel => 'Cenedligrwydd';

  @override
  String get countryOfResidenceErrorRequired => 'Mae angen eich gwlad breswyl.';

  @override
  String get countryOfResidenceLabel => 'Gwlad Breswyl';

  @override
  String get phoneNumberErrorRequired => 'Mae angen eich rhif ffôn.';

  @override
  String get phoneNumberErrorInvalid => 'Mae angen rhif ffôn dilys.';

  @override
  String get phoneNumberLabel => 'Rhif Ffôn';

  @override
  String get submitButton => 'Cyflwyno\'r Ffurflen Ddemo';

  @override
  String get formValidated => 'Ffurflen wedi\'i ddilysu!';

  @override
  String get dateOfBirthPrefix => 'Dyddiad Geni';

  @override
  String get nationalityPrefix => 'Cenedligrwydd';

  @override
  String get countryOfResidencePrefix => 'Gwlad Breswyl';

  @override
  String get phonePrefix => 'Ffôn';

  @override
  String get languageMenuTooltip => 'Iaith';
}
