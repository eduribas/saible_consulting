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
import 'package:saible_consulting_core/domain/iso3166_countries.dart';

/// Renders a flag icon using emoji text for a given country.
class const FlagIcon.forIso3166({super.key, required this.country, this.style}) extends StatelessWidget {
  /// The country whose flag is rendered.
  final Iso3166Country country;

  /// An override style for the icon, if desired
  final TextStyle? style;

  /// Creates a flag icon for the given [country].
  this;

  @override
  Widget build(BuildContext context) => Text(
    country.flagEmoji(),
    style: style ?? Theme.of(context).textTheme.headlineSmall,
  );
}

/// A list tile displaying a country's flag and localized name.
class const NationTile({super.key, required this.country, this.onTap}) extends StatelessWidget {
  /// Called when the tile is tapped.
  final void Function()? onTap;

  /// The country displayed in this tile.
  final Iso3166Country country;

  /// Creates a [NationTile] displaying [country] with optional [onTap] handler.
  this;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: FlagIcon.forIso3166(country: country),
    title: Text(country.tr(context)),
    onTap: onTap,
  );
}

/// A list tile displaying a country's flag, localized name, and phone calling code.
class const PhoneCodeTile({super.key, required this.country, this.onTap}) extends StatelessWidget {
  /// Called when the tile is tapped.
  final void Function()? onTap;

  /// The country displayed in this tile.
  final Iso3166Country country;

  /// Creates a [PhoneCodeTile] displaying [country] with optional [onTap] handler.
  this;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: FlagIcon.forIso3166(country: country),
    title: Text(country.tr(context)),
    subtitle: Text('+${country.phoneCode}'),
    onTap: onTap,
  );
}
