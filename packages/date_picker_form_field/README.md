# date_picker_form_field

[![pub package](https://img.shields.io/pub/v/date_picker_form_field.svg)](https://pub.dev/packages/date_picker_form_field)

An accessible, locale-adaptive date input field for Flutter that bridges keyboard data entry with an intuitive graphical calendar picker.

`DatePickerFormField` solves the classic user experience dilemma between typing dates quickly and choosing dates from a calendar. It dynamically formats input as the user types according to the active locale's natural date pattern (e.g. `DD/MM/YYYY`, `MM/DD/YYYY`, or `YYYY-MM-DD`), supports direct keyboard entry of date separators (`/`, `.`, `-`), and offers seamless adaptive popup calendar selection (Material and Cupertino).

<table>
  <tr>
    <th align="center">Date of Birth</th>
    <th align="center">Language Switcher</th>
  </tr>
  <tr>
    <td align="center" width="50%"><a href="https://github.com/user-attachments/assets/1e3d969f-0c3d-4a97-a98e-c641134e75db"><img src="https://raw.githubusercontent.com/saible-app/saible_consulting/main/doc/images/dob_thumbnail.png" alt="Date of Birth demo" width="100%"/></a></td>
    <td align="center" width="50%"><a href="https://github.com/user-attachments/assets/8b2d14bc-45e1-4e6a-a1a5-6182a36e986d"><img src="https://raw.githubusercontent.com/saible-app/saible_consulting/main/doc/images/language_thumbnail.png" alt="Language Switcher demo" width="100%"/></a></td>
  </tr>
</table>

---

## Key Architectural Strengths

- **Dynamic, Locale-Adaptive Masking with Typed Separator Support (`DateInputFormatter`)**:
  - Unlike rigid fixed-mask formatters, `DateInputFormatter` inspects `DateFormat.yMd` for the active locale at runtime to determine the true localized ordering of Day, Month, and Year as well as the regional separator (`/`, `-`, `.`).
  - Users can type numbers continuously or type separators directly from their keyboard; typed separators show immediately without waiting for subsequent digits, and single-digit day or month entries followed by a separator are automatically zero-padded (`03/`).
  - Automatically matches and adjusts placeholder hints (e.g. `DD/MM/YYYY` in the UK, `MM/DD/YYYY` in the US, `YYYY-MM-DD` in Canada/Japan).
- **Intelligent Cursor & Separator Navigation**:
  - Purpose-built editing logic handles typing, digit insertions, and backspacing across separators gracefully: backspacing over a separator removes the preceding digit cleanly without breaking cursor placement or trapping user focus.
- **Adaptive Platform Date Picking (`AdaptiveDatePickerProvider`)**:
  - Automatically chooses the native design idiom for the current platform: Cupertino date picker in a modal popup on iOS and macOS, and Material `DatePickerDialog` on Android and desktop platforms.
  - On the web the Material `DatePickerDialog` is always used, regardless of the underlying operating system, so a browser running on a Mac receives the Material picker rather than the Cupertino modal popup.
  - Pluggable layer of indirection: inject a custom `datePicker` directly into `DatePickerFormField` or provide an `AdaptiveDatePickerProvider` higher in the widget tree.
- **Unified Dual-Mode Workflow**:
  - Users can either type digits directly (with or without separators) or tap the calendar icon to select from the platform picker.
  - Date choices in either mode keep the text field and validation state perfectly synchronized.
- **Validation-Ready State Contract**:
  - The `onDateChanged` callback provides a structured `DateInputValue(rawText: ..., parsedDate: ...)`.
  - `parsedDate` evaluates to `null` if the date is incomplete, syntactically invalid (e.g. February 30th), or outside the allowable `firstDate` and `lastDate` boundaries, enabling instant integration with `Formz` or Flutter `Form` validation.
- **Enterprise Reliability & Testability**:
  - Provides exported static keys (`textInputKey`, `launchDatePickerKey`) for deterministic end-to-end testing.
  - Backed by comprehensive test suites with >99% code coverage.

---

## Features

- **Locale-Aware Formatting**: Dynamically formats date components based on the user's regional preferences.
- **Typed Separator Entry**: Direct keyboard typing of date separators (`/`, `.`, `-`) with instant feedback and auto-padding for single digits.
- **Adaptive Platform Picking**: Seamless Cupertino picker on iOS/macOS and Material date picker dialog on Android/desktop/web, plus support for custom `AdaptiveDatePickerProvider`s.
- **Dual Input Modes**: Fluid keyboard entry alongside standard graphical calendar picking.
- **Strict Range Clamping**: Enforces configurable `firstDate` and `lastDate` boundaries.
- **Clean Event Lifecycle**: Dedicated callbacks for `onDateChanged`, `onPickDate`, `onEditText`, `onFieldSubmitted`, and `onEditingComplete`.
- **Form-Ready Validation**: Typed `validator` and `onSaved` callbacks that receive the parsed `DateTime`, integrating with `Form.validate()` and form-level `AutovalidateMode`.

---

## Getting Started

Add `date_picker_form_field` to your `pubspec.yaml`:

```yaml
dependencies:
  date_picker_form_field: ^1.0.3
```

> **UI library:** this package is built on `material_ui`, the official Flutter
> Material library, and its API accepts `material_ui` types such as
> `InputDecoration`. Import `package:material_ui/material_ui.dart` in code that
> constructs those arguments: it exports distinct types that are not assignable
> to or from the copies exported by `package:flutter/material.dart`.

### Localization setup

Initialize date formatting before the first frame, so that typed input is parsed
and re-formatted with the pattern of the active locale:

```dart
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const MyApp());
}
```

Then configure your `MaterialApp` with the localization plumbing from
`saible_consulting_core`:

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
import 'package:date_picker_form_field/date_picker_form_field.dart';

class DateOfBirthExample extends StatefulWidget {
  const DateOfBirthExample({super.key});

  @override
  State<DateOfBirthExample> createState() => _DateOfBirthExampleState();
}

class _DateOfBirthExampleState extends State<DateOfBirthExample> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return DatePickerFormField(
      initialDate: DateTime(1995, 6, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        border: OutlineInputBorder(),
      ),
      onDateChanged: (value) {
        setState(() {
          _selectedDate = value.parsedDate;
        });
        print('Typed: ${value.rawText}, Valid Date: ${value.parsedDate}');
      },
      onPickDate: (pickedDate) {
        print('Selected from calendar: $pickedDate');
      },
    );
  }
}
```

### Standalone `DateInputFormatter` Usage

You can also use the formatter independently on any standard Flutter `TextFormField`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:date_picker_form_field/presentation/date_input_formatter.dart';

final formatter = DateInputFormatter(locale: 'en_GB');

TextFormField(
  inputFormatters: [formatter],
  decoration: InputDecoration(
    hintText: formatter.hintText, // "DD/MM/YYYY"
  ),
);
```

