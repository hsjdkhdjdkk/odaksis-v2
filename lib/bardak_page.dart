import 'package:flutter/material.dart';
import 'bardak_calisma_sure_page.dart';
import 'bardak_guncel_durum_page.dart';
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
    'Çalışma Sürem',
    'Güncel Durumum ve Hedeflerim',
    'Deneme Sonuçlarım',
    'Deneme İstatistiklerim',
    'Eksiklerim',
  ];

  final List<Widget> sayfalar = [
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
        title: const Text(
          '📊 İstatistiklerim',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
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
