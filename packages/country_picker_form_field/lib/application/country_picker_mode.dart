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

/// Choose whether you want the country list to open in its own context (effectively in an overlaid page),
/// or in-place.
/// 
/// Both modes use the same underlying Jaro-Winkler fuzzy search, so the decision should be based on the
/// size of the list, the amount of screen real estate available, and the overarching UI design of your app.
enum CountryPickerMode() {
  /// The [searchAnchor] mode opens a full searchbar when the country picker is clicked.
  /// 
  /// This opens the search in a clean, new page. It is suited to longer lists of countries.
  searchAnchor,
  /// The [dropdown] mode presents the country list inline, as a dropdown where the user opens it.
  /// 
  /// This is appropriate when you have more screen real estate, or when the country list is shorter.
  dropdown,
}