### Adaptive Date Picker & Custom Implementation

By default, `DatePickerFormField` automatically adapts to the host platform, displaying a Cupertino date picker in a modal popup on iOS and macOS, and a Material date picker dialog on Android, Linux, and Windows. On the web the Material date picker dialog is always used - even when the host operating system reports macOS or iOS (for example a browser running on a Mac) - because the Cupertino modal popup is not appropriate in a browser.

To override the platform default or plug in a custom date picker implementation, supply a custom `AdaptiveDatePicker` via `datePicker`:

```dart
import 'package:date_picker_form_field/date_picker_form_field.dart';

DatePickerFormField(
  decoration: const InputDecoration(labelText: 'Birth Date'),
  // Explicitly select AdaptiveCupertinoDatePicker, AdaptiveMaterialDatePicker, or a custom AdaptiveDatePicker:
  datePicker: AdaptiveCupertinoDatePicker(),
  onPickDate: (date) => print('Picked: $date'),
)
```

### Standalone `AdaptiveDatePicker` Usage

We have you covered if you want an adaptive date picker outside the context of a form field:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:date_picker_form_field/date_picker_form_field.dart';

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton();

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.calendar_month),
    onPressed: () async {
      final date = await context.read<AdaptiveDatePicker>().show(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      debugPrint('$date');
    },
  );  
}

