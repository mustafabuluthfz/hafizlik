import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hafizlik/hafizlik_sira.dart';
import '../hafizlik/quran_veri.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import '../ses/ses_cubugu.dart';

/// Sayfa bazlı ezber, gizleme, sayfa başı/sonu kontrolü ve kişisel ezber listesi.
class EzberAtolyesiEkrani extends StatefulWidget {
  final int? ilkSayfa;
  const EzberAtolyesiEkrani({super.key, this.ilkSayfa});

  @override
  State<EzberAtolyesiEkrani> createState() => _EzberAtolyesiEkraniState();
}

class _EzberAtolyesiEkraniState extends State<EzberAtolyesiEkrani> {
  static const _listeAnahtari = 'ezber_atolyesi_sayfa_listesi_v1';
  late int _sayfa;
  int _gizleme = 0; // 0 metin, 1-4 artan gizleme
  bool _soluk = false;
  List<int> _ezberListesi = [];
  bool _yukleniyor = true;
  late Future<List<Ayet>> _ayetFuture;

  @override
  void initState() {
    super.initState();
    _sayfa = (widget.ilkSayfa ?? 1).clamp(1, HafizlikSira.toplamSayfa).toInt();
    _ayetFuture = QuranVeri.sayfa(_sayfa);
    _listeyiYukle();
  }

