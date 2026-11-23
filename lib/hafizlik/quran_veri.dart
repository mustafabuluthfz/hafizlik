import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Ayet {
  final int sure;
  final int numara;
  final String metin;
  final int sayfa;

  const Ayet({
    required this.sure,
    required this.numara,
    required this.metin,
    required this.sayfa,
  });
}

/// Kur'an metni uygulamanın içinde (assets/quran/sayfalar.json) bulunur.
/// İnternet gerektirmez.
class QuranVeri {
  static Map<int, List<Ayet>>? _onbellek;

  static Future<List<Ayet>> tumAyetler() async {
    _onbellek ??= await _yukle();
    return _onbellek!.values.expand((liste) => liste).toList();
  }

  /// Surenin ilk ayetinin bulunduğu sayfa.
  static Future<int> sureninIlkSayfasi(int sure) async {
    final tum = await tumAyetler();
    var enKucuk = 9999;
    for (final a in tum) {
      if (a.sure == sure && a.sayfa < enKucuk) enKucuk = a.sayfa;
    }
    return enKucuk;
  }

  static Future<List<Ayet>> sayfa(int sayfa) async {
    _onbellek ??= await _yukle();
    return _onbellek![sayfa] ?? [];
  }

  static Future<Map<int, List<Ayet>>> _yukle() async {
    final metin = await rootBundle.loadString('assets/quran/sayfalar.json');
    final veri = jsonDecode(metin) as Map<String, dynamic>;

    final sonuc = <int, List<Ayet>>{};
    veri.forEach((anahtar, liste) {
      final sayfa = int.parse(anahtar);
      sonuc[sayfa] = (liste as List).map((e) {
        final dizi = e as List;
        return Ayet(
          sure: dizi[0] as int,
          numara: dizi[1] as int,
          metin: dizi[2] as String,
          sayfa: sayfa,
        );
      }).toList();
    });
    return sonuc;
  }
}
