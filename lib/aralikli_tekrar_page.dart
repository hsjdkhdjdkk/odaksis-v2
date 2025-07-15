import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashCard {
  final String front;
  final String back;
  FlashCard({required this.front, required this.back});

  Map<String, dynamic> toJson() => {'front': front, 'back': back};

  factory FlashCard.fromJson(Map<String, dynamic> json) =>
      FlashCard(front: json['front'], back: json['back']);
}

class AralikliTekrarPage extends StatefulWidget {
  const AralikliTekrarPage({super.key});

  @override
  State<AralikliTekrarPage> createState() => _AralikliTekrarPageState();
}

class _AralikliTekrarPageState extends State<AralikliTekrarPage>
    with SingleTickerProviderStateMixin {
  List<FlashCard> cards = [];
  int currentIndex = 0;
  bool showBack = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  final frontController = TextEditingController();
  final backController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('flashcards');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() {
        cards = list.map((e) => FlashCard.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(cards.map((e) => e.toJson()).toList());
    await prefs.setString('flashcards', data);
  }

  void _flipCard() {
    if (_controller.isCompleted) {
      _controller.reverse();
      setState(() => showBack = false);
    } else {
      _controller.forward();
      setState(() => showBack = true);
    }
  }

  void _nextCard() {
    if (currentIndex < cards.length - 1) {
      setState(() {
        currentIndex++;
        showBack = false;
        _controller.reset();
      });
    }
  }

  void _addCard(String front, String back) {
    setState(() {
      cards.add(FlashCard(front: front, back: back));
      _saveCards();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    frontController.dispose();
    backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🃏 Aralıklı Tekrar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Yeni Kart Ekle"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: frontController, decoration: const InputDecoration(labelText: "Ön Yüz")),
                      TextField(controller: backController, decoration: const InputDecoration(labelText: "Arka Yüz")),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _addCard(frontController.text, backController.text);
                        frontController.clear();
                        backController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text("Kaydet"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: cards.isEmpty
          ? const Center(child: Text("Henüz kart eklenmedi."))
          : Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final angle = _animation.value;
                    final isUnder = angle > pi / 2;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(angle),
                      child: Container(
                        width: isTablet ? 300 : 240,
                        height: isTablet ? 400 : 280,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade100,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: isUnder
                              ? Matrix4.rotationY(pi)
                              : Matrix4.identity(),
                          child: Text(
                            isUnder
                                ? cards[currentIndex].back
                                : cards[currentIndex].front,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _nextCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("İlerle", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
