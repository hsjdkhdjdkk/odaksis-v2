import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'dashboard_page.dart';
import 'ders_secimi_page.dart';
import 'program_secimi_page.dart';
import 'profil_page.dart';
import 'bardak_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const OdaksisApp());
}

class OdaksisApp extends StatelessWidget {
  const OdaksisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odaksis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  bool _askedEksikler = false;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ProgramSecimiPage(),
    const BardakPage(),
    const ProfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleEksiklerim();
    });
  }

  Future<void> _handleEksiklerim() async {
    if (_askedEksikler) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/eksikler.json');

    if (!await file.exists()) {
      _askedEksikler = true;
      return;
    }

    final questionsData = json.decode(await rootBundle.loadString('assets/questions.json'));
    List<dynamic> eksiklerList = json.decode(await file.readAsString());

    for (var eksik in List.from(eksiklerList)) {
      final soruText = eksik['soru'];

      Map<String, dynamic>? matchedQuestion;

      for (var videoId in questionsData.keys) {
        final videoQuestions = questionsData[videoId] as Map<String, dynamic>;
        for (var q in videoQuestions.entries) {
          final val = q.value;
          if (val['question'] == soruText) {
            matchedQuestion = Map<String, dynamic>.from(val);
            break;
          }
        }
        if (matchedQuestion != null) break;
      }

      if (matchedQuestion != null) {
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.quiz, color: Colors.deepPurple, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    matchedQuestion!['question'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.from(
                (matchedQuestion['options'] as List<dynamic>).map(
                      (opt) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, opt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
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

        final correctAnswer = matchedQuestion['answer'];
        final isCorrect = result == correctAnswer;

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 30,
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
                  ? "Tebrikler doğru cevapladın."
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

        if (isCorrect) {
          eksiklerList.remove(eksik);
          await file.writeAsString(jsonEncode(eksiklerList));
        }
      }
    }

    _askedEksikler = true;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DersSecimiPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        shape: const CircleBorder(),
        child: const Icon(Icons.book, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0 ? Colors.lightBlue : Colors.grey,
                ),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.directions_run,
                  color: _selectedIndex == 1 ? Colors.lightBlue : Colors.grey,
                ),
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.local_cafe,
                  color: _selectedIndex == 2 ? Colors.lightBlue : Colors.grey,
                ),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: _selectedIndex == 3 ? Colors.lightBlue : Colors.grey,
                ),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
