# phone_number_form_field

[![pub package](https://img.shields.io/pub/v/phone_number_form_field.svg)](https://pub.dev/packages/phone_number_form_field)

An accessible, international phone number input field for Flutter applications featuring intelligent country dial-code selection, as-you-type formatting, and rigorous international E.164 compliance validation.

`PhoneNumberFormField` delivers an enterprise-grade phone input experience by uniting an interactive calling-code prefix selector with continuous formatting and parsing powered by Google's authoritative `libphonenumber` metadata.

<table>
  <tr>
    <th align="center">Phone Number</th>
    <th align="center">Language Switcher</th>
  </tr>
  <tr>
    <td align="center" width="50%"><a href="https://github.com/user-attachments/assets/ddd343e0-60fb-4984-b33e-4331375b668b"><img src="https://raw.githubusercontent.com/saible-app/saible_consulting/main/doc/images/phone_thumbnail.png" alt="Phone Number demo" width="100%"/></a></td>
    <td align="center" width="50%"><a href="https://github.com/user-attachments/assets/8b2d14bc-45e1-4e6a-a1a5-6182a36e986d"><img src="https://raw.githubusercontent.com/saible-app/saible_consulting/main/doc/images/language_thumbnail.png" alt="Language Switcher demo" width="100%"/></a></td>
  </tr>
</table>

---

## Key Architectural Strengths

- **Powered by Google's `libphonenumber` Standard (`dlibphonenumber`)**:
  - Employs the industry gold standard for international phone number plans, area codes, number lengths, and formatting rules across every global region.
  - Avoids brittle regexes or crude length assumptions that fail on complex national numbering systems.
- **Continuous As-You-Type Formatting with Trunk Stripping**:
  - Formats numbers naturally in real time as user digits are typed.
  - Automatically detects and removes redundant domestic trunk prefixes (such as the leading `0` in UK or Australian mobile numbers) when typed or pasted, guaranteeing proper international formatting.
- **Strict International E.164 State Contract**:
  - Emits an immutable `PhoneNumberState` containing `rawText`, `regionCode`, and parsed `e164` (e.g. `+442079460123`).
  - `e164` is non-null only when the number is genuinely valid and deliverable, making backend integrations (Twilio, AWS SNS, Firebase Auth, Stripe) immediate and reliable.
- **Modern Material 3 Prefix Selector with Typo-Tolerant Search**:
  - The dial code selector uses a Material 3 `SearchAnchor` overlay that opens a fast, in-memory fuzzy search over country names, ISO codes, and dialing prefixes.
- **Multi-Lingual Country Search**:
  - Country names and search aliases are translated across 39 global languages (English, French, German, Spanish, Welsh, Japanese, Chinese, Arabic, Russian, Korean, Turkish, Hindi, and more), resolved synchronously from the active `Localizations` locale.
- **Lightweight, Zero-Asset Design**:
  - Renders native Unicode flag emojis without bundling hundreds of heavy vector or raster flag image files.
  - Fully offline, self-contained, and tested with >99% code coverage.

---

## Features

- **Country Calling-Code Selector**: Tap prefix to search all 249 ISO countries by localized name, code, or dial prefix.
- **As-You-Type Phone Formatting**: Automatic national phone structure formatting.
- **Trunk Code Normalization**: Automatically strips redundant domestic trunk zeros.
- **E.164 Compliance Validation**: Instant access to formatted E.164 string and boolean validity checks (`state.isValid`).
- **Flexible Form Integration**: Drop-in `Form` support through typed `validator` and `onSaved` callbacks that receive the parsed `PhoneNumberState`, alongside `onPhoneNumberChanged` for `Formz` and BLoC/Riverpod state managers.

---

## Getting Started

Add `phone_number_form_field` and [`saible_consulting_core`](https://pub.dev/packages/saible_consulting_core) to your `pubspec.yaml`:

```yaml
dependencies:
  phone_number_form_field: ^1.0.6
  saible_consulting_core: ^1.0.6
```

> **UI library:** this package is built on `material_ui`, the official Flutter
> Material library, and its API accepts `material_ui` types such as
> `InputDecoration`. Import `package:material_ui/material_ui.dart` in code that
> constructs those arguments: it exports distinct types that are not assignable
> to or from the copies exported by `package:flutter/material.dart`.

### Localization setup

Configure your `MaterialApp` with the localization plumbing from
`saible_consulting_core` (no provider or lookup is required):

```dart
import 'package:material_ui/material_ui.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

MaterialApp(
  supportedLocales: SaibleLocalizations.supportedLocales,
  localizationsDelegates: SaibleLocalizations.localizationsDelegates,
  home: const MyPhoneFormPage(),
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
import 'package:phone_number_form_field/phone_number_form_field.dart';

class PhoneInputExample extends StatefulWidget {
  const PhoneInputExample({super.key});

  @override
  State<PhoneInputExample> createState() => _PhoneInputExampleState();
}

class _PhoneInputExampleState extends State<PhoneInputExample> {
  PhoneNumberState _phoneState = const PhoneNumberState.empty();

  @override
  Widget build(BuildContext context) {
    return PhoneNumberFormField(
      decoration: InputDecoration(
        labelText: 'Phone Number',
        border: const OutlineInputBorder(),
        errorText: _phoneState.isNotEmpty && !_phoneState.isValid
            ? 'Please enter a valid phone number'
            : null,
      ),
      onPhoneNumberChanged: (state) {
        setState(() {
          _phoneState = state;
        });
        print('E.164 number: ${state.e164}'); // e.g. "+442079460123"
        print('Region: ${state.regionCode}');  // e.g. "+44"
        print('Valid: ${state.isValid}');
      },
    );
  }
}
```

### Prepopulating an Initial Number

You can initialize the field with an existing `PhoneNumberState`:

```dart
PhoneNumberFormField(
  initialValue: const PhoneNumberState(
    rawText: '20 7946 0123',
    e164: '+442079460123',
    regionCode: '+44',
  ),
  onPhoneNumberChanged: (phoneState) {
    // handle state changes
  },
);
```

### Form Validation

`validator` and `onSaved` plug the field into a `Form` and receive the parsed
`PhoneNumberState`, so validation and submission work on the E.164 value and the
selected dial code rather than on the raw text:

```dart
final formKey = GlobalKey<FormState>();
PhoneNumberState? saved;

Form(
  key: formKey,
  child: PhoneNumberFormField(
    decoration: const InputDecoration(labelText: 'Phone Number'),
    validator: (state) => state.isValid ? null : 'Enter a valid phone number',
    onSaved: (state) => saved = state,
  ),
);

if (formKey.currentState!.validate()) {
  formKey.currentState!.save();
  print(saved!.e164);       // e.g. "+442079460123"
  print(saved!.regionCode); // e.g. "+44"
}
```

The validator runs whenever the enclosing `Form` validates - through
`FormState.validate()` or a form-level `AutovalidateMode`. `state.e164` is
`null` until the number is complete and valid, so a single `state.isValid` check
covers empty, partial and malformed input; inspect `state.rawText` instead when
you want to distinguish "required" from "malformed".

### Restricting the Dial Code List

Offer only a subset of countries with `include`, drop some with `exclude`, or
apply a dynamic `filter` predicate that is evaluated on every build:

```dart
// Opt in to a short list
PhoneNumberFormField(
  include: const [Iso3166Country.unitedKingdom, Iso3166Country.ireland],
  decoration: const InputDecoration(labelText: 'Mobile Phone'),
)

// Opt out of the countries you cannot serve
PhoneNumberFormField(
  exclude: const [Iso3166Country.unitedKingdom],
  decoration: const InputDecoration(labelText: 'Mobile Phone'),
)

// Filter dynamically, e.g. only countries on a +44 dial code
PhoneNumberFormField(
  filter: (country) => country.phoneCode == 44,
  decoration: const InputDecoration(labelText: 'Mobile Phone'),
)
```

At most one of `include`, `exclude` and `filter` may be supplied, which is
enforced by an assertion. The restriction applies to the picker's search as well
as its list, and the field's implicit default dial code is always resolved to a
country that is still on offer. An explicit `initialValue` is used exactly as
given, so it is up to the caller to keep it compatible.

### Input Decoration

`PhoneNumberFormField` supports full `InputDecoration` customization (labels,
helper text, error styling, borders, etc.). Because the interactive calling-code
selector occupies the prefix area, specifying any prefix in `decoration` (`prefix`,
`prefixIcon`, or `prefixText`) is disallowed and triggers a runtime assertion:

```dart
// Allowed:
PhoneNumberFormField(
  decoration: const InputDecoration(
    labelText: 'Mobile Phone',
    border: OutlineInputBorder(),
  ),
);

// Throws an AssertionError at runtime:
PhoneNumberFormField(
  decoration: const InputDecoration(
    prefixText: '+44', // Prohibited: prefix is managed by the country dial code selector
  ),
);
```

---

## Testing

`PhoneNumberFormField` exposes stable testing keys for automation:

- `PhoneNumberFormField.countrySearchAnchorKey`: Key for the prefix search anchor.
- `PhoneNumberFormField.textInputKey`: Key for the phone number text entry field.
- `PhoneNumberFormField.countrySuggestionKey(country)`: Generates a test key for a country's suggestion tile.

Example widget test:

```dart
// Enter phone number
await tester.enterText(
  find.byKey(PhoneNumberFormField.textInputKey),
  '02079460123',
);
await tester.pumpAndSettle();

// Tap dial code selector
await tester.tap(find.text('+44'));
await tester.pumpAndSettle();
```

---

## How this compares

Alternative pub.dev packages, with their like counts, 30-day downloads and
latest releases as of 1 October 2026:

| Package | Likes | Downloads | Latest | Trade-offs |
| --- | --: | --: | --- | --- |
| [`intl_phone_number_input`](https://pub.dev/packages/intl_phone_number_input) | 926 | 128k | 0.7.5 (Sep 2025) | The most-used option and also built on `dlibphonenumber`. Its `InternationalPhoneNumberInput` offers selector styles (dropdown, bottom sheet, dialog), but it asks you to assemble more of the field yourself, and its flags are image assets unless you opt into emoji. Published by an unverified uploader. |
| [`intl_phone_field`](https://pub.dev/packages/intl_phone_field) | 782 | 119k | 3.2.0 (Jun 2023) | No release since 2023, so its validation rules are frozen rather than tracking current numbering plans. |
| [`phone_number_field`](https://pub.dev/packages/phone_number_field) | 6 | 94 | 1.2.0 (Jul 2025) | Minimal: English-only country names and regex-based validation. |

Pick `phone_number_form_field` when you want libphonenumber-grade parsing and an
E.164 result from a single widget that drops straight into a `Form`, with an
offline dial code picker that fuzzy-searches all 249 countries in 39 languages
and renders Unicode flag emojis instead of bundling flag assets.

---

## Additional Information

- Source code: [GitHub Repository](https://github.com/saible-app/saible_consulting)
- Issue tracker: File bugs or feature requests via GitHub Issues.
- License: See [LICENSE](LICENSE) for details.

