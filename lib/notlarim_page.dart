import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'not_player_page.dart';

class NotlarimPage extends StatefulWidget {
  const NotlarimPage({super.key});

  @override
  State<NotlarimPage> createState() => _NotlarimPageState();
}

class _NotlarimPageState extends State<NotlarimPage> {
  List<Map<String, String>> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/video_notes.json');

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonList = List<Map<String, dynamic>>.from(jsonDecode(jsonString));

      setState(() {
        notes = jsonList
            .map((e) => {
          'videoId': e['videoId']?.toString() ?? '',
          'note': e['note']?.toString() ?? '',
          'timestamp': e['timestamp']?.toString() ?? '',
        })
            .toList();
      });
    }
  }

  String formatVideoId(String id) {
    return "Video ID: $id"; // Buraya ID yerine gerçek başlık dönüştürme koyarsın.
  }

  Future<void> deleteNote(int index) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/video_notes.json');

    notes.removeAt(index);
    await file.writeAsString(jsonEncode(notes));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Notlarım'),
        backgroundColor: Colors.lightBlue,
      ),
      body: notes.isEmpty
          ? const Center(
        child: Text(
          'Henüz not eklenmedi.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.note_alt, color: Colors.lightBlue),
              title: Text(note['note'] ?? ''),
              subtitle: Text(
                'Video: ${formatVideoId(note['videoId'] ?? '')}\nTarih: ${note['timestamp']?.substring(0, 16) ?? ''}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill, color: Colors.green),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotPlayerPage(
                            videoId: note['videoId'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => deleteNote(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
