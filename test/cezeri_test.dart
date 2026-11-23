import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/hafizlik/cezeri_mukaddime.dart';

void main() {
  test('Cezerî bölümleri ve beyitleri boş değil', () {
    expect(cezeriBablar, isNotEmpty);
    for (final bab in cezeriBablar) {
      expect(bab.beyitler, isNotEmpty);
      for (final b in bab.beyitler) {
        expect(b.birinci.trim(), isNotEmpty);
        expect(b.ikinci.trim(), isNotEmpty);
        expect(b.turkce.trim(), isNotEmpty);
      }
    }
  });
}
