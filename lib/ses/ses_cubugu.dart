import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hafizlik/quran_veri.dart';
import '../ortak/ikonlar.dart';
import '../ortak/tema.dart';
import 'okuyucu.dart';
import 'sayfa_oynatici.dart';

/// Bir sayfanın ayetlerini sesli okutan çubuk.
/// Sayfa değiştiğinde yeni bir örnek oluşturulmalıdır (ValueKey ile).
class SesCubugu extends StatefulWidget {
  final int sayfaNo;

  const SesCubugu({super.key, required this.sayfaNo});

  @override
  State<SesCubugu> createState() => _SesCubuguState();
}

class _SesCubuguState extends State<SesCubugu> {
  final SayfaOynatici _oynatici = SayfaOynatici();
  Okuyucu _okuyucu = okuyucular.first;
  List<Ayet> _ayetler = [];
  bool _yuklendi = false;
  String? _hata;
  bool _tekrarAcik = false;
  double _hiz = 1.0;

  @override
  void initState() {
    super.initState();
    _hazirla();
  }

  @override
  void dispose() {
    _oynatici.kapat();
    super.dispose();
  }

  Future<void> _hazirla() async {
    final prefs = await SharedPreferences.getInstance();
    final dizin = prefs.getInt('okuyucu_dizin') ?? 0;
    final ayetler = await QuranVeri.sayfa(widget.sayfaNo);
    if (!mounted) return;
    setState(() {
      _okuyucu = okuyucular[dizin.clamp(0, okuyucular.length - 1).toInt()];
      _ayetler = ayetler;
    });
  }

  Future<void> _calVeyaDevamEt() async {
    setState(() => _hata = null);
    try {
      if (!_yuklendi) {
        await _oynatici.cal(_ayetler, _okuyucu);
        _yuklendi = true;
      } else {
        await _oynatici.oynatDurdur();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _hata = 'Ses çalınamadı. Bağlantıyı ve okuyucuyu kontrol edin.');
    }
  }

  Future<void> _okuyucuSec() async {
    final secilen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (c) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: kBosluk24),
        children: [
          for (var i = 0; i < okuyucular.length; i++)
            ListTile(
              title: Text(okuyucular[i].ad),
              trailing: okuyucular[i] == _okuyucu
                  ? const Icon(AppIkonlari.tamam, color: kYesil)
                  : null,
              onTap: () => Navigator.pop(c, i),
            ),
        ],
      ),
    );
    if (secilen == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('okuyucu_dizin', secilen);
    await _oynatici.durdur();
    _yuklendi = false;
    setState(() => _okuyucu = okuyucular[secilen]);
  }

  @override
  Widget build(BuildContext context) {
    final renk = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 6,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kBosluk12, kBosluk8, kBosluk12, kBosluk4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hata != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: kBosluk4),
                  child: Text(_hata!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              StreamBuilder<PlayerState>(
                stream: _oynatici.durum,
                builder: (context, durumSnap) {
                  final calisiyor = durumSnap.data?.playing ?? false;
                  return StreamBuilder<int?>(
                    stream: _oynatici.siraIndeksi,
                    builder: (context, siraSnap) {
                      final sira = siraSnap.data;
                      final etiket = (sira == null || sira >= _ayetler.length)
                          ? (_yuklendi ? 'Hazır' : 'Sayfayı sesli dinleyin')
                          : 'Ayet ${_ayetler[sira].numara} çalıyor';
                      return Row(
                        children: [
                          IconButton(
                            tooltip: 'Önceki ayet',
                            onPressed: _yuklendi ? _oynatici.onceki : null,
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          FilledButton(
                            onPressed: _ayetler.isEmpty ? null : _calVeyaDevamEt,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(calisiyor
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                          ),
                          IconButton(
                            tooltip: 'Sonraki ayet',
                            onPressed: _yuklendi ? _oynatici.sonraki : null,
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                          const SizedBox(width: kBosluk8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(etiket,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(_okuyucu.ad,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: renk.onSurface.withOpacity(0.6))),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Dinleme ayarları',
                            icon: Icon(Icons.tune_rounded, color: _tekrarAcik ? kYesil : null),
                            onSelected: (secim) async {
                              if (secim == 'tekrar') {
                                final yeni = !_tekrarAcik;
                                await _oynatici.tekrarModu(yeni);
                                if (mounted) setState(() => _tekrarAcik = yeni);
                              } else if (secim.startsWith('hiz:')) {
                                final hiz = double.tryParse(secim.substring(4));
                                if (hiz != null) {
                                  await _oynatici.hizAyarlama(hiz);
                                  if (mounted) setState(() => _hiz = hiz);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'tekrar', child: Text(_tekrarAcik ? '✓ Sayfa tekrarını kapat' : 'Sayfayı sürekli tekrar et')),
                              PopupMenuItem(value: 'hiz:0.75', child: Text(_hiz == 0.75 ? '✓ 0,75× yavaş' : '0,75× yavaş')),
                              PopupMenuItem(value: 'hiz:1.0', child: Text(_hiz == 1.0 ? '✓ 1,00× normal' : '1,00× normal')),
                              PopupMenuItem(value: 'hiz:1.25', child: Text(_hiz == 1.25 ? '✓ 1,25×' : '1,25×')),
                              PopupMenuItem(value: 'hiz:1.5', child: Text(_hiz == 1.5 ? '✓ 1,50× hızlı' : '1,50× hızlı')),
                            ],
                          ),
                          IconButton(
                            tooltip: 'Okuyucu seç',
                            onPressed: _okuyucuSec,
                            icon: const Icon(Icons.record_voice_over_rounded),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
