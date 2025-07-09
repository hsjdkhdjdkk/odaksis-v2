import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class BardakDenemeSonucPage extends StatefulWidget {
  const BardakDenemeSonucPage({super.key});

  @override
  State<BardakDenemeSonucPage> createState() => _BardakDenemeSonucPageState();
}

class _BardakDenemeSonucPageState extends State<BardakDenemeSonucPage> {
  String selectedType = 'TYT';
  final nameController = TextEditingController();

  Map<String, Map<String, int>> answers = {};

  List<String> tytLessons = ['Türkçe', 'Sosyal Bilgiler', 'Matematik', 'Fen Bilimleri'];
  List<String> aytLessons = [
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

  List<Map<String, dynamic>> denemeler = [];

  @override
  void initState() {
    super.initState();
    for (var ders in tytLessons + aytLessons) {
      answers[ders] = {'dogru': 0, 'yanlis': 0};
    }
    loadData();
  }

  double calcNet(String ders) {
    final d = answers[ders]!['dogru']!;
    final y = answers[ders]!['yanlis']!;
    return d - y * 0.25;
  }

  double get totalNet {
    final lessons = selectedType == 'TYT' ? tytLessons : aytLessons;
    return lessons.map((ders) => calcNet(ders)).reduce((a, b) => a + b);
  }

  Future<void> saveDeneme() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/denemeler.json');

    if (await file.exists()) {
      final list = json.decode(await file.readAsString());
      denemeler = List<Map<String, dynamic>>.from(list);
    }

    final data = {
      'name': nameController.text,
      'type': selectedType,
      'answers': Map.from(answers),
      'timestamp': DateTime.now().toIso8601String(),
    };

    denemeler.add(data);

    await file.writeAsString(json.encode(denemeler));

    setState(() {});
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
    final lessons = selectedType == 'TYT' ? tytLessons : aytLessons;

    return Scaffold(
      appBar: AppBar(title: const Text('📚 Denemelerim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButton<String>(
              value: selectedType,
              items: ['TYT', 'AYT']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedType = val!),
            ),
            const SizedBox(height: 10),
            ...lessons.map(
                  (ders) => Card(
                child: ListTile(
                  title: Text(ders),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Doğru'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                          answers[ders]!['dogru'] = int.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Yanlış'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                          answers[ders]!['yanlis'] = int.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text("Net: ${calcNet(ders).toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Deneme Adı"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: saveDeneme,
              icon: const Icon(Icons.save),
              label: const Text("Kaydet"),
            ),
            const SizedBox(height: 10),
            Text("Toplam Net: ${totalNet.toStringAsFixed(2)}"),
            const Divider(),
            const Text("Kayıtlı Denemeler:"),
            ...denemeler.map(
                  (e) => ListTile(
                title: Text(e['name']),
                subtitle: Text("${e['type']} - ${e['timestamp'].split('T')[0]}"),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(e['name']),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: (e['answers'] as Map).entries.map((entry) {
                        final d = entry.value['dogru'];
                        final y = entry.value['yanlis'];
                        final n = d - y * 0.25;
                        return Text(
                            "${entry.key} | D: $d | Y: $y | Net: ${n.toStringAsFixed(2)}");
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
