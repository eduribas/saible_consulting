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

  /// Matches the prepared terms against [query], listing favourite matches
  /// first (in the caller's order) and remaining matches afterwards.
  ///
  /// Unlike [suggest], no result limit is applied, so this suits the dropdown
  /// mode where the filtered list *is* the menu rather than a bounded set of
  /// suggestions.
  List<Iso3166Country> matches(String query) => [
    ..._favorites.fastSearch(query),
    ..._others.fastSearch(query),
  ];
}

class const _CountrySuffix({
  required this.country
}) extends StatelessWidget {
  final Iso3166Country country;

  @override
  Widget build(BuildContext context) => FlagIcon.forIso3166(
    country: country
  );
}

class const _CountryPicker({
  required this.onCountryPicked,
  required this.mode,
  this.initial,
  this.favorites,
  this.decoration,
  this.focusNode,
  this.validator,
  this.onSaved,
  this.filter,
}) extends StatefulWidget {
  static Key countrySuggestionKey(Iso3166Country country) => Key('countryPicker_country_${country.alpha2}');
  final void Function(Iso3166Country country) onCountryPicked;
  final CountryPickerMode mode;
  final Iso3166Country? initial;
  final List<Iso3166Country>? favorites;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final bool Function(Iso3166Country)? filter;
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
    final filter = widget.filter;
    final countries = filter == null
      ? context.watch<Countries>()
      : context.watch<Countries>().where(context, filter);
    // Prepared once per rebuild (not per keystroke): the search terms are
    // stable for the current locale, so the favourites/remaining split is
    // computed here rather than on every keystroke. Shared by both modes, so
    // the dropdown filters with exactly the same fuzzy search as the
    // search-anchor view.
    final search = _CountrySearch(
      searchTerms: countries.searchTerms,
      favorites: widget.favorites ?? const <Iso3166Country>[],
    );
    if (widget.mode == CountryPickerMode.dropdown) {
      // The caller's favourites, matched by value against the entries. The same
      // fuzzy search as the search-anchor view lists them ahead of the rest.
      final favorites = widget.favorites ?? const <Iso3166Country>[];
      // Every country, favourites first: the order the unfiltered menu shows.
      final unfiltered = search.matches('');
      // DropdownMenu is not a FormField, so it is wrapped in one to give the
      // enclosing Form the typed validator and onSaved callbacks.
      final country = chosenCountry;
      return FormField<Iso3166Country>(
        initialValue: country,
        validator: widget.validator,
        onSaved: widget.onSaved,
        builder: (field) => LayoutBuilder(
          builder: (context, constraints) => DropdownMenu<Iso3166Country>(
            key: CountryPickerFormField.countrySearchAnchorKey,
            focusNode: widget.focusNode,
            initialSelection: country,
            enableFilter: true,
            width: constraints.maxWidth,
            // Typing to filter is only reachable on mobile if tapping the field may
            // focus it and raise the keyboard; desktop already behaves this way.
            requestFocusOnTap: true,
            trailingIcon: country == null ? null : _CountrySuffix(country: country),
            // The caller's decoration is applied to the inner field verbatim, with
            // the validation error and our default error height layered on top. A
            // caller-supplied suffixIcon wins; otherwise DropdownMenu contributes
            // its own drop-down arrow.
            decorationBuilder: (context, controller) => (widget.decoration ?? const InputDecoration()).copyWith(
              errorText: field.errorText,
              errorMaxLines: widget.decoration?.errorMaxLines ?? 2,
            ),
            // The entries are rebuilt from the matched countries rather than reused
            // from the list DropdownMenu hands back, because it re-filters its own
            // previous results on every rebuild. Rebuilding keeps the favourites
            // divider beside the last favourite that is actually on screen.
            filterCallback: (_, filter) => _dropdownEntries(context, search.matches(filter), favorites),
            onSelected: (c) {
              if (c == null) return;
              setState(() { chosenCountry = c; });
              field.didChange(c);
              widget.onCountryPicked(c);
            },
            dropdownMenuEntries: _dropdownEntries(context, unfiltered, favorites),
          )
        ),
      );
    }

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

  /// Builds the dropdown entries for [ordered] countries, which must list the
  /// caller's [favorites] ahead of the remaining countries.
  ///
  /// When both groups are represented, the final favourite is underlined with a
  /// bottom border so the two read as separate sections. [DropdownMenu] has no
  /// separator of its own, so the divider is expressed as a [LinearBorder]
  /// bottom edge on that entry's [DropdownMenuEntry.style]. When only one group
  /// is present the plain list is shown.
  List<DropdownMenuEntry<Iso3166Country>> _dropdownEntries(
    BuildContext context,
    List<Iso3166Country> ordered,
    List<Iso3166Country> favorites,
  ) {
    // The favourites are listed first, so the last of them sits just before the
    // first remaining country, and the divider is warranted only while both
    // groups are present.
    final favoriteCount = ordered.where(favorites.contains).length;
    final dividerAfter = favoriteCount > 0 && favoriteCount < ordered.length ? ordered[favoriteCount - 1] : null;
    final entries = <DropdownMenuEntry<Iso3166Country>>[];
    for (final country in ordered) {
      final label = country.tr(context);
      entries.add(DropdownMenuEntry(
        value: country,
        label: label,
        leadingIcon: FlagIcon.forIso3166(country: country),
        style: country == dividerAfter ? MenuItemButton.styleFrom(
          shape: LinearBorder.bottom(
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ) : null,
      ));
    }
    return entries;
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
class CountryPickerFormField({
  super.key,
  this.decoration,
  required this.onCountryPicked,
  this.initial,
  this.favorites,
  this.focusNode,
  this.validator,
  this.onSaved,
  this.mode = CountryPickerMode.searchAnchor,
  this.include,
  this.exclude,
  this.filter,
}) extends StatelessWidget {
  /// The [Key] for the country search anchor view.
  static const Key countrySearchAnchorKey = Key('countryPicker_searchAnchor');

  /// The [Key] for the country search bar field.
  static const Key countrySearchBarKey = Key('countryPicker_searchBar');

  /// The [Key] for the [Divider] separating favourites from the remaining
  /// countries in the suggestions view. Only present while both groups are
  /// represented, so a lone group is never trailed by a stray divider.
  ///
  /// [CountryPickerMode.dropdown] expresses the same separation as a bottom
  /// border on the final favourite's menu entry rather than a [Divider] widget,
  /// so this key does not appear in that mode.
  static const Key favoritesDividerKey = Key('countryPicker_favoritesDivider');

  /// Creates a [CountryPickerFormField].
  ///
  /// At most one of [include], [exclude] and [filter] may be supplied, which is
  /// enforced by an assertion.
  this {
    final CountryPickerFormField(:include, :exclude, :filter) = this;
    assert(
      <Object?>[include, exclude, filter].where((e) => e != null).length <= 1,
      'Only one of include, exclude and filter can be used at any one time.',
    );
  }

  /// The mode in which you want to show the countries.
  /// 
  /// Do you want to show them in-place, where the user taps the dropdown ([CountryPickerMode.dropdown]),
  /// or in a new context, from a SearchAnchor ([CountryPickerMode.searchAnchor])?
  final CountryPickerMode mode;

  /// An opt-in list of countries to include
  /// 
  /// Cannot be used at the same time as [CountryPickerFormField.exclude] or
  /// [CountryPickerFormField.filter], which is enforced by an assertion.
  final List<Iso3166Country>? include;

  /// An opt-out list of countries to exclude
  /// 
  /// Cannot be used at the same time as [CountryPickerFormField.include] or
  /// [CountryPickerFormField.filter], which is enforced by an assertion.
  final List<Iso3166Country>? exclude;

  /// A dynamic filter function that can be applied to restrict the countries to be chosen.
  ///
  /// Cannot be used at the same time as [CountryPickerFormField.include] or
  /// [CountryPickerFormField.exclude], which is enforced by an assertion.
  /// 
  /// Use with caution, as this filter will be applied in the build() step, which may be invoked dozens
  /// of times per second.
  final bool Function(Iso3166Country)? filter;

  /// The decoration applied to the underlying form field.
  /// 
  /// This offers rich customisation for your form input (e.g. labels, hints, error descriptions).
  /// If you provide a suffix icon, that will override the default suffix icon we have provided,
  /// but that won't break the underlying implementation.
  ///
  /// In [CountryPickerMode.searchAnchor] the default suffix icon is the selected
  /// country's flag (or a globe when nothing is selected). In
  /// [CountryPickerMode.dropdown] the underlying [DropdownMenu] contributes its
  /// own drop-down arrow unless you supply a suffix icon.
  final InputDecoration? decoration;

  /// Callback invoked when a country is selected.
  final void Function(Iso3166Country country) onCountryPicked;

  /// The initially selected country, if any.
  ///
  /// This is an explicit selection and is used exactly as given. It is up to the
  /// caller to keep it compatible with [CountryPickerFormField.include],
  /// [CountryPickerFormField.exclude] and [CountryPickerFormField.filter]: if it
  /// names a country that is not on offer, the picker will not offer it.
  /// [CountryPickerMode.searchAnchor] still shows the given name as the field's
  /// text, whereas [CountryPickerMode.dropdown] leaves the field empty.
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
  Widget build(BuildContext context) => CountriesProvider(
    include: include,
    exclude: exclude,
    child: _CountryPicker(
      decoration: decoration, 
      onCountryPicked: onCountryPicked,
      initial: initial,
      favorites: favorites,
      focusNode: focusNode,
      validator: validator,
      onSaved: onSaved,
      filter: filter,
      mode: mode,
    )
  );
}
