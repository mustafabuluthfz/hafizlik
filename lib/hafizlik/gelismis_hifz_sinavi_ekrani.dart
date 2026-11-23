import 'dart:math';
import 'package:flutter/material.dart';
import '../ortak/tema.dart';
import 'quran_veri.dart';

enum HifzSoruTuru { sayfaBasi, sayfaOrtasi, sayfaSonu, rastgele }

class GelismisHifzSinaviEkrani extends StatefulWidget {
  const GelismisHifzSinaviEkrani({super.key});
  @override
  State<GelismisHifzSinaviEkrani> createState() => _GelismisHifzSinaviEkraniState();
}

class _GelismisHifzSinaviEkraniState extends State<GelismisHifzSinaviEkrani> {
  final _r = Random();
  List<Ayet> _tum = [];
  List<_HifzSoru> _sorular = [];
  int _index = 0, _dogru = 0, _yanlis = 0;
  int? _secim;
  bool _yukleniyor = true, _bitti = false;
  HifzSoruTuru _tur = HifzSoruTuru.rastgele;
  static const _soruSayisi = 10;

  @override
  void initState() { super.initState(); _hazirla(); }

  Future<void> _hazirla() async {
    _tum = await QuranVeri.tumAyetler();
    _tum.sort((a, b) => a.sure != b.sure ? a.sure.compareTo(b.sure) : a.numara.compareTo(b.numara));
    if (mounted) setState(() => _yukleniyor = false);
  }

  String get _turAdi => switch (_tur) {
    HifzSoruTuru.sayfaBasi => 'Sayfa başı',
    HifzSoruTuru.sayfaOrtasi => 'Sayfa ortası',
    HifzSoruTuru.sayfaSonu => 'Sayfa sonu',
    HifzSoruTuru.rastgele => 'Rastgele ayet',
  };

  void _sinavBaslat(HifzSoruTuru tur) {
    _tur = tur;
    final adaylar = <int>[];
    for (var i = 0; i < _tum.length - 1; i++) {
      if ((_tum[i].sure == _tum[i + 1].sure && _tum[i + 1].numara == _tum[i].numara + 1) || _tum[i + 1].sure == _tum[i].sure + 1 && _tum[i + 1].numara == 1) adaylar.add(i);
    }
    final filtre = adaylar.where((i) {
      final sayfaAyetleri = _tum.where((a) => a.sayfa == _tum[i].sayfa).toList();
      if (sayfaAyetleri.isEmpty) return false;
      return switch (tur) {
        HifzSoruTuru.sayfaBasi => _tum[i].numara == sayfaAyetleri.first.numara && _tum[i].sure == sayfaAyetleri.first.sure,
        HifzSoruTuru.sayfaOrtasi => _tum[i].sure == sayfaAyetleri[sayfaAyetleri.length ~/ 2].sure && _tum[i].numara == sayfaAyetleri[sayfaAyetleri.length ~/ 2].numara,
        HifzSoruTuru.sayfaSonu => _tum[i].sure == sayfaAyetleri.last.sure && _tum[i].numara == sayfaAyetleri.last.numara,
        HifzSoruTuru.rastgele => true,
      };
    }).toList();
    final havuz = filtre.isNotEmpty ? filtre : adaylar;
    havuz.shuffle(_r);
    final secilen = havuz.take(_soruSayisi).toList();
    // Az sayıda uygun sayfa bulunan modlarda tekrar etmeden mümkün olan soru sayısı kullanılır.
    _sorular = secilen.map((i) {
      final dogru = _tum[i + 1];
      final yanlis = <Ayet>{};
      while (yanlis.length < 3) {
        final a = _tum[_r.nextInt(_tum.length)];
        if (a.sure != dogru.sure || a.numara != dogru.numara) yanlis.add(a);
      }
      final secenek = [dogru, ...yanlis]..shuffle(_r);
      return _HifzSoru(_tum[i], dogru, secenek);
    }).toList();
    setState(() { _index = 0; _dogru = 0; _yanlis = 0; _secim = null; _bitti = false; });
  }

