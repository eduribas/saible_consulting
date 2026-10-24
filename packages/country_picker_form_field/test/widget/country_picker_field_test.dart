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

import 'package:country_picker_form_field/application/country_picker_mode.dart';
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
    CountryPickerMode mode = CountryPickerMode.searchAnchor,
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
            child: CountryPickerFormField(
              mode: mode,
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
              include: include,
              exclude: exclude,
              filter: filter,
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

  group('CountryPicker dropdown', () {
    /// The `DropdownMenu` currently rendered by the field.
    DropdownMenu<Iso3166Country> dropdownMenu(WidgetTester tester) =>
        tester.widget<DropdownMenu<Iso3166Country>>(find.byType(DropdownMenu<Iso3166Country>));

    /// The countries the `filterCallback` keeps for [query], in ranked order.
    List<Iso3166Country> filteredCountries(WidgetTester tester, String query) {
      final menu = dropdownMenu(tester);
      return menu.filterCallback!(menu.dropdownMenuEntries, query).map((entry) => entry.value).toList();
    }

    testWidgets('renders a DropdownMenu instead of a search anchor', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DropdownMenu<Iso3166Country>), findsOneWidget);
      expect(find.byType(SearchAnchor), findsNothing);
      expect(find.byType(FlagIcon), findsWidgets);
    });

    testWidgets('shows the initial country', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          initial: Iso3166Country.france,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'France');
    });

    testWidgets('maps the decoration label, hint and error height onto the field', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country of Residence',
          hintText: 'Select country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final decoration = tester.widget<TextField>(find.byType(TextField)).decoration!;
      expect(decoration.labelText, 'Country of Residence');
      expect(decoration.hintText, 'Select country');
      expect(decoration.errorMaxLines, 2);
      // No suffixIcon was supplied, so the DropdownMenu contributes its own arrow.
      expect(find.byIcon(Icons.arrow_drop_down), findsWidgets);
    });

    testWidgets('a caller-supplied suffixIcon replaces the drop-down arrow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          localizationsDelegates: SaibleLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Center(
              child: CountryPickerFormField(
                mode: CountryPickerMode.dropdown,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  suffixIcon: Icon(Icons.flag, key: Key('custom_suffix')),
                ),
                onCountryPicked: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_suffix')), findsWidgets);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('lists favourites first, trailing the last one with a divider', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          // Chosen so they are neither alphabetical nor adjacent to the top of
          // the sorted list, proving they are actually hoisted.
          favorites: const [Iso3166Country.zimbabwe, Iso3166Country.brazil],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final entries = dropdownMenu(tester).dropdownMenuEntries;
      expect(entries.take(2).map((entry) => entry.value).toList(), [
        Iso3166Country.zimbabwe,
        Iso3166Country.brazil,
      ]);
      // Only the final favourite is trailed by the divider.
      expect(entries[1].labelWidget, isNotNull);
      expect(entries.where((entry) => entry.labelWidget != null), hasLength(1));
      // The divider is actually laid out across the menu entry (which is at least
      // 112 wide), rather than collapsing to its intrinsic width.
      final divider = find.byKey(CountryPickerFormField.favoritesDividerKey).first;
      expect(tester.getSize(divider).width, greaterThan(100));
      expect(tester.getSize(divider).height, greaterThan(0));
    });

    testWidgets('shows the plain list when there are no favourites', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(dropdownMenu(tester).dropdownMenuEntries.every((entry) => entry.labelWidget == null), isTrue);
      expect(find.byKey(CountryPickerFormField.favoritesDividerKey), findsNothing);
    });

    testWidgets('shows the plain list when every country is a favourite', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          favorites: Iso3166Country.values,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(dropdownMenu(tester).dropdownMenuEntries.every((entry) => entry.labelWidget == null), isTrue);
      expect(find.byKey(CountryPickerFormField.favoritesDividerKey), findsNothing);
    });

    testWidgets('keeps the divider beside the last favourite while filtering', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          // Only Zimbabwe matches the query below, so a divider fixed to the last
          // configured favourite (France) would disappear while filtering.
          favorites: const [Iso3166Country.zimbabwe, Iso3166Country.france],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final filtered = dropdownMenu(tester).filterCallback!(
        const <DropdownMenuEntry<Iso3166Country>>[],
        'Zimb',
      );
      expect(filtered.first.value, Iso3166Country.zimbabwe);
      expect(filtered.first.labelWidget, isNotNull);
      // A non-favourite matches too, so the divider is warranted.
      expect(filtered.map((entry) => entry.value), contains(Iso3166Country.zambia));
      expect(filtered.where((entry) => entry.labelWidget != null), hasLength(1));
    });

    testWidgets('filterCallback keeps every entry for an empty filter', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        filteredCountries(tester, ''),
        hasLength(dropdownMenu(tester).dropdownMenuEntries.length),
      );
    });
    testWidgets('filterCallback matches typo-tolerantly and ranks the best match first', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(filteredCountries(tester, 'germny').first, Iso3166Country.germany);
    });

    testWidgets('filterCallback matches ISO codes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(filteredCountries(tester, 'DE').first, Iso3166Country.germany);
      expect(filteredCountries(tester, 'DEU').first, Iso3166Country.germany);
    });

    testWidgets('filterCallback returns nothing when no country matches', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(filteredCountries(tester, 'zzzzzzzz'), isEmpty);
    });

    testWidgets('filterCallback hoists favourites ahead of better-scoring matches', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          favorites: const [Iso3166Country.unitedArabEmirates],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final matches = filteredCountries(tester, 'united');
      expect(matches, contains(Iso3166Country.unitedKingdom));
      expect(matches, contains(Iso3166Country.unitedStates));
      expect(matches.first, Iso3166Country.unitedArabEmirates);
    });

    testWidgets('selecting an entry reports it via onCountryPicked', (tester) async {
      // No focusNode is supplied: the field is still typeable because the
      // DropdownMenu sets requestFocusOnTap, which is what makes filtering
      // reachable on platforms that would otherwise leave the field read-only.
      Iso3166Country? selected;
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          onCountryPicked: (country) => selected = country,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'germny');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Germany').last);
      await tester.pumpAndSettle();

      expect(selected, Iso3166Country.germany);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Germany');
    });

    testWidgets('validator and onSaved integrate with the enclosing Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      Iso3166Country? savedCountry;

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Nationality',
          mode: CountryPickerMode.dropdown,
          formKey: formKey,
          onCountryPicked: (_) {},
          validator: (country) => country == null ? 'Select a country' : null,
          onSaved: (country) => savedCountry = country,
        ),
      );
      await tester.pumpAndSettle();

      // Nothing selected yet, so the validator rejects the field and the
      // message is surfaced through the DropdownMenu's error text.
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Select a country'), findsOneWidget);

      // Pick Germany from the fuzzy-filtered menu.
      await tester.enterText(find.byType(TextField), 'germny');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Germany').last);
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Select a country'), findsNothing);

      // Saving the form hands the chosen country, not the search text, to onSaved.
      formKey.currentState!.save();
      expect(savedCountry, Iso3166Country.germany);
    });
  });

  group('CountryPicker include, exclude and filter', () {
    /// The countries the dropdown offers, in menu order.
    List<Iso3166Country> dropdownCountries(WidgetTester tester) => tester
        .widget<DropdownMenu<Iso3166Country>>(find.byType(DropdownMenu<Iso3166Country>))
        .dropdownMenuEntries
        .map((entry) => entry.value)
        .toList();

    /// The countries the suggestions view currently offers, in list order.
    List<Iso3166Country> suggestionCountries(WidgetTester tester) =>
        tester.widgetList<NationTile>(find.byType(NationTile)).map((tile) => tile.country).toList();

    /// Opens the suggestions view of a search-anchor field.
    Future<void> openSuggestions(WidgetTester tester) async {
      await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
      await tester.pumpAndSettle();
    }

    /// Types [query] into the already open suggestions view.
    Future<void> enterQuery(WidgetTester tester, String query) async {
      await tester.enterText(find.byType(TextField).last, query);
      await tester.pumpAndSettle();
    }

    testWidgets('include offers only the included countries, in localized order', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          // Deliberately reversed, to show the caller's order is not preserved.
          include: const [Iso3166Country.germany, Iso3166Country.france],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(dropdownCountries(tester), [Iso3166Country.france, Iso3166Country.germany]);
    });

    testWidgets('include restricts the suggestions view to the included countries', (tester) async {
      const included = [Iso3166Country.france, Iso3166Country.germany];
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          include: included,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await openSuggestions(tester);

      // The unfiltered suggestions are exactly the included countries.
      expect(suggestionCountries(tester), included);

      // An included country stays searchable...
      await enterQuery(tester, 'France');
      expect(suggestionCountries(tester), contains(Iso3166Country.france));

      // ...while a country left out of include is unreachable, even by name.
      await enterQuery(tester, 'Finland');
      expect(suggestionCountries(tester), isNot(contains(Iso3166Country.finland)));
      expect(suggestionCountries(tester), everyElement(isIn(included)));
    });

    testWidgets('an empty include list offers nothing', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          include: const <Iso3166Country>[],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(dropdownCountries(tester), isEmpty);
    });

    testWidgets('exclude omits the excluded countries', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          exclude: const [Iso3166Country.france, Iso3166Country.germany],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final countries = dropdownCountries(tester);
      expect(countries, isNot(contains(Iso3166Country.france)));
      expect(countries, isNot(contains(Iso3166Country.germany)));
      expect(countries, contains(Iso3166Country.finland));
      expect(countries, hasLength(Iso3166Country.values.length - 2));
    });

    testWidgets('exclude removes a country from the suggestions view', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          exclude: const [Iso3166Country.finland],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await openSuggestions(tester);

      // Countries that remain offered are still searchable...
      await enterQuery(tester, 'Fiji');
      expect(suggestionCountries(tester), contains(Iso3166Country.fiji));

      // ...while the excluded one cannot be reached, even by its exact name.
      await enterQuery(tester, 'Finland');
      expect(suggestionCountries(tester), isNot(contains(Iso3166Country.finland)));
    });

    testWidgets('filter restricts the dropdown entries', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          filter: (country) => country != Iso3166Country.france,
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final countries = dropdownCountries(tester);
      expect(countries, isNot(contains(Iso3166Country.france)));
      expect(countries, contains(Iso3166Country.germany));
      expect(countries, hasLength(Iso3166Country.values.length - 1));
    });

    testWidgets('filter restricts the suggestions view', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          // A dynamic filter: only countries whose alpha-2 code starts with 'F'.
          filter: (country) => country.alpha2.startsWith('F'),
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await openSuggestions(tester);
      await enterQuery(tester, 'France');
      expect(suggestionCountries(tester), contains(Iso3166Country.france));

      await enterQuery(tester, 'Germany');
      expect(suggestionCountries(tester), isNot(contains(Iso3166Country.germany)));

      // No suggestion slips past the filter, whatever the query.
      await enterQuery(tester, 'a');
      final suggestions = suggestionCountries(tester);
      expect(suggestions, isNotEmpty);
      expect(suggestions.every((country) => country.alpha2.startsWith('F')), isTrue);
    });
    testWidgets('filter is re-evaluated whenever the field rebuilds', (tester) async {
      Widget build(bool allowFrance) => buildTestWidget(
        labelText: 'Country',
        mode: CountryPickerMode.dropdown,
        filter: (country) => allowFrance || country != Iso3166Country.france,
        onCountryPicked: (_) {},
      );

      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(dropdownCountries(tester), contains(Iso3166Country.france));

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();
      expect(dropdownCountries(tester), isNot(contains(Iso3166Country.france)));
    });

    test('include, exclude and filter cannot be combined', () {
      // At most one of the three may be supplied, enforced by an assertion on the
      // field's constructor.
      expect(
        () => CountryPickerFormField(
          include: const [Iso3166Country.france],
          exclude: const [Iso3166Country.germany],
          onCountryPicked: (_) {},
        ),
        throwsAssertionError,
      );
      expect(
        () => CountryPickerFormField(
          include: const [Iso3166Country.france],
          filter: (country) => country != Iso3166Country.germany,
          onCountryPicked: (_) {},
        ),
        throwsAssertionError,
      );
      expect(
        () => CountryPickerFormField(
          exclude: const [Iso3166Country.france],
          filter: (country) => country != Iso3166Country.germany,
          onCountryPicked: (_) {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('ignores favourites that are not offered', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Country',
          mode: CountryPickerMode.dropdown,
          include: const [Iso3166Country.france, Iso3166Country.germany, Iso3166Country.zimbabwe],
          // Brazil is not in the offered list, so it is silently dropped.
          favorites: const [Iso3166Country.brazil, Iso3166Country.zimbabwe],
          onCountryPicked: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(dropdownCountries(tester), [
        Iso3166Country.zimbabwe,
        Iso3166Country.france,
        Iso3166Country.germany,
      ]);
      expect(find.byKey(CountryPickerFormField.favoritesDividerKey), findsWidgets);
    });
  });
}
