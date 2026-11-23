class HafizlikSira {
  static const int toplamSayfa = 604;

  /// Bir tur kaç gün sürer. Her gün sıradaki bir sayfa okunur; 30 gün sonra tur başa döner.
  static const int dongu = 30;

  // Standart 604 sayfalık mushafta her cüzün başlangıç sayfası.
  // Son eleman (605) 30. cüzün bitişini hesaplamak için.
  static const List<int> _juzBaslangic = [
    1, 22, 42, 62, 82, 102, 121, 142, 162, 182,
    201, 222, 242, 262, 282, 302, 322, 342, 362, 382,
    402, 422, 442, 462, 482, 502, 522, 542, 562, 582, 605,
  ];

  /// 604 elemanlık sıralı sayfa listesi.
  /// 1. tur: her cüzün son sayfası. 2. tur: sondan 2. sayfalar. Bu şekilde devam eder.
  static final List<int> sira = _olustur();

  static List<int> _olustur() {
    final cuzListeleri = <List<int>>[];
    for (var j = 0; j < 30; j++) {
      final sayfalar = <int>[];
      for (var p = _juzBaslangic[j + 1] - 1; p >= _juzBaslangic[j]; p--) {
        sayfalar.add(p);
      }
      cuzListeleri.add(sayfalar);
    }

    final enUzun = cuzListeleri
        .map((l) => l.length)
        .reduce((a, b) => a > b ? a : b);

    final sonuc = <int>[];
    for (var k = 0; k < enUzun; k++) {
      for (final sayfalar in cuzListeleri) {
        if (k < sayfalar.length) sonuc.add(sayfalar[k]);
      }
    }
    return sonuc;
  }

  /// Başlangıç gününden bu yana geçen takvim gününe göre sayfa numarası döndürür.
  static int pageForDay(DateTime baslangic, DateTime bugun) {
    final b = DateTime.utc(baslangic.year, baslangic.month, baslangic.day);
    final g = DateTime.utc(bugun.year, bugun.month, bugun.day);
    final fark = g.difference(b).inDays;

    final n = dongu;
    return sira[((fark % n) + n) % n];
  }

  /// Verilen cüzün ilk sayfası (1-30).
  static int cuzBaslangici(int cuz) => _juzBaslangic[cuz - 1];

  /// Sayfanın hangi cüzde olduğunu döndürür (1-30).
  static int cuzOf(int sayfa) {
    for (var j = 29; j >= 0; j--) {
      if (sayfa >= _juzBaslangic[j]) return j + 1;
    }
    return 1;
  }
}
