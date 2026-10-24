// Copyright 2026 Saible Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:country_picker_form_field/country_picker_form_field.dart';
import 'package:date_picker_form_field/date_picker_form_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_demo/main.dart';
import 'package:form_demo/presentation/language_menu.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phone_number_form_field/phone_number_form_field.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

void main() {
  setUpAll(() async {
    // The date picker formats dates via intl, which needs the date symbols
    // for every locale the language switcher can select.
    await initializeDateFormatting();
  });

  group('Form Demo App Widget Tests', () {
    testWidgets('renders all primary form fields and UI elements', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('Registration Demo'), findsOneWidget);

      // Privacy Notice Banner
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.textContaining('Privacy Notice: This is a demonstration app.'), findsOneWidget);

      // Form fields
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.byKey(DatePickerFormField.textInputKey), findsOneWidget);
      expect(find.byKey(DatePickerFormField.launchDatePickerKey), findsOneWidget);

      expect(find.text('Nationality'), findsOneWidget);
      expect(find.byKey(CountryPickerFormField.countrySearchBarKey), findsOneWidget);

      expect(find.text('Country of Residence'), findsWidgets);
      // The residence field is a dropdown-mode country picker restricted to the
      // UK crown dependencies, with the United Kingdom as its favourite.
      expect(
        tester.widget<DropdownMenu<Iso3166Country>>(find.byType(DropdownMenu<Iso3166Country>))
            .dropdownMenuEntries.map((entry) => entry.value).toList(),
        [Iso3166Country.unitedKingdom, Iso3166Country.guernsey, Iso3166Country.isleOfMan, Iso3166Country.jersey],
      );

      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.byKey(PhoneNumberFormField.textInputKey), findsOneWidget);
      expect(find.text('+44'), findsOneWidget);

      // Submit Button is disabled initially
      final submitButtonFinder = find.widgetWithText(FilledButton, 'Submit Demo Form');
      expect(submitButtonFinder, findsOneWidget);
      final submitButton = tester.widget<FilledButton>(submitButtonFinder);
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('language switcher icon opens a menu listing all supported languages', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      expect(find.byKey(LanguageSwitcher.switcherButtonKey), findsOneWidget);
      // Icons.language also appears as the nationality field's empty-state
      // suffix icon, so scope this check to the app bar.
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.byIcon(Icons.language)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(LanguageSwitcher.switcherButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('English (GB)'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('Deutsch'), findsOneWidget);
      expect(find.text('Cymraeg'), findsOneWidget);
      expect(find.text('English (US)'), findsOneWidget);
      expect(find.text('日本語'), findsOneWidget);
    });

    testWidgets('the active language is ticked in the menu', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(LanguageSwitcher.switcherButtonKey));
      await tester.pumpAndSettle();

      // English is active by default in the test environment.
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Switch to Deutsch and reopen the menu.
      await tester.tap(find.byKey(LanguageSwitcher.menuItemKey(const Locale('de'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(LanguageSwitcher.switcherButtonKey));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.descendant(of: find.byKey(LanguageSwitcher.menuItemKey(const Locale('de'))), matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );
    });

    testWidgets('switching language localises the app bar, labels and submit button', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(LanguageSwitcher.switcherButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      expect(find.text("Démo d'inscription"), findsOneWidget);
      expect(find.text('Date de naissance'), findsOneWidget);
      expect(find.text('Nationalité'), findsOneWidget);
      expect(find.text('Pays de résidence'), findsWidgets);
      expect(find.text('Numéro de téléphone'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Envoyer le formulaire de démo'), findsOneWidget);

      // Switching back to English restores the English strings.
      await tester.tap(find.byKey(LanguageSwitcher.switcherButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English (GB)'));
      await tester.pumpAndSettle();

      expect(find.text('Registration Demo'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
    });

    testWidgets('validating date of birth shows error messages on invalid input', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      final dobField = find.byKey(DatePickerFormField.textInputKey);

      // 1. Typing incomplete date (triggers invalid error)
      await tester.enterText(dobField, '1');
      await tester.pumpAndSettle();
      expect(find.text('A valid date of birth is required.'), findsOneWidget);

      // 2. Clear date (triggers required error)
      await tester.enterText(dobField, '');
      await tester.pumpAndSettle();
      expect(find.text('Your date of birth is required.'), findsOneWidget);

      // 3. Year before 1900 (triggers tooEarly error)
      await tester.enterText(dobField, '01011899');
      await tester.pumpAndSettle();
      expect(find.textContaining('Your date of birth cannot precede'), findsOneWidget);

      // 4. Future/underage date (triggers tooLate error)
      await tester.enterText(dobField, '01012025');
      await tester.pumpAndSettle();
      expect(find.textContaining('You must claim to be over 18'), findsOneWidget);

      // 5. Valid date clears error
      await tester.enterText(dobField, '15061995');
      await tester.pumpAndSettle();
      expect(find.text('A valid date of birth is required.'), findsNothing);
      expect(find.text('Your date of birth is required.'), findsNothing);
      expect(find.textContaining('Your date of birth cannot precede'), findsNothing);
      expect(find.textContaining('You must claim to be over 18'), findsNothing);
    });

    testWidgets('selecting date of birth via calendar picker sets valid date', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      // Open DatePickerDialog
      await tester.tap(find.byKey(DatePickerFormField.launchDatePickerKey));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Navigate to previous month to ensure day 15 is within range regardless of current date
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Select day 15 in the calendar
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      // Confirm selected date by tapping OK button in DatePickerDialog
      final okButton = find.widgetWithText(TextButton, 'OK');
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);

      // Field text now contains '15'
      final dobField = tester.widget<TextFormField>(find.byKey(DatePickerFormField.textInputKey));
      expect(dobField.controller?.text, contains('15'));
    });

    testWidgets('selecting nationality updates field and shows country flag', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      // Tap Nationality search bar to open suggestions view
      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();

      // Search for France
      await tester.enterText(find.byType(TextField).last, 'France');
      await tester.pumpAndSettle();

      final franceTileKey = Key('countryPicker_country_${Iso3166Country.france.alpha2}');
      expect(find.byKey(franceTileKey), findsOneWidget);

      // Select France
      await tester.tap(find.byKey(franceTileKey));
      await tester.pumpAndSettle();

      expect(find.text('France'), findsOneWidget);
      // Assert the selected country's flag specifically: the residence dropdown
      // renders its entries (and their flag icons) offscreen for width
      // measurement, so find.byType(FlagIcon) would match those too.
      expect(find.text(Iso3166Country.france.flagEmoji()), findsOneWidget);
    });

    testWidgets('validating phone number shows error messages on invalid input', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      final phoneField = find.byKey(PhoneNumberFormField.textInputKey);

      // Incomplete phone number triggers invalid error
      await tester.enterText(phoneField, '123');
      await tester.pumpAndSettle();
      expect(find.text('A valid phone number is required.'), findsOneWidget);

      // Clearing phone number triggers required error
      await tester.enterText(phoneField, '');
      await tester.pumpAndSettle();
      expect(find.text('Your phone number is required.'), findsOneWidget);

      // Valid phone number clears errors
      await tester.enterText(phoneField, '02079460123');
      await tester.pumpAndSettle();
      expect(find.text('A valid phone number is required.'), findsNothing);
      expect(find.text('Your phone number is required.'), findsNothing);
    });

    testWidgets('changing country code in phone number field updates prefix', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      // Tap country dial code prefix (+44) to open country selector
      await tester.tap(find.text('+44'));
      await tester.pumpAndSettle();

      // Search for France
      await tester.enterText(find.byType(TextField).last, 'France');
      await tester.pumpAndSettle();

      final francePhoneTileKey = PhoneNumberFormField.countrySuggestionKey(Iso3166Country.france);
      expect(find.byKey(francePhoneTileKey), findsOneWidget);
      await tester.tap(find.byKey(francePhoneTileKey));
      await tester.pumpAndSettle();

      expect(find.text('+33'), findsOneWidget);
      expect(find.text(Iso3166Country.france.flagEmoji()), findsOneWidget);
    });

    testWidgets('submit button enables when all fields are valid and shows SnackBar on submission', (tester) async {
      await tester.pumpWidget(const DemoApp());
      await tester.pumpAndSettle();

      // Initially submit button is disabled
      var submitButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit Demo Form'));
      expect(submitButton.onPressed, isNull);

      // 1. Enter valid Date of Birth: 15/06/1990
      await tester.enterText(find.byKey(DatePickerFormField.textInputKey), '15061990');
      await tester.pumpAndSettle();

      // Submit still disabled
      submitButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit Demo Form'));
      expect(submitButton.onPressed, isNull);

      // 2. Select Nationality: United Kingdom
      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'United Kingdom');
      await tester.pumpAndSettle();
      final ukTileKey = Key('countryPicker_country_${Iso3166Country.unitedKingdom.alpha2}');
      await tester.tap(find.byKey(ukTileKey));
      await tester.pumpAndSettle();

      // Submit still disabled
      submitButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit Demo Form'));
      expect(submitButton.onPressed, isNull);

      // 3. Enter valid phone number: 020 7946 0123
      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '02079460123');
      await tester.pumpAndSettle();

      // Submit still disabled: the country of residence is mandatory
      submitButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit Demo Form'));
      expect(submitButton.onPressed, isNull);

      // 4. Select Country of Residence: Jersey, from the dropdown-mode picker
      await tester.tap(find.byType(DropdownMenu<Iso3166Country>));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Jersey').last);
      await tester.pumpAndSettle();

      // Submit button is now enabled!
      submitButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit Demo Form'));
      expect(submitButton.onPressed, isNotNull);

      // 5. Tap submit button
      await tester.tap(find.widgetWithText(FilledButton, 'Submit Demo Form'));
      await tester.pumpAndSettle();

      // Verify SnackBar content
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Form Validated!'), findsOneWidget);
      expect(find.textContaining('DoB: 15/06/1990'), findsOneWidget);
      expect(find.textContaining('Nationality: United Kingdom'), findsOneWidget);
      expect(find.textContaining('Country of Residence: Jersey'), findsOneWidget);
      expect(find.textContaining('Phone: +44 20 7946 0123'), findsOneWidget);
    });
  });
}
