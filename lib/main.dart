import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'dashboard_page.dart';
import 'ders_secimi_page.dart';
import 'program_secimi_page.dart';
import 'bardak_page.dart';
import 'profil_page.dart';
import 'aralikli_tekrar_decks.dart'; // 🔁 Yeni eklenen sayfa

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const OdaksisApp());
}

class OdaksisApp extends StatelessWidget {
  const OdaksisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odaksis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ProgramSecimiPage(),
    const AralikliTekrarDecksPage(), // ✅ Aralıklı tekrar buraya geldi
    const BardakPage(), // ✅ İstatistik sayfası
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DersSecimiPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        shape: const CircleBorder(),
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.video_library, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue.shade50,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Anasayfa", 0),
              _buildNavItem(Icons.calendar_today, "Program", 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.refresh, "Aralıklı Tekrar", 2),
              _buildNavItem(Icons.bar_chart, "İstatistik", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onItemTapped(index),
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.lightBlue : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.lightBlue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
