import 'package:flutter/material.dart';
import 'video_listesi_page.dart';

class SeviyeSecimiPage extends StatelessWidget {
  const SeviyeSecimiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final seviyeler = ['TYT', 'AYT'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Seviye Seçimi'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
            ),
            itemCount: seviyeler.length,
            itemBuilder: (context, index) {
              final seviye = seviyeler[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VideoListesiPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.lightBlue.shade100,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.lightBlue.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.lightBlue.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        seviye,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
