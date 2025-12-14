import 'card.dart';

enum HandType {
  highCard,
  onePair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
  royalFlush,
}

class HandRank implements Comparable<HandRank> {
  final HandType type;
  final List<int> kickers; // For tie-breaking
  final List<PlayingCard> bestCards; // The 5 cards making the hand
  final String description;

  HandRank({
    required this.type,
    required this.kickers,
    required this.bestCards,
    required this.description,
  });

  int get typeValue => type.index;

  @override
  int compareTo(HandRank other) {
    if (typeValue != other.typeValue) {
      return typeValue.compareTo(other.typeValue);
    }
    // Compare kickers for tie-breaking
    for (int i = 0; i < kickers.length && i < other.kickers.length; i++) {
      if (kickers[i] != other.kickers[i]) {
        return kickers[i].compareTo(other.kickers[i]);
      }
    }
    return 0;
  }

  bool operator >(HandRank other) => compareTo(other) > 0;
  bool operator <(HandRank other) => compareTo(other) < 0;
  bool operator >=(HandRank other) => compareTo(other) >= 0;
  bool operator <=(HandRank other) => compareTo(other) <= 0;

  String get typeName {
    switch (type) {
      case HandType.highCard: return 'High Card';
      case HandType.onePair: return 'One Pair';
      case HandType.twoPair: return 'Two Pair';
      case HandType.threeOfAKind: return 'Three of a Kind';
      case HandType.straight: return 'Straight';
      case HandType.flush: return 'Flush';
      case HandType.fullHouse: return 'Full House';
      case HandType.fourOfAKind: return 'Four of a Kind';
      case HandType.straightFlush: return 'Straight Flush';
      case HandType.royalFlush: return 'Royal Flush';
    }
  }

  @override
  String toString() => description;
}

class HandEvaluator {
  static HandRank evaluate(List<PlayingCard> cards) {
    if (cards.length < 5) {
      return HandRank(
        type: HandType.highCard,
        kickers: cards.map((c) => c.value).toList()..sort((a, b) => b.compareTo(a)),
        bestCards: cards,
        description: 'Not enough cards',
      );
    }

    // Generate all 5-card combinations if more than 5 cards
    List<List<PlayingCard>> combinations = _getCombinations(cards, 5);

    HandRank? bestHand;
    for (var combo in combinations) {
      var hand = _evaluateFiveCards(combo);
      if (bestHand == null || hand > bestHand) {
        bestHand = hand;
      }
    }

    return bestHand!;
  }

  static List<List<PlayingCard>> _getCombinations(List<PlayingCard> cards, int r) {
    List<List<PlayingCard>> result = [];

    void combine(int start, List<PlayingCard> current) {
      if (current.length == r) {
        result.add(List.from(current));
        return;
      }
      for (int i = start; i < cards.length; i++) {
        current.add(cards[i]);
        combine(i + 1, current);
        current.removeLast();
      }
    }

    combine(0, []);
    return result;
  }

