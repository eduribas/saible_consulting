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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_demo/application/country_input_state.dart';
import 'package:form_demo/application/date_input_state.dart';
import 'package:form_demo/application/phone_number_input_state.dart';
import 'package:form_demo/application/registration_form_event.dart';
import 'package:form_demo/application/registration_form_state.dart';

/// Manages the state and business logic of the registration form.
class RegistrationFormBloc() extends Bloc<RegistrationFormEvent, RegistrationFormState> {
  /// Creates a [RegistrationFormBloc] initialized with default registration form state.
  this : super(const RegistrationFormState.initial()) {
    on<DateOfBirthChanged>((event, emit) {
      emit(state.copyWith(
        dateOfBirth: DateInputState.dirty(first: event.first, last: event.last, input: event.value)
      ));
    });

    on<NationalityChanged>((event, emit) {
      emit(state.copyWith(
        nationality: CountryInputState.dirty(event.value)
      ));
    });

    on<CountryOfResidenceChanged>((event, emit) {
      emit(state.copyWith(
        countryOfResidence: CountryInputState.dirty(event.value)
      ));
    });

    on<PhoneNumberChanged>((event, emit) {
      emit(state.copyWith(
        phoneNumber: PhoneNumberInputState.dirty(event.value)
      ));
    });
  }
}
