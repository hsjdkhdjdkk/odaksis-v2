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
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profil - Paketler'),
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

            const Text(
              "Üyelik Planları",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                // Başlık satırı
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE0F7FA)),
                  children: const [
                    SizedBox(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Freemium',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                ),

                _buildRow('Sınırlı Video (Günde 3)', Icons.check_circle, Icons.check_circle),
                _buildRow('Sınırsız Video', Icons.close, Icons.check_circle),
                _buildRow('Odaklanma Modu', Icons.check_circle, Icons.check_circle),
                _buildRow('Program Hazırlama', Icons.check_circle, Icons.check_circle),
                _buildRow('Aralıklı Tekrar', Icons.close, Icons.check_circle),
                _buildRow('Detaylı Deneme Analizi', Icons.close, Icons.check_circle),
                _buildRow('Destek & İletişim', Icons.close, Icons.check_circle),

                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE0F7FA)),
                  children: const [
                    SizedBox(),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'ÜCRETSİZ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '89.99 TL / AY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium üyelik satın alma sayfası yakında!')),
                );
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('Premium Satın Al'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static TableRow _buildRow(String feature, IconData freeIcon, IconData premiumIcon) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            feature,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            freeIcon,
            color: freeIcon == Icons.check_circle ? Colors.green : Colors.red,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            premiumIcon,
            color: premiumIcon == Icons.check_circle ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
