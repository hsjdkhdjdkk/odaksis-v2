import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'focus_session_page.dart';

class OdaklanmaPage extends StatefulWidget {
  const OdaklanmaPage({super.key});

  @override
  State<OdaklanmaPage> createState() => _OdaklanmaPageState();
}

class _OdaklanmaPageState extends State<OdaklanmaPage> {
  int selectedHours = 0;
  int selectedMinutes = 25;

  int workMinutes = 25;
  int breakMinutes = 5;
  int pomodoroRounds = 4;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎯 Odaklanma Modu'),
          backgroundColor: Colors.lightBlue,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sayaç'),
              Tab(text: 'Kronometre'),
              Tab(text: 'Pomodoro'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /// Sayaç
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Çalışma Süresi Seç',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedHours,
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedHours = index;
                              });
                            },
                            children: List.generate(
                              13,
                                  (index) => Center(child: Text('$index saat')),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedMinutes,
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedMinutes = index;
                              });
                            },
                            children: List.generate(
                              60,
                                  (index) => Center(child: Text('$index dk')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      final seconds = selectedHours * 3600 + selectedMinutes * 60;
                      if (seconds > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FocusSessionPage(
                              totalSeconds: seconds,
                              isCountdown: true,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Başlat'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 40 : 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            /// Kronometre
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Kronometre',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FocusSessionPage(
                            totalSeconds: 0,
                            isCountdown: false,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Başlat'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 40 : 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            /// Pomodoro
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Pomodoro Ayarları',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(
                              initialItem: workMinutes - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                workMinutes = index + 1;
                              });
                            },
                            children: List.generate(
                              60,
                                  (index) =>
                                  Center(child: Text('${index + 1} dk Çalış')),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(
                              initialItem: breakMinutes - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                breakMinutes = index + 1;
                              });
                            },
                            children: List.generate(
                              30,
                                  (index) =>
                                  Center(child: Text('${index + 1} dk Mola')),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(
                              initialItem: pomodoroRounds - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                pomodoroRounds = index + 1;
                              });
                            },
                            children: List.generate(
                              10,
                                  (index) => Center(child: Text('${index + 1} Tur')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FocusSessionPage(
                            totalSeconds: workMinutes * 60,
                            isCountdown: true,
                            isPomodoro: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Başlat'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 40 : 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
