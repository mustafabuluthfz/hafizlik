import 'dart:math';
import 'package:flutter/material.dart';
import 'tecvid_ekrani.dart';

class TecvidSinaviEkrani extends StatefulWidget {
  const TecvidSinaviEkrani({super.key});
  @override
  State<TecvidSinaviEkrani> createState() => _TecvidSinaviEkraniState();
}

class _TecvidSinaviEkraniState extends State<TecvidSinaviEkrani> {
  final _random = Random();
  late final List<TecvidKural> _sorular;
  int _index = 0, _dogru = 0, _yanlis = 0;
  int? _secim;
  bool _bitti = false;
  late List<TecvidKural> _secenekler;

  @override
  void initState() {
    super.initState();
    _sorular = [...TecvidEkrani.kurallar]..shuffle(_random);
    _sorular.removeRange(10, _sorular.length);
    _secenekleriHazirla();
  }

  void _secenekleriHazirla() {
    final dogru = _sorular[_index];
    final digerleri = TecvidEkrani.kurallar.where((k) => k.ad != dogru.ad).toList()..shuffle(_random);
    _secenekler = [dogru, ...digerleri.take(3)]..shuffle(_random);
    _secim = null;
  }

  void _cevapla(int i) {
    if (_secim != null || _bitti) return;
    setState(() {
      _secim = i;
      if (_secenekler[i].ad == _sorular[_index].ad) _dogru++; else _yanlis++;
    });
  }

  void _sonraki() {
    if (_index == _sorular.length - 1) {
      setState(() => _bitti = true);
    } else {
      setState(() { _index++; _secenekleriHazirla(); });
    }
  }

  void _yeniden() => setState(() { _sorular.shuffle(_random); _index = 0; _dogru = 0; _yanlis = 0; _bitti = false; _secenekleriHazirla(); });

  @override
  Widget build(BuildContext context) {
    if (_bitti) {
      final oran = (_dogru * 100 / _sorular.length).round();
      return Scaffold(appBar: AppBar(title: const Text('Tecvid sınavı')),
        body: Center(child: Card(margin: const EdgeInsets.all(24), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.workspace_premium_rounded, size: 58, color: Colors.amber),
          const SizedBox(height: 12), const Text('Sınav tamamlandı', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12), Text('$_dogru doğru · $_yanlis yanlış', style: const TextStyle(fontSize: 18)),
          Text('Başarı: %$oran', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16), FilledButton.icon(onPressed: _yeniden, icon: const Icon(Icons.refresh), label: const Text('Yeniden sınav ol')),
        ])))));
    }
    final soru = _sorular[_index];
    return Scaffold(appBar: AppBar(title: Text('Tecvid sınavı · ${_index + 1}/${_sorular.length}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        LinearProgressIndicator(value: (_index + 1) / _sorular.length),
        const SizedBox(height: 18),
        Text('Aşağıdaki açıklama hangi tecvid kuralına aittir?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(soru.kategori, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8), Text(soru.tanim),
          const SizedBox(height: 14), Center(child: Text(soru.ornek, textDirection: TextDirection.rtl, style: const TextStyle(fontFamily: 'Amiri', fontSize: 29))),
        ]))),
        const SizedBox(height: 12),
        for (var i = 0; i < _secenekler.length; i++) ...[
          Card(child: ListTile(
            title: Text(_secenekler[i].ad),
            leading: CircleAvatar(child: Text(String.fromCharCode(65 + i))),
            trailing: _secim == null ? null : _secenekler[i].ad == soru.ad ? const Icon(Icons.check_circle, color: Colors.green) : _secim == i ? const Icon(Icons.cancel, color: Colors.red) : null,
            onTap: () => _cevapla(i),
          )),
        ],
        if (_secim != null) ...[
          Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(_secenekler[_secim!].ad == soru.ad ? 'Doğru cevap!' : 'Doğru cevap: ${soru.ad}', style: const TextStyle(fontWeight: FontWeight.bold))),
          FilledButton.icon(onPressed: _sonraki, icon: const Icon(Icons.arrow_forward), label: Text(_index == _sorular.length - 1 ? 'Sonuçları gör' : 'Sonraki soru')),
        ],
        const SizedBox(height: 10),
        Text('Doğru: $_dogru  ·  Yanlış: $_yanlis', textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text('Bu sınav öğretici amaçlıdır. Tecvid uygulamasının doğru telaffuzla öğrenilmesi için ehil bir hocadan dinleme ve tashih alınmalıdır.', style: TextStyle(fontSize: 12)),
      ]));
  }
}
