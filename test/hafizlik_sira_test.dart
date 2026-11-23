import 'package:flutter_test/flutter_test.dart';
import 'package:hafizlik_app/hafizlik/hafizlik_sira.dart';

void main() {
  test('sıra 604 sayfa içerir', () {
    expect(HafizlikSira.sira.length, 604);
  });

  test('ilk tur cüzlerin son sayfalarıdır', () {
    expect(HafizlikSira.sira.sublist(0, 5), [21, 41, 61, 81, 101]);
  });

  test('ikinci tur sondan ikinci sayfalardır', () {
    expect(HafizlikSira.sira.sublist(30, 35), [20, 40, 60, 80, 100]);
  });

  test('ikinci gün 41. sayfadır', () {
    expect(
      HafizlikSira.pageForDay(DateTime(2026, 11, 19), DateTime(2026, 11, 20)),
      41,
    );
  });

  test('cüz hesabı doğrudur', () {
    expect(HafizlikSira.cuzOf(1), 1);
    expect(HafizlikSira.cuzOf(21), 1);
    expect(HafizlikSira.cuzOf(22), 2);
    expect(HafizlikSira.cuzOf(241), 12);
    expect(HafizlikSira.cuzOf(242), 13);
    expect(HafizlikSira.cuzOf(604), 30);
  });
}
