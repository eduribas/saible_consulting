## 1.0.6

* The `CountryPickerMode.dropdown` menu now spans the full width of its parent,
  so it lines up with the fields around it instead of collapsing to the
  `DropdownMenu` default width.
* The dropdown now shows the selected country's flag as a trailing icon, giving
  it the same affordance as the search-anchor view.
* The favourites/remaining separator in the dropdown is now drawn as a bottom
  border on the final favourite's menu entry rather than an inline `Divider`, so
  it spans the full width of the entry.
* `CountryPickerFormField.favoritesDividerKey` is unchanged and still marks the
  `Divider` between the two groups of suggestions in the search-anchor view; the
  dropdown expresses the same separation as an entry border instead.
* Bumped version to `1.0.6` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.6`.

## 1.0.5

* Added `CountryPickerMode`, allowing the picker to open either as a search view
  (`CountryPickerMode.searchAnchor`, the default) or inline as a dropdown
  (`CountryPickerMode.dropdown`). `CountryPickerMode` is exported from the
  package's public library.
* The dropdown mode ranks matches with the same Jaro-Winkler search as the
  suggestions view, hoists `favorites` and trails the final favourite with a
  `Divider`, and is wrapped in a `FormField` so an enclosing `Form` drives
  `validator` and `onSaved` with the chosen `Iso3166Country`.
* Added optional `include` and `exclude` lists and a dynamic `filter` predicate
  to `CountryPickerFormField`, restricting which countries are offered and
  searchable. At most one of the three may be supplied, enforced by an
  assertion.
* `CountryPickerFormField.initial` is now used exactly as given, leaving it to
  the caller to keep it compatible with `include`, `exclude` and `filter`.
* The dropdown mode maps `decoration` onto its inner field, requests focus on
  tap so that typing to filter works on mobile, and shows the first offered
  country when the implicit default is not available.
* Bumped version to `1.0.5` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.5`.

## 1.0.4

* Added an optional `favorites` field (`List<Iso3166Country>`) to
  `CountryPickerFormField`. Favourite countries are listed first in the
  suggestions view, in the order supplied, and are separated from the remaining
  matches by a `Divider` whenever both groups contribute to the results.
  Favourites remain subject to the active search query, and a lone group is
  never trailed by a stray divider.
* Exposed the new `CountryPickerFormField.favoritesDividerKey` testing key.
* Bumped version to `1.0.4` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.4`.

## 1.0.3

* Bumped version to `1.0.3` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.3`.

## 1.0.2

* Bumped version to `1.0.2` across the Saible Consulting package suite.
* Bumped `material_ui` dependency constraint to `^1.6.0`.

## 1.0.1

* Bumped version to `1.0.1` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.1`.

## 1.0.0

* Bumped version to `1.0.0` for official stable release.
* Added support for custom `suffixIcon` in `InputDecoration`, overriding default country flag / globe icon.
* Updated `material_ui` dependency constraint to `^1.5.0`.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.0`.

## 0.2.3

* Made `decoration` parameter optional in `CountryPickerFormField`.
* Bumped `saible_consulting_core` dependency constraint to `^0.2.3`.

## 0.2.2

* Bumped `saible_consulting_core` dependency constraint to `^0.2.2`.

## 0.2.1

* Updated README with clickable video preview thumbnails linking to demonstration recordings, compatible with pub.dev and GitHub markdown rendering.
* Bumped `saible_consulting_core` dependency constraint to `^0.2.1`.

## 0.2.0

* Bumped version to `0.2.0` aligned with the Saible Consulting package suite.
* Updated dependency constraint to `saible_consulting_core: ^0.2.0`.
* Verified compatibility with `material_ui` 1.5.0.
* Updated documentation with standard pub.dev package badges and demonstration media.

## 0.1.0

* Initial release.
* `CountryPickerFormField`: a searchable country selector form field that integrates with
  `Form` through `decoration` and `onCountryPicked`, plus typed `validator` and `onSaved`
  callbacks that receive the selected `Iso3166Country`.
* Typo-tolerant fuzzy search (Jaro-Winkler) over country names, alpha-2/alpha-3 codes,
  dial codes and aliases, powered by `saible_consulting_core`.
* Flag emojis and localized country names that follow the active app locale.
* Exposes stable widget keys for widget tests.
* Setup guidance for `material_ui` apps: use
  `SaibleLocalizations.localizationsDelegates` from `saible_consulting_core` to get the
  country strings together with `material_ui`'s Material, Cupertino and Widgets delegates.
* Built on `material_ui`, the official Flutter Material library.

