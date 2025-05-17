import 'package:memory_game/models/Player.dart';
import 'package:memory_game/models/CardItem.dart';

class BoardGame {
  static const int numOfCards = 16;

  final Player p1;
  final Player p2;
  late List<CardItem> cards;

  int currentPlayerIndex = 0;

  Player currentPlayer() => currentPlayerIndex == 0 ? p1 : p2;

  BoardGame(this.p1, this.p2) {
    cards = generateBoard();
    p1.canTap = true;
    p2.canTap = false;
  }

  List<CardItem> generateBoard() {
    List<CardItem> cards = [];
    for (int i = 0; i < numOfCards ~/ 2; i++) {
      cards.add(CardItem(id: i));
      cards.add(CardItem(id: i));
    }

    cards.shuffle();
    return cards;
  }

  bool tryMatch(int firstIndex, int secondIndex) {
    final first = cards[firstIndex];
    final second = cards[secondIndex];

    first.isRevealed = true;
    second.isRevealed = true;

    if (first.id == second.id) {
      first.isMatched = true;
      second.isMatched = true;
      currentPlayer().addPoint();
      return true;
    } else {
      return false;
    }
  }

  void hideCards(int i1, int i2) {
    cards[i1].isRevealed = false;
    cards[i2].isRevealed = false;
  }

  List<int> get currentlyOpenedIndexes {
    List<int> indexes = [];
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].isRevealed && !cards[i].isMatched) {
        indexes.add(i);
      }
    }
    return indexes;
  }

  void switchTurn() {
    p1.canTap = !p1.canTap;
    p2.canTap = !p2.canTap;
  }
}
