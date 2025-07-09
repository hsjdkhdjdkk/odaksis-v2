import 'dart:math';
import 'package:flutter/material.dart';
import 'bardak_detay_page.dart';
import 'bardak_guncel_durum_page.dart';
import 'bardak_calisma_sure_page.dart';
import 'bardak_deneme_sonuc_page.dart';
import 'bardak_deneme_istatistik_page.dart';
import 'eksiklerim_page.dart';

class BardakPage extends StatefulWidget {
  const BardakPage({super.key});

  @override
  State<BardakPage> createState() => _BardakPageState();
}

class _BardakPageState extends State<BardakPage> {
  int selectedIndex = 0;

  final List<String> sekmeler = [
    'Bardağın Dolu Tarafı',
    'Çalışma Sürem',
    'Güncel Durumum ve Hedeflerim',
    'Deneme Sonuçlarım',
    'Deneme İstatistiklerim',
    'Eksiklerim',
  ];

  final List<Widget> sayfalar = [
    const BardakDetaySecimPage(),
    const BardakCalismaSurePage(),
    const BardakGuncelDurumPage(),
    const BardakDenemeSonucPage(),
    const BardakDenemeIstatistikPage(),
    const EksiklerimPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Odaksis Bardak Ekranı'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sekmeler.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ChoiceChip(
                    label: Text(sekmeler[index]),
                    selected: selectedIndex == index,
                    onSelected: (_) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(child: sayfalar[selectedIndex]),
        ],
      ),
    );
  }
}

class BardakDetaySecimPage extends StatelessWidget {
  const BardakDetaySecimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainCup(context, 'TYT'),
          _buildMainCup(context, 'AYT'),
        ],
      ),
    );
  }

  Widget _buildMainCup(BuildContext context, String label) {
    final percent = Random().nextInt(100);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BardakDetayPage(
              type: label,
              onAverageCalculated: (_) {},
            ),
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: 80,
            child: CustomPaint(
              painter: OpenTopGlassPainter(percent / 100),
              child: Center(
                child: Text('$percent%'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
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
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final su = Paint()
      ..color = Colors.blue.shade200
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
