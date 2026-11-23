/// Kur’an’dan ve sahih hadislerden seçilmiş ek dualar.
/// Metinler uygulamaya doğrudan yazılmıştır; Türkçe meallerde kısa ve anlaşılır
/// bir çeviri esas alınmıştır. Diyanet Elif-Ba kitabındaki metinler buraya
/// alınmamıştır; kitap sayfaları paylaşılırsa oradan ekleme yapılabilir.
class EkDua {
  final String ad;
  final String arapca;
  final String turkce;
  final String kaynak;
  const EkDua(this.ad, this.arapca, this.turkce, this.kaynak);
}

const List<EkDua> ekDualar = [
  EkDua(
    'Rabbenâ lâ tuzig',
    'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً إِنَّكَ أَنتَ الْوَهَّابُ',
    'Rabbimiz, bizi hidayete erdirdikten sonra kalplerimizi saptırma ve bize katından rahmet ver. Şüphesiz sen çok bağışlayansın.',
    'Âl-i İmrân 3:8',
  ),
  EkDua(
    'Rabbenâ ağfir',
    'رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
    'Rabbimiz, günahlarımızı ve işimizdeki aşırılıklarımızı bağışla, ayaklarımızı sabit kıl ve kâfir topluluğa karşı bize yardım et.',
    'Âl-i İmrân 3:147',
  ),
  EkDua(
    'Musa’nın duası',
    'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي',
    'Rabbim, göğsümü genişlet, işimi kolaylaştır, dilimdeki düğümü çöz ki sözümü anlasınlar.',
    'Tâhâ 20:25-28',
  ),
  EkDua(
    'Rabbi innî limâ',
    'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
    'Rabbim, bana indirdiğin her hayra muhtacım.',
    'Kasas 28:24',
  ),
  EkDua(
    'Rabbenâ hab lenâ',
    'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
    'Rabbimiz, eşlerimizden ve soyumuzdan bize göz aydınlığı ver ve bizi takva sahiplerine önder kıl.',
    'Furkân 25:74',
  ),
  EkDua(
    'Rabbenâ zalemnâ',
    'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    'Rabbimiz, kendimize zulmettik. Bizi bağışlamaz ve bize merhamet etmezsen, mutlaka kaybedenlerden oluruz.',
    'A’râf 7:23',
  ),
  EkDua(
    'Namazı dosdoğru kılan nesil',
    'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
    'Rabbim, beni ve soyumdan olanları namazı dosdoğru kılanlardan eyle. Rabbimiz, duamı kabul et.',
    'İbrâhîm 14:40',
  ),
  EkDua(
    'Tuvalete girerken',
    'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
    'Allah’ım, erkek ve dişi şeytanların şerrinden sana sığınırım.',
    'Buhârî, Müslim',
  ),
  EkDua(
    'Yemekten sonra',
    'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
    'Bizi yediren, içiren ve Müslüman kılan Allah’a hamd olsun.',
    'Ebû Dâvûd, Tirmizî',
  ),
  EkDua(
    'Sabah duası',
    'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    'Allah’ım, seninle sabahladık, seninle akşamladık, seninle yaşarız, seninle ölürüz ve dönüş sanadır.',
    'Tirmizî',
  ),
  EkDua(
    'Kaygı ve üzüntüde',
    'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ، وَغَلَبَةِ الرِّجَالِ',
    'Allah’ım, keder ve üzüntüden, âcizlik ve tembellikten, cimrilik ve korkaklıktan, borç yükünden ve insanların baskısından sana sığınırım.',
    'Buhârî',
  ),
  EkDua(
    'Yolculukta',
    'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى',
    'Allah’ım, bu yolculuğumuzda senden iyilik, takva ve senin razı olacağın ameller isteriz.',
    'Müslim',
  ),
];
