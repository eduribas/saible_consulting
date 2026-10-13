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

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:saible_consulting_core/application/text_search_item.dart';
import 'package:saible_consulting_core/domain/iso3166_countries.dart';
import 'package:saible_consulting_core/presentation/countries_provider.dart';
import 'package:saible_consulting_core/presentation/nation_tile.dart';

class const _DefaultSuffix({
  this.country
}) extends StatelessWidget {
  final Iso3166Country? country;

  @override
  Widget build(BuildContext context) {
    final country = this.country;
    if (country == null) return const Icon(Icons.language);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FlagIcon.forIso3166(country: country),
    );
  }
}

/// The suggestions for a country search query, split into favourite and
/// remaining matches so the two groups can be rendered separately.
class _CountrySuggestions({
  required this.favorites,
  required this.others,
}) {
  /// The favourite countries matching the query, in the caller's order.
  final List<Iso3166Country> favorites;

  /// The non-favourite countries matching the query.
  final List<Iso3166Country> others;

  /// Whether both groups contain at least one suggestion, in which case the
  /// suggestions view separates them with a divider.
  bool get hasDivider => favorites.isNotEmpty && others.isNotEmpty;
}

/// A prepared country search over a locale's [TextSearchItem]s.
///
/// The terms are partitioned once, at construction, into favourites and the
/// remaining countries so that favourites can be matched first on every
/// keystroke without the shared result limit pushing them out (for example when
/// the query is empty and the unfiltered list would otherwise start
/// alphabetically). Favourites retain the caller's order, with duplicates and
/// unknown countries discarded.
class _CountrySearch._(this._favorites, this._others) {
  factory _CountrySearch({
    required List<TextSearchItem<Iso3166Country>> searchTerms,
    required List<Iso3166Country> favorites,
  }) {
    final termsByCountry = {for (final term in searchTerms) term.item: term};
    final favoriteCountries = <Iso3166Country>{};
    final favoriteItems = <TextSearchItem<Iso3166Country>>[];
    for (final country in favorites) {
      final term = termsByCountry[country];
      if (term != null && favoriteCountries.add(country)) favoriteItems.add(term);
    }
    final otherItems = <TextSearchItem<Iso3166Country>>[
      for (final term in searchTerms)
        if (!favoriteCountries.contains(term.item)) term,
    ];
    return _CountrySearch._(TextSearch(favoriteItems), TextSearch(otherItems));
  }

  /// The highest number of suggestions shown at once, shared across the
  /// favourites and remaining-countries groups.
  static const int _maxSuggestions = 12;

  /// The favourite countries' search terms, in the caller's order.
  final TextSearch<Iso3166Country> _favorites;

  /// The remaining countries' search terms.
  final TextSearch<Iso3166Country> _others;

  /// Matches the prepared terms against [query], listing favourite matches
  /// first (in the caller's order) and remaining matches afterwards.
  _CountrySuggestions suggest(String query) {
    final favorites = _favorites.fastSearch(query, limit: _maxSuggestions);
    final remaining = _maxSuggestions - favorites.length;
    final others = remaining > 0
        ? _others.fastSearch(query, limit: remaining)
        : const <Iso3166Country>[];
    return _CountrySuggestions(favorites: favorites, others: others);
  }
}

