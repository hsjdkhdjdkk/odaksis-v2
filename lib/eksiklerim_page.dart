import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class EksiklerimPage extends StatefulWidget {
  const EksiklerimPage({super.key});

  @override
  State<EksiklerimPage> createState() => _EksiklerimPageState();
}

class _EksiklerimPageState extends State<EksiklerimPage> {
  List<Map<String, dynamic>> eksikler = [];

  @override
  void initState() {
    super.initState();
    loadEksikler();
  }

  Future<void> loadEksikler() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/eksikler.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);

      // JSON formatı her öğe map olmalı
      setState(() {
        eksikler = jsonList.cast<Map<String, dynamic>>();
      });
    } else {
      setState(() {
        eksikler = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 Eksiklerim'),
        backgroundColor: Colors.redAccent,
      ),
      body: eksikler.isEmpty
          ? const Center(
        child: Text(
          'Şimdilik yanlış yapılmış soru yok!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: eksikler.length,
        itemBuilder: (context, index) {
          final item = eksikler[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.warning_amber,
                  color: Colors.redAccent),
              title: Text(
                'Soru: ${item['soru'] ?? 'Bilinmiyor'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Senin cevabın: ${item['kullanici'] ?? '-'}\n'
                    'Doğru cevap: ${item['dogru'] ?? '-'}',
              ),
            ),
          );
        },
      ),
    );
  }
}
