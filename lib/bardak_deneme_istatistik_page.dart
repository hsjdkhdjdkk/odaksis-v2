import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class BardakDenemeIstatistikPage extends StatefulWidget {
  const BardakDenemeIstatistikPage({super.key});

  @override
  State<BardakDenemeIstatistikPage> createState() =>
      _BardakDenemeIstatistikPageState();
}

class _BardakDenemeIstatistikPageState
    extends State<BardakDenemeIstatistikPage> {
  String selectedType = 'TYT';
  List<Map<String, dynamic>> denemeler = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/denemeler.json');

    if (await file.exists()) {
      final list = json.decode(await file.readAsString());
      denemeler = List<Map<String, dynamic>>.from(list);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = denemeler.where((e) => e['type'] == selectedType).toList();
    final lessons = selectedType == 'TYT'
        ? ['Türkçe', 'Sosyal Bilgiler', 'Matematik', 'Fen Bilimleri']
        : [
      'Türk Dili ve Edebiyatı',
      'Tarih 1',
      'Coğrafya 1',
      'Tarih 2',
      'Coğrafya 2',
      'Felsefe',
      'Matematik',
      'Fizik',
      'Kimya',
      'Biyoloji'
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('📈 Deneme İstatistikleri')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                ChoiceChip(
                  label: const Text('TYT'),
                  selected: selectedType == 'TYT',
                  onSelected: (_) => setState(() => selectedType = 'TYT'),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('AYT'),
                  selected: selectedType == 'AYT',
                  onSelected: (_) => setState(() => selectedType = 'AYT'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Toplam Net Grafiği'),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: filtered
                          .asMap()
                          .entries
                          .map((e) {
                        final ans = e.value['answers'] as Map;
                        final total = ans.entries.map((entry) {
                          final d = entry.value['dogru'];
                          final y = entry.value['yanlis'];
                          return d - y * 0.25;
                        }).reduce((a, b) => a + b);
                        return FlSpot(e.key.toDouble(), total);
                      })
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (final ders in lessons) ...[
              Text(ders),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: filtered
                            .asMap()
                            .entries
                            .map((e) {
                          final d = e.value['answers'][ders]?['dogru'] ?? 0;
                          final y = e.value['answers'][ders]?['yanlis'] ?? 0;
                          final net = d - y * 0.25;
                          return FlSpot(e.key.toDouble(), net);
                        })
                            .toList(),
                        isCurved: true,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
