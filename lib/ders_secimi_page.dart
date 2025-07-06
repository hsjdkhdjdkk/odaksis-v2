import 'package:flutter/material.dart';
import 'seviye_secimi_page.dart';

class DersSecimiPage extends StatelessWidget {
  const DersSecimiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dersler = [
      'Türkçe',
      'Matematik',
      'Fizik',
      'Kimya',
      'Biyoloji',
      'Tarih',
      'Coğrafya',
      'Felsefe',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Ders Seçimi'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: dersler.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SeviyeSecimiPage()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.lightBlue.shade200, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    dersler[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
