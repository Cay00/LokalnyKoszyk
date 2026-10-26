import 'package:flutter_test/flutter_test.dart';
import 'package:lokalny_koszyk/core/supabase/nested_row.dart';

void main() {
  group('supabaseEmbeddedMaps', () {
    test('null and unsupported types yield empty list', () {
      expect(supabaseEmbeddedMaps(null), isEmpty);
      expect(supabaseEmbeddedMaps('x'), isEmpty);
      expect(supabaseEmbeddedMaps(1), isEmpty);
    });

    test('single map becomes one-element list', () {
      final result = supabaseEmbeddedMaps(<String, dynamic>{'city': 'Gdańsk'});
      expect(result, hasLength(1));
      expect(result.first['city'], 'Gdańsk');
    });

    test('list of maps is preserved; non-maps dropped', () {
      final result = supabaseEmbeddedMaps(<dynamic>[
        <String, dynamic>{'a': 1},
        'skip',
        <String, dynamic>{'b': 2},
      ]);
      expect(result, hasLength(2));
      expect(result[0]['a'], 1);
      expect(result[1]['b'], 2);
    });
  });
}
