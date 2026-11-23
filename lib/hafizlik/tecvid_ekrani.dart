import 'package:flutter/material.dart';
import '../ortak/tema.dart';
import '../ortak/mushaf.dart';
import 'tecvid_sinavi_ekrani.dart';
import 'cezeri_ekrani.dart';
import 'tecvid_ilkeleri_ekrani.dart';

class TecvidKural {
  final String kategori;
  final String ad;
  final String tanim;
  final String ornek;
  final String ipucu;
  const TecvidKural(this.kategori, this.ad, this.tanim, this.ornek, this.ipucu);
}

/// Tecvid konularını konu başlıkları ve arama ile sunar.
/// Açıklamalar Hafs rivayeti için temel öğretim çerçevesindedir;
/// uygulama otomatik kıraat/tecvid tashihi yaptığı iddiasında bulunmaz.
class TecvidEkrani extends StatefulWidget {
  static const kurallar = <TecvidKural>[
    // Nûn-i sâkin ve tenvin
    TecvidKural('Nûn-i sâkin ve tenvin', 'İzhâr-ı halkî', 'Sâkin nûn veya tenvinden sonra ء ه ع ح غ خ harflerinden biri gelirse nûn/tenvin sesi açıkça okunur.', 'مِنْ هَادٍ', 'Nûn sesini gizlemeden, boğaz harfini belirgin çıkar.'),
    TecvidKural('Nûn-i sâkin ve tenvin', 'İdğâm mea’l-ğunne', 'Sâkin nûn veya tenvinden sonra ي ن م و gelirse iki hareke ğunne ile kaynaştırma yapılır.', 'مَنْ يَعْمَلْ', 'Yâ, nûn, mîm ve vâv harflerini “يَنْمُو” diye hatırla.'),
    TecvidKural('Nûn-i sâkin ve tenvin', 'İdğâm bilâ-ğunne', 'Sâkin nûn veya tenvinden sonra ل veya ر gelirse ğunnesiz kaynaştırma yapılır.', 'مِنْ رَبِّهِمْ', 'Lâm ve râ öncesinde nûn sesini ayrı tutma.'),
    TecvidKural('Nûn-i sâkin ve tenvin', 'İklâb', 'Sâkin nûn veya tenvinden sonra ب gelirse nûn sesi gizli mîm sesine çevrilir ve ğunne yapılır.', 'مِنْ بَعْدِ', 'Dudakları hafifçe kapat; iki hareke ğunne uygula.'),
    TecvidKural('Nûn-i sâkin ve tenvin', 'İhfâ-i hakîkî', 'Sâkin nûn veya tenvinden sonra izhâr, idğâm ve iklâb harfleri dışındaki 15 harften biri gelirse ses ihfâ edilir.', 'مِنْ قَبْلُ', 'Nûn mahrecini tam kapatmadan, sonraki harfin mahrecine hazırlık yap.'),

    // Mîm-i sâkin
    TecvidKural('Mîm-i sâkin', 'İhfâ-i şefevî', 'Sâkin mîmden sonra ب gelirse dudaklarda ihfâ ve ğunne yapılır.', 'تَرْمِيهِمْ بِحِجَارَةٍ', 'Dudakları sertçe bastırmadan kapat.'),
    TecvidKural('Mîm-i sâkin', 'İdğâm-ı misleyn / şefevî', 'Sâkin mîmden sonra başka bir mîm gelirse iki mîm ğunneyle birleştirilir.', 'لَهُمْ مَا', 'İki hareke ğunne ile oku.'),
    TecvidKural('Mîm-i sâkin', 'İzhâr-ı şefevî', 'Sâkin mîmden sonra ب ve م dışındaki harfler gelirse mîm açık okunur.', 'أَنْعَمْتَ', 'Özellikle ف ve و öncesinde mîm açıklığını koru.'),

    // İdğâm çeşitleri
    TecvidKural('İdğâm çeşitleri', 'İdğâm-ı misleyn', 'Mahreç ve sıfatları aynı iki harften ilki sâkin, ikincisi harekeli gelirse birleştirilir.', 'اضْرِبْ بِعَصَاكَ', 'Birinci harfin sesi ikinci harfe katılır.'),
    TecvidKural('İdğâm çeşitleri', 'İdğâm-ı mütecâniseyn', 'Mahreçleri aynı, sıfatları farklı iki harften ilki sâkin, ikincisi harekeli gelirse idğâm yapılır.', 'قَدْ تَبَيَّنَ', 'Dâl ve tâ gibi aynı mahreçli harfleri hocadan dinleyerek çalış.'),
    TecvidKural('İdğâm çeşitleri', 'İdğâm-ı mütekāribeyn', 'Mahreç veya sıfat bakımından birbirine yakın iki harfin belirli birleşmelerinde idğâm yapılır.', 'قُلْ رَبِّ', 'Lâm-râ ve benzeri örnekleri rivayet/usule göre öğren.'),
    TecvidKural('İdğâm çeşitleri', 'İdğâm-ı şemsî', 'ال takısından sonra şemsî harf gelirse lâm okunmaz, sonraki harfe katılır.', 'الشَّمْسُ', 'Şemsî harfler: ت ث د ذ ر ز س ش ص ض ط ظ ل ن.'),

    // Mîm ve nûn müşedded
    TecvidKural('Ğunne', 'Nûn-ı müşedded', 'Şeddeli nûn, vasıl ve vakıf hâllerinde ğunne ile iki hareke tutulur.', 'إِنَّ', 'Geniz sesini belirgin ama ölçülü ver.'),
    TecvidKural('Ğunne', 'Mîm-i müşedded', 'Şeddeli mîm iki hareke ğunne ile okunur.', 'ثُمَّ', 'Dudak kapanışı ve geniz sesini birlikte hisset.'),
    TecvidKural('Ğunne', 'Ğunnenin mertebeleri', 'Ğunne; idğâm, ihfâ, iklâb ve müşedded nûn/mîm gibi yerlerde farklı kuvvette duyulur.', 'إِنَّ · مِنْ بَعْدِ', 'Ğunne süresini ve kuvvetini tecvid hocasının okuyuşuyla pekiştir.'),

    // Medler
    TecvidKural('Medler', 'Medd-i tabîî / aslî', 'Med harfinden sonra hemze veya sükûn sebebi yoksa iki hareke uzatılır.', 'قَالَ', 'Elif, sakin vâv ve sakin yâ öncesindeki harekeye dikkat et.'),
    TecvidKural('Medler', 'Medd-i muttasıl', 'Med harfi ile sebeb-i med olan hemze aynı kelimede bulunur.', 'جَاءَ', 'Uzatma miktarı takip edilen tarik ve öğretim usulüne göre değişebilir.'),
    TecvidKural('Medler', 'Medd-i munfasıl', 'Med harfi kelime sonunda, hemze sonraki kelimenin başında bulunur.', 'بِمَا أُنْزِلَ', 'Vasıl hâlinde med yapılır; ölçüyü hocanın öğrettiği usule göre koru.'),
    TecvidKural('Medler', 'Medd-i lâzım kelimî müsakkal', 'Med harfinden sonra aynı kelimede şeddeli/asıllı lâzım sükûn gelirse altı hareke uzatılır.', 'الضَّالِّينَ', 'Lâzım medde altı hareke ölçüsünü koru.'),
    TecvidKural('Medler', 'Medd-i lâzım kelimî muhaffef', 'Aynı kelimede med harfinden sonra şeddesiz lâzım sükûn gelmesidir.', 'آلْآنَ', 'Kur’an’da sınırlı örneği vardır; hocayla meşk et.'),
    TecvidKural('Medler', 'Medd-i lâzım harfî müsakkal', 'Hurûf-ı mukattaa içinde medden sonra idğâm sebebiyle şeddeli hâle gelen harfî meddir.', 'الٓمٓ', 'Sure başlarındaki harflerin okunuşunu ayrı ayrı öğren.'),
    TecvidKural('Medler', 'Medd-i lâzım harfî muhaffef', 'Hurûf-ı mukattaa harflerinde medden sonra idğâm olmadan lâzım sükûn bulunur.', 'صٓ · قٓ', 'Harf adlarının hece yapısına dikkat et.'),
    TecvidKural('Medler', 'Medd-i ârız li’s-sükûn', 'Vakıf sebebiyle son harf sâkin olduğunda med harfinden önceki uzatma 2, 4 veya 6 hareke yapılabilir.', 'الْعَالَمِينَ', 'Aynı okuyuşta seçtiğin ölçüyü tutarlı uygula.'),
    TecvidKural('Medler', 'Medd-i lîn', 'Fetha sonrası sakin vâv veya yâ üzerinde vakıf yapılınca yumuşak uzatma meydana gelir.', 'خَوْفٍ · بَيْتٍ', 'Vakıfta 2, 4 veya 6 hareke seçenekleri öğretilir.'),
    TecvidKural('Medler', 'Medd-i bedel', 'Hemze med harfinden önce geldiğinde med harfi iki hareke okunur.', 'آمَنُوا', 'Hafs rivayetinde genellikle iki hareke ölçüsündedir.'),
    TecvidKural('Medler', 'Medd-i ıvaz', 'Fetha tenviniyle biten kelimede vakıf yapılınca tenvin elif gibi iki hareke uzatılır.', 'عَلِيمًا', 'ة ile biten kelimelerde bu şekilde uygulanmaz.'),
    TecvidKural('Medler', 'Medd-i sıla suğrâ', 'He zamiri iki harekeli harf arasında bulunur ve ardından hemze gelmezse vasılda kısa med yapılır.', 'إِنَّهُ كَانَ', 'He zamirinin harekesini ve önce-sonra harfleri kontrol et.'),
    TecvidKural('Medler', 'Medd-i sıla kübrâ', 'He zamirinden sonra hemze gelirse vasılda daha uzun sıla meddi yapılır.', 'مَالَهُ أَخْلَدَهُ', 'Hemze sebebini ayırt et; vakıfta sıla yapılmaz.'),
    TecvidKural('Medler', 'Medd-i temkîn', 'Yan yana gelen iki yâ harfinin karışmasını önlemek için gereken açıklık ve uzatmadır.', 'النَّبِيِّينَ', 'Yâların mahreç ve harekelerini birbirine karıştırma.'),
    TecvidKural('Medler', 'Medd-i fark', 'Soru hemzesini haber hemzesinden ayıran özel meddir.', 'ءَآللَّهُ', 'Özel örnekleri mushaf işaretleri ve hocanın talimiyle öğren.'),

    // Harf ve sıfatlar
    TecvidKural('Mahreçler ve sıfatlar', 'Kalkale suğrâ', 'ق ط ب ج د harflerinden biri kelime içinde sâkin olduğunda yankılı ses verilir.', 'يَجْعَلُونَ', 'Harekeli yeni bir ses eklemeden mahreçte yankı oluştur.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Kalkale kübrâ', 'Kalkale harfi kelime sonunda vakıf sebebiyle sâkin olursa yankı daha belirgin duyulur.', 'الْفَلَقْ', 'Yankıyı abartıp harfe fetha/kesra ekleme.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Tefhîm (kalın okuma)', 'İsti‘lâ harfleri خ ص ض غ ط ق ظ kalın okunur; râ ve Allah lafzının lâmı da bağlama göre kalınlaşabilir.', 'قَالَ · الصَّمَدُ', 'Dil kökünü yükselt; kalınlığı aşırılaştırma.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Terkīk (ince okuma)', 'İstifâl harfleri esasen ince okunur; râ ve Allah lafzının lâmı belirli şartlarda ince okunur.', 'بِسْمِ اللَّهِ', 'İnce harfleri kalınlaştırma; lâm ve râ şartlarını ayrıca çalış.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Râ harfinin kalın okunması', 'Râ fethalı veya dammeli olduğunda; ayrıca bazı sükûn durumlarında kalın okunur.', 'رَبِّ · رُزِقُوا', 'Râ sakin ise önceki hareke ve sonraki harfin durumunu incele.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Râ harfinin ince okunması', 'Râ kesralı olduğunda ve bazı sükûn durumlarında ince okunur.', 'رِزْقًا', 'Râ sakin öncesindeki kesre ve isti‘lâ harfi şartlarını kontrol et.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Lâm-ı celâle', 'Allah lafzının lâmı öncesi fetha/damme ise kalın, kesre ise ince okunur.', 'قَالَ اللَّهُ · بِاللَّهِ', 'Bir önceki kelimenin son harekesine dikkat et.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Hemzetü’l-vasl', 'Kelime başında okunur; öncesine vasıl edilirse düşer. Başlangıç harekesi kelime yapısına göre belirlenir.', 'اهْدِنَا', 'İbtidâ ederken hemzeyi başlat; vasılda tekrar etme.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Hemzetü’l-kat‘', 'Hemze her durumda, hem başlangıçta hem vasılda okunur.', 'أَنْعَمْتَ', 'Hemze sesini düşürme.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Lâm-ı kameriyye', 'ال takısından sonra kamerî harf gelirse lâm açık okunur.', 'الْقَمَرُ', 'Kamerî harfleri “ابغ حجك وخف عقيمه” şeklinde ezberleyebilirsin.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Sıfat-ı lâzime', 'Harflerden ayrılmayan kalıcı sıfatlardır; hems, cehr, şiddet, rihvet, isti‘lâ, istifâl gibi sıfatları kapsar.', 'هَمْس · جَهْر', 'Her harfin sıfatlarını mahreçle birlikte öğren.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Sıfat-ı ârıza', 'Harfte okuyuş şartına göre ortaya çıkan veya kaybolan sıfatlardır; idğâm, ihfâ, tefhim ve terkik gibi.', 'مِنْ رَبِّهِمْ', 'Sıfatın hangi bağlamda ortaya çıktığını örnek üzerinde incele.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Mahreçler: boğaz harfleri', 'Hemze ve hâ aksa’l-halktan; ayn ve hâ vasatü’l-halktan; ğayn ve hı edne’l-halktan çıkar.', 'ء ه ع ح غ خ', 'Boğazın üç bölgesini ayırt ederek sesleri hocadan dinle.'),
    TecvidKural('Mahreçler ve sıfatlar', 'Mahreçler: dil, dudak ve geniz', 'Harflerin çoğu dil bölgelerinden; bâ, mîm, vâv dudaklardan; ğunne geniz boşluğundan çıkar.', 'ب · م · و · ن', 'Mahreçleri sadece teorik değil, sesli meşk ile öğren.'),

    // Vakıf ve ibtida
    TecvidKural('Vakıf ve ibtidâ', 'Vakıf', 'Okuyuşu nefes almak veya anlamı tamamlamak için kesmektir; kelimenin sonu vakıf kurallarına göre sükûn/bedel alabilir.', 'الْعَالَمِينَ۝', 'Mana bütünlüğünü bozan yerde durmaktan kaçın.'),
    TecvidKural('Vakıf ve ibtidâ', 'İbtidâ', 'Vakfın ardından okumaya yeniden başlamaktır; anlam ve nahiv bütünlüğüne uygun yerden başlanır.', 'بِسْمِ اللَّهِ', 'Anlamı tamamlamayan bir kelimeden başlama.'),
    TecvidKural('Vakıf ve ibtidâ', 'Vakıf-ı tâm', 'Mana ve söz dizimi bakımından kendisinden sonrası ile bağı bulunmayan yerde duruştur.', 'Kıssa veya konu sonları', 'Mushaf işaretini ve anlamı birlikte değerlendir.'),
    TecvidKural('Vakıf ve ibtidâ', 'Vakıf-ı kâfî', 'Mana bakımından tamam olmakla birlikte sonraki bölümle konu/bağlantı ilişkisi bulunan yerde duruştur.', 'Bağlantılı ayet sonları', 'Sonraki ayetle mana bağını koru.'),
    TecvidKural('Vakıf ve ibtidâ', 'Vakıf-ı hasen', 'Mana anlaşılır olmakla birlikte lafız veya i‘rab bakımından sonraki kısma bağlılık bulunan yerde duruştur.', 'Ayet içi uygun durak', 'Başlangıcı uygun yerden yapmaya dikkat et.'),
    TecvidKural('Vakıf ve ibtidâ', 'Vakıf-ı kabîh', 'Mana tamamlanmadan veya anlamı bozacak biçimde yapılan duruştur.', 'Cümle ortasında uygunsuz kesme', 'Zaruret dışında böyle duruşlardan kaçın.'),
    TecvidKural('Vakıf ve ibtidâ', 'Lâ (لا) işareti', 'Bu işaret, ilgili yerde durulmamasını bildirir; zaruret hâlinde durulursa uygun yerden tekrar başlanır.', 'لا', 'Mushafın vakıf işaretlerini tanı.'),
    TecvidKural('Vakıf ve ibtidâ', 'Muânaka vakfı', 'Üç nokta işaretli iki yerden birinde durulur; ikisinde birden durulmaz.', 'ۛ ۛ', 'İki işaretten yalnızca birini vakıf yeri seç.'),
    TecvidKural('Vakıf ve ibtidâ', 'Mîm (م) vakıf işareti', 'Lâzım vakıf işaretidir; işaretin bulunduğu yerde durulması gerekir.', 'م', 'Mana bütünlüğü için bu işareti dikkate al.'),
    TecvidKural('Vakıf ve ibtidâ', 'Cîm (ج) vakıf işareti', 'Durmanın da geçmenin de caiz olduğunu gösterir.', 'ج', 'Nefes ve mana akışına göre tercih yap.'),
    TecvidKural('Vakıf ve ibtidâ', 'Kılâ (قلى) işareti', 'Durmanın geçmekten daha uygun olduğunu bildirir.', 'قلى', 'Durmak genellikle tercih edilir.'),
    TecvidKural('Vakıf ve ibtidâ', 'Sılâ (صلى) işareti', 'Geçmenin durmaktan daha uygun olduğunu bildirir.', 'صلى', 'Mana bağlantısını sürdürmek genellikle tercih edilir.'),
    TecvidKural('Vakıf ve ibtidâ', 'Tâ (ط) işareti', 'Vakf-ı mutlak olarak bilinir; durmanın uygun olduğu yeri gösterir.', 'ط', 'Ayet içi anlamın tamamlandığı noktaları takip et.'),
    TecvidKural('Vakıf ve ibtidâ', 'Sek­te', 'Nefes almadan, kısa bir süre sesi keserek yapılan özel duruştur.', 'عِوَجًاۜ قَيِّمًا', 'Hafs rivayetindeki sekte yerlerini mushaf ve hocayla öğren.'),
  ];

