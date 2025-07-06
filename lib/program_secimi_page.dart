import 'package:flutter/material.dart';
import 'tyt_program_page.dart'; // ✅ Bu senin form+takvim sayfan

class ProgramSecimiPage extends StatelessWidget {
  const ProgramSecimiPage({super.key});

  void _onImageTap(BuildContext context, String program) {
    if (program == 'TYT Programı') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TytProgramPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$program seçildi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Program Seçimi'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBigBanner(
            context,
            image: 'assets/tyt.jpg', // ✅ Yeni TYT resmi
            label: 'TYT Programı',
            onTap: () => _onImageTap(context, 'TYT Programı'),
          ),
          const SizedBox(height: 16),
          _buildBigBanner(
            context,
            image: 'assets/ayt.jpg', // ✅ Yeni AYT resmi
            label: 'AYT Programı',
            onTap: () => _onImageTap(context, 'AYT Programı'),
          ),
          const SizedBox(height: 16),
          _buildBigBanner(
            context,
            image: 'assets/emergency.jpg', // ✅ Emergency resmi
            label: 'Emergency',
            onTap: () => _onImageTap(context, 'Emergency'),
          ),
          const SizedBox(height: 16),
          _buildBigBanner(
            context,
            image: 'assets/erime_yuksel.jpg', // ✅ NOGIVEUP resmi
            label: 'NOGIVEUP',
            onTap: () => _onImageTap(context, 'NOGIVEUP'),
          ),
        ],
      ),
    );
  }

  Widget _buildBigBanner(
      BuildContext context, {
        required String image,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 1, // Oran sabit kalır!
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
