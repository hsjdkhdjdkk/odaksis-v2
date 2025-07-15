import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'odaklanma_page.dart';
import 'notlarim_page.dart';
import 'player_page.dart';
import 'profil_page.dart'; // ✅ Profil sayfası import

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
  String? lastVideoId;
  String? lastVideoTitle;

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
    loadLastVideo();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('isim') ?? "Öğrenci";
    setState(() {
      userName = name;
    });
  }

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
  }

  Future<void> loadLastVideo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastVideoId = prefs.getString('lastVideoId');
      lastVideoTitle = prefs.getString('lastVideoTitle') ?? "Video";
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayKey = _selectedDay == null
        ? null
        : DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

    final selectedKonular = dayKey == null ? [] : _program[dayKey] ?? [];

    final isTablet = MediaQuery.of(context).size.width > 600;

    final int randomSuccess = 50 + Random().nextInt(50);
    final int randomProgress = 30 + Random().nextInt(70);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.account_circle,
                  color: Colors.lightBlue, size: 34), // ✅ Daha büyük!
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilPage()),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Odaksis',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OdaklanmaPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.lightBlue,
                side: const BorderSide(color: Colors.lightBlue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'ODAK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotlarimPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.lightBlue,
                side: const BorderSide(color: Colors.lightBlue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'NOTLARIM',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Hoş geldin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Merhaba, $userName!',
                      style: TextStyle(
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              /// Takvim ve sağ taraf
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 5,
                    child: TableCalendar(
                      firstDay:
                      DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDay),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
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
                        final dayKey =
                        DateTime(day.year, day.month, day.day);
                        return _program[dayKey] ?? [];
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 5,
                    child: Column(
                      children: [
                        if (lastVideoId != null)
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerPage(
                                      videoId: lastVideoId!,
                                      videoList: const [],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_arrow,
                                        color: Colors.lightBlue, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "İzlemeye Devam Et",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            lastVideoTitle ?? "Video",
                                            style: const TextStyle(
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  "Başarı Oranı",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: randomSuccess / 100,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                        const AlwaysStoppedAnimation(
                                            Colors.green),
                                      ),
                                      Center(
                                        child: Text(
                                          '%$randomSuccess',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Bugünkü Program İlerlemesi",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: randomProgress / 100,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.lightBlue),
                                ),
                                const SizedBox(height: 8),
                                Text('%$randomProgress tamamlandı'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              '"Başarı, hazırlığa bağlıdır. Başarı istiyorsan hazırlan." - Konfüçyüs',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedDay != null)
                const Text(
                  'Seçili Gün Konuları:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 8),
              if (_selectedDay != null)
                SizedBox(
                  height: 200,
                  child: selectedKonular.isEmpty
                      ? const Text(
                    'Seçili günde konu yok.',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400),
                  )
                      : ListView.builder(
                    itemCount: selectedKonular.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 1,
                        child: ListTile(
                          leading: const Icon(Icons.check_circle,
                              color: Colors.green),
                          title: Text(
                            selectedKonular[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
