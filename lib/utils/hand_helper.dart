import '../models/card.dart';

enum HandStrength {
  premium,    // AA, KK, QQ, AKs
  strong,     // JJ, TT, AQs, AJs, KQs, AK
  playable,   // 99-22, suited connectors, suited aces
  marginal,   // Weak suited, off-suit connectors
  trash,      // Fold most of the time
}

class HandHelper {
  /// Get the nickname for hole cards
  static String? getNickname(List<PlayingCard> holeCards) {
    if (holeCards.length < 2) return null;

    var card1 = holeCards[0];
    var card2 = holeCards[1];

    bool isPair = card1.rank == card2.rank;
    bool isSuited = card1.suit == card2.suit;

    int high = card1.value > card2.value ? card1.value : card2.value;
    int low = card1.value < card2.value ? card1.value : card2.value;

    // Pocket Pairs
    if (isPair) {
      switch (card1.value) {
        case 14: return 'Pocket Rockets';
        case 13: return 'Cowboys';
        case 12: return 'Ladies';
        case 11: return 'Fishhooks';
        case 10: return 'Dimes';
        case 9: return 'Nines';
        case 8: return 'Snowmen';
        case 7: return 'Walking Sticks';
        case 6: return 'Route 66';
        case 5: return 'Speed Limit';
        case 4: return 'Sailboats';
        case 3: return 'Crabs';
        case 2: return 'Ducks';
      }
    }

    // Non-pair hands
    if (high == 14 && low == 13) return 'Big Slick';
    if (high == 14 && low == 12) return 'Big Chick';
    if (high == 14 && low == 11) return 'Blackjack';
    if (high == 14 && low == 10) return 'Johnny Moss';
    if (high == 14 && low == 8) return 'Dead Man\'s Hand';
    if (high == 13 && low == 12) return 'Marriage';
    if (high == 13 && low == 11) return 'Kojak';
    if (high == 13 && low == 9) return 'Canine';
    if (high == 12 && low == 11) return 'Maverick';
    if (high == 12 && low == 10) return 'Quint';
    if (high == 12 && low == 7) return 'Computer Hand';
    if (high == 11 && low == 5) return 'Jackson Five';
    if (high == 10 && low == 2) return 'Doyle Brunson';
    if (high == 9 && low == 8) return 'Oldsmobile';
    if (high == 7 && low == 2) return 'Beer Hand';
    if (high == 5 && low == 4) return 'Colt 45';
    if (high == 4 && low == 3) return 'Waltz';

    return null;
  }

  /// Evaluate pre-flop hand strength
  static HandStrength evaluatePreflop(List<PlayingCard> holeCards) {
    if (holeCards.length < 2) return HandStrength.trash;

    var card1 = holeCards[0];
    var card2 = holeCards[1];

    bool isPair = card1.rank == card2.rank;
    bool isSuited = card1.suit == card2.suit;

    int high = card1.value > card2.value ? card1.value : card2.value;
    int low = card1.value < card2.value ? card1.value : card2.value;
    int gap = high - low;

    // Premium hands
    if (isPair && card1.value >= 12) return HandStrength.premium; // QQ+
    if (high == 14 && low == 13 && isSuited) return HandStrength.premium; // AKs

    // Strong hands
    if (isPair && card1.value >= 10) return HandStrength.strong; // TT, JJ
    if (high == 14 && low == 13) return HandStrength.strong; // AK
    if (high == 14 && low == 12 && isSuited) return HandStrength.strong; // AQs
    if (high == 14 && low == 11 && isSuited) return HandStrength.strong; // AJs
    if (high == 13 && low == 12 && isSuited) return HandStrength.strong; // KQs
    if (high == 14 && low == 12) return HandStrength.strong; // AQ

    // Playable hands
    if (isPair) return HandStrength.playable; // Any pair
    if (high == 14 && isSuited) return HandStrength.playable; // Suited aces
    if (isSuited && gap <= 2 && low >= 5) return HandStrength.playable; // Suited connectors
    if (high >= 11 && low >= 10) return HandStrength.playable; // Broadway cards

    // Marginal hands
    if (high == 14) return HandStrength.marginal; // Weak aces
    if (isSuited && gap <= 3) return HandStrength.marginal; // Gapped suited
    if (gap == 1 && low >= 4) return HandStrength.marginal; // Connectors

    return HandStrength.trash;
  }

  /// Get color for hand strength
  static String getStrengthColor(HandStrength strength) {
    switch (strength) {
      case HandStrength.premium: return '#FFD700'; // Gold
      case HandStrength.strong: return '#00FF00'; // Green
      case HandStrength.playable: return '#87CEEB'; // Sky blue
      case HandStrength.marginal: return '#FFA500'; // Orange
      case HandStrength.trash: return '#FF4444'; // Red
    }
  }

  /// Get text description for hand strength
  static String getStrengthText(HandStrength strength) {
    switch (strength) {
      case HandStrength.premium: return 'PREMIUM';
      case HandStrength.strong: return 'STRONG';
      case HandStrength.playable: return 'PLAYABLE';
      case HandStrength.marginal: return 'MARGINAL';
      case HandStrength.trash: return 'WEAK';
    }
  }

  /// Get advice based on hand strength and position
  static String getAdvice(HandStrength strength, bool isLatePosition) {
    switch (strength) {
      case HandStrength.premium:
        return 'Raise or Re-raise from any position!';
      case HandStrength.strong:
        return 'Raise from most positions. Call big raises.';
      case HandStrength.playable:
        return isLatePosition
            ? 'Playable in late position. Consider raising.'
            : 'Call or fold in early position.';
      case HandStrength.marginal:
        return isLatePosition
            ? 'Can play in late position if cheap.'
            : 'Usually fold from early/middle position.';
      case HandStrength.trash:
        return 'Fold! Wait for a better hand.';
    }
  }

  /// Get hand description
  static String getHandDescription(List<PlayingCard> holeCards) {
    if (holeCards.length < 2) return '';

    var card1 = holeCards[0];
    var card2 = holeCards[1];

    bool isPair = card1.rank == card2.rank;
    bool isSuited = card1.suit == card2.suit;

    int high = card1.value > card2.value ? card1.value : card2.value;
    int low = card1.value < card2.value ? card1.value : card2.value;

    String highRank = _valueToRank(high);
    String lowRank = _valueToRank(low);

    if (isPair) {
      return 'Pocket ${highRank}s';
    }

    String suffix = isSuited ? 's' : 'o';
    return '$highRank$lowRank$suffix';
  }

  static String _valueToRank(int value) {
    switch (value) {
      case 14: return 'A';
      case 13: return 'K';
      case 12: return 'Q';
      case 11: return 'J';
      case 10: return 'T';
      default: return value.toString();
    }
  }

  /// Calculate approximate equity against a random hand
  static double getApproxEquity(List<PlayingCard> holeCards) {
    if (holeCards.length < 2) return 0.0;

    var strength = evaluatePreflop(holeCards);

    switch (strength) {
      case HandStrength.premium: return 0.80;
      case HandStrength.strong: return 0.65;
      case HandStrength.playable: return 0.55;
      case HandStrength.marginal: return 0.45;
      case HandStrength.trash: return 0.35;
    }
  }
}
