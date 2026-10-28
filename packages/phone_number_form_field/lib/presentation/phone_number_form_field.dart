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

import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:dlibphonenumber/dlibphonenumber.dart' hide Locale;
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phone_number_form_field/application/phone_util.dart';
import 'package:phone_number_form_field/domain/phone_number.dart';
import 'package:phone_number_form_field/presentation/as_you_type_phone_number_formatter.dart';
import 'package:provider/provider.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

String? _getE164Number(String rawValue, Iso3166Country country) {
  if (rawValue.isEmpty) return null;
  try {
    final PhoneNumber phoneNumber = phoneUtil.parse(rawValue, country.alpha2);
    if (phoneUtil.isValidNumber(phoneNumber)) {
      return phoneUtil.format(phoneNumber, PhoneNumberFormat.e164);
    }
  } catch (_) {
    return null;
  }

  return null;
}

class const _PhoneNumberField({
  this.focusNode,
  this.decoration,
  this.initialValue,
  this.onPhoneNumberChanged,
  this.onFieldSubmitted,
  this.validator,
  this.onSaved,
  this.filter,
}) extends StatefulWidget {
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final ValueChanged<PhoneNumberState>? onPhoneNumberChanged;
  final void Function(String)? onFieldSubmitted;
  final PhoneNumberState? initialValue;
  final String? Function(PhoneNumberState state)? validator;
  final void Function(PhoneNumberState state)? onSaved;
  final bool Function(Iso3166Country)? filter;

  @override
  State<_PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState() extends State<_PhoneNumberField> {
  final TextEditingController _controller = TextEditingController();
  Iso3166Country _selectedCountry = Iso3166Country.unitedKingdom;
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    if (initialValue != null && initialValue.isNotEmpty) {
      final phoneNumber = phoneUtil.parse(initialValue.e164, null);
      final regionCode = phoneUtil.getRegionCodeForNumber(phoneNumber)?.toLowerCase();
      final country = Iso3166Country.values.firstWhereOrNull((c) => c.alpha2.toLowerCase() == regionCode);
      if (country != null) {
        _selectedCountry = country;
        _controller.text = phoneNumber.internationalFormatWithoutTrunk();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = PlatformDispatcher.instance.locale ?? Localizations.maybeLocaleOf(context);
    final localeChanged = locale != _lastLocale;
    if (localeChanged) _lastLocale = locale;
    // The implicit default selection has to be a country that is actually on
    // offer, so it is resolved against the available countries: the app locale's
    // country when the locale changed, then the current selection while it is
    // still on offer, then simply the first country that is on offer. A
    // caller-supplied initialValue fills the controller, so it is left to the
    // caller to keep compatible with include/exclude/filter.
    if (_controller.text.isEmpty) {
      final countries = context.read<Countries>().countries;
      final localeCountry = localeChanged ? countries.firstWhereOrNull((c) => c.alpha2 == locale?.countryCode) : null;
      final defaultCountry =
          localeCountry ?? (countries.contains(_selectedCountry) ? _selectedCountry : countries.firstOrNull);
      if (defaultCountry != null) {
        _selectedCountry = defaultCountry;
      }
    }
    if (localeChanged) {
      // Force a rebuild when the locale changes, so that the suggestions builder is always up to
      // date with the current language
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _lastLocale = locale;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  /// Builds the [PhoneNumberState] for [rawText] as typed in the field, parsed
  /// against the currently selected country.
  PhoneNumberState _stateFor(String rawText) => PhoneNumberState(
    rawText: rawText,
    e164: _getE164Number(rawText, _selectedCountry),
    regionCode: '+${_selectedCountry.phoneCode}',
  );

  @override
  Widget build(BuildContext context) {
    final onPhoneNumberChanged = widget.onPhoneNumberChanged;
    final filter = widget.filter;
    final countries = filter == null ? context.watch<Countries>() : context.watch<Countries>().where(context, filter);
    // Built once per rebuild (not per keystroke) since the search terms
    // are stable for the current locale.
    final textSearch = TextSearch(countries.phoneSearchTerms);
    return TextFormField(
      key: PhoneNumberFormField.textInputKey,
      focusNode: widget.focusNode,
      controller: _controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        AsYouTypePhoneNumberFormatter(
          country: _selectedCountry,
          onFormatFinished: (value) => onPhoneNumberChanged?.call(_stateFor(value)),
        ),
      ],
      // Typed form integration: the enclosing Form validates and saves the
      // parsed PhoneNumberState rather than the raw text.
      validator: (_) => widget.validator?.call(_stateFor(_controller.text)),
      onSaved: (_) => widget.onSaved?.call(_stateFor(_controller.text)),
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        hintText: widget.decoration?.hintText ?? _selectedCountry.examplePhoneNumberWithoutTrunk(),
        errorMaxLines: widget.decoration?.errorMaxLines ?? 2,
        prefixIcon: SearchAnchor(
          key: PhoneNumberFormField.countrySearchAnchorKey,
          shrinkWrap: true,
          builder: (context, controller) => InkWell(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedCountry.flagEmoji(), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text('+${_selectedCountry.phoneCode}'),
                  const Icon(Icons.arrow_drop_down),
                  const SizedBox(width: 4),
                  // Vertical divider separating prefix control from text field
                  Container(height: 24, width: 1, color: Theme.of(context).colorScheme.outlineVariant),
                ],
              ),
            ),
          ),
          suggestionsBuilder: (context, controller) {
            final results = textSearch.fastSearch(controller.text, limit: 12);
            return [
              for (final result in results)
                PhoneCodeTile(
                  key: PhoneNumberFormField.countrySuggestionKey(result),
                  country: result,
                  onTap: () {
                    if (_selectedCountry != result) {
                      setState(() {
                        _selectedCountry = result;
                      });
                      _controller.text = '';
                      widget.onPhoneNumberChanged?.call(_stateFor(''));
                    }
                    controller.closeView(result.tr(context));
                  },
                ),
            ];
          },
        ),
      ),
    );
  }
}

