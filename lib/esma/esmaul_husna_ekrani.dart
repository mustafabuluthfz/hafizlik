import 'package:flutter/material.dart';

import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import '../ortak/ikonlar.dart';

class EsmaIsmi {
  final int no;
  final String arapca;
  final String okunus;
  final String anlam;

  const EsmaIsmi(this.no, this.arapca, this.okunus, this.anlam);
}

const List<EsmaIsmi> esmaulHusna = [
  EsmaIsmi(1, 'الرَّحْمَنُ', 'Er-Rahman', 'Rahmân · Esirgeyen, çok merhametli'),
  EsmaIsmi(2, 'الرَّحِيمُ', 'Er-Rahim', 'Rahîm · Çok merhametli'),
  EsmaIsmi(3, 'الْمَلِكُ', 'El-Melik', 'Melik · Mülkün sahibi'),
  EsmaIsmi(4, 'الْقُدُّوسُ', 'El-Kuddus', 'Kuddüs · Her türlü noksanlıktan münezzeh'),
  EsmaIsmi(5, 'السَّلَامُ', 'Es-Selam', 'Selam · Esenlik veren'),
  EsmaIsmi(6, 'الْمُؤْمِنُ', 'El-Mü\'min', 'Mü\'min · Güven veren'),
  EsmaIsmi(7, 'الْمُهَيْمِنُ', 'El-Müheymin', 'Müheymin · Koruyup gözeten'),
  EsmaIsmi(8, 'الْعَزِيزُ', 'El-Aziz', 'Aziz · Üstün, güçlü'),
  EsmaIsmi(9, 'الْجَبَّارُ', 'El-Cebbar', 'Cebbar · Dilediğini yapan'),
  EsmaIsmi(10, 'الْمُتَكَبِّرُ', 'El-Mütekebbir', 'Mütekebbir · Büyüklük sahibi'),
  EsmaIsmi(11, 'الْخَالِقُ', 'El-Halık', 'Halık · Yaratan'),
  EsmaIsmi(12, 'الْبَارِئُ', 'El-Bari', 'Bari · Var eden'),
  EsmaIsmi(13, 'الْمُصَوِّرُ', 'El-Musavvir', 'Musavvir · Şekil veren'),
  EsmaIsmi(14, 'الْغَفَّارُ', 'El-Gaffar', 'Gaffar · Çok bağışlayan'),
  EsmaIsmi(15, 'الْقَهَّارُ', 'El-Kahhar', 'Kahhar · Her şeye egemen'),
  EsmaIsmi(16, 'الْوَهَّابُ', 'El-Vehhab', 'Vehhab · Çokça veren'),
  EsmaIsmi(17, 'الرَّزَّاقُ', 'Er-Rezzak', 'Rezzak · Rızık veren'),
  EsmaIsmi(18, 'الْفَتَّاحُ', 'El-Fettah', 'Fettah · Açan, fetheden'),
  EsmaIsmi(19, 'الْعَلِيمُ', 'El-Alim', 'Alim · Her şeyi bilen'),
  EsmaIsmi(20, 'الْقَابِضُ', 'El-Kabız', 'Kabız · Daraltan'),
  EsmaIsmi(21, 'الْبَاسِطُ', 'El-Basıt', 'Basıt · Genişleten'),
  EsmaIsmi(22, 'الْخَافِضُ', 'El-Hafıd', 'Hafıd · Alçaltan'),
  EsmaIsmi(23, 'الرَّافِعُ', 'Er-Rafi', 'Rafi · Yükselten'),
  EsmaIsmi(24, 'الْمُعِزُّ', 'El-Muiz', 'Muiz · Aziz eden'),
  EsmaIsmi(25, 'المُذِلُّ', 'El-Müzil', 'Müzil · Zelil eden'),
  EsmaIsmi(26, 'السَّمِيعُ', 'Es-Semi', 'Semi · Hakkıyla işiten'),
  EsmaIsmi(27, 'الْبَصِيرُ', 'El-Basir', 'Basir · Hakkıyla gören'),
  EsmaIsmi(28, 'الْحَكَمُ', 'El-Hakem', 'Hakem · Hüküm veren'),
  EsmaIsmi(29, 'الْعَدْلُ', 'El-Adl', 'Adl · Adil'),
  EsmaIsmi(30, 'اللَّطِيفُ', 'El-Latif', 'Latif · İnce ve lütufkâr'),
  EsmaIsmi(31, 'الْخَبِيرُ', 'El-Habir', 'Habir · Her şeyden haberdar'),
  EsmaIsmi(32, 'الْحَلِيمُ', 'El-Halim', 'Halim · Yumuşak huylu, sabırlı'),
  EsmaIsmi(33, 'الْعَظِيمُ', 'El-Azim', 'Azim · Yüce'),
  EsmaIsmi(34, 'الْغَفُورُ', 'El-Gafur', 'Gafur · Çok bağışlayan'),
  EsmaIsmi(35, 'الشَّكُورُ', 'Eş-Şekur', 'Şekûr · Az amele çok karşılık veren'),
  EsmaIsmi(36, 'الْعَلِيُّ', 'El-Aliyy', 'Aliyy · Yüce'),
  EsmaIsmi(37, 'الْكَبِيرُ', 'El-Kebir', 'Kebir · Büyük'),
  EsmaIsmi(38, 'الْحَفِيظُ', 'El-Hafiz', 'Hafiz · Koruyan'),
  EsmaIsmi(39, 'الْمُقِيتُ', 'El-Mukit', 'Mukît · Rızık veren, gözeten'),
  EsmaIsmi(40, 'الْحَسِيبُ', 'El-Hasib', 'Hasib · Hesap gören'),
  EsmaIsmi(41, 'الْجَلِيلُ', 'El-Celil', 'Celil · Celâl sahibi'),
  EsmaIsmi(42, 'الْكَرِيمُ', 'El-Kerim', 'Kerim · Cömert'),
  EsmaIsmi(43, 'الرَّقِيبُ', 'Er-Rakib', 'Rakib · Gözetleyen'),
  EsmaIsmi(44, 'الْمُجِيبُ', 'El-Mucib', 'Mucib · Duaları kabul eden'),
  EsmaIsmi(45, 'الْوَاسِعُ', 'El-Vasi', 'Vasi · Geniş ilim ve rahmet sahibi'),
  EsmaIsmi(46, 'الْحَكِيمُ', 'El-Hakim', 'Hakîm · Hikmet sahibi'),
  EsmaIsmi(47, 'الْوَدُودُ', 'El-Vedud', 'Vedûd · Çok seven'),
  EsmaIsmi(48, 'الْمَجِيدُ', 'El-Mecid', 'Mecid · Şanı yüce'),
  EsmaIsmi(49, 'الْبَاعِثُ', 'El-Bais', 'Bais · Dirilten'),
  EsmaIsmi(50, 'الشَّهِيدُ', 'Eş-Şehid', 'Şehid · Her şeye şahit'),
  EsmaIsmi(51, 'الْحَقُّ', 'El-Hakk', 'Hakk · Gerçek'),
  EsmaIsmi(52, 'الْوَكِيلُ', 'El-Vekil', 'Vekil · Güvenilir koruyucu'),
  EsmaIsmi(53, 'الْقَوِيُّ', 'El-Kavi', 'Kavî · Çok güçlü'),
  EsmaIsmi(54, 'الْمَتِينُ', 'El-Metin', 'Metin · Sağlam kuvvet sahibi'),
  EsmaIsmi(55, 'الْوَلِيُّ', 'El-Veliyy', 'Veliyy · Dost, yardımcı'),
  EsmaIsmi(56, 'الْحَمِيدُ', 'El-Hamid', 'Hamîd · Övgüye layık'),
  EsmaIsmi(57, 'الْمُحْصِي', 'El-Muhsi', 'Muhsî · Her şeyi sayan'),
  EsmaIsmi(58, 'الْمُبْدِئُ', 'El-Mübdi', 'Mübdi · Başlatan'),
  EsmaIsmi(59, 'الْمُعِيدُ', 'El-Muid', 'Muîd · Geri döndüren'),
  EsmaIsmi(60, 'الْمُحْيِي', 'El-Muhyi', 'Muhyî · Hayat veren'),
  EsmaIsmi(61, 'الْمُمِيتُ', 'El-Mümit', 'Mümit · Öldüren'),
  EsmaIsmi(62, 'الْحَيُّ', 'El-Hayy', 'Hayy · Diri, canlı'),
  EsmaIsmi(63, 'الْقَيُّومُ', 'El-Kayyum', 'Kayyûm · Her şeyi ayakta tutan'),
  EsmaIsmi(64, 'الْوَاجِدُ', 'El-Vacid', 'Vâcid · Bulan, kaybolmayan'),
  EsmaIsmi(65, 'الْمَاجِدُ', 'El-Macid', 'Macid · Yüce, şerefli'),
  EsmaIsmi(66, 'الْوَاحِدُ', 'El-Vahid', 'Vahid · Bir'),
  EsmaIsmi(67, 'الأَحَدُ', 'El-Ahad', 'Ahad · Tek'),
  EsmaIsmi(68, 'الصَّمَدُ', 'Es-Samed', 'Samed · Her şey ona muhtaç'),
  EsmaIsmi(69, 'الْقَادِرُ', 'El-Kadir', 'Kadir · Gücü yeten'),
  EsmaIsmi(70, 'الْمُقْتَدِرُ', 'El-Muktedir', 'Muktedir · Dilediğini yapan'),
  EsmaIsmi(71, 'الْمُقَدِّمُ', 'El-Mukaddim', 'Mukaddim · Öne alan'),
  EsmaIsmi(72, 'الْمُؤَخِّرُ', 'El-Muahhir', 'Muahhir · Geri bırakan'),
  EsmaIsmi(73, 'الأَوَّلُ', 'El-Evvel', 'Evvel · İlk'),
  EsmaIsmi(74, 'الآخِرُ', 'El-Ahir', 'Âhir · Son'),
  EsmaIsmi(75, 'الظَّاهِرُ', 'Ez-Zahir', 'Zâhir · Açık ve belli'),
  EsmaIsmi(76, 'الْبَاطِنُ', 'El-Batın', 'Bâtın · Gizli'),
  EsmaIsmi(77, 'الْوَالِي', 'El-Vali', 'Vali · Her şeyin yöneticisi'),
  EsmaIsmi(78, 'الْمُتَعَالِي', 'El-Müteali', 'Müteâli · Yüceler yücesi'),
  EsmaIsmi(79, 'الْبَرُّ', 'El-Berr', 'Berr · İyilik eden'),
  EsmaIsmi(80, 'التَّوَّابُ', 'Et-Tevvab', 'Tevvab · Tövbeleri kabul eden'),
  EsmaIsmi(81, 'الْمُنْتَقِمُ', 'El-Müntekim', 'Müntekim · İntikam alan'),
  EsmaIsmi(82, 'العَفُوُّ', 'El-Afüv', 'Afüvv · Affeden'),
  EsmaIsmi(83, 'الرَّءُوفُ', 'Er-Rauf', 'Raûf · Çok şefkatli'),
  EsmaIsmi(84, 'مَالِكُ الْمُلْكِ', 'Malikü\'l-Mülk', 'Mâlikü\'l-Mülk · Mülkün sahibi'),
  EsmaIsmi(85, 'ذُو الْجَلاَلِ وَالإِكْرَامِ', 'Zü\'l-Celali vel-İkram', 'Celâl ve ikram sahibi'),
  EsmaIsmi(86, 'الْمُقْسِطُ', 'El-Muksit', 'Muksit · Adaleti gerçekleştiren'),
  EsmaIsmi(87, 'الْجَامِعُ', 'El-Cami', 'Cami · Toplayan'),
  EsmaIsmi(88, 'الْغَنِيُّ', 'El-Ganiyy', 'Ganiyy · Zengin, ihtiyaçsız'),
  EsmaIsmi(89, 'الْمُغْنِي', 'El-Mugni', 'Mugnî · Zengin eden'),
  EsmaIsmi(90, 'الْمَانِعُ', 'El-Mani', 'Mani · Engelleyen'),
  EsmaIsmi(91, 'الضَّارَّ', 'Ed-Darr', 'Darr · Zarar veren'),
  EsmaIsmi(92, 'النَّافِعُ', 'En-Nafi', 'Nafi · Fayda veren'),
  EsmaIsmi(93, 'النُّورُ', 'En-Nur', 'Nûr · Nur'),
  EsmaIsmi(94, 'الْهَادِي', 'El-Hadi', 'Hadi · Hidayet veren'),
  EsmaIsmi(95, 'الْبَدِيعُ', 'El-Bedi', 'Bedî · Eşsiz yaratan'),
  EsmaIsmi(96, 'الْبَاقِي', 'El-Baki', 'Bâki · Daimi, ebedi'),
  EsmaIsmi(97, 'الْوَارِثُ', 'El-Varis', 'Varis · Mirası devralan'),
  EsmaIsmi(98, 'الرَّشِيدُ', 'Er-Reşid', 'Reşid · Doğru yolu gösteren'),
  EsmaIsmi(99, 'الصَّبُورُ', 'Es-Sabur', 'Sabûr · Çok sabırlı'),
];

class EsmaulHusnaEkrani extends StatefulWidget {
  const EsmaulHusnaEkrani({super.key});

  @override
  State<EsmaulHusnaEkrani> createState() => _EsmaulHusnaEkraniState();
}

class _EsmaulHusnaEkraniState extends State<EsmaulHusnaEkrani> {
  String _ara = '';

  @override
  Widget build(BuildContext context) {
    final liste = esmaulHusna
        .where((e) =>
            _ara.isEmpty ||
            e.okunus.toLowerCase().contains(_ara.toLowerCase()) ||
            e.anlam.toLowerCase().contains(_ara.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Esmaül Hüsna')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _ara = v.trim()),
              decoration: InputDecoration(
                hintText: 'İsim veya anlam ara',
                prefixIcon: const Icon(AppIkonlari.arama),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: kAltin.withOpacity(0.4)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: liste.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = liste[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kAltinAcik.withOpacity(0.5),
                      child: Text('${e.no}',
                          style: const TextStyle(
                              color: kYesil, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(e.okunus,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(e.anlam),
                    trailing: Text(
                      e.arapca,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: kMushafFontu,
                        fontSize: 24,
                        color: kYesil,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