  Future<void> _listeyiYukle() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_listeAnahtari);
    List<int> liste = [];
    try {
      liste = (jsonDecode(raw ?? '[]') as List).map((e) => (e as num).toInt()).toSet().toList()..sort();
    } catch (_) {}
    if (!mounted) return;
    setState(() { _ezberListesi = liste; _yukleniyor = false; });
  }

  Future<void> _listeyiKaydet() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_listeAnahtari, jsonEncode(_ezberListesi));
  }

  void _sayfayaGit(int sayfa) {
    final hedef = sayfa.clamp(1, HafizlikSira.toplamSayfa).toInt();
    setState(() {
      _sayfa = hedef;
      _ayetFuture = QuranVeri.sayfa(hedef);
      _gizleme = 0;
    });
  }

  Future<void> _sayfaSec() async {
    final c = TextEditingController(text: '$_sayfa');
    final secilen = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Ezber sayfası seç'),
      content: TextField(controller: c, autofocus: true, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Sayfa (1-${HafizlikSira.toplamSayfa})')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () { final n = int.tryParse(c.text); if (n != null) Navigator.pop(ctx, n); }, child: const Text('Aç'))],
    ));
    if (secilen != null) _sayfayaGit(secilen);
  }

  Future<void> _listeyeEkleCikar() async {
    setState(() {
      if (_ezberListesi.contains(_sayfa)) { _ezberListesi.remove(_sayfa); }
      else { _ezberListesi.add(_sayfa); _ezberListesi.sort(); }
    });
    await _listeyiKaydet();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
      _ezberListesi.contains(_sayfa) ? '$_sayfa. sayfa ezber listene eklendi.' : '$_sayfa. sayfa ezber listesinden çıkarıldı.')));
  }

  Future<void> _baslangicSonKontrolu() async {
    final ayetler = await _ayetFuture;
    if (!mounted || ayetler.isEmpty) return;
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text('$_sayfa. sayfa · Başlangıç ve bitiş kontrolü'),
      content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Önce ayetleri ezberden okumayı deneyin. Ardından kontrol etmek için gösterin.'),
        const SizedBox(height: 14),
        _KontrolAyet(etiket: 'Sayfanın ilk ayeti', ayet: ayetler.first),
        const SizedBox(height: 10),
        _KontrolAyet(etiket: 'Sayfanın son ayeti', ayet: ayetler.last),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
    ));
  }

  Future<void> _ezberListesiniAc() async {
    if (_ezberListesi.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Henüz ezber listesi oluşturmadınız.')));
      return;
    }
    final secim = await showModalBottomSheet<int>(context: context, showDragHandle: true,
      builder: (ctx) => ListView(shrinkWrap: true, children: [
        const ListTile(title: Text('Ezber listem', style: TextStyle(fontWeight: FontWeight.bold))),
        ..._ezberListesi.map((p) => ListTile(leading: const Icon(Icons.menu_book_rounded),
          title: Text('$p. sayfa'), subtitle: Text('${HafizlikSira.cuzOf(p)}. Cüz'),
          trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pop(ctx, p))),
      ]));
    if (secim != null) _sayfayaGit(secim);
  }

  @override
  Widget build(BuildContext context) {
    final listede = _ezberListesi.contains(_sayfa);
    return Scaffold(
      appBar: AppBar(title: const Text('Ezber Atölyesi'), actions: [
        IconButton(tooltip: 'Ezber listem', onPressed: _ezberListesiniAc, icon: const Icon(Icons.bookmarks_outlined)),
        IconButton(tooltip: 'Sayfa seç', onPressed: _sayfaSec, icon: const Icon(Icons.search_rounded)),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Column(children: [
          Row(children: [
            IconButton(onPressed: _sayfa > 1 ? () => _sayfayaGit(_sayfa - 1) : null, icon: const Icon(Icons.chevron_left)),
            Expanded(child: InkWell(onTap: _sayfaSec, child: Column(children: [
              Text('$_sayfa. Sayfa', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text('${HafizlikSira.cuzOf(_sayfa)}. Cüz', style: const TextStyle(color: kIkincilMetin)),
            ]))),
            IconButton(onPressed: _sayfa < HafizlikSira.toplamSayfa ? () => _sayfayaGit(_sayfa + 1) : null, icon: const Icon(Icons.chevron_right)),
          ]),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ezber kontrol modu', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ChoiceChip(label: const Text('Metin'), selected: _gizleme == 0 && !_soluk, onSelected: (_) => setState(() { _gizleme = 0; _soluk = false; })),
              ChoiceChip(label: const Text('Soluk metin'), selected: _soluk, onSelected: (_) => setState(() { _soluk = true; _gizleme = 0; })),
              ChoiceChip(label: const Text('Ezberden'), selected: _gizleme == 4, onSelected: (_) => setState(() { _gizleme = 4; _soluk = false; })),
            ]),
            if (!_soluk) Row(children: [const Text('Gizleme'), Expanded(child: Slider(value: _gizleme.toDouble(), min: 0, max: 4, divisions: 4,
              label: _gizleme == 0 ? 'Kapalı' : '${_gizleme * 25}%', onChanged: (v) => setState(() => _gizleme = v.round()))), Text('${_gizleme * 25}%')]),
            Text(_soluk ? 'Metni soluk göstererek ezberden okumayı deneyin.' : 'Kelimelerin bir kısmını veya tamamını gizleyerek kendinizi sınayın.', style: const TextStyle(fontSize: 12, color: kIkincilMetin)),
          ]))),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _baslangicSonKontrolu, icon: const Icon(Icons.first_page_rounded), label: const Text('Başlangıç / Bitiş'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.tonalIcon(onPressed: _listeyeEkleCikar, icon: Icon(listede ? Icons.bookmark_remove : Icons.bookmark_add), label: Text(listede ? 'Listeden çıkar' : 'Ezber listeme ekle'))),
          ]),
        ])),
        Expanded(child: FutureBuilder<List<Ayet>>(future: _ayetFuture, builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Kur’an sayfası yüklenemedi.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty) return const Center(child: Text('Bu sayfada ayet bulunamadı.'));
          return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 20), child: MushafSayfaGorunumu(
            key: ValueKey('$_sayfa-$_gizleme-$_soluk'), ayetler: snap.data!, gizliSeviye: _gizleme,
            solukMod: _soluk));
        })),
        SesCubugu(key: ValueKey('ezber-ses-$_sayfa'), sayfaNo: _sayfa),
        if (_yukleniyor) const LinearProgressIndicator(minHeight: 2),
      ]),
    );
  }
}

class _KontrolAyet extends StatefulWidget {
  final String etiket;
  final Ayet ayet;
  const _KontrolAyet({required this.etiket, required this.ayet});
  @override
  State<_KontrolAyet> createState() => _KontrolAyetState();
}
class _KontrolAyetState extends State<_KontrolAyet> {
  bool _goster = false;
  @override
  Widget build(BuildContext context) => Card(color: Theme.of(context).cardColor,
    child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(widget.etiket, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text(_goster ? widget.ayet.metin : '••••••••••••••••', textDirection: TextDirection.rtl,
        textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Amiri', fontSize: 23, height: 1.8)),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setState(() => _goster = !_goster),
        child: Text(_goster ? 'Gizle' : 'Ayetin doğrusunu göster'))),
    ])));
}
