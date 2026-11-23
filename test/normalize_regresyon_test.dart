import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/ders/karsilastirma.dart';

void main() {
  test('Arapça harfler normalize sonrası korunur (regresyon)', () {
    expect(normalize('بِسْمِ'), 'بسم');
    expect(normalize('الله الرحمن'), 'الله الرحمن');
  });

  test('yanlış kelime için Türkçe açıklama döner', () {
    final k = KelimeDurumu('كتب', KelimeDurumuTipi.yanlis);
    expect(kelimeAciklamasi(k), contains('farklı'));
  });

  test('şeddeli kelimede şedde notu verir', () {
    expect(tecvidNotu('رَبَّ'), contains('şedde'));
  });
}