class const _CountryPicker({
  required this.onCountryPicked,
  this.initial,
  this.favorites,
  this.decoration,
  this.focusNode,
  this.validator,
  this.onSaved,
}) extends StatefulWidget {
  static Key countrySuggestionKey(Iso3166Country country) => Key('countryPicker_country_${country.alpha2}');
  final void Function(Iso3166Country country) onCountryPicked;
  final Iso3166Country? initial;
  final List<Iso3166Country>? favorites;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final String? Function(Iso3166Country? country)? validator;
  final void Function(Iso3166Country? country)? onSaved;

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState() extends State<_CountryPicker> {
  late final SearchController controller;
  Iso3166Country? chosenCountry;
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    controller = SearchController();
    // The initial display text is seeded in didChangeDependencies, which runs
    // immediately after initState with a fully mounted context; localization
    // lookups are not legal in initState itself.
    chosenCountry = widget.initial;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.maybeLocaleOf(context);
    // isOpen asserts that the controller is attached to a SearchAnchor, which
    // it is not during the first pass, so isAttached is checked first.
    if (locale == _lastLocale || (controller.isAttached && controller.isOpen)) return;
    _lastLocale = locale;
    // The controller text is a pure presentation of the selection, so it is
    // re-derived whenever the ambient locale changes (e.g. the user switches
    // the app language and "United Kingdom" becomes "Vereinigtes Königreich").
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller.text = chosenCountry?.tr(context) ?? '';
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prepared once per rebuild (not per keystroke): the search terms are
    // stable for the current locale, so the favourites/remaining split is
    // computed here rather than on every keystroke.
    final search = _CountrySearch(
      searchTerms: context.watch<Countries>().searchTerms,
      favorites: widget.favorites ?? const <Iso3166Country>[],
    );
    return SearchAnchor(
      key: CountryPickerFormField.countrySearchAnchorKey,
      searchController: controller,
      builder: (context, controller) => TextFormField(
        focusNode: widget.focusNode,
        key: CountryPickerFormField.countrySearchBarKey,
        controller: controller,
        onTap: () => controller.openView(),
        onChanged: (_) => controller.openView(),
        // Typed form integration: the enclosing Form validates and saves the
        // chosen country rather than the search text.
        validator: (_) => widget.validator?.call(chosenCountry),
        onSaved: (_) => widget.onSaved?.call(chosenCountry),
        decoration: (widget.decoration ?? const InputDecoration()).copyWith(
          errorMaxLines: widget.decoration?.errorMaxLines ?? 2,
          suffixIcon: widget.decoration?.suffixIcon ?? _DefaultSuffix(country: chosenCountry),
        ),
      ),
      viewOnClose: () {
        controller.text = chosenCountry?.tr(context) ?? '';
      },
      suggestionsBuilder: (context, controller) => _suggestions(context, controller, search),
    );
  }

  /// Renders the suggestions for the controller's current query: favourite
  /// matches first, a divider when both groups are present, then the rest.
  List<Widget> _suggestions(BuildContext context, SearchController controller, _CountrySearch search) {
    final suggestions = search.suggest(controller.text);
    return [
      for (final country in suggestions.favorites)
        _suggestionTile(context, controller, country),
      // Only divide the two groups when each contributes at least one
      // suggestion, so a lone group is never trailed by a stray divider.
      if (suggestions.hasDivider)
        const Divider(key: CountryPickerFormField.favoritesDividerKey),
      for (final country in suggestions.others)
        _suggestionTile(context, controller, country),
    ];
  }

  /// A tappable suggestion for [country] that updates the selection, closes the
  /// search view and reports the choice to the picker's `onCountryPicked`.
  Widget _suggestionTile(BuildContext context, SearchController controller, Iso3166Country country) => NationTile(
    key: _CountryPicker.countrySuggestionKey(country),
    country: country,
    onTap: () {
      setState(() { chosenCountry = country; });
      controller.closeView(country.tr(context));
      widget.onCountryPicked(country);
    },
  );
}

/// A form field widget that allows selecting a country using a searchable view.
class const CountryPickerFormField({
  super.key,
  this.decoration,
  required this.onCountryPicked,
  this.initial,
  this.favorites,
  this.focusNode,
  this.validator,
  this.onSaved,
}) extends StatelessWidget {
  /// The [Key] for the country search anchor view.
  static const Key countrySearchAnchorKey = Key('countryPicker_searchAnchor');

  /// The [Key] for the country search bar field.
  static const Key countrySearchBarKey = Key('countryPicker_searchBar');

  /// The [Key] for the [Divider] separating favourites from the remaining
  /// suggestions. Only present while both groups contribute a suggestion.
  static const Key favoritesDividerKey = Key('countryPicker_favoritesDivider');

  /// Creates a [CountryPickerFormField].
  this;

  /// The decoration applied to the underlying [TextFormField].
  /// 
  /// This offers rich customisation for your form input (e.g. labels, hints, error descriptions).
  /// If you provide a suffix icon, that will override the default suffix icon we have provided,
  /// but that won't break the underlying implementation.
  final InputDecoration? decoration;

  /// Callback invoked when a country is selected.
  final void Function(Iso3166Country country) onCountryPicked;

  /// The initially selected country, if any.
  final Iso3166Country? initial;

  /// Countries to surface ahead of the rest of the results in the suggestions
  /// view, for example a list of the user's most-used nationalities.
  ///
  /// Any favourites that match the current search are listed first, and are
  /// separated from the remaining matches by a [Divider] whenever both groups
  /// contribute at least one suggestion. Favourites are still subject to the
  /// search query, so a favourite that does not match is not shown.
  final List<Iso3166Country>? favorites;

  /// An optional [FocusNode] to control the focus of the field.
  final FocusNode? focusNode;

  /// Validates the chosen country whenever the enclosing [Form] validates, e.g.
  /// through `Form.validate()` or a form-level [AutovalidateMode]. The value is
  /// the selected [Iso3166Country], or `null` while nothing is selected. Return
  /// `null` when the selection is acceptable.
  ///
  /// ```dart
  /// CountryPickerFormField(
  ///   decoration: const InputDecoration(labelText: 'Nationality'),
  ///   onCountryPicked: (country) => setState(() => _country = country),
  ///   validator: (country) => country == null ? 'Select a country' : null,
  ///   onSaved: (country) => _savedCountry = country,
  /// )
  /// ```
  final String? Function(Iso3166Country? country)? validator;

  /// Callback invoked with the chosen country (or `null`) when the enclosing
  /// [Form] saves, i.e. through `Form.save()`.
  final void Function(Iso3166Country? country)? onSaved;

  @override
  Widget build(BuildContext context) => CountriesProvider(child: _CountryPicker(
    decoration: decoration, 
    onCountryPicked: onCountryPicked,
    initial: initial,
    favorites: favorites,
    focusNode: focusNode,
    validator: validator,
    onSaved: onSaved,
  ));
}
