/// Muhammed b. el-Cezerî’nin (vefatı 833 hicrî) Mukaddime manzumesi.
/// Beyitler klasik ve kamu malı metindir. Türkçe açıklamalar uygulamaya
/// özgü olarak yazılmıştır; kitabın yorum metni kullanılmamıştır.
/// Harekeler kaynak sayfalardan okunmuş olup hocanızla teyit edilmelidir.
class CezeriBeyit {
  final String birinci;
  final String ikinci;
  final String turkce;
  final bool ekBeyit;
  const CezeriBeyit(this.birinci, this.ikinci, this.turkce, {this.ekBeyit = false});
}

class CezeriBab {
  final String ad;
  final String turkceAd;
  final List<CezeriBeyit> beyitler;
  const CezeriBab(this.ad, this.turkceAd, this.beyitler);
}

const List<CezeriBab> cezeriBablar = [
  CezeriBab('مُقَدِّمَةُ الْجَزَرِيِّ', 'Giriş', [
    CezeriBeyit('يَقُولُ رَاجِي عَفْوِ رَبٍّ سَامِعِ',
        'مُحَمَّدُ بْنُ الْجَزَرِيِّ الشَّافِعِي',
        'Duaları işiten Rabbin affını uman Muhammed b. el-Cezerî eş-Şâfiî şöyle der.'),
    CezeriBeyit('الْحَمْدُ لِلَّهِ وَصَلَّى اللَّهُ',
        'عَلَى نَبِيِّهِ وَمُصْطَفَاهُ',
        'Hamd Allah’a; salât ve selam, Peygamber’e ve seçtiği kullara olsun.'),
    CezeriBeyit('مُحَمَّدٍ وَآلِهِ وَصَحْبِهِ',
        'وَمُقْرِي الْقُرْآنِ مَعْ مُحِبِّهِ',
        'Muhammed’e, ailesine, ashabına ve Kur’an okuyanlara ve onları sevenlere salât olsun.'),
    CezeriBeyit('وَبَعْدُ إِنَّ هَذِهِ مُقَدِّمَهْ',
        'إِذْ وَاجِبٌ عَلَيْهِمُ مُحَتَّمَهْ',
        'Bu kısa risale, Kur’an okuyanlara farz ve zorunlu olan bilgileri öğretmek için yazılmıştır.'),
    CezeriBeyit('فِيمَا عَلَى قَارِئِهِ أَنْ يَعْلَمَهْ',
        'قَبْلَ الشُّرُوعِ أَوَّلًا أَنْ يَعْلَمُوا',
        'Okumaya başlamadan önce Kur’an okuyucusunun öğrenmesi gerekenler şunlardır.'),
    CezeriBeyit('مَخَارِجَ الْحُرُوفِ وَالصِّفَاتِ',
        'لِيُلْفِظُوا بِأَفْصَحِ اللُّغَاتِ',
        'Harflerin mahreçlerini ve sıfatlarını bilerek, Arapçanın en fasih biçimiyle telaffuz etmeleri gerekir.'),
    CezeriBeyit('مُحَرِّرِي التَّجْوِيدِ وَالْمَوَاقِفِ',
        'وَمَا الَّذِي رُسِمَ فِي الْمَصَاحِفِ',
        'Tecvidi ve vakıf yerlerini belirleyen kaynaklara göre, mushaflarda yazılı olanı doğru okumaları gerekir.'),
  ]),
  CezeriBab('بَابُ هَمْزِ الْوَصْلِ', 'Hemzetü’l-vasl babı', [
    CezeriBeyit('وَابْدَأْ بِهَمْزِ الْوَصْلِ مِنْ فِعْلٍ بِضَمْ',
        'إِنْ كَانَ ثَالِثٌ مِنَ الْفِعْلِ يُضَمّ',
        'Hemzetü’l-vasl ile başlanan fiilin üçüncü harfi ötreli ise hemze de ötreli okunur.'),
    CezeriBeyit('وَاكْسِرْهُ حَالَ الْكَسْرِ وَالْفَتْحِ وَفِي',
        'الْأَسْمَاءِ غَيْرِ اللَّامِ كَسْرُهَا وَفِي',
        'Bunun dışındaki fiillerde hemze kesreli okunur. İsimlerde de lâm-ı tarif dışında kesredir.'),
    CezeriBeyit('ابْنِ مَعَ ابْنَةِ امْرِئٍ وَامْرَأَةٍ',
        'وَاسْمِ مَعَ اثْنَتَيْنِ وَاثْنَيْنِ',
        'İbn, ibnet, imru, imrae, ism, iki (erkek ve dişi) kelimeleri de kesreli hemzeyle başlar.'),
  ]),
  CezeriBab('بَابُ الْوَقْفِ عَلَى أَوَاخِرِ الْكَلِمِ', 'Kelime sonlarında vakıf', [
    CezeriBeyit('وَحَاذِرِ الْوَقْفَ بِكُلِّ الْحَرَكَهْ',
        'إِلَّا بِفَتْحٍ أَوْ بِنَصْبٍ وَأَشْمِ',
        'Vakfta harekeli son harften kaçın. Fetha ve nasb hâlinde durmak serbesttir; işmam da yapılabilir.'),
    CezeriBeyit('إِلَّا إِذَا رُمْتَ فَبَعْضُ الْحَرَكَهْ',
        'إِشَارَةً بِالضَّمِّ فِي رَفْعٍ وَضَمّ',
        'Rum (harekenin bir kısmını duyurma) yapılabilir. Ref ve ötre hâlinde dudakla işaret edilerek vakfedilir.'),
    CezeriBeyit('وَقَدْ تَقْتَضِي نَظْمِيَ الْمُقَدِّمَهْ',
        'مِنِّي لِقَارِئِ الْقُرْآنِ تَقْدِمَهْ',
        'Bu manzumenin düzeni gereği, Kur’an okuyucusuna bu çalışma ön hazırlık olarak sunulur.'),
    CezeriBeyit('أَبْيَاتُهَا فَاءٌ وَزَايٌ فِي الْعَدَدْ',
        'مِنْ يُحْسِنِ التَّجْوِيدَ يُظْفَرْ بِالرُّشْدِ',
        'Tecvidi güzel yapan, doğruya ulaşır. (Bazı alimlerin eklediği beyit.)',
        ekBeyit: true),
    CezeriBeyit('وَالْحَمْدُ لِلَّهِ لَهَا خِتَامُ',
        'ثُمَّ الصَّلَاةُ بَعْدَ وَالسَّلَامُ',
        'Sonunda hamd, ardından salât ve selam. (Bazı alimlerin eklediği beyit.)',
        ekBeyit: true),
    CezeriBeyit('عَلَى النَّبِيِّ الْمُصْطَفَى وَآلِهِ',
        'وَصَحْبِهِ وَتَابِعِيهِ مَنْوَالِهِ',
        'Seçkin Peygamber’e, âline, ashabına ve onlara uyanlara salât olsun. (Bazı alimlerin eklediği beyit.)',
        ekBeyit: true),
  ]),
  CezeriBab('بَابُ الْمَقْطُوعِ وَالْمَوْصُولِ', 'Maktû ve mevsûl (ayrı ve birleşik yazılanlar)', [
    CezeriBeyit('وَاعْرِفْ لِمَقْطُوعٍ وَمَوْصُولٍ وَتَا',
        'فَاقْطَعْ بِعَشْرِ كَلِمَاتٍ أَنْ لَا',
        'Mushafta ayrı yazılan (maktû) ve birleşik yazılan (mevsûl) kelimeleri bilmek gerekir. ‘Enlâ’ gibi on kelimede ayrı yazım esastır.'),
    CezeriBeyit('وَتَعْبُدُوا يَاسِينَ ثَانِي هُودَ لَا',
        'أَنْ لَا يَقُولُوا لَا أَقُولَ إِنْ مَا',
        'Yâsîn ve Hûd’un ikinci ayetinde geçen ‘ألا تعبدوا’ gibi örnekleri ayrı yazım kuralına göre ezberle.'),
  ]),
  CezeriBab('بَابُ حُكْمِ النُّونِ السَّاكِنَةِ وَالتَّنْوِينِ', 'Nûn-i sâkin ve tenvin hükümleri', [
    CezeriBeyit('وَحُكْمُ تَنْوِينٍ وَنُونٍ يُلْفَى',
        'إِظْهَارٌ إِدْغَامٌ وَقَلْبٌ إِخْفَا',
        'Tenvin ve sâkin nûnun dört hükmü vardır: izhâr, idğâm, iklâb ve ihfâ.'),
    CezeriBeyit('فَعِنْدَ حَرْفِ الْحَلْقِ أَظْهِرْ وَادْغَمْ',
        'فِي اللَّامِ وَالرَّا لَا بِغُنَّةٍ لَزِمْ',
        'Boğaz harflerinden önce izhâr yapılır. Lâm ve râ’dan önce ise ğunnesiz idğâm yapılır.'),
    CezeriBeyit('وَأَدْغِمَنْ بِغُنَّةٍ فِي يُمُنِ',
        'إِلَّا بِكَلِمَةٍ كَدُنْيًا عَنُّوا',
        'ي ن م و harflerinden önce ğunneli idğâm yapılır. Ancak ‘dünyâ’ ve ‘annû’ gibi aynı kelime içindeki örneklerde bu uygulanmaz.'),
    CezeriBeyit('وَالْقَلْبُ عِنْدَ الْبَا بِغُنَّةٍ كَذَا',
        'الْإِخْفَا لَدَى بَاقِي الْحُرُوفِ أَخَذَا',
        'Bâ’dan önce nûn, ğunneli bir mîme çevrilir (iklâb). Diğer harflerden önce ise ihfâ, yani gizleme yapılır.'),
  ]),
  CezeriBab('بَابُ الْمَدِّ', 'Med babı', [
    CezeriBeyit('وَالْمَدُّ لَازِمٌ وَوَاجِبٌ أَتَى',
        'فَلَازِمٌ إِنْ جَاءَ بَعْدَ حَرْفِ مَدِّ',
        'Med harfinden sonra aynı kelimede sükûn gelirse med lâzım olur.'),
    CezeriBeyit('وَوَاجِبٌ إِنْ جَاءَ قَبْلَ هَمْزَةٍ',
        'وَجَائِزٌ إِذَا أَتَى مُنْفَصِلًا',
        'Med harfinden sonra aynı kelimede hemze gelirse med vâcib olur. Ayrı kelimede hemze gelirse med caiz olur.'),
    CezeriBeyit('وَجَائِزٌ وَهْوَ قَصْرٌ ثُبِتَا',
        'سَاكِنٌ حَالَيْنِ وَبِالطُّولِ يُمَدّ',
        'Vakfta sükûn geldiğinde med hem kısa hem uzun okunabilir.'),
  ]),
  CezeriBab('بَابُ مَخَارِجِ الْحُرُوفِ', 'Mahreçler babı', [
    CezeriBeyit('مَخَارِجُ الْحُرُوفِ سَبْعَةَ عَشَرْ',
        'لِلْجَوْفِ أَلِفٌ وَأُخْتَاهَا وَهِيَ',
        'Harflerin mahreçleri on yedi tanedir. Med harfleri (elif ve benzerleri) cevf, yani boğaz boşluğundan çıkar.'),
    CezeriBeyit('ثُمَّ لِأَقْصَى الْحَلْقِ هَمْزٌ هَاءُ',
        'أَدْنَاهُ غَيْنٌ خَاؤُهَا وَالْقَافُ',
        'Boğazın en dip kısmından hemze ve hâ, öne doğru kısmından ğayn ve hâ (خ) çıkar.'),
    CezeriBeyit('أَقْصَى اللِّسَانِ فَوْقُ ثُمَّ الْكَافُ',
        'وَالضَّادُ مِنْ حَافَتِهِ إِذْ وَلِيَا',
        'Dilin arka üst kısmından kâf; dilin kenarından ve ona bitişik yerden dâd çıkar.'),
  ]),
  CezeriBab('بَابُ اللَّامَاتِ وَأَحْكَامٍ مُتَفَرِّقَةٍ', 'Lâmlar ve çeşitli hükümler', [
    CezeriBeyit('وَفَخِّمِ اللَّامَ مِنِ اسْمِ اللهِ',
        'وَحَرِّفِ الِاسْتِعْلَاءِ فَخِّمْ وَاخْصُصَا',
        'Allah lafzındaki lâm kalın okunur. İsti‘lâ harfleri de kalın okunur; bunları özellikle ayırt et.'),
  ]),
  CezeriBab('بَابُ الرَّاءَاتِ', 'Râlar babı', [
    CezeriBeyit('وَرَقِّقِ الرَّاءَ إِذَا مَا كُسِرَتْ',
        'إِنْ لَمْ تَكُنْ مِنْ قَبْلِ حَرْفِ اسْتِعْلَا',
        'Râ kesreli olduğunda ince okunur. Ancak kesreden önce isti‘lâ harfi varsa bu hüküm uygulanmaz.'),
    CezeriBeyit('كَذَاكَ بَعْدَ الْكَسْرِ حَيْثُ سَكَنَتْ',
        'أَوْ كَانَتِ الْكَسْرَةُ لَيْسَتْ أَصْلًا',
        'Kesreden sonra râ sâkin olursa, ya da kesre aslî değilse, aynı ince okuyuş geçerlidir.'),
    CezeriBeyit('وَأَخْفِ تَكْرِيرًا إِذَا تُشَدَّدُ',
        'وَالْخُلْفُ فِي فِرْقٍ لِكَسْرٍ يُوجَدُ',
        'Şeddeli râda tekrar (titreşim) hafif tutulur. Farklı okuyuşlar kesre bulunup bulunmamasına göre değişir.'),
  ]),
];
