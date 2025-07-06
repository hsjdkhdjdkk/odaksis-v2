import 'dart:math';
import 'package:flutter/material.dart';

class BardakDetayPage extends StatefulWidget {
  final String type;
  final Function(double) onAverageCalculated;

  const BardakDetayPage({
    super.key,
    required this.type,
    required this.onAverageCalculated,
  });

  @override
  State<BardakDetayPage> createState() => _BardakDetayPageState();
}

class _BardakDetayPageState extends State<BardakDetayPage> {
  final Map<String, List<String>> dersler = {
    'TYT': [
      'Türkçe',
      'Matematik',
      'Tarih',
      'Coğrafya',
      'Felsefe',
      'Fizik',
      'Kimya',
      'Biyoloji',
    ],
    'AYT': [
      'Matematik',
      'Fizik',
      'Kimya',
      'Biyoloji',
    ],
  };

  final Map<String, double> doluluklar = {};

  @override
  void initState() {
    super.initState();
    final list = dersler[widget.type]!;
    for (var ders in list) {
      doluluklar[ders] = Random().nextDouble();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => hesaplaOrtalama());
  }

  void hesaplaOrtalama() {
    final ort = doluluklar.values.reduce((a, b) => a + b) / doluluklar.length;
    widget.onAverageCalculated(ort);
  }

  @override
  Widget build(BuildContext context) {
    final list = dersler[widget.type]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} Ders Bardakları'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2, // ✅ 2 sütun!
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.6, // oran sabit, bardak dik
          children: list.map((ders) {
            final value = doluluklar[ders]!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 140,
                  width: 80,
                  child: CustomPaint(
                    painter: OpenTopGlassPainter(value),
                    child: Center(
                      child: Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ders,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class OpenTopGlassPainter extends CustomPainter {
  final double doluluk;

  OpenTopGlassPainter(this.doluluk);

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final su = Paint()
      ..color = Colors.lightBlue.shade200
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, height)
      ..lineTo(width, height)
      ..lineTo(width, 0);

    canvas.drawPath(path, outline);

    final doluHeight = height * doluluk;
    final suRect = Rect.fromLTWH(0, height - doluHeight, width, doluHeight);
    canvas.drawRect(suRect, su);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
