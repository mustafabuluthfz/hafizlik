import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ortak/tema.dart';
import '../ai/ai_hoca_ekrani.dart';
import '../ortak/uygulama.dart';
import '../ortak/ikonlar.dart';
import '../ses/okuyucu.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});
  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  int _okuyucuDizin = 0;
  @override
  void initState() { super.initState(); _yukle(); }
  Future<void> _yukle() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _okuyucuDizin = (p.getInt('okuyucu_dizin') ?? 0).clamp(0, okuyucular.length - 1).toInt());
  }

  Future<void> _verileriSil(BuildContext context) async {
    final onay = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Veriler silinsin mi?'),
      content: const Text('Okuma geçmişiniz, seriniz, yer imleriniz ve zikir sayaçlarınız silinir. Bu işlem geri alınamaz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sil'))],
    ));
    if (onay != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    kTemaModu.value = ThemeMode.system;
    kMushafKagitRengi.value = const Color(0xFFFBF6E9);
    kMushafYaziBoyutu.value = 26;
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veriler silindi. Görünüm tercihleri varsayılana döndü.')));
  }

  Future<void> _okuyucuSec(int? index) async {
    if (index == null) return;
    final p = await SharedPreferences.getInstance();
    await p.setInt('okuyucu_dizin', index);
    if (mounted) setState(() => _okuyucuDizin = index);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${okuyucular[index].ad} varsayılan okuyucu seçildi.')));
  }

  Future<void> _temaSec(ThemeMode mod) async {
    kTemaModu.value = mod;
    final p = await SharedPreferences.getInstance();
    await p.setInt('tema', mod.index);
  }

  Future<void> _kagitSec(Color renk) async {
    kMushafKagitRengi.value = renk;
    final p = await SharedPreferences.getInstance();
    await p.setInt('mushaf_kagit', renk.value);
  }

  Future<void> _yaziBoyutu(double boyut) async {
    kMushafYaziBoyutu.value = boyut;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('mushaf_yazi_boyutu', boyut);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ayarlar')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Uygulama teması', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
        ValueListenableBuilder<ThemeMode>(valueListenable: kTemaModu, builder: (context, mod, _) => SizedBox(width: double.infinity, child: SegmentedButton<ThemeMode>(segments: const [ButtonSegment(value: ThemeMode.system,label:Text('Sistem')),ButtonSegment(value:ThemeMode.light,label:Text('Açık')),ButtonSegment(value:ThemeMode.dark,label:Text('Koyu'))],selected:{mod},onSelectionChanged:(s)=>_temaSec(s.first)))),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mushaf görünümü', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Sayfa rengi'), const SizedBox(height: 8),
        ValueListenableBuilder<Color>(valueListenable: kMushafKagitRengi, builder: (context, secili, _) => Wrap(spacing: 10, runSpacing: 10, children: [for(var i=0;i<kKagitPaleti.length;i++) Tooltip(message:kKagitAdlari[i],child:InkWell(onTap:()=>_kagitSec(kKagitPaleti[i]),customBorder:const CircleBorder(),child:Container(width:36,height:36,decoration:BoxDecoration(color:kKagitPaleti[i],shape:BoxShape.circle,border:Border.all(color:secili.value==kKagitPaleti[i].value?kYesil:Colors.grey,width:secili.value==kKagitPaleti[i].value?3:1)),child:secili.value==kKagitPaleti[i].value?const Icon(Icons.check,size:18,color:kYesil):null)))])),
        const SizedBox(height:16),
        ValueListenableBuilder<double>(valueListenable:kMushafYaziBoyutu,builder:(context,boyut,_)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Arapça yazı boyutu'),Text('${boyut.round()} px',style:const TextStyle(fontWeight:FontWeight.bold))]),Slider(min:20,max:40,divisions:10,value:boyut,onChanged:_yaziBoyutu),Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:kMushafKagitRengi.value,borderRadius:BorderRadius.circular(10)),child:Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',textDirection:TextDirection.rtl,textAlign:TextAlign.center,style:TextStyle(fontFamily:'Amiri',fontSize:boyut)))])),
      ]))),
      const SizedBox(height:12),
      Card(child: Column(children:[
        ListTile(leading:const Icon(Icons.record_voice_over_rounded,color:kYesil),title:const Text('Varsayılan ayet okuyucusu'),subtitle:Text(okuyucular[_okuyucuDizin].ad),trailing:const Icon(Icons.expand_more),onTap:()async{final i=await showModalBottomSheet<int>(context:context,showDragHandle:true,builder:(c)=>ListView(shrinkWrap:true,children:[const ListTile(title:Text('Ayet okuyucusu seç',style:TextStyle(fontWeight:FontWeight.bold))),for(var i=0;i<okuyucular.length;i++)ListTile(title:Text(okuyucular[i].ad),trailing:i==_okuyucuDizin?const Icon(Icons.check,color:kYesil):null,onTap:()=>Navigator.pop(c,i))]));await _okuyucuSec(i);}),
        const Divider(height:1),
        const ListTile(leading:Icon(Icons.headphones_rounded,color:kYesil),title:Text('Sesli okuma'),subtitle:Text('Ayet sesleri çevrimiçi çalınabilir; indirilen sesler Ses Kütüphanesi üzerinden çevrimdışı kullanılabilir.'),isThreeLine:true),
      ])),
      const SizedBox(height:12),
      Card(child: Column(children:[
        ListTile(leading:const Icon(Icons.auto_awesome_rounded,color:kAltin),title:const Text('Cihaz içi Hafızlık Hocası'),subtitle:const Text('İnternetsiz metin karşılaştırması ve tekrar önerileri'),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const AiHocaEkrani()))),
        const Divider(height:1),
        ListTile(leading:const Icon(AppIkonlari.degerlendir,color:kAltin),title:const Text('Bizi değerlendir'),onTap:()=>launchUrl(Uri.parse(kMagazaAdresi),mode:LaunchMode.externalApplication)),
        const Divider(height:1),
        ListTile(leading:const Icon(Icons.delete_outline_rounded,color:Colors.red),title:const Text('Verileri sıfırla'),subtitle:const Text('Seri, yer imi, zikir ve hatim kayıtlarını siler'),onTap:()=>_verileriSil(context)),
        const Divider(height:1),
        const ListTile(leading:Icon(Icons.info_outline_rounded,color:kYesil),title:Text('Hafızlık'),subtitle:Text('Sürüm 1.9.0')),
        const Divider(height:1),
        const ListTile(leading:Icon(Icons.shield_outlined,color:kYesil),title:Text('Gizlilik'),subtitle:Text('Ezber karşılaştırması ve kişisel görünüm ayarları cihazınızda saklanır. Ses tanıma özelliği Android konuşma tanıma altyapısını kullanır.'),isThreeLine:true),
      ])),
    ]),
  );
}
