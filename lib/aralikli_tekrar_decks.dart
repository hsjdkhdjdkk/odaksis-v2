import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aralikli_tekrar_deck_page.dart';

class Deck {
  final String name;
  final int dailyLimit;
  final Color color;
  Deck({required this.name, required this.dailyLimit, required this.color});

  Map<String, dynamic> toJson() =>
      {'name': name, 'dailyLimit': dailyLimit, 'color': color.value};

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
      name: json['name'],
      dailyLimit: json['dailyLimit'],
      color: Color(json['color']));
}

class AralikliTekrarDecksPage extends StatefulWidget {
  const AralikliTekrarDecksPage({super.key});

  @override
  State<AralikliTekrarDecksPage> createState() =>
      _AralikliTekrarDecksPageState();
}

class _AralikliTekrarDecksPageState extends State<AralikliTekrarDecksPage> {
  List<Deck> decks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('decks');
    if (jsonStr != null) {
      final List list = jsonDecode(jsonStr);
      setState(() {
        decks = list.map((e) => Deck.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(decks.map((e) => e.toJson()).toList());
    await prefs.setString('decks', jsonStr);
  }

  void _showAddDeckDialog() {
    final nameController = TextEditingController();
    int dailyLimit = 10;
    Color selectedColor = Colors.lightBlue;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Deste Oluştur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Deste Adı'),
            ),
            const SizedBox(height: 12),
            DropdownButton<int>(
              value: dailyLimit,
              items: [5, 10, 15, 20]
                  .map((e) => DropdownMenuItem(
                  value: e, child: Text('Günlük Kart: $e')))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => dailyLimit = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Renk: "),
                GestureDetector(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (_) => SimpleDialog(
                        title: const Text('Renk Seç'),
                        children: [
                          Wrap(
                            spacing: 8,
                            children: [
                              Colors.red,
                              Colors.green,
                              Colors.blue,
                              Colors.purple,
                              Colors.orange,
                              Colors.teal
                            ]
                                .map((c) => GestureDetector(
                              onTap: () {
                                Navigator.pop(context, c);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                color: c,
                              ),
                            ))
                                .toList(),
                          )
                        ],
                      ),
                    );
                    if (color != null) {
                      setState(() {
                        selectedColor = color;
                      });
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    color: selectedColor,
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newDeck = Deck(
                    name: name,
                    dailyLimit: dailyLimit,
                    color: selectedColor);
                setState(() {
                  decks.add(newDeck);
                  _saveDecks();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Oluştur"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("📂 Kart Desteleri")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2 / 3,
          children: [
            ...decks.map((deck) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AralikliTekrarDeckPage(deck: deck),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: deck.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: deck.color, width: 2),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(deck.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text("Günlük Kart: ${deck.dailyLimit}")
                  ],
                ),
              ),
            )),
            GestureDetector(
              onTap: _showAddDeckDialog,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey.shade200,
                ),
                child: const Center(
                    child: Icon(Icons.add, size: 36, color: Colors.black54)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
