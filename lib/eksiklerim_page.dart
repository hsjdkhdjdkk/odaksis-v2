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
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 Eksiklerim'),
        backgroundColor: Colors.redAccent,
      ),
      body: eksikler.isEmpty
          ? const Center(
        child: Text(
          '👏 Şimdilik yanlış yapılmış soru yok!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: eksikler.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = eksikler[index];

            return Card(
              elevation: 4,
              shadowColor: Colors.redAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['soru'] ?? 'Soru bilgisi yok',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '❌ Senin cevabın: ${item['kullanici'] ?? '-'}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '✅ Doğru cevap: ${item['dogru'] ?? '-'}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
