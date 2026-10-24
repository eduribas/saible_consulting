# saible_consulting_core

[![pub package](https://img.shields.io/pub/v/saible_consulting_core.svg)](https://pub.dev/packages/saible_consulting_core)

Shared core domain models, high-performance fuzzy search, localization delegates, and UI components for the Saible Consulting Flutter packages suite ([`country_picker_form_field`](https://pub.dev/packages/country_picker_form_field), [`date_picker_form_field`](https://pub.dev/packages/date_picker_form_field), [`phone_number_form_field`](https://pub.dev/packages/phone_number_form_field), and `form_demo`).

---

## Key Architectural Strengths

- **Comprehensive, Embedded ISO 3166 Dataset**:
  - Full dataset covering all 249 ISO 3166-1 countries and territories (`Iso3166Country` enum) with ISO-2 alpha codes, ISO-3 codes, international calling codes, and native flag emojis.
  - Zero external network dependencies: all country metadata is bundled, type-safe, and instantly accessible offline.
  - Deep multi-lingual localization across 39 languages (40 locales, including both `en` and `en-GB`): English, Welsh, French, German, Spanish, Japanese, Chinese, Arabic, Russian, Hindi, Italian, Dutch, Polish, Portuguese, Korean, Turkish, Swedish, Danish, Finnish, Norwegian Bokmål, Greek, Czech, Slovak, Hungarian, Romanian, Bulgarian, Ukrainian, Vietnamese, Thai, Indonesian, Malay, Persian, Hebrew, Urdu, Bengali, Tamil, Catalan, Serbian, Croatian.
- **Mathematically Optimized In-Memory Search**:
  - **Jaro-Winkler with Provable Upper-Bound Pruning**: Computes similarity and distance with Winkler prefix scaling while utilizing a mathematical length bound (`similarityUpperBound`) to prune non-matching candidates before running costly $O(N \cdot M)$ string comparisons.
  - **Bounded Top-$k$ Selection (`fastSearch`)**: Retains only the best matching candidates with early termination, eliminating the need to score or sort full datasets on every keystroke.
  - **Zero-Allocation Tokenization**: Search terms precompute lowercased, stripped, and word-split representations up front, keeping UI typing completely jank-free.
- **Timezone-Safe Date Arithmetic**:
  - `DateOperations` (`dateOnly()`, `addDays()`, `addMonths()`, `addYears()`) manipulates calendar year, month, and day components directly rather than naive duration addition, completely eliminating Daylight Saving Time (DST) timezone shift bugs.
- **`material_ui` Localization Plumbing (`SaibleLocalizations`)**:
  - `SaibleLocalizations.localizationsDelegates` pairs `CountryLocalizations.delegate` with `material_ui`'s `GlobalMaterialLocalizations.delegates`, so country names *and* Material-owned strings (dialog buttons, text selection toolbars) resolve in the same locales.
  - `material_ui` widgets never read the legacy `package:flutter_localizations` delegates that `CountryLocalizations.localizationsDelegates` bundles, so `SaibleLocalizations` is the list to spread into `MaterialApp` in a `material_ui` app.
- **Lean Dependency Footprint & Enterprise Quality**:
  - Lightweight, modular architecture with zero bloat.
  - Exceptionally high test coverage (>99% lines and branches) ensuring rock-solid stability in production environments.

---

## Features

- **ISO 3166-1 Country Directory**: Complete enum mapping with dial codes, alpha codes, and flag emojis.
- **Jaro-Winkler Fuzzy Matching (`JaroWinkler`)**: Memory-efficient fuzzy distance calculator with tunable prefix scaling.
- **In-Memory Text Search Engine (`TextSearch` & `TextSearchItem`)**: Typo-tolerant, multi-term matching with prefix incentives and word-boundary handling.
- **Calendar & Date Utilities (`DateOperations` & `DateCollection`)**: Safe date math and collection aggregations (`max()`).
- **Presentation Primitives**: `CountriesProvider` for reactive caching, `FlagIcon.forIso3166`, `NationTile`, and `PhoneCodeTile`.
- **`material_ui` Localization Wiring (`SaibleLocalizations`)**: a ready-made delegate list and supported locales for `material_ui` apps - country strings plus the Material, Cupertino and Widgets delegates.

---

## Getting Started

Add `saible_consulting_core` to your `pubspec.yaml`:

```yaml
dependencies:
  saible_consulting_core: ^1.0.5
```

Import the package in your Dart code:

```dart
import 'package:saible_consulting_core/saible_consulting_core.dart';
```

> **UI library:** the widgets in this package are built on `material_ui`, the
> official Flutter Material library, and their APIs accept `material_ui` types
> such as `InputDecoration`. Import `package:material_ui/material_ui.dart` in
> code that constructs those arguments: it exports distinct types that are not
> assignable to or from the copies exported by `package:flutter/material.dart`.

---

## Usage

### 1. Working with Countries and Flag Emojis

```dart
import 'package:saible_consulting_core/saible_consulting_core.dart';

// Lookup by country enum
const country = Iso3166Country.unitedKingdom;
print(country.alpha2);      // 'GB'
print(country.alpha3);      // 'GBR'
print(country.phoneCode);   // 44
print(country.flagEmoji()); // '🇬🇧'

// Localized translation, resolved synchronously from the ambient
// BuildContext (i.e. the active locale of the enclosing MaterialApp)
print(country.tr(context)); // 'United Kingdom', 'y Deyrnas Unedig', ...

// Search terms (name, codes, localized name, aliases) also take a context
print(country.searchTerms(context)); // ['GB', 'GBR', 'United Kingdom', ...]
```

### 2. Restricting the Country List

`CountriesProvider` accepts an optional `include` or `exclude` list to scope the
countries it publishes, and `Countries.where` applies a dynamic predicate at
build time. Both re-derive the localized name and dial code search terms for the
countries that survive, so downstream searches stay consistent with the list:

```dart
import 'package:saible_consulting_core/saible_consulting_core.dart';

// Opt in to a short list of countries
CountriesProvider(
  include: const [Iso3166Country.unitedKingdom, Iso3166Country.ireland],
  child: myForm,
)

// Opt out of the countries you cannot serve
CountriesProvider(
  exclude: const [Iso3166Country.unitedKingdom],
  child: myForm,
)

// Or apply a dynamic predicate while reading the provided data
final countries = context.watch<Countries>().where(
  context,
  (country) => country.phoneCode == 44,
);
```

`include` and `exclude` are mutually exclusive, which is enforced by an
assertion. The form field packages expose all three options directly: `include`
and `exclude` are forwarded to `CountriesProvider`, while a dynamic `filter`
predicate is applied with `Countries.where`.

### 3. High-Performance Fuzzy Search

```dart
import 'package:saible_consulting_core/application/text_search_item.dart';

final search = TextSearch<String>([
  TextSearchItem.fromTerms('United Kingdom', ['united kingdom', 'GB', 'GBR', 'great britain']),
  TextSearchItem.fromTerms('France', ['france', 'FR', 'FRA', 'french republic']),
  TextSearchItem.fromTerms('Germany', ['germany', 'DE', 'DEU', 'deutschland']),
]);

// Returns top 2 matches ordered by score using bounded top-k pruning
final topMatches = search.fastSearch('britain', limit: 2);
print(topMatches); // ['United Kingdom']
```

### 4. Date Manipulation Extensions

```dart
import 'package:saible_consulting_core/application/date_utils.dart';

final now = DateTime.now();
final date = now.dateOnly(); // Strip time component
final nextWeek = date.addDays(7); // Safe across DST transitions
final nextQuarter = date.addMonths(3); // Rolls over the year boundary
final adultDate = date.addYears(-18);

final dates = [date, nextWeek, nextQuarter, adultDate];
print(dates.max()); // nextWeek
```

### 5. Localization Setup for Widgets

Country names resolve synchronously from the ambient `BuildContext`, so there is
no provider, cache, or lookup call to wire up. Simply add the
`saible_consulting_core` delegates and supported locales to your `MaterialApp`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      supportedLocales: SaibleLocalizations.supportedLocales,
      localizationsDelegates: SaibleLocalizations.localizationsDelegates,
      home: MyHomeScreen(),
    );
  }
}
```

`SaibleLocalizations.localizationsDelegates` is `CountryLocalizations.delegate`
plus `material_ui`'s `GlobalMaterialLocalizations.delegates`: the country names
in 40 locales together with the Material, Cupertino and Widgets strings that
`material_ui` widgets look up (dialog buttons, text selection toolbars) - the
combination `material_ui` recommends for an app that needs those strings. The
generated `CountryLocalizations.localizationsDelegates` pairs the country names
with the *legacy* `package:flutter_localizations` delegates instead
(`GlobalMaterialLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`,
`GlobalWidgetsLocalizations.delegate`), which `material_ui` widgets never query:
use it only while part of your app still builds with
`package:flutter/material.dart`. Both lists expose the same 40
`supportedLocales`.

`Iso3166Country.tr(context)` (along with `searchTerms(context)` and
`phoneSearchTerms(context)`) reads the active locale directly via
`Localizations.maybeLocaleOf(context)`, so a locale change (e.g. through a
language switcher) re-translates country names on the next rebuild with no extra
plumbing. When no `Localizations` widget is present in the ancestor tree the
lookup falls back to English (`en-GB`), which keeps naive usage and isolated
tests safe.

> **Note:** `lookupCountryLocalizations` throws for a locale outside
> `CountryLocalizations.supportedLocales`. Listing `supportedLocales` on your
> `MaterialApp` (as above) lets Flutter's locale resolution select the nearest
> supported match (e.g. `pt_BR` → `pt`), so this is only reachable if you call
> the lookup directly with an unsupported locale.

### 6. Migrating from `package:flutter/material.dart`

`material_ui` is the Material library that used to ship inside
`package:flutter/material.dart`; its bundled data-driven fix rewrites the imports
for you:

```sh
dart fix --apply --code=migrate_design_widgets
```

Wherever a dependency or subtree still imports `package:flutter/material.dart`,
`MaterialUiCompatibilityBridge` bridges `ThemeData` and `MaterialLocalizations`
for it, so legacy widgets keep resolving `Theme.of(context)` and
`MaterialLocalizations.of(context)`. Wrap the app through `MaterialApp.builder`:

```dart
import 'package:material_ui/material_ui.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
    home: const MyScreen(),
  );
}
```

...or wrap the individual legacy subtree with the same widget. The bridge is a
temporary migration aid (deprecated in `material_ui` 1.5.0 and scheduled for
removal in a future release), so migrate the legacy dependency rather than
shipping it long term.

---

## How this compares

Country data on pub.dev usually arrives bundled inside a picker widget, without a
standalone search API. Metrics as of 1 October 2026:

| Package | Likes | Downloads | Latest | Trade-offs |
| --- | --: | --: | --- | --- |
| [`country_picker`](https://pub.dev/packages/country_picker) | 466 | 149k | 2.0.28 (Jun 2026) | Its country model and localized names are tied to the bottom-sheet picker, with no standalone fuzzy search over the data. |
| [`country_code_picker`](https://pub.dev/packages/country_code_picker) | 930 | 102k | 3.4.1 (Oct 2025) | i18n for 70 languages and flag images, but the data lives behind the selector widget: no ISO-3/dial-code API and no reusable search engine. |
| [`flutter_country_picker`](https://pub.dev/packages/flutter_country_picker) | 24 | 57 | 0.1.6 (Dec 2019) | Abandoned: no release since 2019. |

Use `saible_consulting_core` when you want the country data and the search engine
on their own - `Iso3166Country` values with `tr(context)` names in 40 locales,
and `TextSearch` for any list you like - rather than as a side effect of a picker
UI. The same primitives back [`country_picker_form_field`](https://pub.dev/packages/country_picker_form_field),
[`date_picker_form_field`](https://pub.dev/packages/date_picker_form_field) and [`phone_number_form_field`](https://pub.dev/packages/phone_number_form_field).

---

## Additional Information

- Source code: [GitHub Repository](https://github.com/saible-app/saible_consulting)
- Issue tracker: File bugs or feature requests via GitHub Issues.
- License: See [LICENSE](LICENSE) for details.

