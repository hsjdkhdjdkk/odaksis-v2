import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:path_provider/path_provider.dart';

class PlayerPage extends StatefulWidget {
  final String videoId;
  final List<Map<String, String>> videoList;

  const PlayerPage({
    super.key,
    required this.videoId,
    required this.videoList,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late YoutubePlayerController _controller;
  bool isPanelOpen = true;
  OverlayEntry? _overlayEntry;

  Map<String, dynamic> questionsMap = {};
  List<String> currentQuestions = [];
  TextEditingController noteController = TextEditingController();
  late String currentVideoId;

  List<int> pausePoints = [];
  Set<int> askedPoints = {};
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    currentVideoId = widget.videoId;

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
      ),
    )..loadVideoById(videoId: currentVideoId);

    _lockLandscape();
    loadQuestions(currentVideoId);
    loadPausePoints(currentVideoId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertOverlay();
    });

    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      checkPausePoints();
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

  Future<void> loadQuestions(String videoId) async {
    final questionJson =
    json.decode(await rootBundle.loadString('assets/questions.json'));
    setState(() {
      questionsMap = questionJson[videoId] ?? {};
      currentQuestions = questionsMap.keys.toList();
      askedPoints.clear();
    });
  }

  Future<void> loadPausePoints(String videoId) async {
    final pauseJson =
    json.decode(await rootBundle.loadString('assets/pause_data.json'));
    final videoPauseData = pauseJson[videoId];
    if (videoPauseData != null) {
      pausePoints = List<int>.from(videoPauseData['pause_points']);
    } else {
      pausePoints = [];
    }
  }

  void checkPausePoints() async {
    final position = await _controller.currentTime;
    final currentSec = position.round();

    for (final p in pausePoints) {
      if ((currentSec - p).abs() <= 1 && !askedPoints.contains(p)) {
        askedPoints.add(p);
        _controller.pauseVideo();
        _showQuestion(p.toString());
        break;
      }
    }
  }

  void _showQuestion(String point) async {
    final questionData = questionsMap[point];
    if (questionData == null) return;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                questionData['question'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.from(
            (questionData['options'] as List<dynamic>).map(
                  (opt) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(opt, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      final correctAnswer = questionData['answer'];
      final isCorrect = result == correctAnswer;

      if (!isCorrect) {
        await saveWrongAnswer(
          questionData['question'],
          correctAnswer,
          result,
        );
      }

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? "Doğru Cevap!" : "Yanlış Cevap!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            isCorrect
                ? "Tebrikler doğru cevapladın!"
                : "Doğru cevap: $correctAnswer",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tamam"),
            ),
          ],
        ),
      );

      _controller.playVideo();
    }
  }

  Future<void> saveWrongAnswer(
      String soru, String dogru, String kullanici) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/eksikler.json');

    List<dynamic> existing = [];
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      existing = jsonDecode(jsonString);
    }

    existing.add({
      'soru': soru,
      'dogru': dogru,
      'kullanici': kullanici,
    });

    await file.writeAsString(jsonEncode(existing));
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
      'videoId': currentVideoId,
      'note': note,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await file.writeAsString(jsonEncode(existing));
  }

  void _showNotePopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Not"),
        content: TextField(
          controller: noteController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: "Notunuzu yazın..."),
        ),
        actions: [
          TextButton(
            child: const Text("İptal"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text("Kaydet"),
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                saveNote(noteController.text);
                noteController.clear();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _checkTimer?.cancel();
    _controller.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String getShortTitle(String title) {
    final parts = title.split('|');
    if (parts.length >= 3) {
      return '${parts[1].trim()} | ${parts[2].trim()}';
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: isPanelOpen ? 6 : 10,
            child: Column(
              children: [
                Expanded(
                  child: YoutubePlayerScaffold(
                    controller: _controller,
                    builder: (context, player) => player,
                  ),
                ),
                if (isPanelOpen)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      children: currentQuestions
                          .map(
                            (q) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () => _showQuestion(q),
                            child: Text("Soru $q"),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                if (isPanelOpen)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton.icon(
                      onPressed: _showNotePopup,
                      icon: const Icon(Icons.note_add),
                      label: const Text("Not Ekle"),
                    ),
                  ),
              ],
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
                          "📺 Sıradaki Videolar",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.videoList.length,
                        itemBuilder: (context, index) {
                          final video = widget.videoList[index];
                          final title = getShortTitle(video['title'] ?? '');
                          return ListTile(
                            title: Text(title),
                            onTap: () {
                              setState(() {
                                currentVideoId = video['videoId'] ?? '';
                                _controller.loadVideoById(
                                    videoId: currentVideoId);
                                loadQuestions(currentVideoId);
                                loadPausePoints(currentVideoId);
                                askedPoints.clear();
                              });
                            },
                          );
                        },
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
