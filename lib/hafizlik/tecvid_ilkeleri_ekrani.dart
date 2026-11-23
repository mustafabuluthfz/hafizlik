import 'package:flutter/material.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';

class TecvidIlke {
  final String ad;
  final String arapca;
  final String turkce;
  final String ornek;
  const TecvidIlke(this.ad, this.arapca, this.turkce, this.ornek);
}

/// Temel tecvid ilkeleri: Arapça ifade ve Türkçe açıklama birlikte verilir.
const List<TecvidIlke> tecvidIlkeleri = [
  TecvidIlke('İzhâr-ı halkî',
      'يُظْهَرُ النُّونُ السَّاكِنَةُ وَالتَّنْوِينُ عِنْدَ حُرُوفِ الْحَلْقِ: الْهَمْزَةِ وَالْهَاءِ وَالْعَيْنِ وَالْحَاءِ وَالْغَيْنِ وَالْخَاءِ',
      'Sâkin nûn veya tenvinden sonra ء ه ع ح غ خ gelirse nûn açık okunur.', 'مِنْ آمَنَ'),
  TecvidIlke('İdğâm bi-ğunne',
      'يُدْغَمُ النُّونُ السَّاكِنَةُ وَالتَّنْوِينُ بِغُنَّةٍ فِي حُرُوفِ «يَنْمُو»',
      'ي ن م و harflerinden önce nûn birleşir ve ğunneyle okunur.', 'مِنْ وَلِيٍّ'),
  TecvidIlke('İdğâm bilâ ğunne',
      'يُدْغَمُ بِلَا غُنَّةٍ فِي اللَّامِ وَالرَّاءِ',
      'ل ve r harflerinden önce nûn ğunnesiz birleşir.', 'مِنْ رَبِّكَ'),
  TecvidIlke('İklâb',
      'تُقْلَبُ النُّونُ السَّاكِنَةُ مِيمًا عِنْدَ الْبَاءِ مَعَ الْغُنَّةِ',
      'Bâ’dan önce nûn, ğunneli bir mîm sesine çevrilir.', 'مِنْ بَعْدِ'),
  TecvidIlke('İhfâ',
      'تُخْفَى النُّونُ السَّاكِنَةُ وَالتَّنْوِينُ عِنْدَ بَاقِي الْحُرُوفِ',
      'Diğer harflerden önce nûn ve tenvin gizlenerek, ğunneyle okunur.', 'مِنْ قَبْلُ'),
  TecvidIlke('İzhâr-ı şefevî',
      'تُظْهَرُ الْمِيمُ السَّاكِنَةُ عِنْدَ جَمِيعِ الْحُرُوفِ إِلَّا الْبَاءَ وَالْمِيمَ',
      'Sâkin mîmden sonra bâ ve mîm dışındaki harfler gelirse mîm açık okunur.', 'لَهُمْ هُدًى'),
  TecvidIlke('İhfâ-yı şefevî',
      'تُخْفَى الْمِيمُ السَّاكِنَةُ عِنْدَ الْبَاءِ مَعَ الْغُنَّةِ',
      'Sâkin mîmden sonra bâ gelirse dudaklar hafifçe kapanır, ğunne yapılır.', 'تَرْمِيهِمْ بِحِجَارَةٍ'),
  TecvidIlke('İdğâm-ı şefevî',
      'تُدْغَمُ الْمِيمُ السَّاكِنَةُ فِي الْمِيمِ بِغُنَّةٍ',
      'Sâkin mîmden sonra mîm gelirse iki mîm birleşir, ğunneyle okunur.', 'لَهُمْ مَا'),
  TecvidIlke('Med-i tabiî',
      'الْمَدُّ الطَّبِيعِيُّ حَرْفُ مَدٍّ بِلَا سَبَبٍ، مِقْدَارُهُ حَرَكَتَانِ',
      'Med harfi, hemze veya sükûn sebebi olmadan gelirse iki hareke uzatılır.', 'قَالَ'),
  TecvidIlke('Med-i muttasıl',
      'إِذَا جَاءَتِ الْهَمْزَةُ بَعْدَ حَرْفِ الْمَدِّ فِي كَلِمَةٍ وَاحِدَةٍ',
      'Med harfinden sonra aynı kelimede hemze gelirse uzatma 4–5 hareke olur.', 'جَاءَ'),
  TecvidIlke('Med-i munfasıl',
      'إِذَا جَاءَتِ الْهَمْزَةُ بَعْدَ حَرْفِ الْمَدِّ فِي كَلِمَةٍ أُخْرَى',
      'Med harfi kelime sonunda, hemze sonraki kelimenin başında gelirse caiz med olur.', 'بِمَا أُنْزِلَ'),
  TecvidIlke('Med-i lâzım',
      'إِذَا جَاءَ بَعْدَ حَرْفِ الْمَدِّ سُكُونٌ لَازِمٌ',
      'Med harfinden sonra kelimede asıl ve sabit sükûn varsa uzatma 6 hareke olur.', 'الضَّالِّينَ'),
  TecvidIlke('Kalkale',
      'الْقَلْقَلَةُ فِي حُرُوفِ «قُطْبُ جَدٍ» إِذَا كَانَتْ سَاكِنَةً',
      'ق ط ب ج د sâkin olduğunda sesin yankılanması (kalkale) oluşur.', 'يَقْذِفُ'),
  TecvidIlke('Tefhîm (kalın okuma)',
      'تُفَخَّمُ الْحُرُوفُ الْمُسْتَعْلِيَةُ: الْخَاءُ وَالصَّادُ وَالضَّادُ وَالْغَيْنُ وَالْقَافُ وَالطَّاءُ وَالظَّاءُ',
      'İsti‘lâ harfleri (خ ص ض غ ق ط ظ) dili yükselterek kalın okunur.', 'الصِّرَاطَ'),
  TecvidIlke('Terkîk (ince okuma)',
      'تُرَقَّقُ الْحُرُوفُ الْمُسْتَفِلَةُ',
      'Diğer harfler (isti‘lâ dışındakiler) ince okunur.', 'بِسْمِ'),
  TecvidIlke('Lâm-ı şemsiyye',
      'اللَّامُ السَّاكِنَةُ الشَّمْسِيَّةُ لَا تُنْطَقُ وَتُدْغَمُ فِي الْحَرْفِ الَّذِي بَعْدَهَا',
      'ال’dan sonra şemsî harf gelirse lâm okunmaz, sonraki harfe katılır.', 'الشَّمْسُ'),
  TecvidIlke('Lâm-ı kameriyye',
      'اللَّامُ الْقَمَرِيَّةُ تُظْهَرُ',
      'ال’dan sonra kamerî harf gelirse lâm açık okunur.', 'الْقَمَرُ'),
  TecvidIlke('Ğunne',
      'الْغُنَّةُ صِفَةٌ تَخْرُجُ مِنَ الْخَيْشُومِ وَمِقْدَارُهَا حَرَكَتَانِ',
      'Burundan çıkan, iki hareke süren sestir.', 'إِنَّ'),
  TecvidIlke('Vakf',
      'الْوَقْفُ قَطْعُ الصَّوْتِ عَلَى آخِرِ الْكَلِمَةِ زَمَنًا يَسِيرًا بِنِيَّةِ اسْتِئْنَافِ الْقِرَاءَةِ',
      'Kelime sonunda, okumaya devam etme niyetiyle sesi kısa süre kesmektir.', 'الْعَالَمِينَ'),
];

class TecvidIlkeleriEkrani extends StatelessWidget {
  const TecvidIlkeleriEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tecvid İlkeleri')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tecvidIlkeleri.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = tecvidIlkeleri[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.ad, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(t.arapca,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, height: 1.8, color: kYesil)),
                  const Divider(height: 18),
                  Text(t.turkce, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 6),
                  Text('Örnek: ${t.ornek}',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontFamily: kMushafFontu, fontSize: 18, color: Colors.brown.shade700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
