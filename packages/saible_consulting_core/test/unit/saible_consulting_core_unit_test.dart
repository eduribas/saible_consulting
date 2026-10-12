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


import 'package:flutter_test/flutter_test.dart';
import 'package:saible_consulting_core/application/jaro_winkler.dart';
import 'package:saible_consulting_core/saible_consulting_core.dart';

void main() {
  test('Iso3166Country enum elements have valid numeric phone codes', () {
    expect(Iso3166Country.unitedKingdom.phoneCode, 44);
    expect(Iso3166Country.unitedStates.phoneCode, 1);
    expect(Iso3166Country.afghanistan.phoneCode, 93);
    expect(Iso3166Country.france.phoneCode, 33);
    expect(Iso3166Country.germany.phoneCode, 49);

    for (final country in Iso3166Country.values) {
      expect(
        country.phoneCode,
        isPositive,
        reason: '${country.name} (${country.alpha2}) should have a positive phoneCode',
      );
    }
  });

  group('JaroWinkler', () {
    final jw = JaroWinkler();

    test('similarity is 1 for identical and 0 for disjoint strings', () {
      expect(jw.similarity('france', 'france'), 1);
      expect(jw.similarity('xyz', 'abc'), lessThan(0.4));
      expect(jw.similarity('', 'abc'), 0);
    });

    test('match window considers the longer string length', () {
      // With the historical window (based on the first string only) the
      // trailing 'k' could never match; using the maximum length lets it.
      final similarity = jw.similarity('uk', 'united kingdom');
      expect(similarity, greaterThan(0.7), reason: "'uk' should score highly against 'united kingdom'");
    });

    test('similarityUpperBound is never exceeded by actual similarity', () {
      const pairs = [
        ('fr', 'france'),
        ('uk', 'united kingdom'),
        ('de', 'germany'),
        ('kingdom', 'united kingdom'),
        ('abcd', 'ab'),
        ('xyz', 'united kingdom'),
      ];
      for (final (s1, s2) in pairs) {
        expect(
          jw.similarityUpperBound(s1.length, s2.length),
          greaterThanOrEqualTo(jw.similarity(s1, s2)),
          reason: 'bound must hold for "$s1" vs "$s2"',
        );
      }
    });

    test('distance is the complement of similarity', () {
      expect(jw.distance('france', 'france'), 0);
      expect(jw.distance('france', 'french'), closeTo(1 - jw.similarity('france', 'french'), 1e-12));
    });
  });

  group('TextSearch', () {
    TextSearch<String> buildSearch() => TextSearch([
      TextSearchItem.fromTerms('France', ['france', 'FR', 'french republic']),
      TextSearchItem.fromTerms('Germany', ['germany', 'DE', 'federal republic of germany']),
      TextSearchItem.fromTerms('United Kingdom', ['united kingdom', 'GB', 'great britain']),
    ]);

    test('exact and case-insensitive matches score 0 and come first', () {
      final results = buildSearch().search('FRANCE');
      expect(results.first.item, 'France');
      expect(results.first.score, 0);
    });

    test('search and fastSearch agree on ordering for the same term', () {
      final search = buildSearch();
      final scored = search.search('german');
      final fast = search.fastSearch('german');
      expect(fast, [for (final r in scored) r.item]);
    });

    test('empty search term matches every item in both methods', () {
      final search = buildSearch();
      expect(search.search('').map((r) => r.item), containsAll(['France', 'Germany', 'United Kingdom']));
      expect(search.fastSearch(''), containsAll(['France', 'Germany', 'United Kingdom']));
    });

    test('items without terms are safely ignored', () {
      final search = TextSearch<String>([const TextSearchItem('orphan', [])]);
      expect(search.search('orphan'), isEmpty);
      expect(search.fastSearch('orphan'), isEmpty);
    });

    test('fastSearch limit returns only the best k results', () {
      final search = buildSearch();
      final unlimited = search.fastSearch('republic');
      final limited = search.fastSearch('republic', limit: 1);
      expect(limited.length, 1);
      expect(limited.first, unlimited.first);
      expect(search.fastSearch('france', limit: 0), isEmpty);
    });

    test('single character terms match case-insensitively', () {
      // Historically the single-character check was case-sensitive, so a
      // lowercase search input never matched an uppercase single-character
      // term such as an ISO-2 code.
      final search = TextSearch<String>([
        TextSearchItem.fromTerms('France', ['F']),
      ]);
      expect(search.fastSearch('f'), contains('France'));
    });

    test('alwaysMatchPrefix matches lowercased search input', () {
      final search = buildSearch();
      expect(search.fastSearch('fren', alwaysMatchPrefix: true), contains('France'));
    });

    test('multi-word terms match on component words', () {
      final results = buildSearch().search('kingdom');
      expect(results, isNotEmpty);
      expect(results.first.item, 'United Kingdom');
    });

    test('multi-word term with all single characters matches', () {
      final search = TextSearch<String>([
        TextSearchItem.fromTerms('SingleChars', ['a b c']),
      ]);
      expect(search.search('z'), isNotEmpty);
    });

    test('multi-word prefix match', () {
      final search = TextSearch<String>([
        TextSearchItem.fromTerms('France', ['republic of france']),
      ]);
      expect(search.search('rep'), isNotEmpty);
    });

    test('fastSearch with limit uses bounded top-k correctly when capacity reached', () {
      final search = TextSearch<String>([
        TextSearchItem.fromTerms('Item1', ['apple one']),
        TextSearchItem.fromTerms('Item2', ['apple two']),
        TextSearchItem.fromTerms('Item3', ['apple three']),
      ]);
      final results = search.fastSearch('apple', limit: 2);
      expect(results.length, 2);
    });

    test('fastSearch with limit replaces worst score and inserts mid-list', () {
      final search = TextSearch<String>([
        TextSearchItem.fromTerms('Mid', ['apple banana']), // moderate score
        TextSearchItem.fromTerms('Worst', ['apple zebra xylophone']), // worse score
        TextSearchItem.fromTerms('Best', ['apple']), // exact match (score 0), replaces worst and inserts before Mid
      ]);
      final results = search.fastSearch('apple', limit: 2);
      expect(results, ['Best', 'Mid']);
    });

    test('search scaled distance returns effectiveThreshold when length bound fails', () {
      final search = TextSearch<String>([
        TextSearchItem.fromTerms('A', ['verylongwordthatclearlyexceedsthresholdandcannotmatch']),
      ]);
      expect(search.search('xy', matchThreshold: 0.1), isEmpty);
    });

    test('fastSearch empty term with limit returns prefix of items', () {
      final search = buildSearch();
      final results = search.fastSearch('', limit: 2);
      expect(results.length, 2);
      expect(results, ['France', 'Germany']);
    });
  });

  group('DateUtils extensions', () {
    test('DateCollection max returns the latest date', () {
      final d1 = DateTime(2020, 1, 1, 10, 30);
      final d2 = DateTime(2021, 5, 20, 8, 15);
      expect([d1, d2].max(), d2);
    });

    test('DateOperations extensions work as expected', () {
      final dt = DateTime(2020, 1, 15, 10, 30, 45);
      expect(dt.dateOnly(), DateTime(2020, 1, 15));
      expect(dt.addDays(5), DateTime(2020, 1, 20, 10, 30, 45));
      expect(dt.addMonths(2), DateTime(2020, 3, 15, 10, 30, 45));
      expect(dt.addYears(2), DateTime(2022, 1, 15, 10, 30, 45));
    });

    test('DateOperations.addMonths rolls the year over and normalizes overflow', () {
      final dt = DateTime(2020, 11, 15, 8);

      // Rolling forward past December lands in the following January.
      expect(dt.addMonths(3), DateTime(2021, 2, 15, 8));
      // Rolling backward past January lands in the previous November.
      expect(dt.addMonths(-12), DateTime(2019, 11, 15, 8));

      // 31 January + 1 month normalizes through the shorter February. In a leap
      // year February has 29 days, so the remainder spills into March 2...
      expect(DateTime(2020, 1, 31).addMonths(1), DateTime(2020, 3, 2));
      // ...and in a non-leap year (28 days) it spills into March 3.
      expect(DateTime(2021, 1, 31).addMonths(1), DateTime(2021, 3, 3));

      // Adding zero months is a no-op that preserves every component.
      final DateTime now = DateTime(2020, 6, 15, 12, 30, 45, 123, 456);
      expect(now.addMonths(0), now);
    });
  });

  group('JaroWinkler edge cases', () {
    test('similarityUpperBound returns 0 if either length is 0', () {
      final jw = JaroWinkler();
      expect(jw.similarityUpperBound(0, 5), 0);
      expect(jw.similarityUpperBound(5, 0), 0);
    });
  });
}
