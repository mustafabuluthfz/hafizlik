import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ortak/tema.dart';
import 'quran_veri.dart';

/// Çevrimdışı sınav, öğrenci raporu ve cihazlar arası aktarım araçları.
/// Aktarım metni öğretmen/öğrenci arasında güvenli bir kanaldan paylaşılabilir.
class EgitimAraclariEkrani extends StatefulWidget {
  const EgitimAraclariEkrani({super.key});

  @override
  State<EgitimAraclariEkrani> createState() => _EgitimAraclariEkraniState();
}

class _EgitimAraclariEkraniState extends State<EgitimAraclariEkrani> {
  static const _ogrenciAnahtar = 'hafizlik_ogrenci_kayitlari';
  static const _sinavAnahtar = 'hafizlik_sinav_gecmisi';
  bool _yukleniyor = true;
  List<Map<String, dynamic>> _ogrenciler = [];
  List<Map<String, dynamic>> _sinavlar = [];

  @override
  void initState() {
    super.initState();
    _yenile();
  }

  Future<void> _yenile() async {
    final p = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> oku(String key) {
      try {
        return (jsonDecode(p.getString(key) ?? '[]') as List)
            .map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) { return []; }
    }
    if (!mounted) return;
    setState(() {
      _ogrenciler = oku(_ogrenciAnahtar);
      _sinavlar = oku(_sinavAnahtar);
      _yukleniyor = false;
    });
  }

