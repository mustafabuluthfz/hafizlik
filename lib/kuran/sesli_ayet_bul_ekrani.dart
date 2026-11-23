import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../hafizlik/quran_veri.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import 'kuran_okuma_ekrani.dart';

class _Aday {
  final Ayet ayet;
  final double oran; // 0..1: sorgudaki kelimelerin ayette bulunma oranı
  const _Aday(this.ayet, this.oran);
}

class SesliAyetBulEkrani extends StatefulWidget {
  const SesliAyetBulEkrani({super.key});
  @override
  State<SesliAyetBulEkrani> createState() => _SesliAyetBulEkraniState();
}

class _SesliAyetBulEkraniState extends State<SesliAyetBulEkrani> {
  final _stt = SpeechToText();
  bool _hazir = false, _dinliyor = false, _yukleniyor = false;
  String _metin = '';
  String _sonSorgu = '';
  String _mesaj = 'Arapça bir ayetten birkaç kelime okuyun.';
  double _esik = 0.6; // varsayılan eşik: %60
  List<_Aday> _adaylar = [];
  List<Ayet>? _tumAyetler;

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }

  /// Harekeleri, noktalamayı ve Arapça dışı karakterleri temizler.
  String _norm(String s) {
    var t = harekesiz(s).replaceAll(RegExp('[ٱأإآٰ]'), 'ا');
    t = t.replaceAll(RegExp('[^\u0621-\u063A\u0641-\u064A' + r'\s' + ']'), ' ');
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _baslat() async {
    setState(() => _mesaj = 'Ses tanıma hazırlanıyor…');
    _hazir = await _stt.initialize(
      onError: (e) {
        if (mounted) setState(() => _mesaj = 'Ses tanıma hatası: ${e.errorMsg}');
      },
      onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && mounted) {
          setState(() => _dinliyor = false);
        }
      },
    );
    if (!_hazir) {
      setState(() => _mesaj =
          'Bu cihazda konuşma tanıma kullanılamıyor. Android konuşma tanıma hizmetini ve Arapça dil paketini kontrol edin.');
      return;
    }
    setState(() => _dinliyor = true);
    await _stt.listen(
      localeId: 'ar-SA',
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 5),
      partialResults: false,
      onResult: (r) {
        if (r.finalResult) {
          setState(() => _metin = r.recognizedWords);
          _ara(r.recognizedWords);
        }
      },
    );
  }

  Future<void> _ara(String kelimeler) async {
    final q = _norm(kelimeler);
    if (q.isEmpty) {
      setState(() => _mesaj = 'Anlaşılır Arapça kelime algılanamadı. Tekrar deneyin.');
      return;
    }
    _sonSorgu = kelimeler;
    setState(() => _yukleniyor = true);
    try {
      _tumAyetler ??= await QuranVeri.tumAyetler();
      final sorgu = q.split(' ').where((w) => w.length > 1).toSet().toList();
      if (sorgu.isEmpty) {
        setState(() => _mesaj = 'Anlaşılır Arapça kelime algılanamadı. Tekrar deneyin.');
        return;
      }

      final adaylar = <_Aday>[];
      for (final a in _tumAyetler!) {
        final ayetKelimeleri = _norm(a.metin).split(' ').toSet();
        final eslesen = sorgu.where(ayetKelimeleri.contains).length;
        final oran = eslesen / sorgu.length;
        if (oran > 0 && oran + 1e-9 >= _esik) adaylar.add(_Aday(a, oran));
      }
      adaylar.sort((a, b) => b.oran.compareTo(a.oran));

      final yuzde = (_esik * 100).round();
      setState(() {
        _adaylar = adaylar.take(200).toList();
        _mesaj = _adaylar.isEmpty
            ? 'Eşiğin (%$yuzde) üzerinde eşleşen ayet yok. Eşiği düşürün ya da daha uzun okuyun.'
            : '${adaylar.length} ayet bulundu (eşik %$yuzde). Doğru ayeti listeden seçin.';
      });
    } catch (_) {
      setState(() => _mesaj = 'Kur’an metni aranırken hata oluştu.');
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Widget _esikKarti() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eşleşme eşiği: %${(_esik * 100).round()}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _esik,
              min: 0.3,
              max: 1.0,
              divisions: 14,
              label: '%${(_esik * 100).round()}',
              onChanged: (v) => setState(() => _esik = v),
              onChangeEnd: (_) {
                if (_sonSorgu.isNotEmpty) _ara(_sonSorgu);
              },
            ),
            const Text(
              'Düşük eşik daha çok, yüksek eşik daha az ama daha kesin sonuç gösterir.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sesli Ayet Bul')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const Icon(Icons.mic_rounded, size: 42, color: kYesil),
                const SizedBox(height: 8),
                const Text('Arapça ayetten birkaç kelime okuyun',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 8),
                Text(_mesaj, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _dinliyor ? () => _stt.stop() : _baslat,
                  icon: Icon(_dinliyor ? Icons.stop : Icons.mic),
                  label: Text(_dinliyor ? 'Dinlemeyi durdur' : 'Sesli ara'),
                ),
              ]),
            ),
          ),
          _esikKarti(),
          if (_metin.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Algılanan Arapça metin',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(_metin,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontFamily: kMushafFontu, fontSize: 23)),
                  ],
                ),
              ),
            ),
          if (_yukleniyor) const Center(child: CircularProgressIndicator()),
          for (final aday in _adaylar)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kYesil,
                  child: Text('%${(aday.oran * 100).round()}',
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
                title: Text(aday.ayet.metin,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: kMushafFontu, fontSize: 22)),
                subtitle: Text(
                    '${aday.ayet.sure}. sure · ${aday.ayet.numara}. ayet · Sayfa ${aday.ayet.sayfa}'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => KuranOkumaEkrani(baslangicSayfa: aday.ayet.sayfa)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Bu özellik ses tanıma metninden olası eşleşmeleri bulur; kesin ayet tanıma garantisi vermez. Sonuçları ayet metninden doğrulayın. Arapça ses tanıma için cihazda Arapça dil desteği gerekebilir.',
            style: TextStyle(fontSize: 12, color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }
}
