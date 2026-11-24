import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../hafizlik/bugunku_sayfa.dart';
import '../hafizlik/quran_veri.dart';
import '../ortak/mushaf.dart';
import 'ders_ekrani.dart';
import 'fonem_motoru/engine/recitation.dart';
import 'fonem_motoru/engine/recitation_session.dart';
import 'fonem_motoru/engine/models/recitation_result.dart';
import 'fonem_motoru/core/services/tasmee_reference_store.dart';

/// Interprets actual acoustic phoneme differences, never inferred tashkeel
/// from the consonant-only transcript. Results are educational suggestions.
String fonemHarekeAdi(String? s) {
  if (s == null || s.isEmpty) return 'Algılanmadı';
  final names = <String>[
    if (s.contains('\u064e')) 'Üstün',
    if (s.contains('\u0650')) 'Esre',
    if (s.contains('\u064f')) 'Ötre',
  ];
  return names.isEmpty ? 'Kısa ünlü işareti yok' : names.join(' / ');
}

String tecvidAdi(TajweedRule rule) {
  final s = ('${rule.nameEn} ${rule.nameAr}').toLowerCase();
  if (s.contains('shadd') || s.contains('geminat') || s.contains('شدة') || s.contains('شدّة')) return 'Şedde';
  if (s.contains('ghunn') || s.contains('غنة')) return 'Gunne';
  if (s.contains('qalqal') || s.contains('قلقلة')) return 'Kalkale';
  if (s.contains('ikhf') || s.contains('إخفاء')) return 'İhfâ';
  if (s.contains('idgh') || s.contains('إدغام')) return 'İdgam';
  if (s.contains('iqlab') || s.contains('إقلاب')) return 'İklâb';
  if (s.contains('madd') || s.contains('مد')) return 'Med / uzatma';
  return rule.nameAr.isNotEmpty ? rule.nameAr : rule.nameEn;
}

String fonemHataAdi(RecitationError e) {
  if (e.errorType == 'tashkeel') return 'Hareke: ${fonemHarekeAdi(e.expectedPh)}';
  if (e.errorType == 'tajweed') {
    final rules = <TajweedRule>[
      ...e.missingTajweedRules, ...e.replacedTajweedRules,
      ...e.insertedTajweedRules, ...e.refTajweedRules,
    ];
    final names = rules.map(tecvidAdi).where((x) => x.isNotEmpty).toSet();
    return names.isEmpty ? 'Tecvid / fonem farkı' : names.join(' · ');
  }
  return 'Harf / telaffuz farkı';
}

class FonemDersEkrani extends StatefulWidget {
  const FonemDersEkrani({super.key});
  @override
  State<FonemDersEkrani> createState() => _FonemDersEkraniState();
}

class _FonemDersEkraniState extends State<FonemDersEkrani> {
  static const _modelName = 'zipformer_p_arabic_v3.1.int8.onnx';
  static const _modelBytes = 72705392;
  List<Ayet> _ayetler = [];
  int? _sayfa;
  int _secili = -1;
  bool _busy = false;
  bool _recording = false;
  bool _engineReady = false;
  String? _hata;
  RecitationSession? _session;
  RecitationResult? _result;
  int _v = -1, _w = -1;

  @override
  void initState() {
    super.initState();
    _sayfaYukle();
  }

  Future<void> _sayfaYukle() async {
    try {
      final sayfa = await bugunkuSayfaNo();
      final ayetler = await QuranVeri.sayfa(sayfa);
      if (!mounted) return;
      setState(() { _sayfa = sayfa; _ayetler = ayetler; });
    } catch (_) {
      if (mounted) setState(() => _hata = 'Ders sayfası yüklenemedi.');
    }
  }

  Future<void> _motorHazirla() async {
    if (_engineReady) return;
    final dir = await getApplicationSupportDirectory();
    final model = File('${dir.path}/$_modelName');
    if (!await model.exists() || await model.length() != _modelBytes) {
      final data = await rootBundle.load('assets/quran_lab/$_modelName');
      if (data.lengthInBytes != _modelBytes) {
        throw StateError('Fonem model dosyası eksik veya bozuk.');
      }
      final part = File('${model.path}.part');
      await part.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
      await part.rename(model.path);
    }
    await TasmeeReferenceStore.instance.load();
    await Recitation.initZipformer(modelPath: model.path);
    if (!await Recitation.isEngineHealthy()) throw StateError('Fonem motoru açılamadı.');
    _engineReady = true;
  }

  List<Ayet> get _hedef => _secili == -1 ? _ayetler : [_ayetler[_secili]];