  const TecvidEkrani({super.key});
  @override
  State<TecvidEkrani> createState() => _TecvidEkraniState();
}

class _TecvidEkraniState extends State<TecvidEkrani> {
  final TextEditingController _arama = TextEditingController();
  String _kategori = 'Tümü';



  List<String> get _kategoriler => ['Tümü', ...{for (final k in TecvidEkrani.kurallar) k.kategori}];

  @override
  void dispose() { _arama.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final q = _arama.text.trim().toLowerCase();
    final filtre = TecvidEkrani.kurallar.where((k) =>
      (_kategori == 'Tümü' || k.kategori == _kategori) &&
      (q.isEmpty || '${k.ad} ${k.tanim} ${k.ornek} ${k.kategori}'.toLowerCase().contains(q))).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Tecvid Öğren'), actions: [IconButton(tooltip: 'Tecvid sınavı', icon: const Icon(Icons.quiz_rounded), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TecvidSinaviEkrani()))) ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: TextField(
          controller: _arama, onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tecvid kuralı ara...', border: OutlineInputBorder()),
        )),
        SizedBox(height: 54, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
          for (final k in _kategoriler) Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: ChoiceChip(label: Text(k), selected: _kategori == k, onSelected: (_) => setState(() => _kategori = k))),
        ])),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), children: [
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${TecvidEkrani.kurallar.length} konu başlığı', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            const Text('Kurallar örnekleriyle açıklanmıştır. Bu bölüm öğretim amaçlıdır; ses kaydından otomatik mahreç, hareke veya tecvid puanlaması yapmaz. Uygulama ve uzatma miktarları rivayet/tarik farklılıklarına göre hocadan teyit edilmelidir.'),
          ]))),
          Card(child: ListTile(
            leading: const Icon(Icons.auto_stories_rounded, color: kAltin),
            title: const Text('Cezerî Mukaddime', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Arapça metin ve Türkçe açıklama'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CezeriEkrani())),
          )),
          Card(child: ListTile(
            leading: const Icon(Icons.rule_rounded, color: kYesil),
            title: const Text('Tecvid İlkeleri', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Arapça ifade ve Türkçe açıklama'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TecvidIlkeleriEkrani())),
          )),
          if (filtre.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Aramanızla eşleşen kural bulunamadı.'))),
          for (final k in filtre) Card(child: ExpansionTile(
            leading: const Icon(Icons.menu_book_rounded, color: kYesil),
            title: Text(k.ad, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(k.kategori),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: kKagitRengi, borderRadius: BorderRadius.circular(12)), child: Text(k.ornek, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Amiri', fontSize: 27))),
              const SizedBox(height: 10), Align(alignment: Alignment.centerLeft, child: Text(k.tanim)),
              const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: Text('Çalışma notu: ${k.ipucu}', style: const TextStyle(fontWeight: FontWeight.w600))),
            ],
          )),
        ])),
      ]),
    );
  }
}
