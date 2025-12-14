import 'card.dart';
import 'hand_rank.dart';

enum PlayerType { human, ai }
enum PlayerAction { fold, check, call, raise, allIn, none }
enum PlayerStatus { active, folded, allIn, eliminated, waiting }

class Player {
  final String id;
  final String name;
  final PlayerType type;
  final String avatar;

  int chips;
  List<PlayingCard> holeCards;
  PlayerStatus status;
  int currentBet;
  bool isDealer;
  bool isSmallBlind;
  bool isBigBlind;
  bool hasTakenAction;
  HandRank? handRank;

  // AI personality traits
  double aggressiveness; // 0.0 - 1.0
  double tightness; // 0.0 - 1.0 (how selective with hands)

  Player({
    required this.id,
    required this.name,
    required this.type,
    this.avatar = '🎭',
    this.chips = 1000,
    List<PlayingCard>? holeCards,
    this.status = PlayerStatus.waiting,
    this.currentBet = 0,
    this.isDealer = false,
    this.isSmallBlind = false,
    this.isBigBlind = false,
    this.hasTakenAction = false,
    this.handRank,
    this.aggressiveness = 0.5,
    this.tightness = 0.5,
  }) : holeCards = holeCards ?? [];

  bool get isHuman => type == PlayerType.human;
  bool get isAI => type == PlayerType.ai;
  bool get canAct => status == PlayerStatus.active;
  bool get isInHand => status == PlayerStatus.active || status == PlayerStatus.allIn;
  bool get hasFolded => status == PlayerStatus.folded;
  bool get isAllIn => status == PlayerStatus.allIn;
  bool get isEliminated => chips <= 0 && status != PlayerStatus.allIn;

  void resetForNewHand() {
    holeCards = [];
    status = chips > 0 ? PlayerStatus.active : PlayerStatus.eliminated;
    currentBet = 0;
    isDealer = false;
    isSmallBlind = false;
    isBigBlind = false;
    hasTakenAction = false;
    handRank = null;
  }

  void fold() {
    status = PlayerStatus.folded;
    hasTakenAction = true;
  }

  void check() {
    hasTakenAction = true;
  }

  int call(int amountToCall) {
    int actualCall = amountToCall.clamp(0, chips);
    chips -= actualCall;
    currentBet += actualCall;
    hasTakenAction = true;
    if (chips == 0) status = PlayerStatus.allIn;
    return actualCall;
  }

  int raise(int raiseAmount) {
    int actualRaise = raiseAmount.clamp(0, chips);
    chips -= actualRaise;
    currentBet += actualRaise;
    hasTakenAction = true;
    if (chips == 0) status = PlayerStatus.allIn;
    return actualRaise;
  }

  int goAllIn() {
    int allInAmount = chips;
    currentBet += chips;
    chips = 0;
    status = PlayerStatus.allIn;
    hasTakenAction = true;
    return allInAmount;
  }

  void receiveCards(List<PlayingCard> cards) {
    holeCards = cards;
    for (var card in holeCards) {
      card.isFaceUp = isHuman;
    }
  }

  void addChips(int amount) {
    chips += amount;
    if (status == PlayerStatus.eliminated && chips > 0) {
      status = PlayerStatus.active;
    }
  }

  Player copyWith({
    String? id,
    String? name,
    PlayerType? type,
    String? avatar,
    int? chips,
    List<PlayingCard>? holeCards,
    PlayerStatus? status,
    int? currentBet,
    bool? isDealer,
    bool? isSmallBlind,
    bool? isBigBlind,
    bool? hasTakenAction,
    HandRank? handRank,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatar: avatar ?? this.avatar,
      chips: chips ?? this.chips,
      holeCards: holeCards ?? this.holeCards,
      status: status ?? this.status,
      currentBet: currentBet ?? this.currentBet,
      isDealer: isDealer ?? this.isDealer,
      isSmallBlind: isSmallBlind ?? this.isSmallBlind,
      isBigBlind: isBigBlind ?? this.isBigBlind,
      hasTakenAction: hasTakenAction ?? this.hasTakenAction,
      handRank: handRank ?? this.handRank,
    );
  }

  @override
  String toString() => '$name (${chips} chips)';
}
