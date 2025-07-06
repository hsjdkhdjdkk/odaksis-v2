import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// Odaklanma sayfasını import et
import 'odaklanma_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _program = {};
  String userName = "Öğrenci";

  int get daysUntilYKS {
    final yksDate = DateTime(2026, 6, 15);
    final now = DateTime.now();
    return yksDate.difference(now).inDays;
  }

  @override
  void initState() {
    super.initState();
    loadUserName();
    loadProgram();
  }

  /// ✅ PROFIL SharedPreferences'tan ISIM oku
  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('isim') ?? "Öğrenci";
    setState(() {
      userName = name;
    });
  }

  /// ✅ Program json'dan oku
  Future<void> loadProgram() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/program.json');

    String jsonString;

    if (await file.exists()) {
      jsonString = await file.readAsString();
    } else {
      jsonString = await rootBundle.loadString('assets/program.json');
    }

    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    Map<DateTime, List<String>> parsed = {};
    jsonMap.forEach((key, value) {
      parsed[DateTime.parse(key)] = List<String>.from(value);
    });

    setState(() {
      _program = parsed;
    });

    debugPrint('✅ Dashboard Loaded Program: $_program');
  }

  @override
  Widget build(BuildContext context) {
    final dayKey = _selectedDay == null
        ? null
        : DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

    final selectedKonular = dayKey == null ? [] : _program[dayKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Dashboard'),
        backgroundColor: Colors.lightBlue,
        actions: [
          // ✅ ODAK Butonu + ikon (ikon sağda)
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OdaklanmaPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
                color: Colors.lightBlue.shade700,
              ),
              child: Row(
                children: const [
                  Text(
                    'ODAK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.play_arrow, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Hoş geldin + kalan gün kutusu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hoş Geldin, $userName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'YKS: $daysUntilYKS gün',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ✅ Takvim (format butonu gizli!)
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // ✔ 2 weeks butonunu GİZLE
                titleCentered: true,
              ),
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
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                final dayKey = DateTime(day.year, day.month, day.day);
                return _program[dayKey] ?? [];
              },
            ),

            const SizedBox(height: 20),

            /// ✅ Seçili günün konuları başlığı
            if (_selectedDay != null)
              const Text(
                'Seçili Gün Konuları:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: selectedKonular.isEmpty
                  ? const Text('Seçili günde konu yok.')
                  : ListView.builder(
                itemCount: selectedKonular.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle,
                        color: Colors.green),
                    title: Text(selectedKonular[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
