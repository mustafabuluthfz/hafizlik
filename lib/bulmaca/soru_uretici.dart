import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../hafizlik/hafizlik_sira.dart';
import '../hafizlik/quran_veri.dart';
import 'sureler.dart';

enum SoruTuru {
  ayetTamamlama,
  sayfa,
  sure,
  cuz,
  ayetNo,
  sonrakiAyet,
  oncekiAyet,
}

enum Zorluk { kolay, orta, zor }

extension ZorlukBilgi on Zorluk {
  String get ad {
    switch (this) {
      case Zorluk.kolay:
        return 'Kolay';
      case Zorluk.orta:
        return 'Orta';
      case Zorluk.zor:
        return 'Zor';
    }
  }

  /// Kolay: 2, orta: 3, zor: 4 seçenek.
  int get secenekSayisi {
    switch (this) {
      case Zorluk.kolay:
        return 2;
      case Zorluk.orta:
        return 3;
      case Zorluk.zor:
        return 4;
    }
  }
}

class Soru {
  final String baslik;
  final String zorlukAdi;
  final String soru;
  final String? ayetMetni;
  final String? cevapMetni;
  final List<String> secenekler;
  final int dogru;
  final bool secenekRtl;
  final String aciklama;

  const Soru({
    required this.baslik,
    required this.zorlukAdi,
    required this.soru,
    this.ayetMetni,
    this.cevapMetni,
    required this.secenekler,
    required this.dogru,
    required this.secenekRtl,
    required this.aciklama,
  });
}

/// Kullanıcının ilerlemesine göre bulmacanın durumu.
class BulmacaDurum {
  final int gun;
  final int sayfaSayisi;
  final int sureSayisi;
  final int cuzSayisi;

  const BulmacaDurum({
    required this.gun,
    required this.sayfaSayisi,
    required this.sureSayisi,
    required this.cuzSayisi,
  });

  bool get ayetNoAcik => gun >= 7;
  bool get sayfaCuzSureAcik =>
      gun >= 14 && sayfaSayisi >= 4 && cuzSayisi >= 4 && sureSayisi >= 4;
}

/// Soruları yalnızca kullanıcının okuduğu sayfalardan üretir.
class SoruUretici {
  static List<Ayet> _havuz = [];
  static List<Ayet> _sirali = [];
  static List<int> _sayfalar = [];
  static List<int> _sureler = [];
  static List<int> _cuzler = [];
  static BulmacaDurum? _durum;
  static String? _hazirGun;

  /// Ekranda ilerleme bilgisi için.
  static Future<BulmacaDurum> durum() async {
    await _hazirla();
    return _durum!;
  }

  static Future<void> _hazirla() async {
    final bugun = DateTime.now();
    final gunAnahtari = '${bugun.year}-${bugun.month}-${bugun.day}';
    if (_hazirGun == gunAnahtari && _durum != null) return;

    final prefs = await SharedPreferences.getInstance();
    final kayit = prefs.getString('baslangic_tarihi');
    final baslangic = (kayit == null ? null : DateTime.tryParse(kayit)) ??
        DateTime(bugun.year, bugun.month, bugun.day);
    final gun = max(
      1,
      DateTime.utc(bugun.year, bugun.month, bugun.day)
              .difference(DateTime.utc(
                  baslangic.year, baslangic.month, baslangic.day))
              .inDays +
          1,
    );

    // Okunan günlerin sayfaları açıktır.
    final acik = <int>{1}; // Fatiha her zaman açık
    final sinir = min(gun, 3650);
    for (var g = 0; g < sinir; g++) {
      final tarih = DateTime(baslangic.year, baslangic.month, baslangic.day + g);
      acik.add(HafizlikSira.pageForDay(baslangic, tarih));
    }

    final tum = await QuranVeri.tumAyetler();
    _havuz = tum.where((a) => acik.contains(a.sayfa)).toList();
    _sirali = [..._havuz]
      ..sort((a, b) => a.sure != b.sure
          ? a.sure.compareTo(b.sure)
          : a.numara.compareTo(b.numara));
    _sayfalar = acik.toList()..sort();
    _sureler = _havuz.map((a) => a.sure).toSet().toList();
    _cuzler = _sayfalar.map(HafizlikSira.cuzOf).toSet().toList();

    _durum = BulmacaDurum(
      gun: gun,
      sayfaSayisi: _sayfalar.length,
      sureSayisi: _sureler.length,
      cuzSayisi: _cuzler.length,
    );
    _hazirGun = gunAnahtari;
  }

  static List<SoruTuru> _acikTurler() {
    final d = _durum!;
    final turler = [
      SoruTuru.ayetTamamlama,
      SoruTuru.sonrakiAyet,
      SoruTuru.oncekiAyet,
    ];
    if (d.ayetNoAcik) turler.add(SoruTuru.ayetNo);
    if (d.sayfaCuzSureAcik) {
      turler.addAll([SoruTuru.sayfa, SoruTuru.cuz, SoruTuru.sure]);
    }
    return turler;
  }

