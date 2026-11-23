import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../hafizlik/quran_veri.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import 'gelismis_hifz_sinavi_ekrani.dart';

class HifzimiTestEtEkrani extends StatefulWidget {
  const HifzimiTestEtEkrani({super.key});
  @override
  State<HifzimiTestEtEkrani> createState() => _HifzimiTestEtEkraniState();
}

class _Soru { final Ayet once; final Ayet dogru; final List<Ayet> secenekler; const _Soru(this.once,this.dogru,this.secenekler); }

class _HifzimiTestEtEkraniState extends State<HifzimiTestEtEkrani> {
  final _r = Random();
  List<Ayet> _ayetler = [];
  _Soru? _soru;
  int _dogru = 0, _yanlis = 0, _soruNo = 0;
  bool _yukleniyor = true;
  int? _secim;
  bool _cevaplandi = false;
  bool _oturumBitti = false;
  static const int _oturumSoruSayisi = 6;

  @override
  void initState() { super.initState(); _hazirla(); }
  Future<void> _hazirla() async {
    try { _ayetler = await QuranVeri.tumAyetler(); _yeniSoru(); }
    finally { if (mounted) setState(() => _yukleniyor = false); }
  }
  void _yeniSoru() {
    if (_ayetler.isEmpty) return;
    final baslangiclar = <int>[];
    for (var i=0;i<_ayetler.length-1;i++) { if (_ayetler[i].sure == _ayetler[i+1].sure && _ayetler[i+1].numara == _ayetler[i].numara+1) baslangiclar.add(i); }
    if (baslangiclar.isEmpty) return;
    final i = baslangiclar[_r.nextInt(baslangiclar.length)];
    final dogru = _ayetler[i+1];
    final yanlislar = <Ayet>{};
    while (yanlislar.length < 3) { final a = _ayetler[_r.nextInt(_ayetler.length)]; if (a.sure != dogru.sure || a.numara != dogru.numara) yanlislar.add(a); }
    final secenekler = [dogru, ...yanlislar]..shuffle(_r);
    _soru = _Soru(_ayetler[i], dogru, secenekler);
    _secim = null; _cevaplandi = false; _soruNo++;
  }
  void _cevapla(int i) {
    if (_cevaplandi || _oturumBitti) return;
    setState(() {
      _secim=i; _cevaplandi=true;
      if (_soru!.secenekler[i].sure == _soru!.dogru.sure && _soru!.secenekler[i].numara == _soru!.dogru.numara) _dogru++; else _yanlis++;
      if (_soruNo >= _oturumSoruSayisi) _oturumBitti = true;
    });
    if (_oturumBitti) _gecmiseKaydet();
  }
  Future<void> _gecmiseKaydet() async {
    final p = await SharedPreferences.getInstance();
    final gecmis = p.getStringList('hifiz_test_gecmisi') ?? <String>[];
    gecmis.insert(0, '${DateTime.now().toIso8601String()}|$_dogru|$_yanlis');
    if (gecmis.length > 30) gecmis.removeRange(30, gecmis.length);
    await p.setStringList('hifiz_test_gecmisi', gecmis);
  }
  void _yeniDeneme() => setState(() { _dogru=0; _yanlis=0; _soruNo=0; _oturumBitti=false; _yeniSoru(); });
  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) return const Scaffold(body: Center(child:CircularProgressIndicator()));
    final s = _soru;
    return Scaffold(appBar: AppBar(title: const Text('Hıfzımı Test Et'), actions:[IconButton(tooltip:'Gelişmiş sınav türleri', icon: const Icon(Icons.tune_rounded), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GelismisHifzSinaviEkrani()))), IconButton(tooltip:'Testi sıfırla',onPressed:_yeniDeneme,icon:const Icon(Icons.refresh))]),
      body: s == null ? const Center(child: Text('Test soruları hazırlanamadı.')) : _oturumBitti ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize:MainAxisSize.min, children:[const Icon(Icons.emoji_events_rounded,size:54,color:kAltin),const SizedBox(height:12),const Text('6 soruluk deneme tamamlandı',style:TextStyle(fontWeight:FontWeight.bold,fontSize:20)),const SizedBox(height:12),Text('Doğru: $_dogru  ·  Yanlış: $_yanlis'),const SizedBox(height:8),Text('Başarı: %${((_dogru/_oturumSoruSayisi)*100).round()}',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:16),FilledButton.icon(onPressed:_yeniDeneme,icon:const Icon(Icons.refresh),label:const Text('Yeni deneme'))]))))) : ListView(padding: const EdgeInsets.all(16), children:[
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[_istatistik('Soru','$_soruNo/$_oturumSoruSayisi'),_istatistik('Doğru','$_dogru'),_istatistik('Yanlış','$_yanlis')]))),
        const SizedBox(height:12),
        const Text('Bu ayetten sonra hangi ayet geliyor?',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),
        const SizedBox(height:12),
        Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:kKagitRengi,borderRadius:BorderRadius.circular(14),border:Border.all(color:kAltin)),child:Text(s.once.metin,textDirection:TextDirection.rtl,textAlign:TextAlign.center,style:const TextStyle(fontFamily:kMushafFontu,fontSize:26,height:2))),
        const SizedBox(height:8),Text('${s.once.sure}. Sure · ${s.once.numara}. Ayet',textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall),
        const SizedBox(height:18),
        for(var i=0;i<s.secenekler.length;i++) Card(child: ListTile(
          leading: CircleAvatar(child:Text(String.fromCharCode(65+i))),
          title: Text(s.secenekler[i].metin,textDirection:TextDirection.rtl,textAlign:TextAlign.right,style:const TextStyle(fontFamily:kMushafFontu,fontSize:21,height:1.8)),
          trailing: !_cevaplandi ? null : (s.secenekler[i].sure==s.dogru.sure && s.secenekler[i].numara==s.dogru.numara ? const Icon(Icons.check_circle,color:Colors.green) : (_secim==i ? const Icon(Icons.cancel,color:Colors.red) : null)),
          onTap:()=>_cevapla(i),
        )),
        if(_cevaplandi) ...[const SizedBox(height:10),Text((_secim!=null && s.secenekler[_secim!].sure==s.dogru.sure && s.secenekler[_secim!].numara==s.dogru.numara)?'Tebrikler, doğru cevap!':'Doğru cevap yeşil işaretlendi. Mushaf üzerinden tekrar kontrol edin.',textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:12),FilledButton.icon(onPressed:()=>setState(_yeniSoru),icon:const Icon(Icons.arrow_forward),label:const Text('Sonraki soru'))]
      ]));
  }
  Widget _istatistik(String ad,String deger)=>Column(children:[Text(deger,style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold)),Text(ad)]);
}
