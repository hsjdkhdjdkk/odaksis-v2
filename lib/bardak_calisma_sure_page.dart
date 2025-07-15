import 'dart:math';
import 'package:flutter/material.dart';

class BardakCalismaSurePage extends StatefulWidget {
  const BardakCalismaSurePage({super.key});

  @override
  State<BardakCalismaSurePage> createState() => _BardakCalismaSurePageState();
}

class _BardakCalismaSurePageState extends State<BardakCalismaSurePage> {
  List<int> dailyMinutes = List.generate(7, (_) => 60 + Random().nextInt(180));
  int? selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⏱️ Çalışma Sürem',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('📊 Günlük Ekran Süresi'),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(dailyMinutes.length, (index) {
                  final maxValue = dailyMinutes.reduce(max).toDouble();
                  final value = dailyMinutes[index].toDouble();
                  final heightPercent = value / maxValue;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDayIndex = index;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: 200 * heightPercent,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Gün ${index + 1}'),
                      ],
                    ),
                  );
                }),
              ),
            ),
            if (selectedDayIndex != null) ...[
              const SizedBox(height: 30),
              Text(
                '📅 Seçili Gün: Gün ${selectedDayIndex! + 1}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.play_circle, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Video: ${dailyMinutes[selectedDayIndex!] ~/ 2} dk'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Odaklanma: ${dailyMinutes[selectedDayIndex!] ~/ 2} dk'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Toplam: ${dailyMinutes[selectedDayIndex!]} dk',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
