import 'dart:math';
import 'card.dart';

class Deck {
  List<PlayingCard> _cards = [];
  final Random _random = Random();

  Deck() {
    reset();
  }

  void reset() {
    _cards = [];
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        _cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  void shuffle() {
    for (int i = _cards.length - 1; i > 0; i--) {
      int j = _random.nextInt(i + 1);
      var temp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = temp;
    }
  }

  PlayingCard? deal({bool faceUp = false}) {
    if (_cards.isEmpty) return null;
    var card = _cards.removeLast();
    card.isFaceUp = faceUp;
    return card;
  }

  List<PlayingCard> dealMultiple(int count, {bool faceUp = false}) {
    List<PlayingCard> dealt = [];
    for (int i = 0; i < count && _cards.isNotEmpty; i++) {
      var card = deal(faceUp: faceUp);
      if (card != null) dealt.add(card);
    }
    return dealt;
  }

  int get remaining => _cards.length;

  bool get isEmpty => _cards.isEmpty;
}
