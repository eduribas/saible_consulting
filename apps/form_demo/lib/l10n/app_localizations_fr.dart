// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Démo d\'inscription';

  @override
  String get privacyNotice =>
      'Avis de confidentialité : Ceci est une application de démonstration. Aucune des informations saisies ici n\'est stockée, transmise ou partagée.';

  @override
  String get dateOfBirthErrorRequired => 'Votre date de naissance est obligatoire.';

  @override
  String get dateOfBirthErrorInvalid => 'Une date de naissance valide est requise.';

  @override
  String dateOfBirthErrorTooEarly(String min) {
    return 'Votre date de naissance ne peut pas être antérieure au $min (vous devez déclarer avoir plus de 18 ans pour envoyer le formulaire).';
  }

  @override
  String dateOfBirthErrorTooLate(String max) {
    return 'Vous devez déclarer avoir plus de 18 ans pour activer le formulaire. Choisissez une date égale ou antérieure au $max.';
  }

  @override
  String get dateOfBirthLabel => 'Date de naissance';

  @override
  String get nationalityErrorRequired => 'Votre nationalité est obligatoire.';

  @override
  String get nationalityLabel => 'Nationalité';

  @override
  String get countryOfResidenceErrorRequired => 'Votre pays de résidence est obligatoire.';

  @override
  String get countryOfResidenceLabel => 'Pays de résidence';

  @override
  String get phoneNumberErrorRequired => 'Votre numéro de téléphone est obligatoire.';

  @override
  String get phoneNumberErrorInvalid => 'Un numéro de téléphone valide est requis.';

  @override
  String get phoneNumberLabel => 'Numéro de téléphone';

  @override
  String get submitButton => 'Envoyer le formulaire de démo';

  @override
  String get formValidated => 'Formulaire validé !';

  @override
  String get dateOfBirthPrefix => 'Date de naissance';

  @override
  String get nationalityPrefix => 'Nationalité';

  @override
  String get countryOfResidencePrefix => 'Pays de résidence';

  @override
  String get phonePrefix => 'Téléphone';

  @override
  String get languageMenuTooltip => 'Langue';
}
