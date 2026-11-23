import 'package:flutter/material.dart';
import '../ortak/mushaf.dart';
import '../ortak/tema.dart';
import 'cezeri_meal.dart';
import 'cezeri_mukaddime.dart';

class CezeriEkrani extends StatefulWidget {
  const CezeriEkrani({super.key});
  @override
  State<CezeriEkrani> createState() => _CezeriEkraniState();
}

class _CezeriEkraniState extends State<CezeriEkrani> {
  bool _turkceGoster = true;

  Widget _beyit(CezeriBeyit b, String meal) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kKagitRengi,
        borderRadius: BorderRadius.circular(kYaricap12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${b.birinci}  ۝  ${b.ikinci}',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 24, height: 1.9),
          ),
          if (_turkceGoster) ...[
            const Divider(height: 18),
            Text('Meal: $meal', style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
            const SizedBox(height: 6),
            Text('Açıklama: ${b.turkce}', style: TextStyle(height: 1.4, color: Colors.brown.shade700)),
          ],
          if (b.ekBeyit)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Ek beyit', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cezerî Mukaddime')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Muhammed b. el-Cezerî’nin Mukaddime manzumesi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    'Her beyit Arapça okunur, altında Türkçe meal ve açıklaması yer alır. Meal ve açıklamalar öğretim amaçlıdır; harekeler ve okuyuş tercihleri hocanızla teyit edilmelidir.',
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Türkçe meal ve açıklamayı göster'),
                    value: _turkceGoster,
                    onChanged: (v) => setState(() => _turkceGoster = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var bi = 0; bi < cezeriBablar.length; bi++)
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.menu_book_rounded, color: kYesil),
                title: Text(cezeriBablar[bi].ad,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Amiri', fontSize: 20)),
                subtitle: Text(cezeriBablar[bi].turkceAd),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  for (var k = 0; k < cezeriBablar[bi].beyitler.length; k++)
                    _beyit(cezeriBablar[bi].beyitler[k], cezeriMealler[bi][k]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
