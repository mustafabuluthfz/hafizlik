import 'package:flutter/material.dart';

class YakindaEkrani extends StatelessWidget {
  final String baslik;

  const YakindaEkrani({super.key, required this.baslik});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: const Center(child: Text('Bu bölüm yakında eklenecek.')),
    );
  }
}
