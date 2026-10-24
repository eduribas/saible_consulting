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
import 'package:provider/provider.dart';
import 'package:saible_consulting_core/application/text_search_item.dart';
import 'package:saible_consulting_core/domain/iso3166_countries.dart';
import 'package:saible_consulting_core/l10n/app_localizations.dart';

/// Precomputed country lists and search terms for lookup and telephone filtering.
typedef Countries = ({
  List<Iso3166Country> countries,
  List<TextSearchItem<Iso3166Country>> searchTerms,
  List<TextSearchItem<Iso3166Country>> phoneSearchTerms,
});

/// A function to perform a dynamic filter on a list of countries
/// 
/// Use with caution within a BuildContext
extension CountryFilterExtension on Countries {
  /// The filter to apply to the list at build time
  Countries where(BuildContext context, bool Function(Iso3166Country) filter) {
    final filteredCountries = countries.where(filter).toList();
    return (
      countries: filteredCountries,
      searchTerms: filteredCountries.map((e) => TextSearchItem.fromTerms(e, e.searchTerms(context))).toList(),
      phoneSearchTerms: filteredCountries.map((e) => TextSearchItem.fromTerms(e, e.phoneSearchTerms(context))).toList(),
    );
  }
}

class const _Provider({
  required this.child,
  this.include,
  this.exclude,
}) extends StatelessWidget {
  final Widget child;
  final List<Iso3166Country>? include;
  final List<Iso3166Country>? exclude;
  this;

  @override
  Widget build(BuildContext context) {
    final values = switch ((include, exclude)) {
      (final List<Iso3166Country> i, _) => i,
      (_, final List<Iso3166Country> e) => Iso3166Country.values.where((v) => !e.contains(v)),
      _ => Iso3166Country.values,
    };
    final countries = [...values]..sort((x, y) => x.tr(context).compareTo(y.tr(context)));
    return Provider<Countries>.value(
      value: (
        countries: countries,
        searchTerms: countries.map((e) => TextSearchItem.fromTerms(e, e.searchTerms(context))).toList(),
        phoneSearchTerms: countries.map((e) => TextSearchItem.fromTerms(e, e.phoneSearchTerms(context))).toList(),
      ),
      child: child,
    );
  }
}

/// Injects localized [Countries] data into the widget tree via [Provider].
class CountriesProvider({
  super.key,
  this.include,
  this.exclude,
  required this.child,
}) extends StatelessWidget {
  /// The widget below this provider in the tree.
  final Widget child;

  /// An opt-in list of countries to include
  /// 
  /// Cannot be used at the same time as [CountriesProvider.exclude])
  final List<Iso3166Country>? include;

  /// An opt-out list of countries to exclude
  /// 
  /// Cannot be used at the same time as [CountriesProvider.include])
  final List<Iso3166Country>? exclude;

  /// Creates a [CountriesProvider] that provides country metadata to [child].
  this {
    final CountriesProvider(:include, :exclude) = this;
    assert(
      [include, exclude].where((e) => e != null).length <= 1,
      'Only one of include and exclude can be used at any one time.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en', 'GB');
    return Provider<CountryLocalizations>.value(
      value: lookupCountryLocalizations(locale),
      child: _Provider(include: include, exclude: exclude, child: child, ),
    );
  }
}
