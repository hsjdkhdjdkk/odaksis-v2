import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'hazir_programlar_page.dart';

class ProgramSecimiPage extends StatefulWidget {
  const ProgramSecimiPage({super.key});

  @override
  State<ProgramSecimiPage> createState() => _ProgramSecimiPageState();
}

class _ProgramSecimiPageState extends State<ProgramSecimiPage> {
  String selectedLevel = 'TYT';
  String? selectedDers;
  List<String> selectedKonular = [];
  List<DateTime> selectedDates = [];
  DateTime? startDate;

  String dailyHours = '2';

  final List<String> hoursOptions = ['1', '2', '3', '4', '5', '6', '7', '8'];

  final List<String> tytDersler = [
    'Türkçe',
    'Matematik',
    'Tarih',
    'Coğrafya',
    'Felsefe',
    'Fizik',
    'Kimya',
    'Biyoloji'
  ];

  final List<String> aytDersler = ['Matematik', 'Fizik', 'Kimya', 'Biyoloji'];

  final Map<String, List<String>> konularMap = {
    'Türkçe': [
      'Sözcükte Anlam',
      'Cümlede Anlam',
      'Paragraf',
      'Yazım Kuralları',
      'Noktalama',
      'Anlatım Bozukluğu',
      'Dil Bilgisi'
    ],
    'Matematik': [
      'Temel Kavramlar',
      'Sayı Basamakları',
      'Bölme Bölünebilme',
      'EBOB EKOK',
      'Rasyonel Sayılar',
      'Basit Eşitsizlikler',
      'Mutlak Değer',
      'Üslü Sayılar',
      'Köklü Sayılar',
      'Çarpanlara Ayırma',
      'Oran Orantı',
      'Denklem Çözme',
      'Problemler',
    ],
    'Fizik': [
      'Fizik Bilimine Giriş',
      'Madde ve Özellikleri',
      'Hareket',
      'Kuvvet',
      'Enerji'
    ],
    'Kimya': [
      'Kimya Bilimi',
      'Atomun Yapısı',
      'Periyodik Sistem',
      'Kimyasal Türler',
      'Kimyasal Tepkimeler'
    ],
    'Biyoloji': [
      'Canlıların Ortak Özellikleri',
      'Hücre',
      'Hücre Bölünmesi',
      'DNA ve Genetik Kod'
    ],
    'Tarih': [
      'Tarih Bilimi',
      'Uygarlık Tarihi',
      'İlk Türk Devletleri'
    ],
    'Coğrafya': [
      'Doğa ve İnsan',
      'Harita Bilgisi',
      'İklim Bilgisi'
    ],
    'Felsefe': [
      'Felsefenin Konusu',
      'Bilgi Felsefesi',
      'Bilim Felsefesi'
    ]
  };

  void toggleKonu(String konu) {
    setState(() {
      if (selectedKonular.contains(konu)) {
        selectedKonular.remove(konu);
      } else {
        selectedKonular.add(konu);
      }
    });
  }

  int get estimatedDays {
    final totalHours = selectedKonular.length * 1;
    final daily = int.parse(dailyHours);
    return (totalHours / daily).ceil();
  }

  Future<void> saveProgram() async {
    final konularPerGun = selectedKonular.length / estimatedDays;
    Map<String, List<String>> program = {};

    for (var i = 0; i < estimatedDays; i++) {
      final start = (i * konularPerGun).floor();
      final end = ((i + 1) * konularPerGun).ceil();
      final day = selectedDates[i];
      program[DateTime(day.year, day.month, day.day).toIso8601String()] =
          selectedKonular.sublist(
            start,
            end > selectedKonular.length ? selectedKonular.length : end,
          );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/program.json');
    await file.writeAsString(jsonEncode(program));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('✅ Program Kaydedildi'),
        content:
        const Text('Programınız kaydedildi. Anasayfada inceleyebilirsiniz!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          )
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    startDate = selectedDay;
    selectedDates = List.generate(
      estimatedDays,
          (index) => selectedDay.add(Duration(days: index)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dersler = selectedLevel == 'TYT' ? tytDersler : aytDersler;
    final konular = selectedDers == null ? [] : konularMap[selectedDers]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '⚙️ Kendi Programını Oluştur',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HazirProgramlarPage()),
              );
            },
            child: const Text(
              'Hazır Programlar',
              style: TextStyle(color: Colors.lightBlue),
            ),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text('Seviye:'),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: selectedLevel,
                items: ['TYT', 'AYT']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedLevel = v!;
                    selectedDers = null;
                    selectedKonular.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Ders Seç:'),
          Wrap(
            spacing: 8,
            children: dersler.map((ders) {
              return ChoiceChip(
                label: Text(ders),
                selected: selectedDers == ders,
                onSelected: (_) {
                  setState(() {
                    selectedDers = ders;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (selectedDers != null) ...[
            const Text('Konular:'),
            Wrap(
              spacing: 8,
              children: konular.map((k) {
                final isSelected = selectedKonular.contains(k);
                return FilterChip(
                  label: Text(k),
                  selected: isSelected,
                  onSelected: (_) => toggleKonu(k),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          const Text('Günde Kaç Saat?'),
          DropdownButton<String>(
            value: dailyHours,
            items: hoursOptions.map((e) {
              return DropdownMenuItem(value: e, child: Text('$e saat'));
            }).toList(),
            onChanged: (v) => setState(() {
              dailyHours = v!;
            }),
          ),
          const SizedBox(height: 12),
          if (selectedKonular.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sepet: ${selectedKonular.length} konu'),
                Wrap(
                  spacing: 8,
                  children:
                  selectedKonular.map((k) => Chip(label: Text(k))).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Tarih Seç:'),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: startDate ?? DateTime.now(),
                  selectedDayPredicate: (d) => selectedDates.contains(d),
                  onDaySelected: _onDaySelected,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: selectedDates.length == estimatedDays
                      ? saveProgram
                      : null,
                  child: const Text('Kaydet'),
                )
              ],
            ),
        ],
      ),
    );
  }
}