  Future<void> _sinavBaslat() async {
    final tum = await QuranVeri.tumAyetler();
    if (!mounted || tum.length < 4) return;
    final rastgele = Random();
    final secilen = List<Ayet>.from(tum)..shuffle(rastgele);
    final sorular = secilen.take(10).toList();
    final cevaplar = <int, int>{};
    final ogrenci = await showDialog<String?>(
      context: context,
      builder: (c) {
        String secim = '';
        return StatefulBuilder(builder: (c, yenile) => AlertDialog(
          title: const Text('Sınavı başlat'),
          content: DropdownButtonFormField<String>(
            value: secim,
            decoration: const InputDecoration(labelText: 'Öğrenci (isteğe bağlı)'),
            items: [const DropdownMenuItem(value: '', child: Text('Kişisel çalışma')),
              ..._ogrenciler.map((o) => o['ad'] as String? ?? '').toSet().map((ad) => DropdownMenuItem(value: ad, child: Text(ad)))],
            onChanged: (v) => yenile(() => secim = v ?? ''),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(c, null), child: const Text('Vazgeç')),
            FilledButton(onPressed: () => Navigator.pop(c, secim), child: const Text('Devam et'))],
        ));
      },
    );
    if (!mounted) return;
    // Öğrenci seçimi sınav akışını durdurmasın; boş değer kişisel çalışmadır.
    final ogrenciAdi = ogrenci ?? '';
    final sonuc = await Navigator.of(context).push<int>(MaterialPageRoute(
      builder: (_) => _SinavSayfasi(sorular: sorular, tumAyetler: tum),
    ));
    if (sonuc == null) return;
    final kayit = <String, dynamic>{
      'tarih': DateTime.now().toIso8601String(),
      'dogru': sonuc,
      'toplam': sorular.length,
      'ogrenci': ogrenciAdi,
      'yuzde': (sonuc * 100 / sorular.length).round(),
    };
    final p = await SharedPreferences.getInstance();
    _sinavlar.insert(0, kayit);
    await p.setString(_sinavAnahtar, jsonEncode(_sinavlar));
    if (ogrenciAdi.isNotEmpty) {
      final i = _ogrenciler.indexWhere((o) => o['ad'] == ogrenciAdi);
      if (i >= 0) {
        _ogrenciler[i]['sonSinav'] = kayit['yuzde'];
        _ogrenciler[i]['sonSinavTarihi'] = kayit['tarih'];
        await p.setString(_ogrenciAnahtar, jsonEncode(_ogrenciler));
      }
    }
    if (mounted) {
      await _yenile();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sınav tamamlandı: $sonuc/${sorular.length} doğru.')));
    }
  }

  Future<void> _yedekOlustur() async {
    final p = await SharedPreferences.getInstance();
    final veri = <String, dynamic>{'uygulama': 'Hafızlık', 'surum': 1,
      'olusturma': DateTime.now().toIso8601String(), 'veriler': <String, dynamic>{}};
    final kayitlar = veri['veriler'] as Map<String, dynamic>;
    for (final key in p.getKeys()) {
      final value = p.get(key);
      if (value is String || value is bool || value is int || value is double || value is List<String>) {
        kayitlar[key] = value;
      }
    }
    final metin = const JsonEncoder.withIndent('  ').convert(veri);
    await showDialog<void>(context: context, builder: (c) {
      final controller = TextEditingController(text: metin);
      return AlertDialog(title: const Text('Yedekleme kodu'), content: SizedBox(width: 520,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Bu metni kopyalayıp güvenli bir yerde saklayın. Başka telefonda “Yedeği içe aktar” ile kullanabilirsiniz.'),
          const SizedBox(height: 10),
          SizedBox(height: 260, child: TextField(controller: controller, readOnly: true, maxLines: null, expands: true, decoration: const InputDecoration(border: OutlineInputBorder()))),
        ])), actions: [TextButton(onPressed: () async { await Clipboard.setData(ClipboardData(text: metin)); if (c.mounted) Navigator.pop(c); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedek panoya kopyalandı.'))); }, child: const Text('Kopyala')), TextButton(onPressed: () => Navigator.pop(c), child: const Text('Kapat'))]);
    });
  }

  Future<void> _yedekIceAktar() async {
    final controller = TextEditingController();
    final onay = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Yedeği içe aktar'),
      content: SizedBox(width: 520, child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Daha önce oluşturduğunuz yedek metnini buraya yapıştırın. Aynı anahtarlardaki mevcut veriler yedekteki verilerle değiştirilir.'),
        const SizedBox(height: 10),
        SizedBox(height: 240, child: TextField(controller: controller, maxLines: null, expands: true, decoration: const InputDecoration(hintText: 'Yedek JSON metni', border: OutlineInputBorder()))),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('İçe aktar'))],
    ));
    if (onay != true) return;
    try {
      final root = jsonDecode(controller.text) as Map<String, dynamic>;
      if (root['uygulama'] != 'Hafızlık' || root['veriler'] is! Map) throw const FormatException();
      final p = await SharedPreferences.getInstance();
      final veriler = Map<String, dynamic>.from(root['veriler'] as Map);
      for (final e in veriler.entries) {
        final v = e.value;
        if (v is String) { await p.setString(e.key, v); }
        else if (v is bool) { await p.setBool(e.key, v); }
        else if (v is int) { await p.setInt(e.key, v); }
        else if (v is double) { await p.setDouble(e.key, v); }
        else if (v is List) { await p.setStringList(e.key, v.cast<String>()); }
      }
      await _yenile();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedek başarıyla içe aktarıldı.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedek okunamadı. Metnin eksiksiz olduğundan emin olun.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final atanan = _sinavlar.where((s) => (s['ogrenci'] as String? ?? '').isNotEmpty).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Sınavlar ve Raporlar')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.quiz_rounded)), title: const Text('Kur’an ezber sınavı'), subtitle: const Text('10 rastgele ayet üzerinden sure ve ayet numarası bilgini ölç.'), trailing: const Icon(Icons.chevron_right), onTap: _sinavBaslat)),
        const SizedBox(height: 14),
        _baslik('Sınav geçmişi', Icons.assessment_rounded),
        if (_sinavlar.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Henüz sınav sonucu yok.')))
        else ..._sinavlar.take(30).map((s) => Card(child: ListTile(
          leading: CircleAvatar(child: Text('${s['yuzde'] ?? 0}%')),
          title: Text('${s['dogru'] ?? 0} / ${s['toplam'] ?? 10} doğru'),
          subtitle: Text('${(s['ogrenci'] as String? ?? '').isEmpty ? 'Kişisel çalışma' : s['ogrenci']} · ${_tarih(s['tarih'] as String?)}'),
        ))),
        const SizedBox(height: 14),
        _baslik('Öğrenci başarı raporları', Icons.groups_rounded),
        if (_ogrenciler.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Öğrenci kaydı bulunamadı. Ezber Programı bölümünden öğrenci ekleyebilirsiniz.')))
        else ..._ogrenciler.map((o) {
          final ad = o['ad'] as String? ?? 'Öğrenci';
          final sayfa = (o['sayfa'] as num?)?.toInt() ?? 1;
          final hedef = (o['hedef'] as num?)?.toInt() ?? 1;
          final yuzde = (o['sonSinav'] as num?)?.toInt();
          final adet = atanan.where((s) => s['ogrenci'] == ad).length;
          return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ad, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 16, runSpacing: 8, children: [Text('Son ezber: $sayfa. sayfa'), Text('Günlük hedef: $hedef sayfa'), Text('Sınav sayısı: $adet'), Text('Son sınav: ${yuzde == null ? 'Henüz yok' : '%$yuzde'}')]),
            if ((o['not'] as String? ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Öğretmen notu: ${o['not']}')),
          ])));
        }),
        const SizedBox(height: 14),
        _baslik('Yedekleme ve cihazlar arası aktarım', Icons.sync_rounded),
        Card(child: Column(children: [
          ListTile(leading: const Icon(Icons.upload_rounded), title: const Text('Yedek oluştur ve paylaş'), subtitle: const Text('Öğrenci, hedef ve çalışma kayıtlarını JSON metni olarak kopyala.'), onTap: _yedekOlustur),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.download_rounded), title: const Text('Yedeği içe aktar'), subtitle: const Text('Başka cihazdan gelen yedek metnini yükle.'), onTap: _yedekIceAktar),
        ])),
        const SizedBox(height: 12),
        const Text('Bilgi: Bu sürümde gerçek zamanlı bulut eşitlemesi ve çevrim içi öğretmen hesabı yoktur. Yedekleme, kullanıcı tarafından paylaşılan metin üzerinden cihazlar arasında aktarım sağlar. Ders Dinlet de tecvid/mahreç değerlendirmesi yapmaz.', style: TextStyle(fontSize: 12, color: kIkincilMetin)),
      ]),
    );
  }

  Widget _baslik(String s, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(i, color: kYesil), const SizedBox(width: 8), Text(s, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]));
  String _tarih(String? s) { final d = DateTime.tryParse(s ?? ''); if (d == null) return 'Tarih yok'; return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}'; }
}

