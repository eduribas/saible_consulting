# country_picker_form_field

[![pub package](https://img.shields.io/pub/v/country_picker_form_field.svg)](https://pub.dev/packages/country_picker_form_field)

An accessible, high-performance country picker form field for Flutter applications with integrated fuzzy search, native flag emojis, and multi-lingual localization.

`CountryPickerFormField` embeds directly into Flutter forms as a first-class form component. Powered by the Material 3 `SearchAnchor` pattern, it provides a fluid search experience that responds in real time across mobile, tablet, desktop, and web platforms.

<table>
  <tr>
    <th align="center">Nationality</th>
    <th align="center">Language Switcher</th>
  </tr>
  <tr>
    <td align="center" width="50%"><a href="https://github.com/user-attachments/assets/0f48cd3b-9714-479f-83dd-a06edd763440"><img src="https://raw.githubusercontent.com/saible-app/saible_consulting/main/doc/images/nationality_thumbnail.png" alt="Nationality demo" width="100%"/></a></td>
    <td align="center" width="50%"><a href="https://github.com/user-attachments/assets/8b2d14bc-45e1-4e6a-a1a5-6182a36e986d"><img src="https://raw.githubusercontent.com/saible-app/saible_consulting/main/doc/images/language_thumbnail.png" alt="Language Switcher demo" width="100%"/></a></td>
  </tr>
</table>

---

## Key Architectural Strengths

- **Modern Material 3 `SearchAnchor` Architecture**:
  - Leverages Flutter's native `SearchAnchor` and `TextFormField` interaction model rather than cumbersome modal sheets, full-page navigators, or custom overlay hacks.
  - Automatically adapts its display presentation to the current screen size and input modality (touch, mouse, keyboard).
- **Fast, Typo-Tolerant Search Engine**:
  - Backed by an in-memory Jaro-Winkler fuzzy search engine with length-bound early rejection.
  - Users can search naturally by localized country name, ISO 3166-1 alpha-2 code, alpha-3 code, or colloquial alternative names.
- **Offline & Zero Extra Asset Footprint**:
  - No asset bundles, custom fonts, or hundreds of SVG files: renders crisp country flag icons using system-native Unicode regional indicator flag emojis.
  - Works 100% offline with zero network latency.
- **Enterprise-Grade Localization**:
  - Built-in translations across 39 global languages (English, French, German, Spanish, Welsh, Japanese, Chinese, Arabic, Russian, Korean, Turkish, Hindi, and more).
- **Comprehensive Testability**:
  - Fully decoupled and deterministic, exporting stable testing keys (`countrySearchAnchorKey`, `countrySearchBarKey`) for clean widget test automation.
  - Maintained with over 99% automated test coverage.

---

## Features

- **Full ISO 3166-1 Country Support**: Covers all 249 recognized countries and territories.
- **Dynamic Fuzzy Search**: Instant, typo-tolerant search across names, codes, and aliases.
- **Multi-Lingual Localization**: Displays localized country names matching the active Flutter app locale, with translations for all 39 supported languages.
- **First-Class Form Integration**: Seamlessly works with `Form` through typed `validator` and `onSaved` callbacks that receive the selected `Iso3166Country`, plus `InputDecoration`, `onCountryPicked`, `Formz`, and state management solutions (BLoC, Riverpod, Provider).
- **Flag Badge Affordance**: Displays clean suffix/prefix flag emojis for the active selection.

---

## Getting Started

Add `country_picker_form_field` and [`saible_consulting_core`](https://pub.dev/packages/saible_consulting_core) to your `pubspec.yaml`:

```yaml
dependencies:
  country_picker_form_field: ^1.0.2
  saible_consulting_core: ^1.0.2
```

> **UI library:** this package is built on `material_ui`, the official Flutter
> Material library, and its API accepts `material_ui` types such as
> `InputDecoration`. Import `package:material_ui/material_ui.dart` in code that
> constructs those arguments: it exports distinct types that are not assignable
> to or from the copies exported by `package:flutter/material.dart`.

### Localization setup

Ensure your `MaterialApp` is configured with the localization plumbing from
`saible_consulting_core` (no provider or lookup is required):

```dart
import 'package:material_ui/material_ui.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

MaterialApp(
  supportedLocales: SaibleLocalizations.supportedLocales,
  localizationsDelegates: SaibleLocalizations.localizationsDelegates,
  home: const MyFormPage(),
);
```

### Migrating from `package:flutter/material.dart`

`material_ui` is the Material library that used to ship inside
`package:flutter/material.dart`, so migration is mostly mechanical - the bundled
data-driven fix rewrites the imports for you:

```sh
dart fix --apply --code=migrate_design_widgets
```

Two things then need attention. Import `package:material_ui/material_ui.dart`
wherever you construct `material_ui` types (such as `InputDecoration`), as
described above - and make sure the localization delegates come from
`material_ui` too. `material_ui` widgets never read the legacy
`GlobalMaterialLocalizations`, `GlobalCupertinoLocalizations` or
`GlobalWidgetsLocalizations` classes from `package:flutter_localizations`, which
is why `SaibleLocalizations.localizationsDelegates` (shown above) pairs the
country names with `material_ui`'s own Material, Cupertino and Widgets
delegates. Use the generated `CountryLocalizations.localizationsDelegates` only
while parts of your app still build with `package:flutter/material.dart`.

If a dependency or subtree still imports `package:flutter/material.dart`, use
`MaterialUiCompatibilityBridge` to bridge `ThemeData` and
`MaterialLocalizations` for it - app-wide through `MaterialApp.builder`, or
around the individual subtree:

```dart
MaterialApp(
  builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
  home: const MyScreen(),
);
```

The bridge is a temporary migration aid (deprecated in `material_ui` 1.5.0 and
scheduled for removal in a future release), so migrate the legacy dependency
rather than shipping it long term.

---

## Usage

### Basic Example

```dart
import 'package:material_ui/material_ui.dart';
import 'package:country_picker_form_field/country_picker_form_field.dart';
import 'package:saible_consulting_core/domain/iso3166_countries.dart';

class NationalityFieldExample extends StatefulWidget {
  const NationalityFieldExample({super.key});

  @override
  State<NationalityFieldExample> createState() => _NationalityFieldExampleState();
}

class _NationalityFieldExampleState extends State<NationalityFieldExample> {
  Iso3166Country? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return CountryPickerFormField(
      initial: Iso3166Country.unitedKingdom,
      decoration: const InputDecoration(
        labelText: 'Nationality',
        hintText: 'Select your country',
        border: OutlineInputBorder(),
      ),
      onCountryPicked: (country) {
        setState(() {
          _selectedCountry = country;
        });
        print('Selected country: ${country.name} (${country.alpha2})');
      },
    );
  }
}
```

### Form & State Management (e.g. Formz / BLoC)

```dart
CountryPickerFormField(
  initial: state.nationality.value,
  decoration: InputDecoration(
    labelText: 'Nationality',
    errorText: state.nationality.isNotValid ? 'Please select a country' : null,
  ),
  onCountryPicked: (country) {
    context.read<MyFormBloc>().add(NationalityChanged(country));
  },
);
```

### Form Validation

`validator` and `onSaved` plug the field into a `Form` and receive the selected
`Iso3166Country` (or `null` while nothing is selected), so validation and
submission work on the country rather than on the search text:

```dart
final formKey = GlobalKey<FormState>();
Iso3166Country? nationality;

Form(
  key: formKey,
  child: CountryPickerFormField(
    decoration: const InputDecoration(labelText: 'Nationality'),
    onCountryPicked: (_) {},
    validator: (country) => country == null ? 'Select a country' : null,
    onSaved: (country) => nationality = country,
  ),
);

if (formKey.currentState!.validate()) {
  formKey.currentState!.save();
  print(nationality!.alpha2); // e.g. "GB"
}
```

The validator runs whenever the enclosing `Form` validates - through
`FormState.validate()` or a form-level `AutovalidateMode`. While the field is
still open, the same state can be driven reactively through `onCountryPicked`.

### Input Decoration

`CountryPickerFormField` supports full `InputDecoration` customization. It provides
a default suffix icon displaying the selected country's flag emoji (or a globe icon
when unselected). You can supply custom decorations or override the suffix icon:

```dart
CountryPickerFormField(
  onCountryPicked: (country) {},
  decoration: InputDecoration(
    labelText: 'Nationality',
    hintText: 'Select country',
    suffixIcon: const Icon(Icons.arrow_drop_down), // Overrides the default flag suffix icon
    border: const OutlineInputBorder(),
  ),
)
```

---

## Testing

`CountryPickerFormField` exposes stable testing keys for automation:

- `CountryPickerFormField.countrySearchAnchorKey`: The `SearchAnchor` widget key.
- `CountryPickerFormField.countrySearchBarKey`: The search entry `TextFormField` key.

In widget tests, you can find and interact with the search bar reliably:

```dart
await tester.tap(find.byKey(CountryPickerFormField.countrySearchBarKey));
await tester.pumpAndSettle();
await tester.enterText(find.byType(TextField).last, 'France');
await tester.pumpAndSettle();
```

---

## How this compares

Alternative pub.dev packages, with their like counts, 30-day downloads and
latest releases as of 1 October 2026:

| Package | Likes | Downloads | Latest | Trade-offs |
| --- | --: | --: | --- | --- |
| [`country_code_picker`](https://pub.dev/packages/country_code_picker) | 930 | 102k | 3.4.1 (Oct 2025) | The most-used option, from a verified publisher: 70 localizations, favourites, filter lists and flag images. It is a selection button with a plain search box rather than a `TextFormField`-based form field, and its country data is not exposed as a standalone API. |
| [`country_picker`](https://pub.dev/packages/country_picker) | 466 | 149k | 2.0.28 (Jun 2026) | A bottom-sheet `showCountryPicker()` function with favourites, exclude/filter lists and its own localized country names; not a form field, so validation state is wired up by hand. |
| [`flutter_country_picker`](https://pub.dev/packages/flutter_country_picker) | 24 | 57 | 0.1.6 (Dec 2019) | Abandoned: no release since 2019. |

Pick `country_picker_form_field` when you want an inline field rather than a
modal, typo-tolerant Jaro-Winkler search across names, ISO-2/ISO-3 codes, dial
codes and aliases as the user types, `Form` validation out of the box, 39
languages of country names, and Unicode flag emojis with no image assets to
bundle.

---

## Additional Information

- Source code: [GitHub Repository](https://github.com/saible-app/saible_consulting)
- Issue tracker: File bugs or feature requests via GitHub Issues.
- License: See [LICENSE](LICENSE) for details.

