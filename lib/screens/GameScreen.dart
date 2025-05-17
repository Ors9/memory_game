import 'package:flutter/material.dart';
import 'package:memory_game/models/Player.dart';
import 'package:memory_game/models/BoardGame.dart';

class GameScreen extends StatefulWidget {
  final Player localPlayer;

  const GameScreen({super.key, required this.localPlayer});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late BoardGame board;

  @override
  void initState() {
    super.initState();
    board = BoardGame(widget.localPlayer, Player("Other"));
  }

  @override
  Widget build(BuildContext context) {
    final Player me = widget.localPlayer;
    final Player opponent = board.p1 == me ? board.p2 : board.p1;
    final isMyTurn = me.canTap;

    return Scaffold(
      appBar: AppBar(
        title: Text("Memory Game - ${isMyTurn ? 'Your Turn' : 'Waiting...'}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "👤 ${me.name}: ${me.score} נקודות",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "🧑 ${opponent.name}: ${opponent.score} נקודות",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: board.cards.length,
                itemBuilder: (context, index) {
                  final card = board.cards[index];
                  final opened = board.currentlyOpenedIndexes;

                  return ElevatedButton(
                    onPressed:
                        !isMyTurn ||
                                card.isRevealed ||
                                card.isMatched ||
                                opened.length >= 2
                            ? null
                            : () {
                              setState(() {
                                card.isRevealed = true;
                              });

                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  final openedNow =
                                      board.currentlyOpenedIndexes;

                                  if (openedNow.length == 2) {
                                    final i1 = openedNow[0];
                                    final i2 = openedNow[1];
                                    final matched = board.tryMatch(i1, i2);

                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () {
                                        setState(() {
                                          if (matched) {
                                            board.cards[i1].isMatched = true;
                                            board.cards[i2].isMatched = true;
                                            me.addPoint();
                                          } else {
                                            board.hideCards(i1, i2);
                                            board.switchTurn();
                                          }

                                          // ✅ שלב 2: סיום המשחק
                                          final allMatched = board.cards.every(
                                            (c) => c.isMatched,
                                          );
                                          if (allMatched) {
                                            final winner =
                                                me.score > opponent.score
                                                    ? me.name
                                                    : me.score < opponent.score
                                                    ? opponent.name
                                                    : "תיקו";

                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => AlertDialog(
                                                    title: const Text(
                                                      "🎉 המשחק הסתיים",
                                                    ),
                                                    content: Text(
                                                      winner == "תיקו"
                                                          ? "המשחק נגמר בתיקו!"
                                                          : "המנצח הוא: $winner",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: const Text(
                                                          "סגור",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                        });
                                      },
                                    );
                                  }
                                },
                              );
                            },
                    child: Text(
                      card.isRevealed || card.isMatched
                          ? card.id.toString()
                          : "?",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
