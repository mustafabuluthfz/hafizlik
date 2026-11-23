import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tema.dart';

/// Sekizgen yıldızlardan oluşan İslami geometrik desen.
/// Canlı varlık içermez; yalnızca çizgi ve geometri kullanır.
class IslimiDesen extends CustomPainter {
  final Color renk;
  final double hucre;

  const IslimiDesen({this.renk = kAltin, this.hucre = 64});

  @override
  void paint(Canvas canvas, Size size) {
    final kalem = Paint()
      ..color = renk.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..isAntiAlias = true;

    final yari = hucre / 2;
    for (double x = -yari; x < size.width + hucre; x += hucre) {
      for (double y = -yari; y < size.height + hucre; y += hucre) {
        _yildiz(canvas, Offset(x, y), yari, kalem);
      }
    }
  }

  void _yildiz(Canvas canvas, Offset merkez, double r, Paint kalem) {
    const noktaSayisi = 16; // 8 sivri uç
    final yol = Path();
    for (var i = 0; i < noktaSayisi; i++) {
      final aci = -math.pi / 2 + i * math.pi / (noktaSayisi / 2);
      final uzaklik = i.isEven ? r : r * 0.48;
      final nokta = Offset(
        merkez.dx + uzaklik * math.cos(aci),
        merkez.dy + uzaklik * math.sin(aci),
      );
      if (i == 0) {
        yol.moveTo(nokta.dx, nokta.dy);
      } else {
        yol.lineTo(nokta.dx, nokta.dy);
      }
    }
    yol.close();
    canvas.drawPath(yol, kalem);
  }

  @override
  bool shouldRepaint(covariant IslimiDesen eski) =>
      eski.renk != renk || eski.hucre != hucre;
}
