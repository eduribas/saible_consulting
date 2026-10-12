# Example

A minimal application that demonstrates `saible_consulting_core`.

Everything lives in [`lib/main.dart`](lib/main.dart):

* `Iso3166Country` lookups with flag emojis (`flagEmoji()`), ISO codes (`alpha2`,
  `alpha3`) and dial codes (`phoneCode`), plus locale-aware names
  (`tr(context)`).
* Typo-tolerant fuzzy search across all 249 countries using
  `TextSearch(...).fastSearch('germny', limit: 3)`.
* Timezone-safe date arithmetic with the `DateOperations` (`dateOnly`,
  `addDays`, `addMonths`, `addYears`) and `DateCollection` (`max()`) extensions.
* A `MaterialApp` wired to `SaibleLocalizations.supportedLocales` and
  `SaibleLocalizations.localizationsDelegates`, so country names follow the
  active locale and `material_ui`'s own Material strings stay localized too.

The example deliberately has no `pubspec.yaml` of its own: it is analyzed and
resolved with the dependencies of the package it ships inside. To run it, copy
[`lib/main.dart`](lib/main.dart) into a Flutter application that depends on
`saible_consulting_core` and `material_ui`, and use it as the app entrypoint.