  /// [zorluk] verilmezse rastgele seçilir.
  static Future<Soru> rastgele(Random rnd, {Zorluk? zorluk}) async {
    await _hazirla();
    final z = zorluk ?? Zorluk.values[rnd.nextInt(Zorluk.values.length)];
    final turler = _acikTurler();
    final tur = turler[rnd.nextInt(turler.length)];
    switch (tur) {
      case SoruTuru.ayetTamamlama:
        return _ayetTamamlama(rnd, z);
      case SoruTuru.sayfa:
        return _sayfaSorusu(rnd, z);
      case SoruTuru.sure:
        return _sureSorusu(rnd, z);
      case SoruTuru.cuz:
        return _cuzSorusu(rnd, z);
      case SoruTuru.ayetNo:
        return _ayetNoSorusu(rnd, z);
      case SoruTuru.sonrakiAyet:
        return _komsuSorusu(rnd, z, sonraki: true);
      case SoruTuru.oncekiAyet:
        return _komsuSorusu(rnd, z, sonraki: false);
    }
  }

  // ---------- yardımcılar ----------

  static Ayet _ayet(Random rnd, bool Function(Ayet) kosul) {
    for (var i = 0; i < 300; i++) {
      final a = _havuz[rnd.nextInt(_havuz.length)];
      if (kosul(a)) return a;
    }
    return _havuz[rnd.nextInt(_havuz.length)];
  }

  static List<String> _kelimeler(String m) => m.trim().split(RegExp(r'\s+'));

  static String _ilk(String m, int adet) =>
      '${_kelimeler(m).take(adet).join(' ')} ۔';

  static int _sinirla(int v, int alt, int ust) => max(alt, min(ust, v));

  static String _sureAdi(int no) => sureler[no - 1].trAd;

  static String _konum(Ayet a) =>
      'Sure ${a.sure} (${_sureAdi(a.sure)}), Ayet ${a.numara}, '
      'Sayfa ${a.sayfa}, ${HafizlikSira.cuzOf(a.sayfa)}. cüz';

  /// Açık listeden, doğru cevaba yakın ya da rastgele bir değer seçer.
  static int _secim(Random rnd, List<int> liste, int dogru, bool yakin) {
    final aday = liste.where((x) => x != dogru).toList();
    if (aday.isEmpty) return dogru + 1;
    if (yakin) {
      aday.sort((a, b) => (a - dogru).abs().compareTo((b - dogru).abs()));
      final ilk = aday.take(6).toList();
      return ilk[rnd.nextInt(ilk.length)];
    }
    return aday[rnd.nextInt(aday.length)];
  }

  /// Doğru cevaptan farklı, benzersiz yanlış seçenekler üretir.
  static List<String> _yanlislar(
      String dogru, int adet, String Function() uret) {
    final s = <String>{};
    var deneme = 0;
    while (s.length < adet && deneme < 800) {
      deneme++;
      final y = uret();
      if (y != dogru) s.add(y);
    }
    return s.take(adet).toList();
  }

  static Soru _kur({
    required String baslik,
    required Zorluk zorluk,
    required String soru,
    required String? ayetMetni,
    required String? cevapMetni,
    required String dogru,
    required String Function() uret,
    required bool secenekRtl,
    required String aciklama,
    required Random rnd,
  }) {
    final yanlislar = _yanlislar(dogru, zorluk.secenekSayisi - 1, uret);
    final secenekler = [dogru, ...yanlislar]..shuffle(rnd);
    return Soru(
      baslik: baslik,
      zorlukAdi: zorluk.ad,
      soru: soru,
      ayetMetni: ayetMetni,
      cevapMetni: cevapMetni,
      secenekler: secenekler,
      dogru: secenekler.indexOf(dogru),
      secenekRtl: secenekRtl,
      aciklama: aciklama,
    );
  }

  // ---------- soru türleri ----------

  static Soru _ayetTamamlama(Random rnd, Zorluk z) {
    final a = _ayet(rnd, (x) => _kelimeler(x.metin).length >= 4);
    final k = _kelimeler(a.metin);
    final bos = 1 + rnd.nextInt(k.length - 1);
    final dogru = k[bos];

    final bosluk = [...k];
    bosluk[bos] = 'ـــــــــ';

    return _kur(
      baslik: 'Ayet tamamlama',
      zorluk: z,
      soru: 'Boş yere hangi kelime gelmeli?',
      ayetMetni: bosluk.join(' '),
      cevapMetni: a.metin,
      dogru: dogru,
      uret: () {
        if (z == Zorluk.zor) return k[rnd.nextInt(k.length)];
        final b = _havuz[rnd.nextInt(_havuz.length)];
        final kb = _kelimeler(b.metin);
        return kb[rnd.nextInt(kb.length)];
      },
      secenekRtl: true,
      aciklama: _konum(a),
      rnd: rnd,
    );
  }

