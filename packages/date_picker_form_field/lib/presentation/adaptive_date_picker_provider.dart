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

import 'package:date_picker_form_field/presentation/adaptive_cupertino_date_picker.dart';
import 'package:date_picker_form_field/presentation/adaptive_date_picker.dart';
import 'package:date_picker_form_field/presentation/adaptive_material_date_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

@visibleForTesting
/// Allow tests to simulate a web browser
bool? debugIsWebOverride;

bool get _isWeb => debugIsWebOverride ?? kIsWeb;

/// Provides an adaptive date picker depending on the widget platform
class const AdaptiveDatePickerProvider({
  super.key,
  required this.child,
  this.datePicker,
}) extends StatelessWidget {
  /// Creates an [AdaptiveDatePickerProvider]
  this;

  /// The widget below this provider in the tree.
  final Widget child;

  /// An optional custom [AdaptiveDatePicker] to override the platform default.
  /// 
  /// If you want to use your own concrete adaptive date picker implementation, you can do so here.
  final AdaptiveDatePicker? datePicker;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return Provider<AdaptiveDatePicker>.value(
      value: datePicker ?? switch ((platform, _isWeb)) {
        (_, true) => AdaptiveMaterialDatePicker(),
        (TargetPlatform.iOS || TargetPlatform.macOS, _) => AdaptiveCupertinoDatePicker(),
        _ => AdaptiveMaterialDatePicker(),
      },
      child: child,
    );
  }
}
