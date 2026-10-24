import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cy.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cy'),
    Locale('de'),
    Locale('en'),
    Locale('en', 'GB'),
    Locale('fr'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Registration Demo'**
  String get appTitle;

  /// No description provided for @privacyNotice.
  ///
  /// In en_GB, this message translates to:
  /// **'Privacy Notice: This is a demonstration app. None of the information entered here is stored, transmitted, or shared.'**
  String get privacyNotice;

  /// No description provided for @dateOfBirthErrorRequired.
  ///
  /// In en_GB, this message translates to:
  /// **'Your date of birth is required.'**
  String get dateOfBirthErrorRequired;

  /// No description provided for @dateOfBirthErrorInvalid.
  ///
  /// In en_GB, this message translates to:
  /// **'A valid date of birth is required.'**
  String get dateOfBirthErrorInvalid;

  /// No description provided for @dateOfBirthErrorTooEarly.
  ///
  /// In en_GB, this message translates to:
  /// **'Your date of birth cannot precede {min} (you have to claim to be over 18 to submit the form).'**
  String dateOfBirthErrorTooEarly(String min);

  /// No description provided for @dateOfBirthErrorTooLate.
  ///
  /// In en_GB, this message translates to:
  /// **'You must claim to be over 18 to enable the form. Choose a date on or before {max}.'**
  String dateOfBirthErrorTooLate(String max);

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en_GB, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @nationalityErrorRequired.
  ///
  /// In en_GB, this message translates to:
  /// **'Your nationality is required.'**
  String get nationalityErrorRequired;

  /// No description provided for @nationalityLabel.
  ///
  /// In en_GB, this message translates to:
  /// **'Nationality'**
  String get nationalityLabel;

  /// No description provided for @countryOfResidenceErrorRequired.
  ///
  /// In en_GB, this message translates to:
  /// **'Your country of residence is required.'**
  String get countryOfResidenceErrorRequired;

  /// No description provided for @countryOfResidenceLabel.
  ///
  /// In en_GB, this message translates to:
  /// **'Country of Residence'**
  String get countryOfResidenceLabel;

  /// No description provided for @phoneNumberErrorRequired.
  ///
  /// In en_GB, this message translates to:
  /// **'Your phone number is required.'**
  String get phoneNumberErrorRequired;

  /// No description provided for @phoneNumberErrorInvalid.
  ///
  /// In en_GB, this message translates to:
  /// **'A valid phone number is required.'**
  String get phoneNumberErrorInvalid;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en_GB, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @submitButton.
  ///
  /// In en_GB, this message translates to:
  /// **'Submit Demo Form'**
  String get submitButton;

  /// No description provided for @formValidated.
  ///
  /// In en_GB, this message translates to:
  /// **'Form Validated!'**
  String get formValidated;

  /// No description provided for @dateOfBirthPrefix.
  ///
  /// In en_GB, this message translates to:
  /// **'DoB'**
  String get dateOfBirthPrefix;

  /// No description provided for @nationalityPrefix.
  ///
  /// In en_GB, this message translates to:
  /// **'Nationality'**
  String get nationalityPrefix;

  /// No description provided for @countryOfResidencePrefix.
  ///
  /// In en_GB, this message translates to:
  /// **'Country of Residence'**
  String get countryOfResidencePrefix;

  /// No description provided for @phonePrefix.
  ///
  /// In en_GB, this message translates to:
  /// **'Phone'**
  String get phonePrefix;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In en_GB, this message translates to:
  /// **'Language'**
  String get languageMenuTooltip;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['cy', 'de', 'en', 'fr', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cy':
      return AppLocalizationsCy();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
