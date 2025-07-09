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

    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Ders Seçimi'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlue.shade100,
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.lightBlue.shade300,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    dersler[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
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
