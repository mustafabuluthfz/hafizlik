import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ortak/mushaf.dart';
import '../ortak/ilerleme_depo.dart';
import 'soru_uretici.dart';

/// Ekranda gösterilen seçenekler. "Karışık" her soruda rastgele zorluk seçer.
enum ZorlukSecimi { karisik, kolay, orta, zor }

class BulmacaEkrani extends StatefulWidget {
  const BulmacaEkrani({super.key});

  @override
  State<BulmacaEkrani> createState() => _BulmacaEkraniState();
}

class _BulmacaEkraniState extends State<BulmacaEkrani> {
  final _rnd = Random();
  ZorlukSecimi _secim = ZorlukSecimi.karisik;
  Soru? _soru;
  int? _secilen;
  int _dogru = 0;
  int _seri = 0;
  int _toplam = 0;
  String? _hata;
  BulmacaDurum? _durum;

  @override
  void initState() {
    super.initState();
    _yeniSoru();
  }

  Zorluk? _zorlukNe(ZorlukSecimi s) {
    switch (s) {
      case ZorlukSecimi.karisik:
        return null;
      case ZorlukSecimi.kolay:
        return Zorluk.kolay;
      case ZorlukSecimi.orta:
        return Zorluk.orta;
      case ZorlukSecimi.zor:
        return Zorluk.zor;
    }
  }

  Future<void> _yeniSoru() async {
    setState(() {
      _soru = null;
      _secilen = null;
      _hata = null;
    });
    try {
      final durum = await SoruUretici.durum();
      final soru = await SoruUretici.rastgele(_rnd, zorluk: _zorlukNe(_secim));
      if (!mounted) return;
      setState(() {
        _durum = durum;
        _soru = soru;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hata = 'Soru hazırlanamadı. Tekrar deneyin.');
    }
  }

  void _sec(int i) {
    if (_secilen != null || _soru == null) return;
    setState(() {
      _secilen = i;
      _toplam++;
      if (i == _soru!.dogru) {
        _dogru++;
        _seri++;
        HapticFeedback.lightImpact();
      } else {
        _seri = 0;
        HapticFeedback.mediumImpact();
      }
      IlerlemeDepo.bulmacaCevap(dogru: i == _soru!.dogru, seri: _seri);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulmaca')),
      body: _govde(),
    );
  }

  Widget _govde() {
    if (_hata != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_hata!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _yeniSoru, child: const Text('Tekrar dene')),
          ],
        ),
      );
    }

    final soru = _soru;
    final cevaplandi = _secilen != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<ZorlukSecimi>(
            segments: const [
              ButtonSegment(value: ZorlukSecimi.karisik, label: Text('Karışık')),
              ButtonSegment(value: ZorlukSecimi.kolay, label: Text('Kolay')),
              ButtonSegment(value: ZorlukSecimi.orta, label: Text('Orta')),
              ButtonSegment(value: ZorlukSecimi.zor, label: Text('Zor')),
            ],
            selected: {_secim},
            onSelectionChanged: (s) {
              setState(() => _secim = s.first);
              _yeniSoru();
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Doğru: $_dogru / $_toplam',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (_seri >= 2)
                    Text(' $_seri seri',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (soru != null)
                    Chip(label: Text('${soru.baslik} · ${soru.zorlukAdi}')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_durum != null) _ilerlemeNotu(_durum!),
          const SizedBox(height: 10),
          if (soru == null)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if ((cevaplandi ? soru.cevapMetni : soru.ayetMetni) != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      (cevaplandi ? soru.cevapMetni : soru.ayetMetni)!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                      fontFamily: kMushafFontu,
                      fontSize: 26,
                      height: 2.0,
                    ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              soru.soru,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < soru.secenekler.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: _renk(i, soru, cevaplandi),
                    foregroundColor: cevaplandi ? Colors.white : null,
                  ),
                  onPressed: () => _sec(i),
                  child: Directionality(
                    textDirection:
                        soru.secenekRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      soru.secenekler[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: soru.secenekRtl ? kMushafFontu : null,
                      ),
                    ),
                  ),
                ),
              ),
            if (cevaplandi) ...[
              const SizedBox(height: 8),
              Text(
                _secilen == soru.dogru
                    ? 'Tebrikler, doğru!'
                    : 'Yanlış. Doğru cevap yeşil ile gösterildi.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(soru.aciklama, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _yeniSoru,
                child: const Text('Sonraki soru'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Okunan sayfalara göre açık soru türlerini anlatan kısa not.
  Widget _ilerlemeNotu(BulmacaDurum d) {
    final String metin;
    if (d.sayfaCuzSureAcik) {
      metin = 'Okuduğunuz ${d.sayfaSayisi} sayfadan sorular geliyor. Tüm soru türleri açık.';
    } else if (d.ayetNoAcik) {
      metin = 'Okuduğunuz sayfalardan sorular geliyor. Sayfa, cüz ve sure soruları 14. günde açılır.';
    } else {
      metin = 'Yalnızca okuduğunuz ayetlerden sorular geliyor. Ayet numarası 7. günde, sayfa, cüz ve sure soruları 14. günde açılır.';
    }
    return Text(
      metin,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Colors.brown.shade700),
    );
  }

  Color? _renk(int i, Soru soru, bool cevaplandi) {
    if (!cevaplandi) return null;
    if (i == soru.dogru) return Colors.green.shade700;
    if (i == _secilen) return Colors.red.shade700;
    return Colors.grey.shade400;
  }
}
