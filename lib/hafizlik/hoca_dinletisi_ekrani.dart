import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bulmaca/sureler.dart';
import '../ses/okuyucu.dart';
import 'quran_veri.dart';

/// Öğrencinin seçtiği sure/ayet aralığını belirlenen sayıda tekrar dinlemesi.
/// Ses akışı ücretsiz EveryAyah kataloğundan gelir; internet gerekir.
class HocaDinletisiEkrani extends StatefulWidget {
  const HocaDinletisiEkrani({super.key});
  @override
  State<HocaDinletisiEkrani> createState() => _HocaDinletisiEkraniState();
}

class _HocaDinletisiEkraniState extends State<HocaDinletisiEkrani> {
  final AudioPlayer _player = AudioPlayer();
  int _sure = 1, _baslangic = 1, _bitis = 7, _tekrar = 3, _okuyucuIndex = 0;
  List<Ayet> _ayetler = [];
  bool _yukleniyor = true, _calisiyor = false, _duraklatildi = false;
  int _aktifAyet = 0, _aktifTekrar = 0;
  String? _hata;

  @override
  void initState() { super.initState(); _ayarYukle(); }

  Future<void> _ayarYukle() async {
    final p = await SharedPreferences.getInstance();
    _okuyucuIndex = (p.getInt('okuyucu_dizin') ?? 0).clamp(0, okuyucular.length - 1);
    await _sureYukle(_sure);
  }

  Future<void> _sureYukle(int no) async {
    setState(() { _yukleniyor = true; _sure = no; _hata = null; });
    try {
      final tum = await QuranVeri.tumAyetler();
      final liste = tum.where((a) => a.sure == no).toList();
      if (!mounted) return;
      setState(() { _ayetler = liste; _baslangic = 1; _bitis = liste.length; _yukleniyor = false; });
    } catch (_) { if (mounted) setState(() { _hata = 'Sure verileri yüklenemedi.'; _yukleniyor = false; }); }
  }

  Future<void> _baslat() async {
    if (_ayetler.isEmpty || _calisiyor) return;
    setState(() { _calisiyor = true; _duraklatildi = false; _aktifAyet = _baslangic; _aktifTekrar = 0; _hata = null; });
    try {
      for (var no = _baslangic; no <= _bitis && _calisiyor; no++) {
        for (var tekrar = 1; tekrar <= _tekrar && _calisiyor; tekrar++) {
          if (!mounted) return;
          setState(() { _aktifAyet = no; _aktifTekrar = tekrar; });
          final ayet = _ayetler.firstWhere((a) => a.numara == no);
          await _player.setUrl(ayetSesAdresi(okuyucular[_okuyucuIndex], ayet.sure, ayet.numara));
          final tamam = _player.playerStateStream.firstWhere((s) => s.processingState == ProcessingState.completed || !_calisiyor);
          await _player.play();
          await tamam;
          while (_duraklatildi && _calisiyor) { await Future<void>.delayed(const Duration(milliseconds: 150)); }
        }
      }
    } catch (_) { _hata = 'Ses açılamadı. İnternet bağlantısını veya seçilen okuyucuyu kontrol edin.'; }
    finally { if (mounted) setState(() { _calisiyor = false; _duraklatildi = false; }); }
  }

  Future<void> _okuyucuSec(int? index) async {
    if (index == null) return;
    final p = await SharedPreferences.getInstance();
    await p.setInt('okuyucu_dizin', index);
    if (mounted) setState(() => _okuyucuIndex = index);
  }

  Future<void> _durdur() async { setState(() { _calisiyor = false; _duraklatildi = false; }); await _player.stop(); }
  Future<void> _duraklatDevam() async {
    if (!_calisiyor) { await _baslat(); return; }
    if (_duraklatildi) { setState(() => _duraklatildi = false); await _player.play(); }
    else { setState(() => _duraklatildi = true); await _player.pause(); }
  }

  @override
  void dispose() { _calisiyor = false; _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sure = sureler[_sure - 1];
    return Scaffold(appBar: AppBar(title: const Text('Hoca Dinletisi')),
      body: _yukleniyor ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tekrar çalışması', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6), const Text('Bir sure veya ayet aralığı seçin; okuyucu her ayeti belirlediğiniz sayıda tekrar etsin.'),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(value: _sure, decoration: const InputDecoration(labelText: 'Sure'), items: [for (final s in sureler) DropdownMenuItem(value: s.no, child: Text('${s.no}. ${s.trAd}'))], onChanged: _calisiyor ? null : (v) { if (v != null) _sureYukle(v); }),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(value: _baslangic.clamp(1, _ayetler.length).toInt(), decoration: const InputDecoration(labelText: 'Başlangıç ayeti'), items: [for (var i = 1; i <= _ayetler.length; i++) DropdownMenuItem(value: i, child: Text('$i. ayet'))], onChanged: _calisiyor ? null : (v) => setState(() { _baslangic = v ?? 1; if (_bitis < _baslangic) _bitis = _baslangic; })),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(value: _bitis.clamp(_baslangic, _ayetler.length).toInt(), decoration: const InputDecoration(labelText: 'Bitiş ayeti'), items: [for (var i = _baslangic; i <= _ayetler.length; i++) DropdownMenuItem(value: i, child: Text('$i. ayet'))], onChanged: _calisiyor ? null : (v) => setState(() => _bitis = v ?? _baslangic)),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(value: _tekrar, decoration: const InputDecoration(labelText: 'Her ayet kaç kez tekrar edilsin?'), items: const [1, 2, 3, 5, 10].map((n) => DropdownMenuItem(value: n, child: Text('$n kez'))).toList(), onChanged: _calisiyor ? null : (v) => setState(() => _tekrar = v ?? 3)),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(value: _okuyucuIndex, isExpanded: true, decoration: const InputDecoration(labelText: 'Kur’an okuyucusu'), items: [for (var i = 0; i < okuyucular.length; i++) DropdownMenuItem(value: i, child: Text(okuyucular[i].ad, overflow: TextOverflow.ellipsis))], onChanged: _calisiyor ? null : _okuyucuSec),
        ]))),
        if (_calisiyor) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Text('${sure.trAd} · $_aktifAyet. ayet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Tekrar $_aktifTekrar / $_tekrar'),
          const SizedBox(height: 8), LinearProgressIndicator(value: _bitis == _baslangic ? 1 : (_aktifAyet - _baslangic + 1) / (_bitis - _baslangic + 1)),
        ]))),
        if (_hata != null) Padding(padding: const EdgeInsets.all(8), child: Text(_hata!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: FilledButton.icon(onPressed: _calisiyor ? _duraklatDevam : _baslat, icon: Icon(_calisiyor && !_duraklatildi ? Icons.pause : Icons.play_arrow), label: Text(_calisiyor ? (_duraklatildi ? 'Devam et' : 'Duraklat') : 'Dinletiyi başlat'))), const SizedBox(width: 10), OutlinedButton.icon(onPressed: _calisiyor ? _durdur : null, icon: const Icon(Icons.stop), label: const Text('Durdur'))]),
        const SizedBox(height: 12), const Text('Not: Sesler ücretsiz çevrimiçi akış olarak sunulur. Dinlemek için internet bağlantısı gerekir; okuyucuların kayıtları uygulamaya gömülü değildir.', style: TextStyle(fontSize: 12)),
      ]));
  }
}
