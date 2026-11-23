import 'package:flutter/material.dart';

import 'tema.dart';

/// Ortak kart: tutarlı boşluk, köşe ve dokunma efekti.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(kBosluk16),
  });

  @override
  Widget build(BuildContext context) {
    final icerik = Padding(padding: padding, child: child);
    return Card(
      child: onTap == null
          ? icerik
          : InkWell(
              borderRadius: BorderRadius.circular(kYaricap16),
              onTap: onTap,
              child: icerik,
            ),
    );
  }
}

/// Bölüm başlığı: büyük, koyu ve alt boşluklu.
class BolumBasligi extends StatelessWidget {
  final String metin;
  final Widget? sag;

  const BolumBasligi(this.metin, {super.key, this.sag});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kBosluk12, top: kBosluk8),
      child: Row(
        children: [
          Expanded(
            child: Text(metin, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (sag != null) sag!,
        ],
      ),
    );
  }
}

/// Boş durum: simge, başlık ve açıklama.
class BosDurum extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String? aciklama;

  const BosDurum({super.key, required this.ikon, required this.baslik, this.aciklama});

  @override
  Widget build(BuildContext context) {
    final soluk = Theme.of(context).colorScheme.onSurface.withOpacity(0.55);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kBosluk24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 56, color: kAltin),
            const SizedBox(height: kBosluk12),
            Text(baslik,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (aciklama != null) ...[
              const SizedBox(height: kBosluk8),
              Text(aciklama!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: soluk)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Küçük bilgi rozeti (seri, gün sayısı vb.).
class BilgiRozeti extends StatelessWidget {
  final IconData ikon;
  final String metin;
  final Color renk;

  const BilgiRozeti({super.key, required this.ikon, required this.metin, required this.renk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kBosluk12, vertical: 6),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.12),
        borderRadius: BorderRadius.circular(kYaricap20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: renk),
          const SizedBox(width: kBosluk4),
          Text(metin,
              style: TextStyle(fontSize: 12, color: renk, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