  Future<void> _baslat() async {
    if (_busy || _recording || _ayetler.isEmpty) return;
    setState(() { _busy = true; _hata = null; _result = null; _v = -1; _w = -1; });
    try {
      await _motorHazirla();
      if (!mounted) return;
      final range = TasmeeReferenceStore.instance.buildRange([
        for (final a in _hedef) (suraIdx: a.sure, ayaIdx: a.numara),
      ]);
      if (range == null) throw StateError('Ayet fonem referansı bulunamadı.');
      _session?.dispose();
      final session = Recitation.createSession(range: range);
      _session = session;
      session.onRangeWord = (v, w) {
        if (mounted && _recording) setState(() { _v = v; _w = w; });
      };
      await session.startLive();
      if (!mounted) return;
      if (!session.isLive.value) {
        throw StateError(session.lastError.value.isEmpty ? 'Mikrofon açılamadı.' : session.lastError.value);
      }
      setState(() => _recording = true);
    } catch (e) {
      if (mounted) setState(() => _hata = 'Ders başlatılamadı. Mikrofon iznini ve cihaz belleğini kontrol edin.\n$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _bitir() async {
    if (!_recording || _busy) return;
    final session = _session;
    setState(() { _busy = true; _recording = false; });
    try {
      if (session == null) throw StateError('Kayıt oturumu bulunamadı.');
      await session.stopLive();
      if (!mounted) return;
      final sonuc = session.result.value;
      setState(() {
        _result = sonuc;
        if (sonuc == null || !sonuc.hasMatch) {
          _hata = 'Okuma güvenilir biçimde eşleştirilemedi. Sessiz bir ortamda yeniden deneyin.';
        }
      });
    } catch (e) {
      if (mounted) setState(() => _hata = 'Ses değerlendirmesi tamamlanamadı: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _session?.dispose();
    Recitation.reset();
    super.dispose();
  }

  Widget _sonucGoster(RecitationResult r) {
    final errors = r.errors.where((e) => !e.isWordRepeat).toList();
    final hareke = errors.where((e) => e.errorType == 'tashkeel').length;
    final tecvid = errors.where((e) => e.errorType == 'tajweed').length;
    final harf = errors.length - hareke - tecvid;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 12),
      Text('Ders değerlendirmesi', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 6, children: [
        Chip(label: Text('Hareke: $hareke')),
        Chip(label: Text('Tecvid: $tecvid')),
        Chip(label: Text('Harf: $harf')),
      ]),
      if (errors.isEmpty)
        const Text('Model, eşleştirebildiği okumada belirgin fark bulmadı. Bu, bütün tecvid kurallarının doğrulandığı anlamına gelmez.'),
      for (final e in errors)
        Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fonemHataAdi(e), style: TextStyle(
              fontWeight: FontWeight.w700,
              color: e.errorType == 'tajweed' ? Colors.deepPurple : Colors.orange.shade900,
            )),
            if (e.suraIdx != null && e.ayaIdx != null)
              Text('Sûre ${e.suraIdx}, ayet ${e.ayaIdx}${e.wordIdx == null ? "" : " · ${e.wordIdx! + 1}. kelime"}'),
            if (e.wordText != null)
              Text(e.wordText!, textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: kMushafFontu, fontSize: 26)),
            const SizedBox(height: 5),
            Text('Beklenen ses: ${e.expectedPh ?? "—"} · Algılanan ses: ${e.predictedPh ?? "—"}',
              style: const TextStyle(fontSize: 14)),
            if (e.errorType == 'tashkeel')
              Text('Beklenen: ${fonemHarekeAdi(e.expectedPh)} · Algılanan: ${fonemHarekeAdi(e.predictedPh)}'),
            if (e.expectedLen != null && e.predictedLen != null)
              Text('Uzatma: beklenen ${e.expectedLen}, algılanan ${e.predictedLen} hareke.'),
            const Text('Olası fark — tekrar okuyarak veya hocanızla kontrol edin.', style: TextStyle(fontSize: 12)),
          ]),
        )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy && !_recording,
      child: Scaffold(
        appBar: AppBar(title: Text(_sayfa == null ? 'Ders Dinlet' : 'Ders Dinlet · Sayfa $_sayfa')),
        body: _sayfa == null && _hata == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              Text('Hareke ve Tecvid Analizi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Üstün, esre, ötre, şedde ve modelin desteklediği tecvid özellikleri, sesin fonemleri üzerinden incelenir. Ses cihazda işlenir.'),
              const SizedBox(height: 8),
              const Text('Hafs rivayeti esas alınır. Otomatik değerlendirme yanılabilir; özellikle vakıf, med seçenekleri ve çocuk okuyuşlarında bir Kur’an hocasının değerlendirmesinin yerini tutmaz.'),
              const SizedBox(height: 12),
              if (_ayetler.isNotEmpty)
                DropdownButtonFormField<int>(
                  value: _secili,
                  decoration: const InputDecoration(labelText: 'Ders kapsamı'),
                  items: [
                    const DropdownMenuItem(value: -1, child: Text('Bugünkü sayfanın tamamı')),
                    for (var i = 0; i < _ayetler.length; i++)
                      DropdownMenuItem(value: i, child: Text('Sûre ${_ayetler[i].sure}, ayet ${_ayetler[i].numara}')),
                  ],
                  onChanged: _busy || _recording ? null : (i) {
                    if (i != null) setState(() { _secili = i; _result = null; _hata = null; });
                  },
                ),
              const SizedBox(height: 12),
              if (_busy) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                const Text('Model hazırlanıyor veya ses değerlendiriliyor…'),
              ],
              if (_recording) ...[
                const Text('Ezberden okuyun. Ders kaydediliyor.'),
                if (_v >= 0 && _v < _hedef.length)
                  Text('Takip: Sûre ${_hedef[_v].sure}, ayet ${_hedef[_v].numara} · Kelime ${_w + 1}'),
              ],
              if (_hata != null) Text(_hata!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              if (!_recording && _ayetler.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: MushafSayfaGorunumu(ayetler: _hedef),
                ),
              if (_result != null && _result!.hasMatch) _sonucGoster(_result!),
              const SizedBox(height: 12),
              if (!_busy && !_recording)
                OutlinedButton(
                  onPressed: () {
                    _session?.dispose();
                    _session = null;
                    Recitation.reset();
                    _engineReady = false;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DersEkrani()));
                  },
                  child: const Text('Temel kelime kontrolü'),
                ),
              const SizedBox(height: 4),
              const Text('Fonem motoru: Quran-Lab Zipformer v3.1 (NPL-1.2). Bu özellik ücretsiz ve reklamsızdır.', style: TextStyle(fontSize: 11)),
            ]),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _busy || _ayetler.isEmpty ? null : (_recording ? _bitir : _baslat),
            icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
            label: Text(_recording ? 'Dersi bitir' : 'Ders Dinlet'),
          ),
        ),
      ),
    );
  }
}