class MyWidget extends StatelessWidget {
  const MyWidget();

  @override
  Widget build(BuildContext context) => AdaptiveDatePickerProvider(
    child: const _DatePickerButton(),
  );  
}
```

### Form Validation

`validator` and `onSaved` plug the field into a `Form` and receive the parsed
`DateTime` - `null` while the input is empty, incomplete, syntactically invalid
or outside `firstDate`/`lastDate`:

```dart
final formKey = GlobalKey<FormState>();
DateTime? dateOfBirth;

Form(
  key: formKey,
  child: DatePickerFormField(
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    decoration: const InputDecoration(labelText: 'Date of Birth'),
    validator: (date) => date == null ? 'Enter a valid date' : null,
    onSaved: (date) => dateOfBirth = date,
  ),
);

if (formKey.currentState!.validate()) {
  formKey.currentState!.save();
  print(dateOfBirth); // e.g. "1995-06-15 00:00:00.000"
}
```

### Input Decoration

`DatePickerFormField` allows flexible `InputDecoration` customization. By default,
it supplies a locale-aware hint (e.g. `DD/MM/YYYY`) and a calendar icon `suffixIcon`
that launches the platform date picker. You can customize the field decoration or
override the hint text and suffix icon:

```dart
DatePickerFormField(
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  decoration: InputDecoration(
    labelText: 'Date of Birth',
    hintText: 'Enter your birth date', // Overrides default date pattern hint
    suffixIcon: Icon(Icons.event),      // Overrides default calendar launcher icon
    border: const OutlineInputBorder(),
  ),
)
```

The validator runs whenever the enclosing `Form` validates - through
`FormState.validate()` or a form-level `AutovalidateMode` - and sees the same
parsed value that `onDateChanged` reports, whether it was typed or picked from
the calendar dialog.

---

## Testing

`DatePickerFormField` exposes stable testing keys for automation:

- `DatePickerFormField.textInputKey`: Key for the date `TextFormField`.
- `DatePickerFormField.launchDatePickerKey`: Key for the calendar picker launcher icon button.

Example widget test:

```dart
// Type a date (with or without separators)
await tester.enterText(find.byKey(DatePickerFormField.textInputKey), '15/06/1995');
await tester.pumpAndSettle();

// Or tap the calendar icon to open the adaptive picker
await tester.tap(find.byKey(DatePickerFormField.launchDatePickerKey));
await tester.pumpAndSettle();
```

---

## How this compares

Alternative pub.dev packages, with their like counts, 30-day downloads and
latest releases as of 1 October 2026:

| Package | Likes | Downloads | Latest | Trade-offs |
| --- | --: | --: | --- | --- |
| [`date_field`](https://pub.dev/packages/date_field) | 139 | 905 | 7.0.0 (Sep 2026) | A well-maintained `DateTimeFormField` wrapping platform pickers (Material and Cupertino) with date, time or date-and-time modes. However, its value always comes from a picker dialog or sheet: there is no keyboard-first entry, no typed separator input, and no locale-driven input mask. |
| Hand-rolled `TextFormField` + `showDatePicker` | - | - | - | Zero extra dependencies, but you implement adaptive platform indirection, locale masking, keyboard separator entry and backspacing, parsing, range clamping and the validation contract yourself. |

Pick `date_picker_form_field` when you want `DD/MM/YYYY`-style keyboard entry driven
by the active locale with typed separator support *and* adaptive platform calendar
pickers (Material on Android/desktop, Cupertino on iOS/macOS, or custom providers)
in the same field, with the parsed `DateTime` (or `null`) handed to your `Form`
through `validator` and `onSaved`.

---

## Additional Information

- Source code: [GitHub Repository](https://github.com/saible-app/saible_consulting)
- Issue tracker: File bugs or feature requests via GitHub Issues.
- License: See [LICENSE](LICENSE) for details.

