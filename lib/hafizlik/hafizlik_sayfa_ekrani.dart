import 'package:flutter/material.dart';

import '../ortak/ilerleme_depo.dart';
import '../ses/ses_cubugu.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import 'bugunku_sayfa.dart';
import 'hafizlik_sira.dart';
import 'quran_veri.dart';
import '../ortak/ikonlar.dart';

class HafizlikSayfaEkrani extends StatefulWidget {
  const HafizlikSayfaEkrani({super.key});

  @override
  State<HafizlikSayfaEkrani> createState() => _HafizlikSayfaEkraniState();
}

class _HafizlikSayfaEkraniState extends State<HafizlikSayfaEkrani> {
  bool _yukleniyor = true;
  String? _hata;
  int? _sayfa;
  List<Ayet> _ayetler = [];
  bool _okundu = false;
  bool _harekesizMod = false;
  int _gizliSeviye = 0;
  int _seri = 0;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      final sayfa = await bugunkuSayfaNo();
      final ayetler = await QuranVeri.sayfa(sayfa);
      final gunler = await IlerlemeDepo.gunler();
      final bugun = DateTime.now();

      if (!mounted) return;
      setState(() {
        _sayfa = sayfa;
        _ayetler = ayetler;
        _okundu = gunler.contains(IlerlemeDepo.gunAnahtari(bugun));
        _seri = IlerlemeDepo.seri(gunler, bugun);
        _yukleniyor = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hata = 'Sayfa yüklenemedi. Uygulamayı yeniden başlatıp tekrar deneyin.';
        _yukleniyor = false;
      });
    }
  }

  Future<void> _okunduDegistir() async {
    final yeni = !_okundu;
    await IlerlemeDepo.gunuIsaretle(DateTime.now(), yeni);
    await _yukle();
    if (!mounted) return;
    if (yeni) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Maşallah! Seriniz: $_seri gün'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugünkü Sayfa'),
        actions: [
          if (!_yukleniyor && _hata == null) ...[
            IconButton(
              tooltip: 'Harekesiz okuma',
              icon: Icon(_harekesizMod
                  ? Icons.text_fields_rounded
                  : Icons.format_size_rounded),
              onPressed: () => setState(() => _harekesizMod = !_harekesizMod),
            ),
            PopupMenuButton<int>(
              tooltip: 'Ezber testi: kelime gizleme',
              icon: Icon(_gizliSeviye == 0
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded),
              onSelected: (v) => setState(() => _gizliSeviye = v),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 0, child: Text('Gizleme kapalı')),
                PopupMenuItem(value: 1, child: Text('%25 gizle')),
                PopupMenuItem(value: 2, child: Text('%50 gizle')),
                PopupMenuItem(value: 3, child: Text('%75 gizle')),
                PopupMenuItem(value: 4, child: Text('Tümünü gizle')),
              ],
            ),
          ],
        ],
      ),
      body: _govde(),
      bottomNavigationBar: (!_yukleniyor && _hata == null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SesCubugu(key: ValueKey('ses-$_sayfa'), sayfaNo: _sayfa!),
                SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: FilledButton.icon(
                  onPressed: _okunduDegistir,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: _okundu ? kAltin : null,
                  ),
                  icon: Icon(_okundu
                      ? AppIkonlari.tamam
                      : AppIkonlari.tamamDegil),
                  label: Text(_okundu
                      ? 'Bugün okundu · Seri: $_seri gün'
                      : 'Bugünkü sayfayı okudum'),
                ),
              ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _govde() {
    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_hata!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _yukle, child: const Text('Tekrar dene')),
            ],
          ),
        ),
      );
    }

    final sayfa = _sayfa!;
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cüz ${HafizlikSira.cuzOf(sayfa)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Sayfa $sayfa / ${HafizlikSira.toplamSayfa}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, kisit) => InteractiveViewer(
              constrained: false,
              minScale: 1,
              maxScale: 4,
              child: SizedBox(
                width: kisit.maxWidth,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  child: MushafSayfaGorunumu(
                  key: ValueKey('$_gizliSeviye-$_harekesizMod-$sayfa'),
                  ayetler: _ayetler,
                  harekesizMod: _harekesizMod,
                  gizliSeviye: _gizliSeviye,
                ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
