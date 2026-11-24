import 'dart:async';
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
import 'fonem_motoru/engine/quran_reference.dart';
import 'fonem_motoru/engine/tasmee_error_kind.dart';
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
  Timer? _takipZamanlayici;
  QuranReferenceRange? _range;
  final _canli = <(int, int), TasmeeErrorKind>{};
  final _canliHata = <(int, int), TasmeeWordMistake>{};
  final _sonHata = <(int, int), List<RecitationError>>{};
  final _eslesen = <(int, int)>{};

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
    setState(() { _busy = true; _hata = null; _result = null; _range = null; _canli.clear(); _canliHata.clear(); _sonHata.clear(); _eslesen.clear(); _v = -1; _w = -1; });
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
      setState(() => _range = range);
      session.onWordDone = (v, w, kind, mistake) {
        if (!mounted || _session != session || !_recording) return;
        if (v < 0 || v >= range.verses.length || w < 0 ||
            w >= range.verses[v].uthmaniWords.length) return;
        setState(() {
          _canli[(v, w)] = kind;
          if (mistake == null) {
            _canliHata.remove((v, w));
          } else {
            _canliHata[(v, w)] = mistake;
          }
        });
      };
      await session.startLive();
      if (!mounted) return;
      if (!session.isLive.value) {
        throw StateError(session.lastError.value.isEmpty ? 'Mikrofon açılamadı.' : session.lastError.value);
      }
      setState(() => _recording = true);
      _takipZamanlayici?.cancel();
      _takipZamanlayici = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!mounted || !_recording || _session != session) return;
        final v = session.currentVerseIdx.value;
        final w = session.currentWordIdx.value;
        if (v != _v || w != _w) setState(() { _v = v; _w = w; });
      });
    } catch (e) {
      if (mounted) setState(() => _hata = 'Ders başlatılamadı. Mikrofon iznini ve cihaz belleğini kontrol edin.\n$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _bitir() async {
    if (!_recording || _busy) return;
    final session = _session;
    _takipZamanlayici?.cancel();
    setState(() { _busy = true; _recording = false; });
    try {
      if (session == null) throw StateError('Kayıt oturumu bulunamadı.');
      await session.stopLive();
      if (!mounted) return;
      final sonuc = session.result.value;
      setState(() {
        _result = sonuc;
        _eslesen.clear();
        _sonHata.clear();
        if (sonuc != null && sonuc.hasMatch && _range != null) {
          for (final span in sonuc.matchedWordSpans) {
            _eslesen.add((span.verseIdx, span.wordIdx));
          }
          for (final e in sonuc.errors) {
            if (e.isWordRepeat || e.wordIdx == null) continue;
            final v = _range!.verses.indexWhere(
              (a) => a.verseKey == '${e.suraIdx}:${e.ayaIdx}');
            final w = e.wordIdx!;
            if (v < 0 || w < 0 || w >= _range!.verses[v].uthmaniWords.length) continue;
            (_sonHata[(v, w)] ??= []).add(e);
          }
        }
        _canli.clear();
        _canliHata.clear();
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
    _takipZamanlayici?.cancel();
    _session?.dispose();
    Recitation.reset();
    super.dispose();
  }


  TasmeeErrorKind? _kelimeDurumu(int v, int w) {
    final key = (v, w);
    if (_result == null) return _canli[key];
    final errors = _sonHata[key];
    if (errors != null && errors.isNotEmpty) {
      if (errors.any((e) => e.errorType == 'normal')) return TasmeeErrorKind.normal;
      if (errors.any((e) => e.errorType == 'tashkeel')) return TasmeeErrorKind.tashkeel;
      return TasmeeErrorKind.tajweed;
    }
    return _eslesen.contains(key) ? TasmeeErrorKind.correct : null;
  }

  Color _renk(TasmeeErrorKind? kind) => switch (kind) {
    TasmeeErrorKind.correct => const Color(0xFF15803D),
    TasmeeErrorKind.normal => const Color(0xFFB91C1C),
    TasmeeErrorKind.tashkeel => const Color(0xFFC2410C),
    TasmeeErrorKind.tajweed => const Color(0xFF7E22CE),
    null => Theme.of(context).colorScheme.onSurface,
  };

  String _durumAdi(TasmeeErrorKind? kind) => switch (kind) {
    TasmeeErrorKind.correct => 'Eşleşti',
    TasmeeErrorKind.normal => 'Harf / kelime farkı',
    TasmeeErrorKind.tashkeel => 'Hareke farkı',
    TasmeeErrorKind.tajweed => 'Tecvid / şedde farkı',
    null => 'Henüz değerlendirilmedi',
  };

  Widget _renkliMushaf() {
    final range = _range!;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 10),
      Wrap(spacing: 12, runSpacing: 6, children: [
        for (final kind in TasmeeErrorKind.values)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.circle, size: 11, color: _renk(kind)),
            const SizedBox(width: 5),
            Text(_durumAdi(kind), style: const TextStyle(fontSize: 12)),
          ]),
      ]),
      const SizedBox(height: 6),
      const Text('Ayrıntıları görmek için renkli kelimeye dokunun. Canlı sonuçlar ders bitince güncellenir.'),
      const SizedBox(height: 8),
      Card(child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var v = 0; v < range.verses.length; v++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                textDirection: TextDirection.rtl,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5, runSpacing: 6,
                children: [
                  for (var w = 0; w < range.verses[v].uthmaniWords.length; w++)
                    _renkliKelime(v, w, range.verses[v].uthmaniWords[w]),
                  Text('۞ ${range.keyOfVerse(v).ayaIdx}',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
        ]),
      )),
    ]);
  }

  Widget _renkliKelime(int v, int w, String word) {
    final kind = _kelimeDurumu(v, w);
    final color = _renk(kind);
    final active = _recording && v == _v && w == _w;
    return Semantics(
      button: kind != null,
      label: '$word, ${_durumAdi(kind)}',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: kind == null ? null : () => _kelimeAyrinti(v, w, word),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: kind == null ? null : color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(6),
            border: active ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          ),
          child: Text(word, textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: kMushafFontu, fontSize: 27,
              height: 1.8, color: color)),
        ),
      ),
    );
  }

  void _kelimeAyrinti(int v, int w, String word) {
    final kind = _kelimeDurumu(v, w);
    if (kind == null) return;
    final key = _range!.keyOfVerse(v);
    final errors = List<RecitationError>.of(_sonHata[(v, w)] ?? []);
    final live = _canliHata[(v, w)];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .65),
            child: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_durumAdi(kind), style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold, color: _renk(kind))),
                Text('Sûre ${key.suraIdx} · Ayet ${key.ayaIdx} · ${w + 1}. kelime'),
                const SizedBox(height: 12),
                Text(word, textDirection: TextDirection.rtl, textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: kMushafFontu, fontSize: 36)),
                const SizedBox(height: 12),
                if (kind == TasmeeErrorKind.correct)
                  const Text('Model bu kelimede belirgin bir fark bulmadı.'),
                for (final e in errors) ...[
                  Text(fonemHataAdi(e), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Beklenen ses: ${e.expectedPh ?? "—"}'),
                  Text('Algılanan ses: ${e.predictedPh ?? "—"}'),
                  if (e.errorType == 'tashkeel')
                    Text('Beklenen: ${fonemHarekeAdi(e.expectedPh)}\nAlgılanan: ${fonemHarekeAdi(e.predictedPh)}'),
                  if (e.expectedLen != null && e.predictedLen != null)
                    Text('Uzatma: beklenen ${e.expectedLen}, algılanan ${e.predictedLen} hareke.'),
                  const Divider(),
                ],
                if (errors.isEmpty && live != null) ...[
                  Text('Beklenen ses: ${live.expectedSymbol ?? "—"}'),
                  Text('Algılanan ses: ${live.predictedSymbol ?? "—"}'),
                  if (kind == TasmeeErrorKind.tashkeel)
                    Text('Beklenen: ${fonemHarekeAdi(live.expectedSymbol)}\nAlgılanan: ${fonemHarekeAdi(live.predictedSymbol)}'),
                  const Text('Canlı tahmin; ders sonunda kesinleşmeden önce değişebilir.'),
                ],
                if (kind != TasmeeErrorKind.correct && errors.isEmpty && live == null)
                  const Text('Model bir farklılık algıladı ancak ayrıntılı ses bilgisi vermedi.'),
                const SizedBox(height: 10),
                const Text('Bu otomatik analizdir; hatalar olası farklılıkları gösterir. Bir Kur’an hocasıyla doğrulayabilirsiniz.', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 10),
                FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
              ],
            )),
          ),
        ),
      ),
    );
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
                    if (i != null) setState(() { _secili = i; _result = null; _range = null; _canli.clear(); _canliHata.clear(); _sonHata.clear(); _eslesen.clear(); _hata = null; });
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
              if (_range != null)
                _renkliMushaf(),
              if (_range == null && !_recording && _ayetler.isNotEmpty)
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
