import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:path_provider/path_provider.dart';

class NotPlayerPage extends StatefulWidget {
  final String videoId;

  const NotPlayerPage({super.key, required this.videoId});

  @override
  State<NotPlayerPage> createState() => _NotPlayerPageState();
}

class _NotPlayerPageState extends State<NotPlayerPage> {
  late YoutubePlayerController _controller;
  bool isPanelOpen = true;
  OverlayEntry? _overlayEntry;

  List<String> notes = [];
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
      ),
    )..loadVideoById(videoId: widget.videoId);

    _lockLandscape();
    loadNotes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertOverlay();
    });
  }

  void _insertOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        right: 0,
        top: MediaQuery.of(context).size.height / 2 - 25,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isPanelOpen = !isPanelOpen;
              });
              _overlayEntry?.markNeedsBuild();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                isPanelOpen ? Icons.chevron_right : Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _lockLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> loadNotes() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/video_notes.json');
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final allNotes = jsonDecode(jsonString) as List<dynamic>;
      notes = allNotes
          .where((e) => e['videoId'] == widget.videoId)
          .map<String>((e) => e['note'].toString())
          .toList();
      setState(() {});
    }
  }

  Future<void> saveNote(String note) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/video_notes.json');

    List<dynamic> existing = [];
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      existing = jsonDecode(jsonString);
    }

    existing.add({
      'videoId': widget.videoId,
      'note': note,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await file.writeAsString(jsonEncode(existing));
    loadNotes();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(
            flex: isPanelOpen ? 6 : 10,
            child: YoutubePlayerScaffold(
              controller: _controller,
              builder: (context, player) => player,
            ),
          ),
          if (isPanelOpen)
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "📝 NOTLAR",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Expanded(
                      child: notes.isEmpty
                          ? const Center(
                        child: Text(
                          "Henüz not eklenmedi.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                          : ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(notes[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                notes.removeAt(index);
                                final dir = await getApplicationDocumentsDirectory();
                                final file = File('${dir.path}/video_notes.json');
                                final allNotes = jsonDecode(await file.readAsString())
                                as List<dynamic>;
                                allNotes.removeWhere((e) =>
                                e['videoId'] == widget.videoId &&
                                    e['note'] == notes[index]);
                                await file.writeAsString(
                                    jsonEncode(allNotes));
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                hintText: 'Not ekle...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (noteController.text.isNotEmpty) {
                                saveNote(noteController.text);
                                noteController.clear();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
