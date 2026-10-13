## 1.0.4

* Bumped version to `1.0.4` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.4`.

## 1.0.3

* `AdaptiveDatePickerProvider` now uses the Material `DatePickerDialog` on the
  web, even when the host platform reports `macOS` or `iOS` (for example a
  browser running on a Mac), instead of the Cupertino modal popup.
* Bumped version to `1.0.3` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.3`.

## 1.0.2

* Bumped version to `1.0.2` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.2`.
* Bumped `material_ui` dependency constraint to `^1.6.0`.
* Bumped `cupertino_ui` dependency constraint to `^1.1.2`.

## 1.0.1

* Bumped version to `1.0.1` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.1`.

## 1.0.0

* Bumped version to `1.0.0` for official stable release.
* **Adaptive date picker consolidation**:
  - Replaced provider classes with `AdaptiveDatePicker` interface hierarchy (`AdaptiveCupertinoDatePicker`, `AdaptiveMaterialDatePicker`).
  - Added `AdaptiveDatePickerProvider` widget and direct `datePicker` injection parameter on `DatePickerFormField`.
  - Added standalone `AdaptiveDatePicker` usage support outside form field contexts.
* **Flexible decoration**:
  - Allowed overriding `hintText` and calendar launcher `suffixIcon` via `decoration`.
* Updated `material_ui` dependency constraint to `^1.5.0`.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.0`.

## 0.2.3

* Bumped `saible_consulting_core` dependency constraint to `^0.2.3`.

## 0.2.2

* Set `DatePickerEntryMode.calendarOnly` as the initial entry mode in `MaterialDatePickerProvider` to prevent unintended mode toggling in the material dialog.
* Bumped `saible_consulting_core` dependency constraint to `^0.2.2`.

## 0.2.1

* Updated README with clickable video preview thumbnails linking to demonstration recordings, compatible with pub.dev and GitHub markdown rendering.
* Bumped `saible_consulting_core` dependency constraint to `^0.2.1`.

## 0.2.0

* **Adaptive platform picker**: introduced `AdaptiveDatePickerProvider` with
  `CupertinoDatePickerProvider` (Cupertino date picker in a modal popup on iOS and macOS)
  and `MaterialDatePickerProvider` (`DatePickerDialog` on Android, Linux, and Windows).
* **Custom provider injection**: added `pickerProvider` parameter to `DatePickerFormField`
  to allow supplying custom date picker implementations or overriding the platform default.
* **Direct separator keyboard typing**: `DateInputFormatter` now supports typing separators
  directly (`/`, `.`, `-`, `,`, space) with immediate display feedback, and automatically
  pads single-digit day or month entries with a leading zero (e.g. `3/` becomes `03/`).
* **Cleaned up testing keys**: removed obsolete `DatePickerFormField.switchToEntryModeKey`
  as the field now defaults directly to keyboard entry.
* **Updated dependencies**: added `cupertino_ui: ^1.1.1` and `provider: ^6.1.5+1`.

## 0.1.0

* Initial release.
* `DatePickerFormField`: a locale-aware date form field that can be typed manually or
  picked from the calendar dialog, with `initialDate`, `firstDate` and `lastDate` bounds.
* `DateInputFormatter`: the locale-aware as-you-type date formatter, exported separately
  so it can be applied to any `TextFormField` (`hintText` reflects the locale pattern).
* Localized `hintText`/pattern ordering driven by the active app locale.
* Typed `validator` and `onSaved` callbacks for `Form` integration, receiving the parsed
  `DateTime` (or `null` while the input is empty, incomplete or out of range).
* Exposes stable widget keys for widget tests (`switchToEntryModeKey`, `textInputKey`,
  `launchDatePickerKey`).
* Setup guidance for `material_ui` apps: use
  `SaibleLocalizations.localizationsDelegates` from `saible_consulting_core` to get the
  country strings together with `material_ui`'s Material, Cupertino and Widgets delegates.
* Built on `material_ui`, the official Flutter Material library.

