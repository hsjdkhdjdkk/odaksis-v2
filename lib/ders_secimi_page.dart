import 'package:flutter/material.dart';
import 'video_listesi_page.dart';

class DersSecimiPage extends StatefulWidget {
  const DersSecimiPage({super.key});

  @override
  State<DersSecimiPage> createState() => _DersSecimiPageState();
}

class _DersSecimiPageState extends State<DersSecimiPage> {
  String selectedLevel = 'TYT';

  final Map<String, List<String>> dersler = {
    'TYT': [
      'Türkçe',
      'Matematik',
      'Fizik',
      'Kimya',
      'Biyoloji',
      'Tarih',
      'Coğrafya',
      'Felsefe',
    ],
    'AYT': [
      'Matematik',
      'Fizik',
      'Kimya',
      'Biyoloji',
      'Edebiyat',
      'Tarih',
      'Coğrafya',
      'Felsefe',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final dersList = dersler[selectedLevel]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '📚 Ders Seçimi',
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildLevelButton('TYT'),
                const SizedBox(width: 12),
                _buildLevelButton('AYT'),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dersList.length,
        itemBuilder: (context, index) {
          final ders = dersList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.lightBlue.shade100, width: 1),
            ),
            child: ListTile(
              title: Text(
                ders,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VideoListesiPage(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelButton(String level) {
    final isSelected = selectedLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          level,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
