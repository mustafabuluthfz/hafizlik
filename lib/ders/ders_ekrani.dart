import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import '../ai/ai_hoca_ekrani.dart';

import '../hafizlik/bugunku_sayfa.dart';
import '../hafizlik/hafizlik_sira.dart';
import '../hafizlik/quran_veri.dart';
import '../ortak/mushaf.dart';
import 'karsilastirma.dart';

/// Ders dinletme: telefonun konuşma tanıma hizmetiyle Arapça okumayı dinler,
/// sayfa kelimeleriyle karşılaştırır; doğru/yanlış/atlanan kelimeleri canlı işaretler.
class DersEkrani extends StatefulWidget {
  const DersEkrani({super.key});

  @override
  State<DersEkrani> createState() => _DersEkraniState();
}

class _RenkAciklama extends StatelessWidget {
  final Color renk;
  final String yazi;
  const _RenkAciklama({required this.renk, required this.yazi});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 9, height: 9, decoration: BoxDecoration(
        color: renk, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(yazi, style: const TextStyle(fontSize: 11)),
    ],
  );
}

class _DersEkraniState extends State<DersEkrani> {
  final SpeechToText _stt = SpeechToText();

  bool _yukleniyor = true;
  bool _sesHazir = false;
  String? _arapcaDil;
  String? _hata;
  int? _sayfa;
  List<String> _kelimeler = [];

  bool _dinliyor = false;
  bool _yenidenBaslatiliyor = false;
  bool _dinlemeBaslatiliyor = false;
  int _yenidenBaslatDenemesi = 0;
  Timer? _yenidenBaslatZamanlayici;
  String _kesin = ''; // tanınıp kesinleşmiş metin
  String _anlik = ''; // henüz kesinleşmemiş (anlık) metin
  List<KelimeDurumu>? _sonuc;
  int _harekeHatalari = 0;
  int _tecvidHatalari = 0;

