import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aralikli_tekrar_decks.dart';

class FlashCard {
  final String front;
  final String back;
  FlashCard({required this.front, required this.back});

  Map<String, dynamic> toJson() => {'front': front, 'back': back};

  factory FlashCard.fromJson(Map<String, dynamic> json) =>
      FlashCard(front: json['front'], back: json['back']);
}

class AralikliTekrarDeckPage extends StatefulWidget {
  final Deck deck;
  const AralikliTekrarDeckPage({super.key, required this.deck});

  @override
  State<AralikliTekrarDeckPage> createState() => _AralikliTekrarDeckPageState();
}

class _AralikliTekrarDeckPageState extends State<AralikliTekrarDeckPage>
    with SingleTickerProviderStateMixin {
  List<FlashCard> cards = [];
  int currentIndex = 0;
  bool showBack = false;
  bool isStudying = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  final frontController = TextEditingController();
  final backController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('deck_${widget.deck.name}');
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
    await prefs.setString('deck_${widget.deck.name}', data);
  }

  void _addCard(String front, String back) {
    setState(() {
      cards.add(FlashCard(front: front, back: back));
      _saveCards();
    });
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

  @override
  void dispose() {
    _controller.dispose();
    frontController.dispose();
    backController.dispose();
    super.dispose();
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Kart Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: frontController, decoration: const InputDecoration(labelText: "Soru")),
            TextField(controller: backController, decoration: const InputDecoration(labelText: "Cevap")),
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
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCardDialog,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: cards.isEmpty
            ? const Center(child: Text("Henüz kart eklenmedi."))
            : Column(
          children: [
            if (!isStudying)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isStudying = true;
                    currentIndex = 0;
                    showBack = false;
                    _controller.reset();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.deck.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("Çözmeye Başla", style: TextStyle(fontSize: 18)),
              ),
            if (isStudying) ...[
              const SizedBox(height: 30),
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
                              color: widget.deck.color.withOpacity(0.2),
                              border: Border.all(color: widget.deck.color, width: 2),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.deck.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("İlerle", style: TextStyle(fontSize: 18)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
