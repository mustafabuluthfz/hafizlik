import 'dart:async';

import 'package:flutter/material.dart';
import 'vakit_widget_veri.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bildirim/bildirim_servisi.dart';
import '../konum/konum_servisi.dart';
import '../ortak/tema.dart';
import 'vakit_hesap.dart';
import '../ortak/ikonlar.dart';

class NamazEkrani extends StatefulWidget {
  const NamazEkrani({super.key});

  @override
  State<NamazEkrani> createState() => _NamazEkraniState();
}

class _NamazEkraniState extends State<NamazEkrani> {
  bool _yukleniyor = true;
  String? _hata;
  KonumBilgisi? _konum;
  Map<String, DateTime> _vakitler = {};

  bool _namazBildirim = false;
  bool _hatirlatmaAcik = false;
  TimeOfDay _hatirlatmaSaati = const TimeOfDay(hour: 20, minute: 0);

  Timer? _sayac;

  @override
  void initState() {
    super.initState();
    _ayarlariYukle();
    _konumAl();
    _sayac = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  double get _saatDilimi => DateTime.now().timeZoneOffset.inMinutes / 60.0;

  Future<void> _ayarlariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _namazBildirim = prefs.getBool('bildirim_namaz') ?? false;
      _hatirlatmaAcik = prefs.getBool('bildirim_hatirlatma') ?? false;
      _hatirlatmaSaati = TimeOfDay(
        hour: prefs.getInt('hatirlatma_saat') ?? 20,
        minute: prefs.getInt('hatirlatma_dakika') ?? 0,
      );
    });
  }

  Future<void> _konumAl() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    final konum = await KonumServisi.al();
    if (!mounted) return;
    if (konum == null) {
      setState(() {
        _hata = 'Konum alınamadı. Konum iznini verip tekrar deneyin.';
        _yukleniyor = false;
      });
      return;
    }
    _konum = konum;
    _vakitler = VakitHesap.gunVakitleri(
        DateTime.now(), konum.enlem, konum.boylam, _saatDilimi);
    vakitWidgetVerisiYaz(_vakitler);
    setState(() => _yukleniyor = false);
    await _planla();
  }

  Future<void> _planla() async {
    final konum = _konum;
    final liste = <MapEntry<String, DateTime>>[];
    if (konum != null && _namazBildirim) {
      final simdi = DateTime.now();
      for (var g = 0; g < 7; g++) {
        final gun = simdi.add(Duration(days: g));
        final v = VakitHesap.gunVakitleri(
            gun, konum.enlem, konum.boylam, _saatDilimi);
        for (final e in v.entries) {
          liste.add(MapEntry(e.key, e.value));
        }
      }
    }
    await BildirimServisi.planla(
      namazVakitleri: liste,
      hatirlatma: _hatirlatmaAcik ? _hatirlatmaSaati : null,
    );
  }

  Future<void> _namazBildirimDegistir(bool v) async {
    if (v) await BildirimServisi.izinIste();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bildirim_namaz', v);
    setState(() => _namazBildirim = v);
    await _planla();
  }

  Future<void> _hatirlatmaDegistir(bool v) async {
    if (v) await BildirimServisi.izinIste();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bildirim_hatirlatma', v);
    setState(() => _hatirlatmaAcik = v);
    await _planla();
  }

  Future<void> _saatSec() async {
    final secilen =
        await showTimePicker(context: context, initialTime: _hatirlatmaSaati);
    if (secilen == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hatirlatma_saat', secilen.hour);
    await prefs.setInt('hatirlatma_dakika', secilen.minute);
    setState(() => _hatirlatmaSaati = secilen);
    await _planla();
  }

  String _saat(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Sıradaki vakit ve kalan süre.
  (String, DateTime)? _sonraki() {
    final simdi = DateTime.now();
    for (final e in _vakitler.entries) {
      if (e.value.isAfter(simdi)) return (e.key, e.value);
    }
    final konum = _konum;
    if (konum == null) return null;
    final yarin = VakitHesap.gunVakitleri(
        simdi.add(const Duration(days: 1)), konum.enlem, konum.boylam, _saatDilimi);
    if (yarin.isEmpty) return null;
    final ilk = yarin.entries.first;
    return (ilk.key, ilk.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Vakitleri'),
        actions: [
          IconButton(
            tooltip: 'Konumu güncelle',
            icon: const Icon(AppIkonlari.konum),
            onPressed: _konumAl,
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_hata!, textAlign: TextAlign.center),
                  ),
                )
              : _icerik(),
    );
  }

  Widget _icerik() {
    final sonraki = _sonraki();
    final kalan = sonraki == null ? null : sonraki.$2.difference(DateTime.now());
    final kalanMetin = kalan == null
        ? ''
        : '${kalan.inHours} sa ${kalan.inMinutes.remainder(60)} dk kaldı';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text('Sıradaki vakit',
                    style: TextStyle(color: kMetin, fontSize: 13)),
                const SizedBox(height: 4),
                Text(sonraki?.$1 ?? '-',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, color: kYesil)),
                Text(sonraki == null ? '' : '${_saat(sonraki.$2)} · $kalanMetin',
                    style: TextStyle(color: Colors.brown.shade700)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final e in _vakitler.entries)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: sonraki?.$1 == e.key ? kAltinAcik.withOpacity(0.45) : null,
            child: ListTile(
              leading: const Icon(Icons.access_time_rounded, color: kYesil),
              title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text(_saat(e.value),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: kMetin)),
            ),
          ),
        const SizedBox(height: 16),
        const Text('Bildirimler',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kMetin)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_rounded, color: kYesil),
                title: const Text('Namaz vakti bildirimleri'),
                subtitle: const Text('Her vakit girdiğinde haber verir'),
                value: _namazBildirim,
                onChanged: _namazBildirimDegistir,
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(AppIkonlari.sayfa, color: kYesil),
                title: const Text('Günlük okuma hatırlatması'),
                subtitle: Text('Her gün ${_hatirlatmaSaati.format(context)}'),
                value: _hatirlatmaAcik,
                onChanged: _hatirlatmaDegistir,
              ),
              if (_hatirlatmaAcik) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule_rounded, color: kYesil),
                  title: const Text('Hatırlatma saati'),
                  trailing: Text(_hatirlatmaSaati.format(context)),
                  onTap: _saatSec,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Vakitler konumunuza göre cihazda hesaplanır, internet gerekmez.',
          style: TextStyle(fontSize: 12, color: Colors.brown.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
