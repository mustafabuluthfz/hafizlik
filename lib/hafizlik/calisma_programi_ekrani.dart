import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ortak/tema.dart';

/// Günlük/haftalık hedefleri ve cihaz üzerinde tutulan öğrenci kayıtlarını yönetir.
/// Kayıtlar yereldir; herhangi bir sunucuya gönderilmez.
class CalismaProgramiEkrani extends StatefulWidget {
  const CalismaProgramiEkrani({super.key});

  @override
  State<CalismaProgramiEkrani> createState() => _CalismaProgramiEkraniState();
}

class _CalismaProgramiEkraniState extends State<CalismaProgramiEkrani> {
  static const _gunlukAnahtar = 'calisma_gunluk_hedef';
  static const _haftalikAnahtar = 'calisma_haftalik_hedef';
  static const _aylikAnahtar = 'calisma_aylik_hedef';
  static const _kayitAnahtar = 'calisma_gunluk_kayitlar';
  static const _ogrenciAnahtar = 'hafizlik_ogrenci_kayitlari';

  bool _yukleniyor = true;
  int _gunluk = 1;
  int _haftalik = 7;
  int _aylik = 30;
  Map<String, dynamic> _gunlukKayitlar = {};
  List<Map<String, dynamic>> _ogrenciler = [];
  Timer? _sayac;
  DateTime? _sayacBaslangici;
  int _gecenSaniye = 0;

  String get _bugun => _tarihAnahtari(DateTime.now());
  String _tarihAnahtari(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> get _bugunKaydi =>
      Map<String, dynamic>.from(_gunlukKayitlar[_bugun] as Map? ?? {});

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  Future<void> _yukle() async {
    final p = await SharedPreferences.getInstance();
    final kayit = p.getString(_kayitAnahtar);
    final ogrenci = p.getString(_ogrenciAnahtar);
    if (!mounted) return;
    setState(() {
      _gunluk = p.getInt(_gunlukAnahtar) ?? 1;
      _haftalik = p.getInt(_haftalikAnahtar) ?? 7;
      _aylik = p.getInt(_aylikAnahtar) ?? 30;
      if (kayit != null) {
        try { _gunlukKayitlar = Map<String, dynamic>.from(jsonDecode(kayit) as Map); } catch (_) {}
      }
      if (ogrenci != null) {
        try {
          _ogrenciler = (jsonDecode(ogrenci) as List)
              .map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (_) {}
      }
      _gecenSaniye = (_bugunKaydi['saniye'] as num?)?.toInt() ?? 0;
      _yukleniyor = false;
    });
  }

  Future<void> _kaydetHedef(String alan, int deger) async {
    final p = await SharedPreferences.getInstance();
    if (alan == 'gunluk') { _gunluk = deger; await p.setInt(_gunlukAnahtar, deger); }
    if (alan == 'haftalik') { _haftalik = deger; await p.setInt(_haftalikAnahtar, deger); }
    if (alan == 'aylik') { _aylik = deger; await p.setInt(_aylikAnahtar, deger); }
    if (mounted) setState(() {});
  }

  Future<void> _gunlukGorev(String gorev, bool tamam) async {
    final kayit = _bugunKaydi;
    final gorevler = Map<String, dynamic>.from(kayit['gorevler'] as Map? ?? {});
    gorevler[gorev] = tamam;
    kayit['gorevler'] = gorevler;
    _gunlukKayitlar[_bugun] = kayit;
    await _kayitlariYaz();
    if (mounted) setState(() {});
  }

  Future<void> _kayitlariYaz() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kayitAnahtar, jsonEncode(_gunlukKayitlar));
  }

  Future<void> _bugunSayfaKaydet(int sayfa) async {
    final kayit = _bugunKaydi;
    kayit['sayfa'] = sayfa.clamp(0, 20);
    _gunlukKayitlar[_bugun] = kayit;
    await _kayitlariYaz();
    if (mounted) setState(() {});
  }

