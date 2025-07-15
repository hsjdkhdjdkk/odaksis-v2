import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dashboard_page.dart';

class TytProgramPage extends StatefulWidget {
  const TytProgramPage({super.key});

  @override
  State<TytProgramPage> createState() => _TytProgramPageState();
}

class _TytProgramPageState extends State<TytProgramPage> {
  final List<String> konular = [
    'Temel Kavramlar',
    'Sayı Basamakları',
    'Bölme ve Bölünebilme',
    'EBOB – EKOK',
    'Rasyonel Sayılar',
    'Basit Eşitsizlikler',
    'Mutlak Değer',
    'Üslü Sayılar',
    'Köklü Sayılar',
    'Çarpanlara Ayırma',
    'Oran Orantı',
    'Denklem Çözme',
    'Problemler',
    'Sayı Problemleri',
    'Kesir Problemleri',
    'Yaş Problemleri',
    'Hareket Hız Problemleri',
    'İşçi Emek Problemleri',
    'Yüzde Problemleri',
    'Kar Zarar Problemleri',
    'Karışım Problemleri',
    'Grafik Problemleri',
    'Rutin Olmayan Problemler',
    'Kümeler – Kartezyen Çarpım',
    'Mantık',
    'Fonksiyonlar',
    'Polinomlar',
    '2.Dereceden Denklemler',
    'Permütasyon ve Kombinasyon',
    'Olasılık',
    'Veri – İstatistik',
  ];

  String _selectedRange = '1-2';
  DateTime? _startDate;
  List<DateTime> _selectedDates = [];

  final List<String> _ranges = [
    '0-1',
    '1-2',
    '2-3',
    '3-4',
    '4-5',
    '5-6',
    '6-7',
    '7-8',
    '8-9',
    '9-10',
    '10++',
  ];

  int get estimatedDays {
    final parts = _selectedRange.split('-');
    double avgHours;
    if (_selectedRange == '10++') {
      avgHours = 11;
    } else {
      avgHours = (int.parse(parts[0]) + int.parse(parts[1])) / 2;
    }
    final totalHours = konular.length * 1.0;
    final days = (totalHours / avgHours).ceil() + 1;
    return days;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _startDate = selectedDay;
    _selectedDates = List.generate(
      estimatedDays,
          (index) => selectedDay.add(Duration(days: index)),
    );
    setState(() {});
  }

  Future<void> _saveProgram() async {
    final konularPerGun = konular.length / estimatedDays;
    Map<String, List<String>> program = {};

    for (var i = 0; i < estimatedDays; i++) {
      final start = (i * konularPerGun).floor();
      final end = ((i + 1) * konularPerGun).ceil();
      final day = _selectedDates[i];
      program[DateTime(day.year, day.month, day.day).toIso8601String()] =
          konular.sublist(
            start,
            end > konular.length ? konular.length : end,
          );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/program.json');
    await file.writeAsString(jsonEncode(program));

    debugPrint('✅ Program JSON Kaydedildi: ${file.path}');

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📚 TYT Programı',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Günde kaç saat çalışabilirsin?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRange,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _ranges.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRange = value!;
                  _startDate = null;
                  _selectedDates = [];
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Tahmini gün: $estimatedDays gün',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ardışık günleri seç',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _startDate ?? DateTime.now(),
              selectedDayPredicate: (day) =>
                  _selectedDates.any((d) => isSameDay(d, day)),
              onDaySelected: _onDaySelected,
              calendarStyle: const CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.lightBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectedDates.length == estimatedDays
                  ? _saveProgram
                  : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('Kaydet ve Dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
