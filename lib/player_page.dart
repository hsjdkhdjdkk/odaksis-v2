import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:path_provider/path_provider.dart';

class PlayerPage extends StatefulWidget {
  final String videoId;
  const PlayerPage({super.key, required this.videoId});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late YoutubePlayerController _controller;
  Timer? _checkTimer;

  List<int> pausePoints = [];
  Map<String, dynamic> questionsMap = {};
  final Set<int> askedPoints = {};

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController();
    _controller.loadVideoById(videoId: widget.videoId);

    lockOrientation();
    loadPauseAndQuestions().then((_) {
      _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) => checkPausePoints());
    });
  }

  Future<void> lockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> loadPauseAndQuestions() async {
    final pauseJson = json.decode(await rootBundle.loadString('assets/pause_data.json'));
    final questionJson = json.decode(await rootBundle.loadString('assets/questions.json'));

    final videoPauseData = pauseJson[widget.videoId];
    if (videoPauseData != null) {
      pausePoints = List<int>.from(videoPauseData['pause_points']);
    }

    questionsMap = questionJson[widget.videoId] ?? {};
  }

  void checkPausePoints() async {
    final position = await _controller.currentTime;
    final currentSec = position.round();

    for (final p in pausePoints) {
      if ((currentSec - p).abs() <= 1 && !askedPoints.contains(p)) {
        askedPoints.add(p);
        _controller.pauseVideo();
        askQuestion(p);
        break;
      }
    }
  }

  void askQuestion(int point) async {
    final questionData = questionsMap[point.toString()];
    if (questionData == null) {
      _controller.playVideo();
      return;
    }

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
                ? "Tebrikler, doğru cevapladın!"
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

  Future<void> saveWrongAnswer(String soru, String dogru, String kullanici) async {
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

  @override
  void dispose() {
    _checkTimer?.cancel();
    _controller.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
            ),
          ),
        );
      },
    );
  }
}