class _SinavSayfasi extends StatefulWidget {
  final List<Ayet> sorular;
  final List<Ayet> tumAyetler;
  const _SinavSayfasi({required this.sorular, required this.tumAyetler});
  @override
  State<_SinavSayfasi> createState() => _SinavSayfasiState();
}

class _SinavSayfasiState extends State<_SinavSayfasi> {
  final Map<int, int> _cevaplar = {};
  int _soru = 0;
  late final List<List<int>> _secenekler;

  @override
  void initState() {
    super.initState();
    final r = Random();
    _secenekler = widget.sorular.map((a) {
      final set = <int>{a.numara};
      final ayniSure = widget.tumAyetler.where((x) => x.sure == a.sure).map((x) => x.numara).toSet().toList()..shuffle(r);
      for (final n in ayniSure) {
        if (set.length == 4) break;
        set.add(n);
      }
      while (set.length < 4) {
        set.add(max(1, a.numara + r.nextInt(9) - 4));
      }
      final l = set.toList()..shuffle(r);
      return l;
    }).toList();
  }

  void _bitir() {
    final dogru = _cevaplar.entries.where((e) => e.value == widget.sorular[e.key].numara).length;
    showDialog<void>(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: const Text('Sınav tamamlandı'),
      content: Text('${widget.sorular.length} sorudan $dogru doğru cevap verdiniz.\nBaşarı: %${(dogru * 100 / widget.sorular.length).round()}'),
      actions: [FilledButton(onPressed: () { Navigator.pop(c); Navigator.pop(context, dogru); }, child: const Text('Sonucu kaydet'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.sorular[_soru];
    return Scaffold(appBar: AppBar(title: Text('Ezber sınavı · ${_soru + 1}/${widget.sorular.length}')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        LinearProgressIndicator(value: (_soru + 1) / widget.sorular.length),
        const SizedBox(height: 24),
        Text('Bu ayetin Mushaf’taki ayet numarası kaçtır?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Text(a.metin, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 27, height: 2, fontFamily: 'Amiri')))),
        const SizedBox(height: 12),
        Text('Sure: ${a.sure}. sure', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        for (final n in _secenekler[_soru]) Card(child: RadioListTile<int>(value: n, groupValue: _cevaplar[_soru], title: Text('$n. ayet'), onChanged: (v) => setState(() => _cevaplar[_soru] = v!))),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: _cevaplar.containsKey(_soru) ? () { if (_soru == widget.sorular.length - 1) { _bitir(); } else { setState(() => _soru++); } } : null,
          icon: Icon(_soru == widget.sorular.length - 1 ? Icons.flag_rounded : Icons.arrow_forward), label: Text(_soru == widget.sorular.length - 1 ? 'Sınavı bitir' : 'Sonraki soru')),
      ]));
  }
}
