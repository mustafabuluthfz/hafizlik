import 'package:flutter/material.dart';
import '../bulmaca/sureler.dart';
import '../hafizlik/quran_veri.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import '../ses/okuyucu.dart';
import '../ses/sayfa_oynatici.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Namazda sık okunan kısa sureleri cihazdaki Kur'an metninden listeler.
class KisaSurelerEkrani extends StatefulWidget {
  const KisaSurelerEkrani({super.key});
  @override
  State<KisaSurelerEkrani> createState() => _KisaSurelerEkraniState();
}

class _KisaSurelerEkraniState extends State<KisaSurelerEkrani> {
  static const List<int> _sureNo = [1, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114];
  final _oynatici = SayfaOynatici();
  int _okuyucu = 0;
  int? _calanSure;
  bool _yukleniyor = false;

  @override
  void initState() { super.initState(); _okuyucuyuYukle(); }
  Future<void> _okuyucuyuYukle() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _okuyucu = (p.getInt('okuyucu_dizin') ?? 0).clamp(0, okuyucular.length - 1).toInt());
  }
  @override
  void dispose() { _oynatici.kapat(); super.dispose(); }

  Future<void> _dinle(int no) async {
    if (_yukleniyor) return;
    setState(() { _yukleniyor = true; _calanSure = no; });
    try {
      final ayetler = await QuranVeri.tumAyetler();
      final secilen = ayetler.where((a) => a.sure == no).toList();
      await _oynatici.cal(secilen, okuyucular[_okuyucu]);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ses başlatılamadı. Seçili okuyucunun ses dosyasını indirin veya bağlantıyı kontrol edin.')));
    } finally { if (mounted) setState(() => _yukleniyor = false); }
  }

  @override
  Widget build(BuildContext context) {
    final liste = sureler.where((s) => _sureNo.contains(s.no)).toList()
      ..sort((a,b) => a.no.compareTo(b.no));
    return Scaffold(
      appBar: AppBar(title: const Text('Kısa Sureler')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Text('Namazlarda sık okunan kısa sureleri ezberleyin, metnini inceleyin ve seçtiğiniz kârîden dinleyin. Ses dosyaları indirilerek çevrimdışı kullanılabilir.', style: Theme.of(context).textTheme.bodyMedium))),
        const SizedBox(height: 8),
        for (final s in liste) Card(child: ListTile(
          leading: CircleAvatar(backgroundColor: kYesil.withOpacity(.12), child: Text('${s.no}', style: const TextStyle(color: kYesil))),
          title: Text(s.trAd, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${s.ayetSayisi} ayet · ${s.trAnlam}'),
          trailing: IconButton(tooltip: 'Sureyi sesli dinle', icon: Icon(_calanSure == s.no ? Icons.volume_up : Icons.play_circle_outline), onPressed: () => _dinle(s.no)),
          onTap: () async {
            final ayetler = (await QuranVeri.tumAyetler()).where((a) => a.sure == s.no).toList();
            if (!context.mounted || ayetler.isEmpty) return;
            showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (c) => DraggableScrollableSheet(expand: false, builder: (_, sc) => ListView(controller: sc, padding: const EdgeInsets.all(16), children: [Text('${s.trAd} · ${s.ad}', style: Theme.of(c).textTheme.titleLarge), const SizedBox(height: 12), Container(color: kKagitRengi, padding: const EdgeInsets.all(16), child: Text(ayetler.map((a) => '${a.metin} ۝${a.numara}').join(' '), textDirection: TextDirection.rtl, textAlign: TextAlign.justify, style: const TextStyle(fontFamily: kMushafFontu, fontSize: 25, height: 2))), const SizedBox(height: 12), FilledButton.icon(onPressed: () { Navigator.pop(c); _dinle(s.no); }, icon: const Icon(Icons.play_arrow), label: const Text('Sureyi dinle'))])));
          },
        )),
      ]),
    );
  }
}
