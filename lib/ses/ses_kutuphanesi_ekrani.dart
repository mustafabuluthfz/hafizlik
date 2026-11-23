import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bulmaca/sureler.dart';
import '../ortak/bilesenler.dart';
import '../ortak/ikonlar.dart';
import '../ortak/tema.dart';
import 'indirme_yoneticisi.dart';
import 'okuyucu.dart';

/// Ses kütüphanesi: okuyucu seçimi, sure bazında indirme, silme ve kullanılan alan.
class SesKutuphanesiEkrani extends StatefulWidget {
  const SesKutuphanesiEkrani({super.key});

  @override
  State<SesKutuphanesiEkrani> createState() => _SesKutuphanesiEkraniState();
}

class _SesKutuphanesiEkraniState extends State<SesKutuphanesiEkrani> {
  bool _yukleniyor = true;
  int _dizin = 0;
  Map<int, bool> _indirildi = {};
  int _boyut = 0;
  final Map<int, double> _ilerleme = {};
  int? _aktifSure;
  bool _iptal = false;

  Okuyucu get _okuyucu => okuyucular[_dizin];

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    final prefs = await SharedPreferences.getInstance();
    _dizin = prefs.getInt('okuyucu_dizin') ?? 0;
    final indirildi = <int, bool>{};
    for (var s = 1; s <= 114; s++) {
      indirildi[s] = await IndirmeYoneticisi.sureIndirildiMi(_okuyucu, s);
    }
    final boyut = await IndirmeYoneticisi.toplamBoyut();
    if (!mounted) return;
    setState(() {
      _indirildi = indirildi;
      _boyut = boyut;
      _yukleniyor = false;
    });
  }

  Future<void> _okuyucuSec(int dizin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('okuyucu_dizin', dizin);
    _dizin = dizin;
    await _yukle();
  }

  Future<void> _indir(int sure) async {
    if (_aktifSure != null) return;
    setState(() {
      _aktifSure = sure;
      _ilerleme[sure] = 0;
      _iptal = false;
    });
    try {
      await IndirmeYoneticisi.sureIndir(
        _okuyucu,
        sure,
        ilerleme: (oran) {
          if (mounted) setState(() => _ilerleme[sure] = oran);
        },
        iptalMi: () => _iptal,
      );
      _indirildi[sure] = true;
    } on IptalEdildi {
      // Kullanıcı iptal etti; kısmi dosyalar sonraki denemede atlanır.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      _ilerleme.remove(sure);
      _aktifSure = null;
      if (mounted) {
        setState(() {});
        _boyut = await IndirmeYoneticisi.toplamBoyut();
        setState(() {});
      }
    }
  }

  Future<void> _tumunuIndir() async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tüm sureler indirilsin mi?'),
        content: const Text(
            'Tüm Kur\'an sesi yaklaşık birkaç yüz MB yer kaplar ve uzun sürebilir. '
            'Wi-Fi bağlantısında indirmeniz önerilir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('İndir')),
        ],
      ),
    );
    if (onay != true) return;
    for (var s = 1; s <= 114 && mounted; s++) {
      if (_indirildi[s] == true) continue;
      await _indir(s);
      if (_iptal) break;
    }
  }

  Future<void> _sil(int sure) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('${sureler[sure - 1].trAd} silinsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sil')),
        ],
      ),
    );
    if (onay != true) return;
    await IndirmeYoneticisi.sureSil(_okuyucu, sure);
    _indirildi[sure] = false;
    _boyut = await IndirmeYoneticisi.toplamBoyut();
    if (mounted) setState(() {});
  }

  String _mb(int bayt) => '${(bayt / (1024 * 1024)).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final izinVar = _okuyucu.indirmeIzniVar;
    final indirilenSayi = _indirildi.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses kütüphanesi'),
        actions: [
          IconButton(
            tooltip: 'Tüm sureleri indir',
            onPressed: (!izinVar || _aktifSure != null) ? null : _tumunuIndir,
            icon: const Icon(AppIkonlari.sayfa),
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(kBosluk16),
              children: [
                DropdownButtonFormField<int>(
                  value: _dizin,
                  decoration: const InputDecoration(labelText: 'Okuyucu'),
                  items: [
                    for (var i = 0; i < okuyucular.length; i++)
                      DropdownMenuItem(value: i, child: Text(okuyucular[i].ad)),
                  ],
                  onChanged: _aktifSure != null ? null : (v) => _okuyucuSec(v ?? 0),
                ),
                const SizedBox(height: kBosluk12),
                AppCard(
                  child: Row(
                    children: [
                      const Icon(AppIkonlari.indir, color: kYesil),
                      const SizedBox(width: kBosluk12),
                      Expanded(
                        child: Text('$indirilenSayi / 114 sure indirildi · ${_mb(_boyut)} kullanılıyor'),
                      ),
                    ],
                  ),
                ),
                if (!izinVar) ...[
                  const SizedBox(height: kBosluk12),
                  AppCard(
                    child: Text(
                      'Bu okuyucunun kaydını indirme izni henüz tanımlanmadı. '
                      'İzin alındığında indirme açılır; şimdilik sesler internetten çalınır.',
                      style: TextStyle(color: Colors.brown.shade700),
                    ),
                  ),
                ],
                const SizedBox(height: kBosluk16),
                const BolumBasligi('Sureler'),
                for (var s = 1; s <= 114; s++) _sureSatiri(s, izinVar),
              ],
            ),
    );
  }

  Widget _sureSatiri(int s, bool izinVar) {
    final sure = sureler[s - 1];
    final indirildi = _indirildi[s] == true;
    final oran = _ilerleme[s];
    Widget sag;
    if (oran != null) {
      sag = Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(value: oran, strokeWidth: 2.5),
        ),
        IconButton(
          tooltip: 'İptal',
          onPressed: () => setState(() => _iptal = true),
          icon: const Icon(Icons.close_rounded),
        ),
      ]);
    } else if (indirildi) {
      sag = Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(AppIkonlari.tamam, color: kYesil),
        IconButton(
          tooltip: 'Sil',
          onPressed: () => _sil(s),
          icon: const Icon(AppIkonlari.sil),
        ),
      ]);
    } else {
      sag = IconButton(
        tooltip: izinVar ? 'İndir' : 'İzin bekleniyor',
        onPressed: (!izinVar || _aktifSure != null) ? null : () => _indir(s),
        icon: const Icon(AppIkonlari.indir),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: kBosluk8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: kAltinAcik.withOpacity(0.5),
          child: Text('$s', style: const TextStyle(fontSize: 12, color: kYesil)),
        ),
        title: Text(sure.trAd),
        subtitle: Text('${sure.ayetSayisi} ayet'),
        trailing: sag,
      ),
    );
  }
}
