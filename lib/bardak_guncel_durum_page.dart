import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BardakGuncelDurumPage extends StatefulWidget {
  const BardakGuncelDurumPage({super.key});

  @override
  State<BardakGuncelDurumPage> createState() => _BardakGuncelDurumPageState();
}

class _BardakGuncelDurumPageState extends State<BardakGuncelDurumPage> {
  int guncelTYT = 50;
  int hedefTYT = 90;
  int guncelAYT = 40;
  int hedefAYT = 80;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      guncelTYT = prefs.getInt('guncelTYT') ?? guncelTYT;
      hedefTYT = prefs.getInt('hedefTYT') ?? hedefTYT;
      guncelAYT = prefs.getInt('guncelAYT') ?? guncelAYT;
      hedefAYT = prefs.getInt('hedefAYT') ?? hedefAYT;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tytPercent = (guncelTYT / hedefTYT).clamp(0.0, 1.0);
    final aytPercent = (guncelAYT / hedefAYT).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            "TYT Durumu",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            width: 150,
            child: CustomPaint(
              painter: CircleGraphPainter(
                percent: tytPercent,
                color: Colors.blueAccent,
              ),
              child: Center(
                child: Text("${(tytPercent * 100).toStringAsFixed(1)}%"),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "AYT Durumu",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            width: 150,
            child: CustomPaint(
              painter: CircleGraphPainter(
                percent: aytPercent,
                color: Colors.green,
              ),
              child: Center(
                child: Text("${(aytPercent * 100).toStringAsFixed(1)}%"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleGraphPainter extends CustomPainter {
  final double percent;
  final Color color;

  CircleGraphPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 16;
    double radius = size.width / 2 - strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);

    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    double sweepAngle = 2 * pi * percent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
