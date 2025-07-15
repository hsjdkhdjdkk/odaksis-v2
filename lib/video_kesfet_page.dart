// lib/video_kesfet_page.dart
import 'package:flutter/material.dart';

class VideoKesfetPage extends StatefulWidget {
  const VideoKesfetPage({super.key});

  @override
  State<VideoKesfetPage> createState() => _VideoKesfetPageState();
}

class _VideoKesfetPageState extends State<VideoKesfetPage> {
  String selectedLevel = 'TYT';

  final Map<String, Map<String, List<String>>> konular = {
    'TYT': {
      'Türkçe': [
        'Ses Bilgisi', 'Yazım Kuralları', 'Noktalama İşaretleri',
        'Sözcükte Anlam', 'Cümlede Anlam', 'Paragrafta Anlam',
        'Yazılış Özellikleri'
      ],
      'Matematik': [
        'Temel Kavramlar', 'Sayı Basamakları', 'Bölme ve Bölünebilme',
        'EBOB-EKOK', 'Rasyonel Sayılar', 'Üslü Sayılar', 'Köklü Sayılar',
        'Mutlak Değer', 'Çarpanlara Ayırma', 'Oran Orantı', 'Denklem Çözme',
        'Problemler', 'Kümeler', 'Fonksiyonlar', 'Geometri Temel'
      ],
      'Fen': ['Fizik', 'Kimya', 'Biyoloji'],
      'Sosyal': ['Tarih', 'Coğrafya', 'Felsefe', 'Din Kültürü']
    },
    'AYT': {
      'Türk Dili ve Edebiyatı': [
        'Divan Edebiyatı', 'Halk Edebiyatı', 'Tanzimat Edebiyatı',
        'Cumhuriyet Edebiyatı', 'Modern Türk Edebiyatı'
      ],
      'Tarih': [
        'İslamiyet Öncesi', 'Türk İslam Tarihi', 'Osmanlı Tarihi',
        'Türkiye Cumhuriyeti Tarihi'
      ],
      'Coğrafya': [
        'Fiziki Coğrafya', 'Beşeri Coğrafya', 'Türkiye Coğrafyası'
      ],
      'Matematik': ['Fonksiyon', 'Limit', 'Türev', 'İntegral'],
      'Fizik': ['Klasik Mekanik', 'Elektromagnetizma', 'Optik'],
      'Kimya': ['Atom', 'Kimyasal Türler', 'Tepkimeler'],
      'Biyoloji': ['Hücre', 'Genetik', 'Ekoloji']
    },
  };

  @override
  Widget build(BuildContext context) {
    final dersler = konular[selectedLevel]!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Keşfet'),
        backgroundColor: Colors.white60,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleButtons(
                  isSelected: [selectedLevel == 'TYT', selectedLevel == 'AYT'],
                  onPressed: (i) {
                    setState(() {
                      selectedLevel = i == 0 ? 'TYT' : 'AYT';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: Colors.lightBlue,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('TYT'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('AYT'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...dersler.entries.map(
                  (e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: e.value.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (_, i) {
                      final konu = e.value[i];
                      return InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Videolar geliyor: $konu')),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            konu,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
