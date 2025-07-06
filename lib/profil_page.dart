import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_form_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String isim = "Ali";
  String soyisim = "Yılmaz";
  String cinsiyet = "Erkek";
  String dogumTarihi = "01/01/2005";
  String hedefUni = "Boğaziçi";
  String hedefBolum = "Tıp";

  int guncelTYT = 60;
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
      isim = prefs.getString('isim') ?? isim;
      soyisim = prefs.getString('soyisim') ?? soyisim;
      cinsiyet = prefs.getString('cinsiyet') ?? cinsiyet;
      dogumTarihi = prefs.getString('dogumTarihi') ?? dogumTarihi;
      hedefUni = prefs.getString('hedefUni') ?? hedefUni;
      hedefBolum = prefs.getString('hedefBolum') ?? hedefBolum;

      guncelTYT = prefs.getInt('guncelTYT') ?? guncelTYT;
      hedefTYT = prefs.getInt('hedefTYT') ?? hedefTYT;

      guncelAYT = prefs.getInt('guncelAYT') ?? guncelAYT;
      hedefAYT = prefs.getInt('hedefAYT') ?? hedefAYT;
    });
  }

  String getEmoji() {
    if (hedefBolum.toLowerCase().contains('tıp')) {
      return cinsiyet == 'Kadın' ? '👩‍⚕️' : '👨‍⚕️';
    } else if (hedefBolum.toLowerCase().contains('mühendis')) {
      return cinsiyet == 'Kadın' ? '👩‍💻' : '👨‍💻';
    } else if (hedefBolum.toLowerCase().contains('hukuk')) {
      return '⚖️';
    } else {
      return '🧑';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tytKalan = hedefTYT - guncelTYT;
    final aytKalan = hedefAYT - guncelAYT;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profil'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getEmoji(),
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$isim $soyisim",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Cinsiyet: $cinsiyet"),
                          Text("Doğum Tarihi: $dogumTarihi"),
                          const SizedBox(height: 12),
                          Text("Hedef Üniversite: $hedefUni"),
                          Text("Hedef Bölüm: $hedefBolum"),
                          const SizedBox(height: 12),
                          const Divider(),
                          const Text(
                            "odaksis.com.tr",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.lightBlue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentFormPage(),
                          ),
                        );
                        loadData(); // Dönünce güncelle!
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TYT Progress
            Text(
              "TYT İlerleme",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: CustomPaint(
                  foregroundPainter: CircleGraphPainter(
                    guncel: guncelTYT,
                    hedef: hedefTYT,
                    toplam: 120,
                    renkGuncel: Colors.redAccent,
                    renkHedef: Colors.green,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "Hedefe ${tytKalan > 0 ? tytKalan : 0} net kaldı",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            // AYT Progress
            Text(
              "AYT İlerleme",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: CustomPaint(
                  foregroundPainter: CircleGraphPainter(
                    guncel: guncelAYT,
                    hedef: hedefAYT,
                    toplam: 160,
                    renkGuncel: Colors.redAccent,
                    renkHedef: Colors.green,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "Hedefe ${aytKalan > 0 ? aytKalan : 0} net kaldı",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleGraphPainter extends CustomPainter {
  final int guncel;
  final int hedef;
  final int toplam;
  final Color renkGuncel;
  final Color renkHedef;

  CircleGraphPainter({
    required this.guncel,
    required this.hedef,
    required this.toplam,
    required this.renkGuncel,
    required this.renkHedef,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 14;
    double radius = size.width / 2 - strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);

    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final guncelPaint = Paint()
      ..color = renkGuncel
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hedefPaint = Paint()
      ..color = renkHedef
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    double guncelAngle = 2 * pi * (guncel / toplam);
    double hedefAngle = 2 * pi * (hedef / toplam);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      guncelAngle,
      false,
      guncelPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + guncelAngle,
      hedefAngle - guncelAngle,
      false,
      hedefPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
