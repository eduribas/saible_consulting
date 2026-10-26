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
import 'package:provider/provider.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

/// Builds a minimal widget tree whose [Localizations] widget carries [locale]
/// so that context-based localization lookups resolve to it.
Widget _localeHarness(Locale locale, ValueChanged<BuildContext> onContext) => Localizations(
      locale: locale,
      delegates: const [CountryLocalizations.delegate, DefaultWidgetsLocalizations.delegate],
      child: Builder(
        builder: (context) {
          onContext(context);
          return const SizedBox.shrink();
        },
      ),
    );

void main() {
  testWidgets('CountryLocalizations loads English and Welsh translations for ISO 3166 countries using ISO-2 keys', (tester) async {
    await tester.pumpWidget(_localeHarness(const Locale('en', 'GB'), (context) {
      final enLocalizations = CountryLocalizations.of(context);
      expect(enLocalizations.country_GB, 'United Kingdom');
      expect(enLocalizations.country_AF, 'Afghanistan');
    }));

    await tester.pumpWidget(_localeHarness(const Locale('cy'), (context) {
      final cyLocalizations = CountryLocalizations.of(context);
      expect(cyLocalizations.country_GB, 'y Deyrnas Unedig');
      expect(cyLocalizations.country_AF, 'Affganistan');
    }));
  });

  testWidgets('Iso3166Country enum tr function looks up translations from the ambient locale', (tester) async {
    await tester.pumpWidget(_localeHarness(const Locale('en', 'GB'), (context) {
      expect(Iso3166Country.unitedKingdom.tr(context), 'United Kingdom');
      expect(Iso3166Country.afghanistan.tr(context), 'Afghanistan');
    }));

    await tester.pumpWidget(_localeHarness(const Locale('cy'), (context) {
      expect(Iso3166Country.unitedKingdom.tr(context), 'y Deyrnas Unedig');
      expect(Iso3166Country.afghanistan.tr(context), 'Affganistan');
    }));
  });

  testWidgets('Iso3166Country tr falls back to en-GB when no Localizations ancestor is present', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          expect(Iso3166Country.unitedKingdom.tr(context), 'United Kingdom');
          expect(Iso3166Country.afghanistan.tr(context), 'Afghanistan');
          return const SizedBox.shrink();
        },
      ),
    );
  });

  testWidgets('CountryLocalizations loads translations for common languages', (tester) async {
    const expectations = <(Locale, String)>[
      (Locale('es'), 'Reino Unido'),
      (Locale('fr'), 'Royaume-Uni'),
      (Locale('de'), 'Vereinigtes Königreich'),
      (Locale('zh'), '英国'),
      (Locale('ja'), 'イギリス'),
      (Locale('ar'), 'المملكة المتحدة'),
      (Locale('ko'), '영국'),
      (Locale('tr'), 'Birleşik Krallık'),
      (Locale('el'), 'Ηνωμένο Βασίλειο'),
      (Locale('uk'), 'Велика Британія'),
      (Locale('vi'), 'Vương quốc Anh'),
      (Locale('cs'), 'Spojené království'),
    ];

    for (final (locale, translation) in expectations) {
      await tester.pumpWidget(
        _localeHarness(locale, (context) {
          expect(Iso3166Country.unitedKingdom.tr(context), translation);
        }),
      );
    }
  });

  testWidgets('Iso3166Country enum tr function returns non-empty localized name for all countries', (tester) async {
    expect(Iso3166Country.values, isNotEmpty);
    expect(Iso3166Country.values.length, 249);

    await tester.pumpWidget(_localeHarness(const Locale('en', 'GB'), (context) {
      for (final country in Iso3166Country.values) {
        expect(
          country.tr(context),
          isNotEmpty,
          reason: 'Country ${country.name} (${country.alpha2}) English translation should not be empty',
        );
      }
    }));

    await tester.pumpWidget(_localeHarness(const Locale('cy'), (context) {
      for (final country in Iso3166Country.values) {
        expect(
          country.tr(context),
          isNotEmpty,
          reason: 'Country ${country.name} (${country.alpha2}) Welsh translation should not be empty',
        );
      }
    }));
  });

  testWidgets('CountryExtension methods generate valid flag emojis and search terms', (tester) async {
    await tester.pumpWidget(_localeHarness(const Locale('en', 'GB'), (context) {
      for (final country in Iso3166Country.values) {
        final flag = country.flagEmoji();
        expect(flag, isNotEmpty, reason: '${country.name} flagEmoji should not be empty');

        final searchTerms = country.searchTerms(context);
        expect(searchTerms, contains(country.alpha2));
        expect(searchTerms, contains(country.alpha3));
        expect(searchTerms, contains(country.tr(context)));

        final phoneSearchTerms = country.phoneSearchTerms(context);
        expect(phoneSearchTerms, contains(country.phoneCode.toString()));
        expect(phoneSearchTerms, contains('+${country.phoneCode}'));
      }

      const uk = Iso3166Country.unitedKingdom;
      expect(uk.flagEmoji(), '🇬🇧');
      expect(uk.searchTerms(context), containsAll(['GB', 'GBR', 'United Kingdom']));
      expect(uk.phoneSearchTerms(context), containsAll(['+44', '44']));
    }));
  });
  group('CountriesProvider and presentation widgets', () {
    testWidgets('renders CountriesProvider, NationTile, PhoneCodeTile and FlagIcon', (tester) async {
      var nationTapped = false;
      var phoneCodeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          locale: const Locale('en', 'GB'),
          localizationsDelegates: const [CountryLocalizations.delegate],
          supportedLocales: CountryLocalizations.supportedLocales,
          home: CountriesProvider(
            child: Builder(
              builder: (context) {
                final countriesData = context.watch<Countries>();
                return Scaffold(
                  body: ListView(
                    children: [
                      Text('Count: ${countriesData.countries.length}'),
                      NationTile(
                        country: Iso3166Country.unitedKingdom,
                        onTap: () {
                          nationTapped = true;
                        },
                      ),
                      PhoneCodeTile(
                        country: Iso3166Country.france,
                        onTap: () {
                          phoneCodeTapped = true;
                        },
                      ),
                      const FlagIcon.forIso3166(country: Iso3166Country.germany),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Count: 249'), findsOneWidget);
      expect(find.text('United Kingdom'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
      expect(find.text('+33'), findsOneWidget);
      expect(find.text(Iso3166Country.germany.flagEmoji()), findsOneWidget);

      await tester.tap(find.text('United Kingdom'));
      expect(nationTapped, isTrue);

      await tester.tap(find.text('France'));
      expect(phoneCodeTapped, isTrue);
    });

    test('throws AssertionError if include and exclude are both provided', () {
      expect(
        () => CountriesProvider(
          include: const [Iso3166Country.france],
          exclude: const [Iso3166Country.germany],
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });
}
