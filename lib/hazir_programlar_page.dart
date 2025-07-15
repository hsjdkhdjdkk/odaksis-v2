import 'package:flutter/material.dart';
import 'tyt_program_page.dart';

class HazirProgramlarPage extends StatelessWidget {
  const HazirProgramlarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '📋 Hazır Programlar',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Image.asset('assets/tyt.jpg'),
                const SizedBox(height: 12),
                Image.asset('assets/ayt.jpg'),
                const SizedBox(height: 12),
                Image.asset('assets/emergency.jpg'),
                const SizedBox(height: 12),
                Image.asset('assets/erime_yuksel.jpg'),
              ],
            ),
          ),
          const Expanded(
            flex: 6,
            child: TytProgramPage(),
          ),
        ],
      ),
    );
  }
}