  void _kelimeAciklamaGoster(KelimeDurumu d) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(d.metin,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: kMushafFontu, fontSize: 30)),
              ),
              const SizedBox(height: 12),
              Text(kelimeAciklamasi(d), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(tecvidNotu(d.metin),
                  style: TextStyle(fontSize: 13, color: Colors.brown.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  @override
  void dispose() {
    _yenidenBaslatZamanlayici?.cancel();
    _dinliyor = false;
    _stt.cancel();
    super.dispose();
  }

  Future<void> _baslat() async {
    try {
      final sayfa = await bugunkuSayfaNo();
      final ayetler = await QuranVeri.sayfa(sayfa);
      _kelimeler = [
        for (final a in ayetler) ...a.metin.trim().split(RegExp(r'\s+')),
      ];
      _sayfa = sayfa;
    } catch (_) {
      _hata = 'Ders sayfası yüklenemedi.';
    }

    try {
      _sesHazir = await _stt.initialize(
        onError: (e) {
          if (!mounted || !_dinliyor) return;
          final kod = e.errorMsg.toLowerCase();
          // Android sessizlik veya kısa duraklamalarda oturumu kapatabilir.
          final gecici = kod.contains('speech_timeout') ||
              kod.contains('no_match') || kod == 'no_match' ||
              kod.contains('busy') || kod.contains('network_timeout');
          if (gecici) {
            _yenidenBaslatPlanla();
          } else {
            _yenidenBaslatZamanlayici?.cancel();
            setState(() {
              _dinliyor = false;
              _hata = 'Ses tanıma durdu: ${e.errorMsg}. Mikrofon iznini, '
                  'internet bağlantısını ve telefondaki Arapça konuşma tanıma '
                  'hizmetini kontrol edin.';
            });
          }
        },
        onStatus: (durum) {
          final s = durum.toLowerCase();
          if ((s == 'done' || s == 'notlistening') && _dinliyor) {
            _yenidenBaslatPlanla();
          }
        },
      );
      if (_sesHazir) {
        // speech_to_text bazı Android sürümlerinde locales() listesini boş
        // döndürebiliyor. Bu durumda sabit Arapça koduyla denemeye izin ver.
        // Gerçek destek kontrolünü listen() başlatırken sistem servisi yapar.
        final diller = await _stt.locales();
        final arapca = diller
            .where((d) => d.localeId.toLowerCase().startsWith('ar'))
            .toList();
        if (arapca.isNotEmpty) {
          final tercih = arapca.where((d) {
            final id = d.localeId.toLowerCase().replaceAll('-', '_');
            return id == 'ar_sa' || id == 'ar' || id == 'ar_eg';
          }).toList();
          _arapcaDil = (tercih.isNotEmpty ? tercih.first : arapca.first).localeId;
        } else {
          _arapcaDil = 'ar-SA';
        }
        final izinVar = await _stt.hasPermission;
        if (!izinVar) {
          _sesHazir = false;
          _hata = 'Mikrofon izni verilmemiş. Android uygulama ayarlarından '
              'Hafızlık için Mikrofon iznini açıp tekrar deneyin.';
        }
      } else {
        _hata ??= 'Bu telefonda ses tanıma kullanılamıyor.';
      }
    } catch (_) {
      _hata ??= 'Ses tanıma başlatılamadı.';
    }

    if (!mounted) return;
    setState(() => _yukleniyor = false);
  }

  Future<void> _dinlemeyiBaslat() async {
    if (!_sesHazir || _arapcaDil == null || _dinliyor) return;
    final izinVar = await _stt.hasPermission;
    if (!mounted) return;
    if (!izinVar) {
      setState(() => _hata = 'Mikrofon izni gerekli. Uygulama ayarlarından '
          'mikrofon iznini verip yeniden deneyin.');
      return;
    }
    _yenidenBaslatZamanlayici?.cancel();
    _yenidenBaslatDenemesi = 0;
    setState(() {
      _hata = null;
      _dinliyor = true;
      _kesin = '';
      _anlik = '';
      _sonuc = null;
      _harekeHatalari = 0;
      _tecvidHatalari = 0;
    });
    await _dinlemeyiSurdur();
  }

  Future<void> _dinlemeyiSurdur() async {
    if (!_dinliyor || _arapcaDil == null || _dinlemeBaslatiliyor) return;
    try {
      if (_stt.isListening) return;
      _dinlemeBaslatiliyor = true;
      await _stt.listen(
        onResult: _sonucGeldi,
        localeId: _arapcaDil,
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 10),
        partialResults: true,
        // onDevice:true birçok telefonda Arapça çevrimdışı modeli bulunmadığı
        // için dinlemeyi hiç başlatmıyordu. Sistem tanıma hizmeti seçsin.
        onDevice: false,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dinliyor = false;
        _hata = 'Ses dinleme başlatılamadı. Mikrofon iznini, internet '
            'bağlantısını ve telefondaki konuşma tanıma hizmetini kontrol edin.';
      });
    } finally {
      _dinlemeBaslatiliyor = false;
    }
  }

  void _yenidenBaslatPlanla() {
    if (!_dinliyor || !mounted || _yenidenBaslatiliyor ||
        _yenidenBaslatZamanlayici?.isActive == true) return;
    if (_yenidenBaslatDenemesi >= 8) {
      setState(() {
        _dinliyor = false;
        _hata = 'Ses tanıma art arda durdu. Daha sessiz bir ortamda veya '
            'internet bağlantısını kontrol ederek yeniden deneyin.';
      });
      return;
    }
    _yenidenBaslatDenemesi++;
    final ms = (500 * _yenidenBaslatDenemesi).clamp(500, 3000).toInt();
    _yenidenBaslatZamanlayici = Timer(Duration(milliseconds: ms), _yenidenBaslat);
  }

  Future<void> _yenidenBaslat() async {
    if (_yenidenBaslatiliyor || !_dinliyor || !mounted) return;
    _yenidenBaslatZamanlayici?.cancel();
    _yenidenBaslatiliyor = true;
    try {
      if (_stt.isListening) await _stt.stop();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (_dinliyor && mounted) await _dinlemeyiSurdur();
    } finally {
      _yenidenBaslatiliyor = false;
    }
  }

  void _sonucGeldi(SpeechRecognitionResult r) {
    if (!mounted) return;
    _yenidenBaslatDenemesi = 0;
    setState(() {
      if (r.finalResult) {
        _kesin = '$_kesin ${r.recognizedWords}'.trim();
        _anlik = '';
      } else {
        _anlik = r.recognizedWords;
      }
      _sonuc = karsilastir(_kelimeler, '$_kesin $_anlik');
    });
  }

  Future<void> _dinlemeyiDurdur() async {
    if (!_dinliyor) return;
    _yenidenBaslatZamanlayici?.cancel();
    setState(() => _dinliyor = false);
    await _stt.stop();
    _dinlemeBaslatiliyor = false;
    if (!mounted) return;
    setState(() {
      _kesin = '$_kesin $_anlik'.trim();
      _anlik = '';
      _sonuc = karsilastir(_kelimeler, _kesin, tamamlandi: true);
    });
  }

  void _sifirla() {
    _yenidenBaslatZamanlayici?.cancel();
    setState(() {
      _kesin = '';
      _anlik = '';
      _sonuc = null;
      _harekeHatalari = 0;
      _tecvidHatalari = 0;
      _hata = null;
    });
  }


  Future<void> _hataEkle(String tur) async {
    final aciklama = tur == 'hareke'
        ? 'Hareke hatası bu oturumda kaydedilsin mi?'
        : 'Tecvid hatası bu oturumda kaydedilsin mi?';
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tur == 'hareke' ? 'Hareke hatası' : 'Tecvid hatası'),
        content: Text(aciklama),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hata olarak say')),
        ],
      ),
    );
    if (onay != true || !mounted) return;
    setState(() {
      if (tur == 'hareke') { _harekeHatalari++; } else { _tecvidHatalari++; }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sayfa == null ? 'Ders Dinlet' : 'Ders · Sayfa $_sayfa'),
      ),
      body: _govde(),
    );
  }

  Widget _govde() {
    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_sayfa == null) {
      return Center(child: Text(_hata ?? 'Bir hata oluştu.'));
    }

    final durumlar = _sonuc ??
        [for (final k in _kelimeler) KelimeDurumu(k, KelimeDurumuTipi.bekliyor)];
    final dogruSayisi = durumlar.where((d) => d.durum == KelimeDurumuTipi.dogru).length;
    final yanlisSayisi = durumlar.where((d) => d.durum == KelimeDurumuTipi.yanlis).length;
    final atlananSayisi = durumlar.where((d) => d.durum == KelimeDurumuTipi.atlandi).length;
    final fazlaSayisi = _sonuc == null ? 0 : fazlaKelimeSayisi(_kelimeler, '$_kesin $_anlik');

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cüz ${HafizlikSira.cuzOf(_sayfa!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Flexible(
                  child: Text(_sonuc == null && !_dinliyor
                      ? 'Başlamak için mikrofon düğmesine dokunun'
                      : 'Doğru: $dogruSayisi  ·  Kelime hatası: ${yanlisSayisi + atlananSayisi + fazlaSayisi}  ·  Hareke: $_harekeHatalari  ·  Tecvid: $_tecvidHatalari',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_hata != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(_hata!, style: const TextStyle(color: Colors.red)),
          ),
        if (_dinliyor)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text('Ezberden okuyun. Sayfa gizlidir; bitirdiğinizde sonuçlar açılacak.',
                style: TextStyle(color: Colors.black87)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: Wrap(spacing: 12, runSpacing: 4, children: const [
            _RenkAciklama(renk: Colors.green, yazi: 'Doğru'),
            _RenkAciklama(renk: Colors.red, yazi: 'Farklı algılandı'),
            _RenkAciklama(renk: Colors.orange, yazi: 'Atlandı'),
            _RenkAciklama(renk: Colors.black54, yazi: 'Henüz okunmadı'),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Text(
            'Kelime kontrolü ses tanıma metnine dayanır. Hareke ve tecvid hataları ayrıca kaydedilir.',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ),
        Expanded(
          child: _dinliyor
              ? Center(
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.visibility_off, size: 58),
                          SizedBox(height: 14),
                          Text('EZBER MODU', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Sayfa gizlendi. Mushaf metni dinleme bitene kadar gösterilmeyecek.', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Container(
              decoration: BoxDecoration(
                color: kKagitRengi,
                border: Border.all(color: Colors.brown.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Text.rich(
                TextSpan(
                  children: [
                    for (final d in durumlar)
                      TextSpan(
                        text: '${d.metin} ',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _kelimeAciklamaGoster(d),
                        style: TextStyle(
                          color: switch (d.durum) {
                            KelimeDurumuTipi.dogru => Colors.green.shade800,
                            KelimeDurumuTipi.yanlis => Colors.red.shade700,
                            KelimeDurumuTipi.atlandi => Colors.orange.shade800,
                            KelimeDurumuTipi.bekliyor => Colors.black87,
                          },
                          fontWeight: d.durum == KelimeDurumuTipi.bekliyor
                              ? FontWeight.normal : FontWeight.bold,
                          backgroundColor: d.durum == KelimeDurumuTipi.dogru
                              ? Colors.green.withOpacity(0.08) : null,
                        ),
                      ),
                  ],
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: kMushafFontu,
                  fontSize: 24,
                  height: 2.1,
                ),
              ),
            ),
          ),
        ),
        if (!_dinliyor && _sonuc != null && _kesin.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AiHocaEkrani(
                      sayfa: _sayfa,
                      beklenenMetin: _kelimeler.join(' '),
                      taninanMetin: _kesin,
                    ),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Yapay zekâ hafızlık hocasına danış'),
              ),
            ),
          ),
        if (!_dinliyor) Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Ek hata kaydı  ·  Hareke: $_harekeHatalari  ·  Tecvid: $_tecvidHatalari',
                textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: _sonuc == null ? null : () => _hataEkle('hareke'),
                  icon: const Icon(Icons.spellcheck), label: const Text('Hareke hatası +1')),
                ),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _sonuc == null ? null : () => _hataEkle('tecvid'),
                  icon: const Icon(Icons.record_voice_over), label: const Text('Tecvid hatası +1')),
                ),
              ]),
              const SizedBox(height: 3),
              const Text('Not: Telefonun konuşma tanıması hareke ve tecvidi güvenilir biçimde ölçemez. Bu iki hata, dinleme sonrası öğretmen/denetçi tarafından ayrıca kaydedilir; otomatik tespit olarak sunulmaz.',
                style: TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: !_sesHazir
                        ? null
                        : (_dinliyor ? _dinlemeyiDurdur : _dinlemeyiBaslat),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: _dinliyor ? Colors.red.shade700 : null,
                    ),
                    icon: Icon(_dinliyor ? Icons.stop : Icons.mic),
                    label: Text(_dinliyor ? 'Dinlemeyi bitir' : 'Okumayı dinle'),
                  ),
                ),
                if (_sonuc != null || _kesin.isNotEmpty || _anlik.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _dinliyor ? null : _sifirla,
                    child: const Text('Sıfırla'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
