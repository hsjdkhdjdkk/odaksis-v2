import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusSessionPage extends StatefulWidget {
  final int totalSeconds;
  final bool isCountdown;
  final bool isPomodoro;

  const FocusSessionPage({
    super.key,
    required this.totalSeconds,
    required this.isCountdown,
    this.isPomodoro = false,
  });

  @override
  State<FocusSessionPage> createState() => _FocusSessionPageState();
}

class _FocusSessionPageState extends State<FocusSessionPage> {
  late int secondsLeft;
  Timer? _timer;
  bool isRunning = true;

  /// Pomodoro için
  int pomodoroRound = 1;
  static const int totalRounds = 4;
  bool isWork = true;
  int initialWork = 25 * 60;
  int initialBreak = 5 * 60;

  /// UI kontrol
  bool showControls = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.totalSeconds;

    if (widget.isPomodoro) {
      pomodoroRound = 1;
      isWork = true;
      initialWork = widget.totalSeconds;
    }

    _startSession();
    _lockOrientation();
  }

  Future<void> _lockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _startSession() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (widget.isCountdown && !widget.isPomodoro) {
          if (secondsLeft > 0) {
            secondsLeft--;
          } else {
            _timer?.cancel();
            _showFinishedDialog();
          }
        } else if (widget.isPomodoro) {
          if (secondsLeft > 0) {
            secondsLeft--;
          } else {
            if (isWork) {
              isWork = false;
              secondsLeft = initialBreak;
            } else {
              if (pomodoroRound < totalRounds) {
                pomodoroRound++;
                isWork = true;
                secondsLeft = initialWork;
              } else {
                _timer?.cancel();
                _showFinishedDialog();
              }
            }
          }
        } else {
          secondsLeft++;
        }
      });
    });
    isRunning = true;
  }

  void _pauseSession() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void _resumeSession() {
    _startSession();
  }

  void _resetSession() {
    _timer?.cancel();
    setState(() {
      if (widget.isPomodoro) {
        pomodoroRound = 1;
        isWork = true;
        secondsLeft = initialWork;
      } else {
        secondsLeft = widget.isCountdown ? widget.totalSeconds : 0;
      }
      isRunning = false;
    });
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Tebrikler!"),
        content: Text("Odaklanma süresi tamamlandı."),
      ),
    ).then((_) => Navigator.pop(context));
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggleControls() {
    _hideTimer?.cancel();
    setState(() {
      showControls = true;
    });
    _hideTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        showControls = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: showControls ? (isTablet ? 70 : 60) : (isTablet ? 100 : 80),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                child: Text(_formatTime(secondsLeft)),
              ),
            ),
            if (widget.isPomodoro)
              Positioned(
                top: 40,
                left: 40,
                child: Text(
                  isWork ? "Çalışma" : "Mola\nTur: $pomodoroRound/$totalRounds",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ),
            AnimatedOpacity(
              opacity: showControls ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                            isRunning ? _pauseSession : _resumeSession,
                            icon: Icon(
                                isRunning ? Icons.pause : Icons.play_arrow),
                            label: Text(isRunning ? 'Durdur' : 'Devam Et'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton.icon(
                            onPressed: _resetSession,
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Sıfırla'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Çık'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
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
