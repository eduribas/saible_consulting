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

import 'package:country_picker_form_field/presentation/country_picker_form_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

void main() {
  Widget buildTestWidget({
    Locale locale = const Locale('en', 'GB'),
    required String labelText,
    required void Function(Iso3166Country country) onCountryPicked,
    Iso3166Country? initial,
    List<Iso3166Country>? favorites,
    String? hintText,
    FocusNode? focusNode,
    GlobalKey<FormState>? formKey,
    String? Function(Iso3166Country? country)? validator,
    void Function(Iso3166Country? country)? onSaved,
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
            child: CountryPickerFormField(
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
              ),
              onCountryPicked: onCountryPicked,
              initial: initial,
              favorites: favorites,
              focusNode: focusNode,
              validator: validator,
              onSaved: onSaved,
            ),
          ),
        ),
      ),
    );
  }

  group('CountryPicker', () {
    testWidgets('renders properly with labelText, hintText, and default icon when initial is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country of Residence',
          hintText: 'Select country',
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Country of Residence'), findsOneWidget);
      expect(find.text('Select country'), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byType(FlagIcon), findsNothing);
    });
    testWidgets('renders properly when decoration is omitted', (tester) async {
      final saibleLoc = lookupCountryLocalizations(const Locale('en', 'GB'));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          supportedLocales: SaibleLocalizations.supportedLocales,
          localizationsDelegates: SaibleLocalizations.localizationsDelegates,
          builder: (context, child) => Provider<CountryLocalizations>.value(
            value: saibleLoc,
            child: child,
          ),
          home: Scaffold(
            body: Center(
              child: CountryPickerFormField(
                onCountryPicked: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CountryPickerFormField), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('allows overriding suffixIcon via decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          localizationsDelegates: SaibleLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Center(
              child: CountryPickerFormField(
                decoration: const InputDecoration(
                  labelText: 'Country',
                  suffixIcon: Icon(Icons.arrow_drop_down, key: Key('custom_suffix')),
                ),
                initial: Iso3166Country.unitedKingdom,
                onCountryPicked: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_suffix')), findsOneWidget);
      expect(find.byType(FlagIcon), findsNothing);
      expect(find.byIcon(Icons.language), findsNothing);
    });



    testWidgets('renders initial country name and flag icon when initial country is provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country of Residence',
          initial: Iso3166Country.unitedKingdom,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('United Kingdom'), findsOneWidget);
      expect(find.byType(FlagIcon), findsOneWidget);
      expect(find.byIcon(Icons.language), findsNothing);
    });

    testWidgets('opens suggestions view on tap and displays suggestions', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('countryPicker_searchBar')));
      await tester.pumpAndSettle();

      expect(find.byType(NationTile), findsWidgets);
    });

    testWidgets('filters suggestions and selects a country', (tester) async {
      Iso3166Country? selectedCountry;
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          onCountryPicked: (country) => selectedCountry = country,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('countryPicker_searchBar')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'France');
      await tester.pumpAndSettle();

      final franceTileKey = Key('countryPicker_country_${Iso3166Country.france.alpha2}');
      expect(find.byKey(franceTileKey), findsOneWidget);

      await tester.tap(find.byKey(franceTileKey));
      await tester.pumpAndSettle();

      expect(selectedCountry, Iso3166Country.france);
      expect(find.text('France'), findsOneWidget);
      expect(find.byType(FlagIcon), findsOneWidget);
    });

    testWidgets('restores previous selection on close if no new country was selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          initial: Iso3166Country.germany,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Germany'), findsOneWidget);

      await tester.tap(find.byKey(const Key('countryPicker_searchBar')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'xyz');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Germany'), findsOneWidget);
    });

    testWidgets('uses provided focusNode', (tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          focusNode: focusNode,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isFalse);
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      focusNode.dispose();
    });

    testWidgets('supports different locales (e.g. French)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('fr'),
          labelText: 'Pays',
          initial: Iso3166Country.unitedKingdom,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Royaume-Uni'), findsOneWidget);
      expect(find.text('Pays'), findsOneWidget);
    });
    
    testWidgets('re-translates the selected country name when the locale changes', (tester) async {
      var pickedCount = 0;
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          initial: Iso3166Country.unitedKingdom,
          onCountryPicked: (_) {
            pickedCount++;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('United Kingdom'), findsOneWidget);

      // Switch the app locale from en-GB to de; the same field state is kept
      // alive (same element tree position) so only dependencies re-resolve.
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('de'),
          labelText: 'Country',
          initial: Iso3166Country.unitedKingdom,
          onCountryPicked: (_) {
            pickedCount++;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vereinigtes Königreich'), findsOneWidget);
      expect(find.text('United Kingdom'), findsNothing);
      // The selection is unchanged; only its presentation was re-derived.
      expect(pickedCount, 0);
    });

    testWidgets('typing or changing text opens suggestions view via onChanged', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(CountryPickerFormField.countrySearchBarKey), 'Fra');
      await tester.pumpAndSettle();

      expect(find.byType(NationTile), findsWidgets);
    });

    testWidgets('validator and onSaved integrate with the enclosing Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      Iso3166Country? savedCountry;

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Nationality',
          formKey: formKey,
          onCountryPicked: (_) {},
          validator: (country) => country == null ? 'Select a country' : null,
          onSaved: (country) => savedCountry = country,
        ),
      );
      await tester.pumpAndSettle();

      // Nothing selected yet, so the validator rejects the field.
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Select a country'), findsOneWidget);

      // Pick France from the suggestions view.
      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'France');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('countryPicker_country_${Iso3166Country.france.alpha2}')));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Select a country'), findsNothing);

      // Saving the form hands the chosen country, not the search text, to onSaved.
      formKey.currentState!.save();
      expect(savedCountry, Iso3166Country.france);
    });
  });

  group('CountryPicker favourites', () {
    /// The countries currently rendered as suggestions, in list order.
    List<Iso3166Country> suggestionCountries(WidgetTester tester) =>
        tester.widgetList<NationTile>(find.byType(NationTile)).map((tile) => tile.country).toList();

    testWidgets('lists favourites first, separated from the rest by a divider', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          // Chosen so they are neither alphabetical nor adjacent to the top of
          // the sorted list, proving they are actually hoisted.
          favorites: const [Iso3166Country.zimbabwe, Iso3166Country.brazil],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();

      final countries = suggestionCountries(tester);
      // Favourites appear first, in the order the caller supplied them.
      expect(countries.take(2).toList(), [Iso3166Country.zimbabwe, Iso3166Country.brazil]);
      expect(countries.length, greaterThan(2));

      // A single divider sits between the favourite and remaining groups.
      final dividerFinder = find.byKey(CountryPickerFormField.favoritesDividerKey);
      expect(dividerFinder, findsOneWidget);
      final dividerY = tester.getTopLeft(dividerFinder).dy;
      final lastFavoriteY = tester.getTopLeft(
        find.byKey(Key('countryPicker_country_${Iso3166Country.brazil.alpha2}')),
      ).dy;
      final firstOtherY = tester.getTopLeft(
        find.byKey(Key('countryPicker_country_${countries[2].alpha2}')),
      ).dy;
      expect(dividerY, greaterThan(lastFavoriteY));
      expect(dividerY, lessThan(firstOtherY));
    });

    testWidgets('omits the divider when only favourites match the query', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          favorites: const [Iso3166Country.zimbabwe],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Zimbabwe');
      await tester.pumpAndSettle();

      expect(suggestionCountries(tester), [Iso3166Country.zimbabwe]);
      expect(find.byKey(CountryPickerFormField.favoritesDividerKey), findsNothing);
    });

    testWidgets('hides favourites that do not match the current query', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          favorites: const [Iso3166Country.japan],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'France');
      await tester.pumpAndSettle();

      final countries = suggestionCountries(tester);
      expect(countries, contains(Iso3166Country.france));
      expect(countries, isNot(contains(Iso3166Country.japan)));
    });

    testWidgets('selecting a favourite reports it via onCountryPicked', (tester) async {
      Iso3166Country? selected;
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          favorites: const [Iso3166Country.newZealand],
          onCountryPicked: (country) => selected = country,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(Key('countryPicker_country_${Iso3166Country.newZealand.alpha2}')),
      );
      await tester.pumpAndSettle();

      expect(selected, Iso3166Country.newZealand);
      expect(find.text('New Zealand'), findsOneWidget);
    });

    testWidgets('shows no divider when no favourites are configured', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'France');
      await tester.pumpAndSettle();

      expect(find.byType(NationTile), findsWidgets);
      expect(find.byKey(CountryPickerFormField.favoritesDividerKey), findsNothing);
    });
  });
}
