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

import 'package:material_ui/material_ui.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

/// Runs the `saible_consulting_core` example application.
void main() => runApp(const CoreExampleApp());

/// Root widget, configured with the package's `SaibleLocalizations`, which
/// pairs the country strings with `material_ui`'s localization delegates.
class const CoreExampleApp({super.key}) extends StatelessWidget {
  /// Creates a [CoreExampleApp].
  this;

  @override
  Widget build(BuildContext context) => const MaterialApp(
    supportedLocales: SaibleLocalizations.supportedLocales,
    localizationsDelegates: SaibleLocalizations.localizationsDelegates,
    home: CoreExamplePage(),
  );
}

/// Demonstrates country lookups, fuzzy search and the date extensions.
class const CoreExamplePage({super.key}) extends StatelessWidget {
  /// The countries listed at the top of the example.
  static const List<Iso3166Country> featured = [
    Iso3166Country.unitedKingdom,
    Iso3166Country.france,
    Iso3166Country.japan,
  ];

  /// Creates a [CoreExamplePage].
  this;

  @override
  Widget build(BuildContext context) {
    // Typo-tolerant search across all 249 countries, using the localized names,
    // the ISO codes and the aliases as search terms.
    final List<Iso3166Country> matches = TextSearch<Iso3166Country>([
      for (final Iso3166Country country in Iso3166Country.values)
        TextSearchItem<Iso3166Country>.fromTerms(
          country,
          country.searchTerms(context),
        ),
    ]).fastSearch('germny', limit: 3);

    // Timezone-safe calendar arithmetic: no DST skew, no duration maths.
    final DateTime today = DateTime.now().dateOnly();
    final List<DateTime> dates = [today, today.addDays(30), today.addMonths(3), today.addYears(-18)];
    final DateTime latest = dates.max();

    return Scaffold(
      appBar: AppBar(title: const Text('saible_consulting_core')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Featured countries'),
          for (final Iso3166Country country in featured)
            _CountryRow(country: country),
          const Divider(height: 32),
          const _SectionTitle('fastSearch("germny")'),
          for (final Iso3166Country country in matches)
            _CountryRow(country: country),
          const Divider(height: 32),
          const _SectionTitle('Date extensions'),
          Text('dateOnly(): ${_formatDate(today)}'),
          Text('addDays(30): ${_formatDate(today.addDays(30))}'),
          Text('addMonths(3): ${_formatDate(today.addMonths(3))}'),
          Text('addYears(-18): ${_formatDate(today.addYears(-18))}'),
          Text('dates.max(): ${_formatDate(latest)}'),
        ],
      ),
    );
  }

  /// Formats [date] as an ISO-8601 calendar date, e.g. `2026-09-28`.
  static String _formatDate(DateTime date) =>
      date.toIso8601String().substring(0, 10);
}

/// A section heading used to group the parts of the example.
class const _SectionTitle(this.title) extends StatelessWidget {
  /// The heading text.
  final String title;

  /// Creates a [_SectionTitle].
  this;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// Renders a single country with its flag, localized name and codes.
class const _CountryRow({required this.country}) extends StatelessWidget {
  /// The country rendered by this row.
  final Iso3166Country country;

  /// Creates a [_CountryRow] for [country].
  this;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Text(country.flagEmoji(), style: const TextStyle(fontSize: 24)),
    title: Text(country.tr(context)),
    subtitle: Text(
      '${country.alpha2} · ${country.alpha3} · +${country.phoneCode}',
    ),
  );
}
