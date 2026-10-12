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

import 'package:material_ui/material_ui.dart';

/// Extension methods on collections of [DateTime].
extension DateCollection on Iterable<DateTime> {
  /// Returns the latest date-time in the iterable.
  DateTime max() => reduce((x, y) => x.isAfter(y) ? x : y);
}

/// Extension methods for common date manipulation on [DateTime].
extension DateOperations on DateTime {
  /// Returns a [DateTime] with only the date components (year, month, day).
  DateTime dateOnly() => DateUtils.dateOnly(this);

  /// Adds the given number of [days] without timezone offset issues.
  /// 
  /// This is safer than using add(Duration(days: days)), because that will add days * 24 hours to the current value,
  // which will break the implementation when you move through a timezone.
  DateTime addDays(int days) => DateTime(year, month, day + days, hour, minute, second, millisecond, microsecond);

  /// Adds the given number of [months] preserving the time and day components.
  ///
  /// This is safer than using add(Duration(days: months * 30)), because a month
  /// is not a fixed number of days and such an approximation would silently
  /// drift. Constructing the [DateTime] directly keeps the arithmetic in
  /// calendar terms, so it is free of timezone offset issues just like
  /// [addDays] and [addYears].
  ///
  /// Dart's [DateTime] constructor normalizes overflow, so the result rolls
  /// over the year boundary (e.g. adding one month to December lands in the
  /// following January) and clamps the day to the last day of the shorter
  /// target month (e.g. 31 January + 1 month yields early March).
  DateTime addMonths(int months) => DateTime(year, month + months, day, hour, minute, second, millisecond, microsecond);

  /// Adds the given number of [years] preserving the time and day components.
  DateTime addYears(int years) => DateTime(year + years, month, day, hour, minute, second, millisecond, microsecond);
}
