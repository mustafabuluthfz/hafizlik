import 'package:flutter/material.dart';

import '../bulmaca/sureler.dart';
import '../hafizlik/hafizlik_sira.dart';
import '../hafizlik/quran_veri.dart';
import '../ortak/ilerleme_depo.dart';
import '../ortak/mushaf.dart';
import '../ses/ses_cubugu.dart';
import '../ortak/tema.dart';
import '../ortak/ikonlar.dart';

/// Tüm Kur'an'ı mushaf sayfa sayfa okutur.
/// - İki parmakla sayfayı büyütüp küçültebilir, büyütünce kaydırabilirsiniz.
/// - Sayfalar "Sonraki" ve "Önceki" düğmeleriyle çevrilir.
/// - Üstteki simgeden cüz, sure veya sayfa seçilebilir.
class KuranOkumaEkrani extends StatefulWidget {
  final int? baslangicSayfa;

  const KuranOkumaEkrani({super.key, this.baslangicSayfa});

  @override
  State<KuranOkumaEkrani> createState() => _KuranOkumaEkraniState();
}

class _KuranOkumaEkraniState extends State<KuranOkumaEkrani> {
  late int _sayfa;
  late final PageController _kontrol;

  static int _sinirla(int v) {
    if (v < 1) return 1;
    if (v > HafizlikSira.toplamSayfa) return HafizlikSira.toplamSayfa;
    return v;
  }

  @override
  void initState() {
    super.initState();
    _sayfa = _sinirla(widget.baslangicSayfa ?? 1);
    _kontrol = PageController(initialPage: _sayfa - 1);
    IlerlemeDepo.kuranAcildi();
    if (widget.baslangicSayfa == null) _sonKalinanaGit();
  }

  /// Açılışta son kalınan sayfaya git.
  Future<void> _sonKalinanaGit() async {
    final son = await OkumaKaydi.sonSayfa();
    if (son == null || son == _sayfa || !mounted) return;
    _git(son);
  }

  Future<void> _yerImiDegistir() async {
    final eklendi = await OkumaKaydi.yerImiDegistir(_sayfa);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(eklendi
          ? 'Sayfa $_sayfa yer imlerine eklendi'
          : 'Yer imi kaldırıldı'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _yerImleriniAc() async {
    final liste = await OkumaKaydi.yerImleri();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        if (liste.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Henüz yer imi yok. Üstteki yer imi simgesiyle ekleyebilirsiniz.'),
          );
        }
        return ListView(
          shrinkWrap: true,
          children: [
            for (final p in liste)
              ListTile(
                leading: const Icon(AppIkonlari.yerImi, color: kAltin),
                title: Text('Sayfa $p'),
                subtitle: Text('${HafizlikSira.cuzOf(p)}. Cüz'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _git(p);
                },
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  void _git(int sayfa) {
    final hedef = _sinirla(sayfa);
    setState(() => _sayfa = hedef);
    if (_kontrol.hasClients) {
      _kontrol.jumpToPage(hedef - 1);
    }
    OkumaKaydi.sonSayfaKaydet(hedef);
  }

  Future<void> _seciciyiAc() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _GitPaneli(
        mevcutSayfa: _sayfa,
        onGit: (sayfa) {
          Navigator.of(sheetContext).pop();
          _git(sayfa);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sayfa $_sayfa / ${HafizlikSira.toplamSayfa}'),
        actions: [
          IconButton(
            tooltip: 'Yer imlerim',
            icon: const Icon(Icons.bookmarks_rounded),
            onPressed: _yerImleriniAc,
          ),
          IconButton(
            tooltip: 'Bu sayfaya yer imi ekle',
            icon: const Icon(Icons.bookmark_add_rounded),
            onPressed: _yerImiDegistir,
          ),
          IconButton(
            tooltip: 'Cüz, sure veya sayfa seç',
            icon: const Icon(Icons.search),
            onPressed: _seciciyiAc,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: kKagitRengi,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${HafizlikSira.cuzOf(_sayfa)}. Cüz',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('İki parmakla büyütüp küçültebilirsiniz',
                    style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _kontrol,
              reverse: true,
              // Sayfa değişimi düğmelerle; parmakla kaydırma sayfa içi büyütme/kaydırma için.
              physics: const NeverScrollableScrollPhysics(),
              itemCount: HafizlikSira.toplamSayfa,
              onPageChanged: (i) => setState(() => _sayfa = i + 1),
              itemBuilder: (context, i) => _SayfaIcerigi(sayfa: i + 1),
            ),
          ),
          SesCubugu(key: ValueKey('ses-$_sayfa'), sayfaNo: _sayfa),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sayfa < HafizlikSira.toplamSayfa
                          ? () => _git(_sayfa + 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Sonraki'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sayfa > 1 ? () => _git(_sayfa - 1) : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Önceki'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SayfaIcerigi extends StatefulWidget {
  final int sayfa;

  const _SayfaIcerigi({required this.sayfa});

  @override
  State<_SayfaIcerigi> createState() => _SayfaIcerigiState();
}

class _SayfaIcerigiState extends State<_SayfaIcerigi> {
  late final Future<List<Ayet>> _veri;

  @override
  void initState() {
    super.initState();
    _veri = QuranVeri.sayfa(widget.sayfa);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ayet>>(
      future: _veri,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Sayfa yüklenemedi.'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, kisit) => InteractiveViewer(
            // Sayfa genişliği ekran kadar; yükseklik içeriğe göre.
            constrained: false,
            minScale: 1,
            maxScale: 4,
            child: SizedBox(
              width: kisit.maxWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: MushafSayfaGorunumu(ayetler: snap.data!),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Cüz, sure veya sayfa numarası ile gidilecek yeri seçme paneli.
class _GitPaneli extends StatefulWidget {
  final int mevcutSayfa;
  final void Function(int sayfa) onGit;

  const _GitPaneli({required this.mevcutSayfa, required this.onGit});

  @override
  State<_GitPaneli> createState() => _GitPaneliState();
}

class _GitPaneliState extends State<_GitPaneli> {
  late final TextEditingController _sayfaKontrol;

  @override
  void initState() {
    super.initState();
    _sayfaKontrol = TextEditingController(text: '${widget.mevcutSayfa}');
  }

  @override
  void dispose() {
    _sayfaKontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Cüz',
              border: OutlineInputBorder(),
            ),
            items: [
              for (var c = 1; c <= 30; c++)
                DropdownMenuItem(value: c, child: Text('$c. Cüz')),
            ],
            onChanged: (c) {
              if (c != null) widget.onGit(HafizlikSira.cuzBaslangici(c));
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Sure',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final s in sureler)
                DropdownMenuItem(
                  value: s.no,
                  child: Text(
                    '${s.no}. ${s.trAd} (${s.okunus})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (no) async {
              if (no == null) return;
              final sayfa = await QuranVeri.sureninIlkSayfasi(no);
              widget.onGit(sayfa);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sayfaKontrol,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sayfa (1-604)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () {
                  final s = int.tryParse(_sayfaKontrol.text.trim());
                  if (s != null) widget.onGit(s);
                },
                child: const Text('Git'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