  void _cevapla(int i) {
    if (_secim != null) return;
    setState(() { _secim = i; final a = _sorular[_index].secenekler[i]; if (a.sure == _sorular[_index].dogru.sure && a.numara == _sorular[_index].dogru.numara) _dogru++; else _yanlis++; });
  }

  void _sonraki() {
    if (_index == _sorular.length - 1) setState(() => _bitti = true);
    else setState(() { _index++; _secim = null; });
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_sorular.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Gelişmiş hafızlık sınavı')), body: _secimEkrani());
    if (_bitti) return Scaffold(appBar: AppBar(title: const Text('Sınav sonucu')), body: Center(child: Card(margin: const EdgeInsets.all(24), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.emoji_events, size: 58, color: Colors.amber), const SizedBox(height: 12), const Text('Sınav tamamlandı', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      Text('$_dogru doğru · $_yanlis yanlış'), Text('Başarı: %${(_dogru * 100 / _sorular.length).round()}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16), FilledButton(onPressed: () => setState(() { _sorular = []; _bitti = false; }), child: const Text('Başka sınav seç')),
      TextButton(onPressed: () => _sinavBaslat(_tur), child: const Text('Aynı türde tekrar çöz')),
    ])))));
    final s = _sorular[_index];
    return Scaffold(appBar: AppBar(title: Text('$_turAdi · ${_index + 1}/${_sorular.length}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        LinearProgressIndicator(value: (_index + 1) / _sorular.length), const SizedBox(height: 16),
        Text('Gösterilen ayetten sonra hangi ayet gelir?', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text(s.once.metin, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Amiri', fontSize: 28, height: 2)), const SizedBox(height: 8), Text('${s.once.sure}. sure · ${s.once.numara}. ayet · Mushaf sayfası ${s.once.sayfa}')]))),
        const SizedBox(height: 12),
        for (var i = 0; i < s.secenekler.length; i++) Card(child: ListTile(
          title: Text(s.secenekler[i].metin, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Amiri', fontSize: 22, height: 1.8)),
          subtitle: _secim == null ? null : Text('${s.secenekler[i].sure}. sure · ${s.secenekler[i].numara}. ayet'),
          trailing: _secim == null ? null : (s.secenekler[i].sure == s.dogru.sure && s.secenekler[i].numara == s.dogru.numara ? const Icon(Icons.check_circle, color: Colors.green) : _secim == i ? const Icon(Icons.cancel, color: Colors.red) : null),
          onTap: () => _cevapla(i),
        )),
        if (_secim != null) FilledButton.icon(onPressed: _sonraki, icon: const Icon(Icons.arrow_forward), label: Text(_index == _sorular.length - 1 ? 'Sonucu gör' : 'Sonraki soru')),
        const SizedBox(height: 10), Text('Doğru: $_dogru · Yanlış: $_yanlis', textAlign: TextAlign.center),
      ]));
  }

  Widget _secimEkrani() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Sınav türünü seçin. Uygulama seçilen konuma göre bir ayet gösterir; siz de ardından gelen ayeti ezberinizden bulursunuz.', style: TextStyle(fontSize: 15)),
    const SizedBox(height: 16),
    _modKart('Sayfa başından', 'Her sayfanın başlangıç bölümünden soru', Icons.vertical_align_top, HifzSoruTuru.sayfaBasi),
    _modKart('Sayfa ortasından', 'Sayfanın orta bölümünden soru', Icons.vertical_align_center, HifzSoruTuru.sayfaOrtasi),
    _modKart('Sayfa sonundan', 'Sayfanın son ayetinden soru', Icons.vertical_align_bottom, HifzSoruTuru.sayfaSonu),
    _modKart('Rastgele ayet', 'Kur’an genelinden rastgele devam soruları', Icons.shuffle, HifzSoruTuru.rastgele),
  ]);

  Widget _modKart(String baslik, String aciklama, IconData ikon, HifzSoruTuru tur) => Card(child: ListTile(leading: Icon(ikon, color: Colors.teal), title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(aciklama), trailing: const Icon(Icons.chevron_right), onTap: () => _sinavBaslat(tur)));
}

class _HifzSoru { final Ayet once; final Ayet dogru; final List<Ayet> secenekler; const _HifzSoru(this.once, this.dogru, this.secenekler); }