  static Soru _sayfaSorusu(Random rnd, Zorluk z) {
    final a = _ayet(rnd, (_) => true);
    return _kur(
      baslik: 'Sayfa bulma',
      zorluk: z,
      soru: 'Bu ayet mushafın kaçıncı sayfasında?',
      ayetMetni: a.metin,
      cevapMetni: a.metin,
      dogru: a.sayfa.toString(),
      uret: () =>
          _secim(rnd, _sayfalar, a.sayfa, z == Zorluk.zor).toString(),
      secenekRtl: false,
      aciklama: _konum(a),
      rnd: rnd,
    );
  }

  static Soru _sureSorusu(Random rnd, Zorluk z) {
    final a = _ayet(rnd, (_) => true);
    return _kur(
      baslik: 'Sure bulma',
      zorluk: z,
      soru: 'Bu ayet hangi surede?',
      ayetMetni: a.metin,
      cevapMetni: a.metin,
      dogru: _sureAdi(a.sure),
      uret: () =>
          _sureAdi(_secim(rnd, _sureler, a.sure, z == Zorluk.zor)),
      secenekRtl: false,
      aciklama: _konum(a),
      rnd: rnd,
    );
  }

  static Soru _cuzSorusu(Random rnd, Zorluk z) {
    final a = _ayet(rnd, (_) => true);
    final cuz = HafizlikSira.cuzOf(a.sayfa);
    return _kur(
      baslik: 'Cüz bulma',
      zorluk: z,
      soru: 'Bu ayet hangi cüzdedir?',
      ayetMetni: a.metin,
      cevapMetni: a.metin,
      dogru: '$cuz. cüz',
      uret: () => '${_secim(rnd, _cuzler, cuz, z == Zorluk.zor)}. cüz',
      secenekRtl: false,
      aciklama: _konum(a),
      rnd: rnd,
    );
  }

  static Soru _ayetNoSorusu(Random rnd, Zorluk z) {
    final a = _ayet(rnd, (x) => sureler[x.sure - 1].ayetSayisi >= 4);
    final adet = sureler[a.sure - 1].ayetSayisi;
    return _kur(
      baslik: 'Ayet numarası',
      zorluk: z,
      soru: 'Bu ayet surenin kaçıncı ayetidir?',
      ayetMetni: a.metin,
      cevapMetni: a.metin,
      dogru: a.numara.toString(),
      uret: () {
        if (z == Zorluk.zor) {
          return _sinirla(a.numara + rnd.nextInt(7) - 3, 1, adet).toString();
        }
        return (rnd.nextInt(adet) + 1).toString();
      },
      secenekRtl: false,
      aciklama: _konum(a),
      rnd: rnd,
    );
  }

  /// Sıralı havuzda aynı surede bir sonraki/önceki ayet çiftini bulur.
  static int _komsuIndeks(Random rnd) {
    for (var i = 0; i < 500; i++) {
      final idx = rnd.nextInt(_sirali.length - 1);
      final a = _sirali[idx];
      final b = _sirali[idx + 1];
      if (a.sure == b.sure && b.numara == a.numara + 1) return idx;
    }
    return 0;
  }

  /// sonraki: true ise "bundan sonra hangi ayet gelir", false ise "bundan önce".
  static Soru _komsuSorusu(Random rnd, Zorluk z, {required bool sonraki}) {
    final idx = _komsuIndeks(rnd);
    final gosterilen = sonraki ? _sirali[idx] : _sirali[idx + 1];
    final hedefIdx = sonraki ? idx + 1 : idx;
    final hedef = _sirali[hedefIdx];

    return _kur(
      baslik: sonraki ? 'Sonraki ayet' : 'Önceki ayet',
      zorluk: z,
      soru: sonraki
          ? 'Bu ayetten sonra hangi ayet gelir?'
          : 'Bu ayetten önce hangi ayet gelir?',
      ayetMetni: gosterilen.metin,
      cevapMetni: gosterilen.metin,
      dogru: _ilk(hedef.metin, 5),
      uret: () {
        if (z == Zorluk.zor) {
          var off = 0;
          while (off == 0) {
            off = rnd.nextInt(9) - 4;
          }
          final j = _sinirla(hedefIdx + off, 0, _sirali.length - 1);
          return _ilk(_sirali[j].metin, 5);
        }
        return _ilk(_sirali[rnd.nextInt(_sirali.length)].metin, 5);
      },
      secenekRtl: true,
      aciklama:
          'Doğrusu: Sure ${hedef.sure}, Ayet ${hedef.numara}. ${_konum(hedef)}',
      rnd: rnd,
    );
  }
}
