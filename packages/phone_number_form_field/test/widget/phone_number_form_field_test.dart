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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phone_number_form_field/domain/phone_number.dart';
import 'package:phone_number_form_field/presentation/phone_number_form_field.dart';
import 'package:provider/provider.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

void main() {
  Widget buildTestWidget({
    Locale locale = const Locale('en', 'GB'),
    FocusNode? focusNode,
    String? labelText,
    String? errorText,
    int? errorMaxLines,
    PhoneNumberState? initialValue,
    ValueChanged<PhoneNumberState>? onPhoneNumberChanged,
    GlobalKey<FormState>? formKey,
    String? Function(PhoneNumberState state)? validator,
    void Function(PhoneNumberState state)? onSaved,
    String? hintText,
    List<Iso3166Country>? include,
    List<Iso3166Country>? exclude,
    bool Function(Iso3166Country)? filter,

  }) {
    final saibleLoc = lookupCountryLocalizations(locale);
    return MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      locale: locale,
      supportedLocales: SaibleLocalizations.supportedLocales,
      localizationsDelegates: SaibleLocalizations.localizationsDelegates,
      builder: (context, child) => Provider<CountryLocalizations>.value(
        value: saibleLoc,
        child: child,
      ),
      home: Scaffold(
        body: Center(
          child: Form(
            key: formKey,
            child: PhoneNumberFormField(
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: labelText,
                errorText: errorText,
                hintText: hintText,

                errorMaxLines: errorMaxLines,
              ),
              initialValue: initialValue,
              onPhoneNumberChanged: onPhoneNumberChanged,
              validator: validator,
              onSaved: onSaved,
              include: include,
              exclude: exclude,
              filter: filter,
            ),
          ),
        ),
      ),
    );
  }

  group('PhoneNumberField', () {
    testWidgets('renders default state with UK flag, +44, labelText and empty text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(labelText: 'Mobile Phone'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mobile Phone'), findsOneWidget);
      expect(find.text('+44'), findsOneWidget);
      expect(find.text(Iso3166Country.unitedKingdom.flagEmoji()), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      final searchBarFinder = find.byKey(PhoneNumberFormField.textInputKey);
      expect(searchBarFinder, findsOneWidget);
      final textFormField = tester.widget<TextFormField>(searchBarFinder);
      expect(textFormField.controller?.text, isEmpty);
    });
    testWidgets('allows overriding hintText via decoration', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          hintText: 'Custom Phone Hint',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Phone Hint'), findsOneWidget);
    });


    testWidgets('displays errorText and uses focusNode', (tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        buildTestWidget(
          focusNode: focusNode,
          labelText: 'Phone',
          errorText: 'Invalid phone number',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid phone number'), findsOneWidget);
      expect(focusNode.hasFocus, isFalse);

      await tester.tap(find.byKey(PhoneNumberFormField.textInputKey));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      focusNode.dispose();
    });

    testWidgets('renders with initialValue and pre-selects country and formatted text', (tester) async {
      // Official Ofcom reserved drama dummy number: 020 7946 0123 / +442079460123
      const initial = PhoneNumberState(
        rawText: '20 7946 0123',
        e164: '+442079460123',
        regionCode: '+44',
      );

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone Number',
          initialValue: initial,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+44'), findsOneWidget);
      expect(find.text(Iso3166Country.unitedKingdom.flagEmoji()), findsOneWidget);

      final textFormField = tester.widget<TextFormField>(
        find.byKey(PhoneNumberFormField.textInputKey),
      );
      expect(textFormField.controller?.text, isNotEmpty);
    });

    testWidgets('renders with foreign initialValue (e.g. US) and selects US country', (tester) async {
      // Standard reserved 555 fictional US number: +12015550123
      const initial = PhoneNumberState(
        rawText: '201 555 0123',
        e164: '+12015550123',
        regionCode: '+1',
      );

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone Number',
          initialValue: initial,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+1'), findsOneWidget);
      expect(find.text(Iso3166Country.unitedStates.flagEmoji()), findsOneWidget);
    });

    testWidgets('formats a US initialValue in national style, matching as-you-type output', (tester) async {
      // Standard reserved 555 fictional US number: +12015550123. The field must
      // render `(201) 555-0123`, not the international `201-555-0123`, so that
      // pre-filled values display identically to a number typed by the user.
      const initial = PhoneNumberState(
        rawText: '201 555 0123',
        e164: '+12015550123',
        regionCode: '+1',
      );

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone Number',
          initialValue: initial,
        ),
      );
      await tester.pumpAndSettle();

      final textFormField = tester.widget<TextFormField>(
        find.byKey(PhoneNumberFormField.textInputKey),
      );
      expect(textFormField.controller?.text, '(201) 555-0123');

      // Typing the same number must produce the same rendered text.
      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '2015550123');
      await tester.pumpAndSettle();

      final typedFormField = tester.widget<TextFormField>(
        find.byKey(PhoneNumberFormField.textInputKey),
      );
      expect(typedFormField.controller?.text, '(201) 555-0123');
    });

    testWidgets('formats as-you-type and notifies onPhoneNumberChanged with valid E164', (tester) async {
      final changedValues = <PhoneNumberState>[];

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          onPhoneNumberChanged: changedValues.add,
        ),
      );
      await tester.pumpAndSettle();

      // Enter official Ofcom drama dummy number: 020 7946 0123
      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '02079460123');
      await tester.pumpAndSettle();

      expect(changedValues, isNotEmpty);
      final last = changedValues.last;
      expect(last.regionCode, '+44');
      expect(last.e164, isNotNull);
      expect(last.isValid, isTrue);
      expect(last.e164, '+442079460123');
    });

    testWidgets('notifies with null e164 when phone number is incomplete or cleared', (tester) async {
      final changedValues = <PhoneNumberState>[];

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          onPhoneNumberChanged: changedValues.add,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '123');
      await tester.pumpAndSettle();

      expect(changedValues.last.e164, isNull);
      expect(changedValues.last.isValid, isFalse);

      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '');
      await tester.pumpAndSettle();

      expect(changedValues.last.isEmpty, isTrue);
      expect(changedValues.last.e164, isNull);
    });

    testWidgets('tapping prefix opens search view with PhoneCodeTile suggestions', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(labelText: 'Phone'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('+44'));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneCodeTile), findsWidgets);
    });

    testWidgets('can search country in prefix search view, change country and reset input', (tester) async {
      PhoneNumberState? latestValue;

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          onPhoneNumberChanged: (val) => latestValue = val,
        ),
      );
      await tester.pumpAndSettle();

      // Enter dummy number under UK
      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '02079460123');
      await tester.pumpAndSettle();
      expect(latestValue?.e164, '+442079460123');

      // Tap prefix to open search view
      await tester.tap(find.text('+44'));
      await tester.pumpAndSettle();

      // Search for France
      await tester.enterText(find.byType(TextField).last, 'France');
      await tester.pumpAndSettle();

      final franceTileKey = PhoneNumberFormField.countrySuggestionKey(Iso3166Country.france);
      expect(find.byKey(franceTileKey), findsOneWidget);

      await tester.tap(find.byKey(franceTileKey));
      await tester.pumpAndSettle();

      // Now France is selected with code +33, controller text is reset
      expect(find.text('+33'), findsOneWidget);
      expect(find.text(Iso3166Country.france.flagEmoji()), findsOneWidget);

      final textFormField = tester.widget<TextFormField>(
        find.byKey(PhoneNumberFormField.textInputKey),
      );
      expect(textFormField.controller?.text, isEmpty);
      expect(latestValue?.rawText, isEmpty);
      expect(latestValue?.regionCode, '+33');
      expect(latestValue?.e164, isNull);
    });

    testWidgets('can search by dial code prefix in prefix search view', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(labelText: 'Phone'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('+44'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '33');
      await tester.pumpAndSettle();

      final franceTileKey = PhoneNumberFormField.countrySuggestionKey(Iso3166Country.france);
      expect(find.byKey(franceTileKey), findsOneWidget);
    });

    testWidgets('handles parse error gracefully in formatting', (tester) async {
      final changedValues = <PhoneNumberState>[];

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          onPhoneNumberChanged: changedValues.add,
        ),
      );
      await tester.pumpAndSettle();

      // Enter text that could trigger parsing exceptions
      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '+++');
      await tester.pumpAndSettle();

      expect(changedValues.last.e164, isNull);
    });

    testWidgets('validator and onSaved integrate with the enclosing Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      PhoneNumberState? savedState;

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Mobile Phone',
          formKey: formKey,
          validator: (state) => state.isValid ? null : 'Enter a valid phone number',
          onSaved: (state) => savedState = state,
        ),
      );
      await tester.pumpAndSettle();

      // An empty field fails validation and surfaces the validator's message.
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsOneWidget);

      // A complete UK number passes the same validator.
      await tester.enterText(find.byKey(PhoneNumberFormField.textInputKey), '02079460123');
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsNothing);

      // Saving the form hands the parsed state, not the raw text, to onSaved.
      formKey.currentState!.save();
      expect(savedState, isNotNull);
      expect(savedState!.e164, '+442079460123');
      expect(savedState!.regionCode, '+44');
      expect(savedState!.rawText, isNotEmpty);
    });
    
    test('throws AssertionError if prefix is provided in decoration', () {
      expect(
        () => PhoneNumberFormField(
          decoration: const InputDecoration(prefix: Text('+1')),
        ),
        throwsAssertionError,
      );
    });

    test('throws AssertionError if prefixIcon is provided in decoration', () {
      expect(
        () => PhoneNumberFormField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.phone)),
        ),
        throwsAssertionError,
      );
    });

    test('throws AssertionError if prefixText is provided in decoration', () {
      expect(
        () => PhoneNumberFormField(
          decoration: const InputDecoration(prefixText: '+1'),
        ),
        throwsAssertionError,
      );
    });

  });

  group('PhoneNumberField include, exclude and filter', () {
    /// The countries the dial code picker currently offers, in list order.
    List<Iso3166Country> suggestionCountries(WidgetTester tester) =>
        tester.widgetList<PhoneCodeTile>(find.byType(PhoneCodeTile)).map((tile) => tile.country).toList();

    /// Opens the dial code picker by tapping the dial code prefix control.
    Future<void> openPicker(WidgetTester tester) async {
      await tester.tap(find.byKey(PhoneNumberFormField.countrySearchAnchorKey));
      await tester.pumpAndSettle();
    }

    /// Types [query] into the already open dial code picker.
    Future<void> search(WidgetTester tester, String query) async {
      await tester.enterText(find.byType(TextField).last, query);
      await tester.pumpAndSettle();
    }

    testWidgets('include offers only the included countries', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          // Deliberately reversed, to show the caller's order is not preserved.
          include: const [Iso3166Country.germany, Iso3166Country.france],
        ),
      );
      await tester.pumpAndSettle();
      await openPicker(tester);

      expect(suggestionCountries(tester), [Iso3166Country.france, Iso3166Country.germany]);
    });

    testWidgets('include restricts the dial code search', (tester) async {
      const included = [Iso3166Country.france, Iso3166Country.germany];
      await tester.pumpWidget(
        buildTestWidget(labelText: 'Phone', include: included),
      );
      await tester.pumpAndSettle();
      await openPicker(tester);

      // An included country is reachable by its dial code...
      await search(tester, '33');
      expect(suggestionCountries(tester), contains(Iso3166Country.france));

      // ...while a country left out of include is unreachable, even by dial code.
      await search(tester, '44');
      expect(suggestionCountries(tester), isNot(contains(Iso3166Country.unitedKingdom)));
      expect(suggestionCountries(tester), everyElement(isIn(included)));
    });

    testWidgets('an empty include list offers nothing', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          include: const <Iso3166Country>[],
        ),
      );
      await tester.pumpAndSettle();
      await openPicker(tester);

      expect(tester.takeException(), isNull);
      expect(suggestionCountries(tester), isEmpty);
    });

    testWidgets('falls back to the first offered country when the default is excluded', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          // The package default (United Kingdom) is not on offer, so the implicit
          // default falls back to the first country that is.
          exclude: const [Iso3166Country.unitedKingdom],
        ),
      );

      // Resolved before the first frame, so the unoffered default is never shown.
      expect(find.text('+93'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('+44'), findsNothing);
      expect(find.text('+93'), findsOneWidget);
      expect(find.text(Iso3166Country.afghanistan.flagEmoji()), findsOneWidget);
    });

    testWidgets('falls back to the first offered country when the default is not included', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          include: const [Iso3166Country.germany, Iso3166Country.france],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+44'), findsNothing);
      expect(find.text('+33'), findsOneWidget);
      expect(find.text(Iso3166Country.france.flagEmoji()), findsOneWidget);
    });

    testWidgets('keeps an explicit initialValue even when its country is not offered', (tester) async {
      // Official Ofcom reserved drama dummy number: 020 7946 0123 / +442079460123
      const initial = PhoneNumberState(
        rawText: '20 7946 0123',
        e164: '+442079460123',
        regionCode: '+44',
      );

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          initialValue: initial,
          // The initial value's country is not on offer, but it is an explicit
          // choice, so it is kept rather than reconciled with include.
          include: const [Iso3166Country.france, Iso3166Country.germany],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+44'), findsOneWidget);
      expect(find.text(Iso3166Country.unitedKingdom.flagEmoji()), findsOneWidget);
    });
    testWidgets('exclude omits the excluded countries', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          exclude: const [Iso3166Country.france],
        ),
      );
      await tester.pumpAndSettle();
      await openPicker(tester);

      // The excluded country is no longer reachable by its dial code...
      await search(tester, '33');
      expect(suggestionCountries(tester), isNot(contains(Iso3166Country.france)));

      // ...while the other countries are unaffected.
      await search(tester, '49');
      expect(suggestionCountries(tester), contains(Iso3166Country.germany));
    });

    testWidgets('filter restricts the dial code picker', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          // A predicate no include/exclude list could express: only the
          // countries whose calling code is +33 or +49.
          filter: (country) => country.phoneCode == 33 || country.phoneCode == 49,
        ),
      );
      await tester.pumpAndSettle();
      await openPicker(tester);

      expect(suggestionCountries(tester), [Iso3166Country.france, Iso3166Country.germany]);

      await search(tester, '44');
      expect(suggestionCountries(tester), isNot(contains(Iso3166Country.unitedKingdom)));
    });

    testWidgets('filter only offers countries that satisfy it', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Phone',
          // Only countries whose ISO alpha-2 code starts with 'F'.
          filter: (country) => country.alpha2.startsWith('F'),
        ),
      );
      await tester.pumpAndSettle();
      await openPicker(tester);

      final suggestions = suggestionCountries(tester);
      expect(suggestions, isNotEmpty);
      expect(suggestions.every((country) => country.alpha2.startsWith('F')), isTrue);
    });
    test('include, exclude and filter cannot be combined', () {
      // At most one of the three may be supplied, enforced by an assertion on the
      // field's constructor.
      expect(
        () => PhoneNumberFormField(
          include: const [Iso3166Country.france],
          exclude: const [Iso3166Country.germany],
        ),
        throwsAssertionError,
      );
      expect(
        () => PhoneNumberFormField(
          include: const [Iso3166Country.france],
          filter: (country) => country != Iso3166Country.germany,
        ),
        throwsAssertionError,
      );
      expect(
        () => PhoneNumberFormField(
          exclude: const [Iso3166Country.france],
          filter: (country) => country != Iso3166Country.germany,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('filter is re-evaluated whenever the field rebuilds', (tester) async {
      Widget build(bool allowFrance) => buildTestWidget(
        labelText: 'Phone',
        filter: (country) => allowFrance || country != Iso3166Country.france,
      );

      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      await openPicker(tester);
      await search(tester, '33');
      expect(suggestionCountries(tester), contains(Iso3166Country.france));

      // An open view keeps the suggestions builder it was opened with, so it has
      // to be dismissed before rebuilding the field with a different filter.
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();
      await openPicker(tester);
      await search(tester, '33');
      expect(suggestionCountries(tester), isNot(contains(Iso3166Country.france)));
    });
  });
}
