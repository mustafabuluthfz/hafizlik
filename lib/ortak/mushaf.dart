import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../bulmaca/sureler.dart';
import '../hafizlik/quran_veri.dart';
import 'tema.dart';

/// Kur'an metni için font (Amiri, SIL Open Font License).
const String kMushafFontu = 'Amiri';

/// Mushaf sayfası zemin rengi.
Color get kKagitRengi => kMushafKagitRengi.value;

/// Arabic-Indic rakamlar.
String arapcaRakam(int sayi) {
  const hane = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return sayi.toString().split('').map((c) => hane[int.parse(c)]).join();
}

/// Harekeleri ve tatweli kaldırır (ezber testi için).
String harekesiz(String s) => s.replaceAll(
      RegExp('[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'),
      '',
    );

/// Ayetleri mushaf gibi akan paragraf halinde gösterir.
///
/// [harekesizMod]: harekeler gizlenir.
/// [gizliSeviye]: kelimeler seviyeye göre gizlenir; dokunarak tek tek açılır (ezber kendini sınama).
class MushafSayfaGorunumu extends StatefulWidget {
  final List<Ayet> ayetler;
  final double? yaziBoyutu;
  final bool harekesizMod;
  /// 0: kapalı; 1..4: kelimelerin %25, %50, %75 veya tamamı gizlenir.
  final int gizliSeviye;
  /// Metni ezber çalışması için soluk renkte gösterir.
  final bool solukMod;

  const MushafSayfaGorunumu({
    super.key,
    required this.ayetler,
    this.yaziBoyutu,
    this.harekesizMod = false,
    this.gizliSeviye = 0,
    this.solukMod = false,
  });

  @override
  State<MushafSayfaGorunumu> createState() => _MushafSayfaGorunumuState();
}

class _MushafSayfaGorunumuState extends State<MushafSayfaGorunumu> {
  final Set<int> _acik = {};
  final Map<int, TapGestureRecognizer> _tanikYoneticileri = {};

  @override
  void didUpdateWidget(covariant MushafSayfaGorunumu eski) {
    super.didUpdateWidget(eski);
    if (eski.ayetler != widget.ayetler || eski.gizliSeviye != widget.gizliSeviye) {
      _acik.clear();
    }
  }

  @override
  void dispose() {
    for (final t in _tanikYoneticileri.values) {
      t.dispose();
    }
    super.dispose();
  }

  /// Kelime indeksi seviyeye göre gizli mi? Her 4 kelimede: seviye 1 → 1 kelime, seviye 2 → 2 kelime...
  bool _gizliMi(int indeks) =>
      widget.gizliSeviye > 0 && (indeks % 4) < widget.gizliSeviye;

  TapGestureRecognizer _tanik(int indeks) {
    return _tanikYoneticileri.putIfAbsent(indeks, () {
      return TapGestureRecognizer()
        ..onTap = () => setState(() => _acik.add(indeks));
    });
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Color>(
    valueListenable: kMushafKagitRengi,
    builder: (context, kagit, _) => ValueListenableBuilder<double>(
      valueListenable: kMushafYaziBoyutu,
      builder: (context, boyut, _) => _icerik(context, kagit, boyut),
    ),
  );

  Widget _icerik(BuildContext context, Color kagit, double boyut) {
    final parcalar = <Widget>[];
    var satirlar = <InlineSpan>[];
    int? mevcutSure;
    var kelimeIndeksi = 0;

    final koyuKagit = kagit.computeLuminance() < 0.35;
    final anaYaziRengi = koyuKagit ? Colors.white70 : Colors.black87;
    final stil = TextStyle(
      fontFamily: kMushafFontu,
      fontSize: widget.yaziBoyutu ?? boyut,
      height: 2.1,
      color: widget.solukMod ? anaYaziRengi.withOpacity(0.28) : anaYaziRengi,
    );

    void paragrafiKapat() {
      if (satirlar.isEmpty) return;
      parcalar.add(
        Text.rich(
          TextSpan(children: satirlar, style: stil),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
        ),
      );
      satirlar = [];
    }

    for (final a in widget.ayetler) {
      if (a.sure != mevcutSure) {
        paragrafiKapat();
        mevcutSure = a.sure;
        parcalar.add(_sureBasligi(a.sure));
      }

      final kelimeler = a.metin.trim().split(RegExp(r'\s+'));
      for (final kelime in kelimeler) {
        final indeks = kelimeIndeksi++;
        if (_gizliMi(indeks) && !_acik.contains(indeks)) {
          satirlar.add(TextSpan(
            text: 'ـــــــ ',
            style: TextStyle(color: kAltin.withOpacity(0.7)),
            recognizer: _tanik(indeks),
          ));
        } else {
          satirlar.add(TextSpan(
            text: '${widget.harekesizMod ? harekesiz(kelime) : kelime} ',
            recognizer: widget.gizliSeviye > 0 ? _tanik(indeks) : null,
          ));
        }
      }

      satirlar.add(TextSpan(
        text: '۝${arapcaRakam(a.numara)} ',
        style: TextStyle(color: koyuKagit ? Colors.amber.shade200 : const Color(0xFF8D6E63), fontSize: 20),
      ));
    }
    paragrafiKapat();

    return Container(
      decoration: BoxDecoration(
        color: kagit,
        border: Border.all(color: const Color(0xFFB8860B), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: parcalar,
      ),
    );
  }

  Widget _sureBasligi(int sureNo) {
    final s = sureler[sureNo - 1];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFB8860B), width: 0.8),
        ),
      ),
      child: Column(
        children: [
          Text(
            s.ad,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: kMushafFontu,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
            ),
          ),
          Text(
            '${s.no}. ${s.trAd} · ${s.trAnlam} · ${s.ayetSayisi} ayet',
            style: TextStyle(fontSize: 12, color: Colors.brown.shade700),
          ),
        ],
      ),
    );
  }
}
