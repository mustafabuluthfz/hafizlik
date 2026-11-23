import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/ders/karsilastirma.dart';

void main() {
  group('Ders dinletme kelime karşılaştırması', () {
    test('harekeleri ve elif varyantlarını eşit kabul eder', () {
      expect(normalize('أَنْعَمْتَ'), normalize('انعمت'));
    });

    test('tam eşleşen kelimeleri doğru işaretler', () {
      final sonuc = karsilastir(['بِسْمِ', 'اللَّهِ'], 'بسم الله');
      expect(sonuc.map((e) => e.durum), [
        KelimeDurumuTipi.dogru,
        KelimeDurumuTipi.dogru,
      ]);
    });

    test('sonraki kelime okununca aradaki kelimeyi atlandı işaretler', () {
      final sonuc = karsilastir(['بسم', 'الله', 'الرحمن'], 'بسم الرحمن');
      expect(sonuc.map((e) => e.durum), [
        KelimeDurumuTipi.dogru,
        KelimeDurumuTipi.atlandi,
        KelimeDurumuTipi.dogru,
      ]);
    });

    test('yanlış tanınan kelimeyi kırmızı durumuna ayırır', () {
      final sonuc = karsilastir(['بسم', 'الله'], 'بسم الحمد');
      expect(sonuc[0].durum, KelimeDurumuTipi.dogru);
      expect(sonuc[1].durum, KelimeDurumuTipi.yanlis);
    });

    test('yakın ama farklı harfi doğru kabul etmez', () {
      final sonuc = karsilastir(['كتب'], 'كذب');
      expect(sonuc.single.durum, KelimeDurumuTipi.yanlis);
    });

    test('fazladan söylenen kelimeleri hata sayar', () {
      expect(fazlaKelimeSayisi(['بسم', 'الله'], 'بسم الحمد الله'), 1);
    });

    test('henüz okunmamış kelimeleri beklemede bırakır', () {
      final sonuc = karsilastir(['بسم', 'الله', 'الرحمن'], 'بسم');
      expect(sonuc.map((e) => e.durum), [
        KelimeDurumuTipi.dogru,
        KelimeDurumuTipi.bekliyor,
        KelimeDurumuTipi.bekliyor,
      ]);
    });

    test('dinleme bitince okunmamış kalan kelimeleri atlandı sayar', () {
      final sonuc = karsilastir(['بسم', 'الله', 'الرحمن'], 'بسم', tamamlandi: true);
      expect(sonuc.map((e) => e.durum), [
        KelimeDurumuTipi.dogru,
        KelimeDurumuTipi.atlandi,
        KelimeDurumuTipi.atlandi,
      ]);
    });

    test('boş okumada sayfadaki bütün kelimeler beklemede kalır', () {
      final sonuc = karsilastir(['الحمد', 'لله'], '');
      expect(sonuc.every((e) => e.durum == KelimeDurumuTipi.bekliyor), isTrue);
    });

    test('noktalama işaretlerini karşılaştırmaya dahil etmez', () {
      final sonuc = karsilastir(['بِسْمِ', 'اللَّهِ'], 'بسم، الله.');
      expect(sonuc.every((e) => e.durum == KelimeDurumuTipi.dogru), isTrue);
    });
  });
}
