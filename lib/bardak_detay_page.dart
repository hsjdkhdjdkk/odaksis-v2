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
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final crossAxisCount = isTablet ? 3 : 2;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
              children: list.map((ders) {
                final value = doluluklar[ders]!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: isTablet ? 200 : 140,
                      width: isTablet ? 100 : 80,
                      child: CustomPaint(
                        painter: OpenTopGlassPainter(value),
                        child: Center(
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ders,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.blueGrey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
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
      ..color = Colors.lightBlue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final gradient = LinearGradient(
      colors: [Colors.lightBlueAccent, Colors.blue.shade700],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final su = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, height)
      ..lineTo(width, height)
      ..lineTo(width, 0)
      ..close();

    canvas.drawPath(path, outline);

    final doluHeight = height * doluluk;
    final suRect = Rect.fromLTWH(0, height - doluHeight, width, doluHeight);
    canvas.drawRect(suRect, su);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
