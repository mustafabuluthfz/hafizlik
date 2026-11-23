import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ai_hoca_servisi.dart';

class AiHocaEkrani extends StatefulWidget {
  final int? sayfa;
  final String? beklenenMetin;
  final String? taninanMetin;

  const AiHocaEkrani({super.key, this.sayfa, this.beklenenMetin, this.taninanMetin});

  @override
  State<AiHocaEkrani> createState() => _AiHocaEkraniState();
}

class _AiHocaEkraniState extends State<AiHocaEkrani> {
  bool _islemde = false;
  String? _sonuc;
  String? _hata;

  bool get _analizModu => widget.beklenenMetin != null && widget.taninanMetin != null;

  @override
  void initState() {
    super.initState();
    if (_analizModu) _analizEt();
  }

  Future<void> _analizEt() async {
    setState(() { _islemde = true; _hata = null; _sonuc = null; });
    try {
      _sonuc = await AiHocaServisi.instance.analizEt(
        sayfa: widget.sayfa ?? 0,
        beklenenMetin: widget.beklenenMetin ?? '',
        taninanMetin: widget.taninanMetin ?? '',
      );
    } catch (e) {
      _hata = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _islemde = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cihaz İçi Hafızlık Hocası')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Row(children: [Icon(Icons.school_rounded, color: Colors.teal), SizedBox(width: 8), Expanded(child: Text('Çevrimdışı hafızlık yardımcın', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
              SizedBox(height: 10),
              Text('Bu özellik uygulamanın içinde çalışır. harici bir servis, API anahtarı, hesap, başka uygulama veya internet bağlantısı istemez. Okuma metnini Mushaf metniyle cihaz üzerinde karşılaştırır ve tekrar önerileri üretir.'),
              SizedBox(height: 10),
              Text('Önemli sınır: Bu sürüm metin eşleştirme ve kural tabanlı çalışma rehberidir; eğitilmiş ses modeli değildir. Gerçek ses, mahreç, hareke ve tecvid değerlendirmesi yapamaz. Bu kontroller için öğretmen doğrulaması gerekir.', style: TextStyle(fontSize: 12, color: Colors.deepOrange)),
            ]),
          )),
          if (_analizModu) ...[
            const SizedBox(height: 12),
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Ders analizi · Sayfa ${widget.sayfa ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Tanınan kelime sayısı: ${(widget.taninanMetin ?? '').trim().isEmpty ? 0 : (widget.taninanMetin ?? '').trim().split(RegExp(r'\s+')).length}'),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _islemde ? null : _analizEt, icon: const Icon(Icons.auto_awesome), label: const Text('Cihazda yeniden analiz et')),
              ]),
            )),
          ] else ...[
            const SizedBox(height: 12),
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Ders Dinlet ekranından bir okuma tamamladığında bu ekrana dönerek metin karşılaştırmasını ve tekrar önerilerini görebilirsin.'))),
          ],
          if (_islemde) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          if (_hata != null) Card(color: Theme.of(context).colorScheme.errorContainer, child: Padding(padding: const EdgeInsets.all(12), child: Text(_hata!))),
          if (_sonuc != null) Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hocanın değerlendirmesi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SelectableText(_sonuc!),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(
                onPressed: () async { await Clipboard.setData(ClipboardData(text: _sonuc!)); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değerlendirme panoya kopyalandı.'))); },
                icon: const Icon(Icons.copy), label: const Text('Kopyala'),
              )),
            ]),
          )),
        ],
      ),
    );
  }
}
