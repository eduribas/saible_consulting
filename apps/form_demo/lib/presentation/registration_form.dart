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

import 'package:country_picker_form_field/presentation/country_picker_form_field.dart';
import 'package:date_picker_form_field/presentation/date_picker_form_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_demo/application/country_input_state.dart';
import 'package:form_demo/application/date_input_state.dart';
import 'package:form_demo/application/phone_number_input_state.dart';
import 'package:form_demo/application/registration_form_bloc.dart';
import 'package:form_demo/application/registration_form_event.dart';
import 'package:form_demo/application/registration_form_state.dart';
import 'package:form_demo/l10n/app_localizations.dart';
import 'package:form_demo/presentation/language_menu.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phone_number_form_field/presentation/phone_number_form_field.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

/// The main registration form screen of the demo application.
///
/// Collects user information including date of birth, nationality,
/// and phone number, and exposes an app bar with language selection.
class const RegistrationForm({super.key, required this.onLocaleChanged}) extends StatefulWidget {
  /// Callback invoked when the user selects a new locale from the language switcher.
  final ValueChanged<Locale> onLocaleChanged;

  /// Creates a [RegistrationForm].
  this;

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class const _DateOfBirthField() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMd(locale.toLanguageTag());
    return BlocSelector<RegistrationFormBloc, RegistrationFormState, DateInputState>(
      selector: (state) => state.dateOfBirth,
      builder: (context, dateOfBirth) {
        final first = dateOfBirth.first;
        final last = dateOfBirth.last;
        return ListTile(
          title: DatePickerFormField(
            firstDate: dateOfBirth.first(),
            lastDate: dateOfBirth.last(),
            decoration: InputDecoration(
              labelText: l10n.dateOfBirthLabel,
              errorText: switch (dateOfBirth.error) {
                null => null,
                _ when dateOfBirth.isPure => null,
                DateInputStateErrorRequired() => l10n.dateOfBirthErrorRequired,
                DateInputStateErrorInvalid() => l10n.dateOfBirthErrorInvalid,
                DateInputStateErrorTooEarly(first: final f) => l10n.dateOfBirthErrorTooEarly(dateFormat.format(f)),
                DateInputStateErrorTooLate(last: final l) => l10n.dateOfBirthErrorTooLate(dateFormat.format(l))
              }
            ),
            onDateChanged: (input) {
              context.read<RegistrationFormBloc>().add(
                DateOfBirthChanged(first: first, last: last, value: input)
              );
            },
          ),
        );
      },
    );
  }
}

class const _NationalityField() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocSelector<RegistrationFormBloc, RegistrationFormState, CountryInputState>(
      selector: (state) => state.nationality,
      builder: (context, nationality) => ListTile(
        title: CountryPickerFormField(
          favorites: const [
            Iso3166Country.unitedKingdom,
            Iso3166Country.ireland,
            Iso3166Country.france,
          ],
          decoration: InputDecoration(
            labelText: l10n.nationalityLabel,
            errorText: switch (nationality.error) {
              null => null,
              _ when nationality.isPure => null,
              CountryValidationError.empty => l10n.nationalityErrorRequired,
            }
          ),
          onCountryPicked: (input) {
            context.read<RegistrationFormBloc>().add(
              NationalityChanged(value: input)
            );
          },
        ),
      ),
    );
  }
}

class const _PhoneNumberField() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocSelector<RegistrationFormBloc, RegistrationFormState, PhoneNumberInputState>(
      selector: (state) => state.phoneNumber,
      builder: (context, phoneNumber) => ListTile(
        title: PhoneNumberFormField(
          decoration: InputDecoration(
            labelText: l10n.phoneNumberLabel,
            errorText: switch (phoneNumber.error) {
              null => null,
              _ when phoneNumber.isPure => null,
              PhoneNumberInputStateError.required => l10n.phoneNumberErrorRequired,
              PhoneNumberInputStateError.invalid => l10n.phoneNumberErrorInvalid,
            }
          ),
          onPhoneNumberChanged: (input) {
            context.read<RegistrationFormBloc>().add(
              PhoneNumberChanged(value: input)
            );
          },
        ),
      ),
    );
  }
}

class const _Actions() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<RegistrationFormBloc, RegistrationFormState>(
      builder: (context, state) {
        void submitForm() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.formValidated}\n'
                '${l10n.dateOfBirthPrefix}: ${state.dateOfBirth.value.rawText}\n'
                '${l10n.nationalityPrefix}: ${state.nationality.value?.tr(context)}\n'
                '${l10n.phonePrefix}: ${state.phoneNumber.value.regionCode} ${state.phoneNumber.value.rawText}',
              ),
            ),
          );
        }
        return ListTile(
          title: FilledButton(
            onPressed: state.isValid ? submitForm : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: Text(l10n.submitButton),
          ),
        );
      },
    );
  }
}

class const _PrivacyBanner() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: const Icon(Icons.shield_outlined),
          title: Text(l10n.privacyNotice, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}

class const _Form() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Form(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrivacyBanner(),
        SizedBox(height: 24),
        _DateOfBirthField(),
        _NationalityField(),
        _PhoneNumberField(),
        SizedBox(height: 32),
        _Actions(),
      ],
    ),
  );
}

class _RegistrationFormState() extends State<RegistrationForm> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        elevation: 2,
        actions: [LanguageSwitcher(onLocaleChanged: widget.onLocaleChanged)],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: _Form(),
        ),
      ),
    );
  }
}