/// A form field widget for inputting international phone numbers with country code selection and validation.
class PhoneNumberFormField({
  super.key,
  this.focusNode,
  this.initialValue,
  this.decoration,
  this.onPhoneNumberChanged,
  this.onFieldSubmitted,
  this.validator,
  this.onSaved,
  this.include,
  this.exclude,
  this.filter,
}) extends StatelessWidget {
  /// Creates a [PhoneNumberFormField].
  this {
    final prefix = decoration?.prefix;
    final prefixIcon = decoration?.prefixIcon;
    final prefixText = decoration?.prefixText;
    assert(
      prefix == null && prefixIcon == null && prefixText == null,
      'PhoneNumberFormField cannot specify any prefix in decoration as it uses an interactive prefix dial code.',
    );
    assert(
      <Object?>[include, exclude, filter].where((e) => e != null).length <= 1,
      'Only one of include, exclude and filter can be used at any one time.',
    );
  }

  /// The [Key] for the country search anchor prefix icon button.
  static const Key countrySearchAnchorKey = Key('phoneNumberTextField_searchAnchor');

  /// The [Key] for the phone number text input search/entry field.
  static const textInputKey = Key('phoneNumberTextField_textInput');

  /// Generates a [Key] for a country suggestion tile based on the country's alpha2 code.
  static Key countrySuggestionKey(Iso3166Country country) => Key('phoneNumberTextField_country_${country.alpha2}');

  /// An optional [FocusNode] to control the focus of the text input.
  final FocusNode? focusNode;

  /// The decoration applied to the underlying [TextFormField].
  ///
  /// This allows you to apply rich features to the field, such as floating labels, borders,
  /// and error handling. However, a runtime assertion will be thrown if you provide a prefix,
  /// as the prefix is used to provide the mandatory international number code.
  ///
  /// If you provide a hint, you will lose the locale-aware phone number masking feature provided
  /// by this package.
  final InputDecoration? decoration;

  /// Callback invoked when the phone number input changes or country selection changes.
  final ValueChanged<PhoneNumberState>? onPhoneNumberChanged;

  /// Callback invoked when the user indicates they are done editing (e.g. presses Enter/Submit).
  final void Function(String)? onFieldSubmitted;

  /// An optional initial value to populate the field with.
  ///
  /// This is an explicit selection and is used exactly as given, unlike the
  /// implicit default, which is always resolved to a country that is on offer.
  /// It is up to the caller to keep it compatible with
  /// [PhoneNumberFormField.include], [PhoneNumberFormField.exclude] and
  /// [PhoneNumberFormField.filter]: if it names a country that is not on offer,
  /// the field still displays and parses against that country.
  final PhoneNumberState? initialValue;

  /// Validates the current [PhoneNumberState] whenever the enclosing [Form]
  /// validates, e.g. through `Form.validate()` or a form-level
  /// [AutovalidateMode]. Return `null` when the number is acceptable.
  ///
  /// ```dart
  /// PhoneNumberFormField(
  ///   decoration: const InputDecoration(labelText: 'Phone Number'),
  ///   validator: (state) => state.isValid ? null : 'Enter a valid phone number',
  ///   onSaved: (state) => _phoneNumber = state,
  /// )
  /// ```
  final String? Function(PhoneNumberState state)? validator;

  /// Callback invoked with the current [PhoneNumberState] when the enclosing
  /// [Form] saves, i.e. through `Form.save()`.
  final void Function(PhoneNumberState state)? onSaved;

  /// An opt-in list of countries to include in the dial code picker.
  ///
  /// Cannot be used at the same time as [PhoneNumberFormField.exclude] or
  /// [PhoneNumberFormField.filter], which is enforced by an assertion.
  final List<Iso3166Country>? include;

  /// An opt-out list of countries to exclude from the dial code picker.
  ///
  /// Cannot be used at the same time as [PhoneNumberFormField.include] or
  /// [PhoneNumberFormField.filter], which is enforced by an assertion.
  final List<Iso3166Country>? exclude;

  /// A dynamic filter applied to the countries offered by the dial code picker.
  ///
  /// Cannot be used at the same time as [PhoneNumberFormField.include] or
  /// [PhoneNumberFormField.exclude], which is enforced by an assertion.
  ///
  /// Use with caution, as this filter will be applied in the build() step, which
  /// may be invoked dozens of times per second.
  final bool Function(Iso3166Country)? filter;

  @override
  Widget build(BuildContext context) => CountriesProvider(
    include: include,
    exclude: exclude,
    child: _PhoneNumberField(
      focusNode: focusNode,
      initialValue: initialValue,
      decoration: decoration,
      onPhoneNumberChanged: onPhoneNumberChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onSaved: onSaved,
      filter: filter,
    ),
  );
}