  void _sayaciDegistir() {
    if (_sayacBaslangici != null) {
      _sayac?.cancel();
      _sayac = null;
      _sayacBaslangici = null;
      _gunlukKaydiSaniyeYaz();
    } else {
      _sayacBaslangici = DateTime.now();
      _sayac = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _gecenSaniye++);
        if (_gecenSaniye % 15 == 0) _gunlukKaydiSaniyeYaz();
      });
    }
    if (mounted) setState(() {});
  }

  Future<void> _gunlukKaydiSaniyeYaz() async {
    final kayit = _bugunKaydi;
    kayit['saniye'] = _gecenSaniye;
    _gunlukKayitlar[_bugun] = kayit;
    await _kayitlariYaz();
  }

  int _toplamSayfa(String aralik) {
    final now = DateTime.now();
    final baslangic = aralik == 'hafta'
        ? DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1))
        : DateTime(now.year, now.month, 1);
    var toplam = 0;
    for (var i = 0; i < (aralik == 'hafta' ? 7 : now.day); i++) {
      final d = baslangic.add(Duration(days: i));
      if (d.isAfter(DateTime(now.year, now.month, now.day))) continue;
      final g = Map<String, dynamic>.from(_gunlukKayitlar[_tarihAnahtari(d)] as Map? ?? {});
      toplam += (g['sayfa'] as num?)?.toInt() ?? 0;
    }
    return toplam;
  }

  Future<void> _ogrenciEkle({Map<String, dynamic>? mevcut, int? indeks}) async {
    final ad = TextEditingController(text: mevcut?['ad'] as String? ?? '');
    final hedef = TextEditingController(text: '${mevcut?['hedef'] ?? 1}');
    final sayfa = TextEditingController(text: '${mevcut?['sayfa'] ?? 1}');
    final not = TextEditingController(text: mevcut?['not'] as String? ?? '');
    final sonuc = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(mevcut == null ? 'Öğrenci ekle' : 'Öğrenciyi düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: ad, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Adı soyadı')),
          const SizedBox(height: 8),
          TextField(controller: sayfa, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Son ezberlediği sayfa')),
          const SizedBox(height: 8),
          TextField(controller: hedef, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Günlük hedef (sayfa)')),
          const SizedBox(height: 8),
          TextField(controller: not, maxLines: 2, decoration: const InputDecoration(labelText: 'Öğretmen notu (isteğe bağlı)')),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Kaydet'))],
      ),
    );
    if (sonuc != true) return;
    final adMetni = ad.text.trim();
    if (adMetni.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Öğrenci adı boş bırakılamaz.')));
      return;
    }
    final yeni = <String, dynamic>{
      'ad': adMetni,
      'sayfa': (int.tryParse(sayfa.text) ?? 1).clamp(1, 604),
      'hedef': (int.tryParse(hedef.text) ?? 1).clamp(1, 20),
      'not': not.text.trim(),
      'guncelleme': DateTime.now().toIso8601String(),
    };
    if (indeks == null) { _ogrenciler.add(yeni); } else { _ogrenciler[indeks] = yeni; }
    await _ogrencileriYaz();
    if (mounted) setState(() {});
  }

  Future<void> _ogrenciSil(int i) async {
    final onay = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Öğrenci silinsin mi?'),
      content: Text('${_ogrenciler[i]['ad']} kaydı cihazdan silinecek.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sil'))],
    ));
    if (onay != true) return;
    _ogrenciler.removeAt(i);
    await _ogrencileriYaz();
    if (mounted) setState(() {});
  }

  Future<void> _ogrencileriYaz() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_ogrenciAnahtar, jsonEncode(_ogrenciler));
  }

  String _sure(int saniye) => '${(saniye ~/ 3600).toString().padLeft(2, '0')}:${((saniye % 3600) ~/ 60).toString().padLeft(2, '0')}:${(saniye % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final kayit = _bugunKaydi;
    final gorevler = Map<String, dynamic>.from(kayit['gorevler'] as Map? ?? {});
    final tamam = gorevler.values.where((v) => v == true).length;
    final haftalikTamam = _toplamSayfa('hafta');
    final aylikTamam = _toplamSayfa('ay');
    final bugunSayfa = (kayit['sayfa'] as num?)?.toInt() ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Ezber Programı ve Öğrenciler')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _baslik('Günlük çalışma planı', Icons.today_rounded),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _hedefSatiri('Günlük ezber hedefi', _gunluk, 1, 10, 'sayfa', (v) => _kaydetHedef('gunluk', v)),
          const Divider(height: 24),
          _hedefSatiri('Haftalık ezber hedefi', _haftalik, 1, 70, 'sayfa', (v) => _kaydetHedef('haftalik', v)),
          const Divider(height: 24),
          _hedefSatiri('Aylık ezber hedefi', _aylik, 1, 300, 'sayfa', (v) => _kaydetHedef('aylik', v)),
          const SizedBox(height: 12),
          _hedefIlerleme('Günlük ezber', bugunSayfa, _gunluk),
          const SizedBox(height: 8),
          _hedefIlerleme('Haftalık ezber', haftalikTamam, _haftalik),
          const SizedBox(height: 8),
          _hedefIlerleme('Aylık ezber', aylikTamam, _aylik),
        ]))),
        const SizedBox(height: 10),
        Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [const Expanded(child: Text('Bugün ezberlenen sayfa', style: TextStyle(fontWeight: FontWeight.w600))), IconButton(onPressed: bugunSayfa > 0 ? () => _bugunSayfaKaydet(bugunSayfa - 1) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$bugunSayfa', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), IconButton(onPressed: () => _bugunSayfaKaydet(bugunSayfa + 1), icon: const Icon(Icons.add_circle_outline))]))),
        const SizedBox(height: 18),
        _baslik('Bugünün görevleri', Icons.checklist_rounded),
        Card(child: Column(children: [
          _gorev('Yeni ezberini çalış', 'ezber', gorevler),
          const Divider(height: 1),
          _gorev('Önceki ezberleri tekrar et', 'tekrar', gorevler),
          const Divider(height: 1),
          _gorev('Ders Dinlet ile kontrol et', 'dinlet', gorevler),
          const Divider(height: 1),
          _gorev('Bulmaca ile kendini sına', 'sinav', gorevler),
          Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Expanded(child: Text('$tamam / 4 görev tamamlandı', style: const TextStyle(fontWeight: FontWeight.w600))),
            SizedBox(width: 100, child: LinearProgressIndicator(value: tamam / 4, minHeight: 7)),
          ])),
        ])),
        const SizedBox(height: 18),
        _baslik('Çalışma süresi', Icons.timer_outlined),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: Text(_sure(_gecenSaniye), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kYesil))),
          FilledButton.icon(onPressed: _sayaciDegistir, icon: Icon(_sayacBaslangici == null ? Icons.play_arrow : Icons.pause), label: Text(_sayacBaslangici == null ? 'Başlat' : 'Duraklat')),
        ]))),
        const SizedBox(height: 18),
        Row(children: [Expanded(child: _baslik('Öğrenci takibi', Icons.groups_rounded)), IconButton(onPressed: () => _ogrenciEkle(), icon: const Icon(Icons.person_add_alt_1), tooltip: 'Öğrenci ekle')]),
        if (_ogrenciler.isEmpty)
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [const Text('Henüz öğrenci eklenmedi.'), const SizedBox(height: 8), OutlinedButton.icon(onPressed: () => _ogrenciEkle(), icon: const Icon(Icons.add), label: const Text('İlk öğrenciyi ekle'))])))
        else
          for (var i = 0; i < _ogrenciler.length; i++) _ogrenciKarti(i),
        const SizedBox(height: 18),
        const Text('Not: Bu ekrandaki öğrenci kayıtları ve çalışma planı yalnızca bu cihazda saklanır. Ders Dinlet sonuçları konuşma tanıma eşleşmesidir; yapay zekâ, tecvid veya mahreç değerlendirmesi değildir.', style: TextStyle(fontSize: 12, color: kIkincilMetin)),
      ]),
    );
  }

  Widget _baslik(String metin, IconData ikon) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Icon(ikon, color: kYesil), const SizedBox(width: 8), Text(metin, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]));

  Widget _hedefSatiri(String baslik, int deger, int min, int max, String birim, ValueChanged<int> degistir) => Row(children: [Expanded(child: Text(baslik, style: const TextStyle(fontWeight: FontWeight.w600))), IconButton(onPressed: deger > min ? () => degistir(deger - 1) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$deger $birim', style: const TextStyle(fontWeight: FontWeight.w700)), IconButton(onPressed: deger < max ? () => degistir(deger + 1) : null, icon: const Icon(Icons.add_circle_outline))]);

  Widget _hedefIlerleme(String baslik, int deger, int hedef) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(baslik), Text('$deger / $hedef')]), const SizedBox(height: 5), LinearProgressIndicator(value: hedef == 0 ? 0.0 : (deger / hedef).clamp(0.0, 1.0).toDouble(), minHeight: 6)]);

  Widget _gorev(String baslik, String anahtar, Map<String, dynamic> gorevler) => CheckboxListTile(value: gorevler[anahtar] == true, onChanged: (v) => _gunlukGorev(anahtar, v ?? false), title: Text(baslik), controlAffinity: ListTileControlAffinity.leading, dense: true);

  Widget _ogrenciKarti(int i) {
    final o = _ogrenciler[i];
    final sayfa = (o['sayfa'] as num?)?.toInt() ?? 1;
    final hedef = (o['hedef'] as num?)?.toInt() ?? 1;
    return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
      leading: CircleAvatar(backgroundColor: kYesil.withOpacity(.12), child: const Icon(Icons.school_rounded, color: kYesil)),
      title: Text(o['ad'] as String? ?? 'Öğrenci', style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('Son ezber: $sayfa. sayfa · Günlük hedef: $hedef sayfa${(o['not'] as String? ?? '').isEmpty ? '' : '\n${o['not']}'}'),
      isThreeLine: (o['not'] as String? ?? '').isNotEmpty,
      trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'duzenle') _ogrenciEkle(mevcut: o, indeks: i); if (v == 'sil') _ogrenciSil(i); }, itemBuilder: (_) => const [PopupMenuItem(value: 'duzenle', child: Text('Düzenle')), PopupMenuItem(value: 'sil', child: Text('Sil'))]),
    ));
  }
}