  static HandRank _evaluateFiveCards(List<PlayingCard> cards) {
    cards.sort((a, b) => b.value.compareTo(a.value));

    bool isFlush = _isFlush(cards);
    bool isStraight = _isStraight(cards);
    Map<int, List<PlayingCard>> groups = _groupByRank(cards);

    // Royal Flush
    if (isFlush && isStraight && cards.first.value == 14 && cards.last.value == 10) {
      return HandRank(
        type: HandType.royalFlush,
        kickers: [14],
        bestCards: cards,
        description: 'Royal Flush',
      );
    }

    // Straight Flush
    if (isFlush && isStraight) {
      return HandRank(
        type: HandType.straightFlush,
        kickers: [cards.first.value],
        bestCards: cards,
        description: 'Straight Flush, ${cards.first.rankString} high',
      );
    }

    // Four of a Kind
    var quads = groups.entries.where((e) => e.value.length == 4).toList();
    if (quads.isNotEmpty) {
      int quadRank = quads.first.key;
      int kicker = groups.entries.where((e) => e.key != quadRank).first.key;
      return HandRank(
        type: HandType.fourOfAKind,
        kickers: [quadRank, kicker],
        bestCards: cards,
        description: 'Four of a Kind, ${_rankName(quadRank)}s',
      );
    }

    // Full House
    var trips = groups.entries.where((e) => e.value.length == 3).toList();
    var pairs = groups.entries.where((e) => e.value.length == 2).toList();
    if (trips.isNotEmpty && pairs.isNotEmpty) {
      return HandRank(
        type: HandType.fullHouse,
        kickers: [trips.first.key, pairs.first.key],
        bestCards: cards,
        description: 'Full House, ${_rankName(trips.first.key)}s over ${_rankName(pairs.first.key)}s',
      );
    }

    // Flush
    if (isFlush) {
      return HandRank(
        type: HandType.flush,
        kickers: cards.map((c) => c.value).toList(),
        bestCards: cards,
        description: 'Flush, ${cards.first.rankString} high',
      );
    }

    // Straight
    if (isStraight) {
      return HandRank(
        type: HandType.straight,
        kickers: [cards.first.value],
        bestCards: cards,
        description: 'Straight, ${cards.first.rankString} high',
      );
    }

    // Three of a Kind
    if (trips.isNotEmpty) {
      List<int> kickers = [trips.first.key];
      kickers.addAll(
        groups.entries
          .where((e) => e.key != trips.first.key)
          .map((e) => e.key)
          .toList()
      );
      return HandRank(
        type: HandType.threeOfAKind,
        kickers: kickers,
        bestCards: cards,
        description: 'Three of a Kind, ${_rankName(trips.first.key)}s',
      );
    }

    // Two Pair
    if (pairs.length >= 2) {
      pairs.sort((a, b) => b.key.compareTo(a.key));
      int kicker = groups.entries
        .where((e) => e.key != pairs[0].key && e.key != pairs[1].key)
        .first.key;
      return HandRank(
        type: HandType.twoPair,
        kickers: [pairs[0].key, pairs[1].key, kicker],
        bestCards: cards,
        description: 'Two Pair, ${_rankName(pairs[0].key)}s and ${_rankName(pairs[1].key)}s',
      );
    }

    // One Pair
    if (pairs.isNotEmpty) {
      List<int> kickers = [pairs.first.key];
      kickers.addAll(
        groups.entries
          .where((e) => e.key != pairs.first.key)
          .map((e) => e.key)
          .toList()
      );
      return HandRank(
        type: HandType.onePair,
        kickers: kickers,
        bestCards: cards,
        description: 'Pair of ${_rankName(pairs.first.key)}s',
      );
    }

    // High Card
    return HandRank(
      type: HandType.highCard,
      kickers: cards.map((c) => c.value).toList(),
      bestCards: cards,
      description: 'High Card, ${cards.first.rankString}',
    );
  }

  static bool _isFlush(List<PlayingCard> cards) {
    return cards.every((c) => c.suit == cards.first.suit);
  }

  static bool _isStraight(List<PlayingCard> cards) {
    List<int> values = cards.map((c) => c.value).toList()..sort((a, b) => b.compareTo(a));

    // Check normal straight
    bool isNormalStraight = true;
    for (int i = 0; i < values.length - 1; i++) {
      if (values[i] - values[i + 1] != 1) {
        isNormalStraight = false;
        break;
      }
    }
    if (isNormalStraight) return true;

    // Check wheel (A-2-3-4-5)
    if (values[0] == 14 && values[1] == 5 && values[2] == 4 && values[3] == 3 && values[4] == 2) {
      return true;
    }

    return false;
  }

  static Map<int, List<PlayingCard>> _groupByRank(List<PlayingCard> cards) {
    Map<int, List<PlayingCard>> groups = {};
    for (var card in cards) {
      groups.putIfAbsent(card.value, () => []).add(card);
    }
    return groups;
  }

  static String _rankName(int value) {
    switch (value) {
      case 14: return 'Ace';
      case 13: return 'King';
      case 12: return 'Queen';
      case 11: return 'Jack';
      case 10: return 'Ten';
      case 9: return 'Nine';
      case 8: return 'Eight';
      case 7: return 'Seven';
      case 6: return 'Six';
      case 5: return 'Five';
      case 4: return 'Four';
      case 3: return 'Three';
      case 2: return 'Two';
      default: return value.toString();
    }
  }
}
