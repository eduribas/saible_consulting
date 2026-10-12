## 1.0.2

* Added `DateOperations.addMonths`, a timezone-safe month adder that keeps the
  arithmetic in calendar terms and lets `DateTime` normalize overflow the same
  way the existing `addDays` and `addYears` helpers do.
* Bumped version to `1.0.2` across the Saible Consulting package suite.
* Bumped `material_ui` dependency constraint to `^1.6.0`.

## 1.0.1

* Bumped version to `1.0.1` across the Saible Consulting package suite.

## 1.0.0

* Bumped version to `1.0.0` for official stable release.
* Updated `material_ui` dependency constraint to `^1.5.0`.

## 0.2.3

* Bumped version to `0.2.3` across the Saible Consulting package suite.

## 0.2.2

* Bumped version to `0.2.2` across the Saible Consulting package suite.

## 0.2.1

* Bumped version to `0.2.1` across the Saible Consulting package suite.
* Updated documentation with clickable video preview thumbnails across the monorepo packages.

## 0.2.0

* Bumped version to `0.2.0` across the Saible Consulting package suite.
* Validated and confirmed compatibility with `material_ui` 1.5.0 and `cupertino_ui` 1.1.1.
* Updated documentation with standard pub.dev package badges and references.

## 0.1.0

* Initial release.
* **ISO 3166-1 country directory**: all 249 countries and territories exposed as the
  type-safe `Iso3166Country` enum, with alpha-2, alpha-3 and numeric codes, international
  dial codes, flag emojis, common aliases and native name search terms.
* **Localizations for 40 locales** (39 languages, including both `en` and `en-GB`),
  published through `CountryLocalizations.supportedLocales` and
  `CountryLocalizations.localizationsDelegates` for direct use in `MaterialApp`.
* **`material_ui` localization plumbing**: `SaibleLocalizations.localizationsDelegates`
  pairs the country delegate with `material_ui`'s `GlobalMaterialLocalizations.delegates`,
  so Material-owned strings (dialog buttons, text selection toolbars) stay localized
  alongside country names; `SaibleLocalizations.supportedLocales` mirrors
  `CountryLocalizations.supportedLocales`.
* **Fuzzy search**: `JaroWinkler` similarity with upper-bound pruning, plus the
  `TextSearch`/`TextSearchItem` in-memory engines (`search` and bounded top-`k`
  `fastSearch`) for typo-tolerant, jank-free filtering.
* **Timezone-safe date utilities**: the `DateOperations` extension (`dateOnly`, `addDays`,
  `addYears`) and the `DateCollection` aggregation extension (`max()`).
* **Country selection widgets**: `CountriesProvider` and `NationTile`.
* Built on `material_ui`, the official Flutter Material library.

