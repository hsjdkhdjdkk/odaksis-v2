import 'dart:math';
import 'package:flutter/material.dart';
import 'bardak_detay_page.dart';
import 'eksiklerim_page.dart';

class BardakPage extends StatefulWidget {
  const BardakPage({super.key});

  @override
  State<BardakPage> createState() => _BardakPageState();
}

class _BardakPageState extends State<BardakPage> {
  int tytDoluluk = 50;
  int aytDoluluk = 70;

  List<int> dailyMinutes = List.generate(7, (_) => 30 + Random().nextInt(180));
  int? selectedDayIndex;

  final List<String> weekDays = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  void rastgeleDoldur() {
    setState(() {
      tytDoluluk = Random().nextInt(100);
      aytDoluluk = Random().nextInt(100);
    });
  }

  String formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}sa ${mins}dk';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Odaksis Bardak Ekranı'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMainCup(
                  label: 'TYT',
                  percent: tytDoluluk,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BardakDetayPage(
                          type: 'TYT',
                          onAverageCalculated: (value) {
                            setState(() {
                              tytDoluluk = value.toInt();
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildMainCup(
                  label: 'AYT',
                  percent: aytDoluluk,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BardakDetayPage(
                          type: 'AYT',
                          onAverageCalculated: (value) {
                            setState(() {
                              aytDoluluk = value.toInt();
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
            const Text(
              '📊 Günlük Ekran Süresi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(dailyMinutes.length, (index) {
                  final maxValue = dailyMinutes.reduce(max).toDouble();
                  final value = dailyMinutes[index].toDouble();
                  final heightPercent = value / maxValue;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDayIndex = selectedDayIndex == index ? null : index;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (selectedDayIndex == index)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formatTime(dailyMinutes[index]),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Container(
                          width: 24,
                          height: 200 * heightPercent,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(weekDays[index]),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),

            /// Eksiklerim Butonu
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EksiklerimPage()),
                  );
                },

                icon: const Icon(Icons.warning_amber),
                label: const Text('Eksiklerim'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCup({
    required String label,
    required int percent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 140,
            child: CustomPaint(
              painter: OpenTopGlassPainter(percent / 100),
              child: Center(
                child: Text(
                  '$percent%',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
