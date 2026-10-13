## 1.0.4

* Bumped version to `1.0.4` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.4`.

## 1.0.3

* Bumped version to `1.0.3` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.3`.

## 1.0.2

* Bumped version to `1.0.2` across the Saible Consulting package suite.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.2`.
* Bumped `material_ui` dependency constraint to `^1.6.0`.
* Bumped `dlibphonenumber` dependency constraint to `^1.1.74`.

## 1.0.1

* Fixed initial value and example hint formatting so that pre-filled numbers render identically to as-you-type input.
  - `internationalFormatWithoutTrunk()` now formats numbers using the region's national style with the national (trunk) prefix stripped, so `+12015550123` renders as `(201) 555-0123` rather than the international `201-555-0123`.
  - `PhoneNumberFormField` now renders its `initialValue` with the same formatting as the as-you-type formatter.
* Added an `onFieldSubmitted` callback, forwarded to the underlying `TextFormField`.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.1`.

## 1.0.0

* Bumped version to `1.0.0` for official stable release.
* Added runtime validation check asserting that `decoration` does not specify `prefix`, `prefixIcon`, or `prefixText`, ensuring calling-code prefix selector integrity.
* Allowed overriding `hintText` via `decoration` without interfering with dial code prefix selector.
* Updated `material_ui` dependency constraint to `^1.5.0` and `dlibphonenumber` to `^1.1.73`.
* Bumped `saible_consulting_core` dependency constraint to `^1.0.0`.

## 0.2.3

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
* `PhoneNumberFormField`: an international phone number form field with a searchable dial
  code prefix selector and full `Form` integration; typed `validator` and `onSaved`
  callbacks receive the parsed `PhoneNumberState` (E.164, region code, raw text).
* `PhoneNumberState` value type (`rawText`, `e164`, `regionCode`, `isValid`) reported
  through `onPhoneNumberChanged`, plus `PhoneNumberState.empty()` and
  `PhoneNumberState.fromPhoneNumber()` for prepopulating the field.
* E.164 parsing and validation through `dlibphonenumber`, with localized example numbers
  per country.
* `AsYouTypePhoneNumberFormatter` and other stable widget keys exposed for integration
  and widget tests.
* Setup guidance for `material_ui` apps: use
  `SaibleLocalizations.localizationsDelegates` from `saible_consulting_core` to get the
  country strings together with `material_ui`'s Material, Cupertino and Widgets delegates.
* Built on `material_ui`, the official Flutter Material library.

