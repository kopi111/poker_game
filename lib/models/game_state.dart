import 'card.dart';
import 'deck.dart';
import 'player.dart';
import 'hand_rank.dart';

enum GamePhase {
  waiting,      // Before game starts
  preFlop,      // After hole cards dealt
  flop,         // After first 3 community cards
  turn,         // After 4th community card
  river,        // After 5th community card
  showdown,     // Revealing hands
  handComplete, // Winner determined
}

enum GameType {
  cashGame,
  tournament,
  sitAndGo,
}

class GameState {
  final List<Player> players;
  final Deck deck;
  final List<PlayingCard> communityCards;
  final int smallBlind;
  final int bigBlind;

  GamePhase phase;
  int pot;
  int currentBet;
  int dealerIndex;
  int currentPlayerIndex;
  int lastRaiserIndex;
  int minRaise;
  bool handInProgress;
  String? lastAction;
  List<String> actionLog;
  Player? winner;

  GameState({
    required this.players,
    Deck? deck,
    List<PlayingCard>? communityCards,
    this.smallBlind = 10,
    this.bigBlind = 20,
    this.phase = GamePhase.waiting,
    this.pot = 0,
    this.currentBet = 0,
    this.dealerIndex = 0,
    this.currentPlayerIndex = 0,
    this.lastRaiserIndex = -1,
    this.minRaise = 20,
    this.handInProgress = false,
    this.lastAction,
    List<String>? actionLog,
    this.winner,
  }) : deck = deck ?? Deck(),
       communityCards = communityCards ?? [],
       actionLog = actionLog ?? [];

  Player get currentPlayer => players[currentPlayerIndex];
  Player get dealer => players[dealerIndex];

  int get smallBlindIndex => (dealerIndex + 1) % players.length;
  int get bigBlindIndex => (dealerIndex + 2) % players.length;

  List<Player> get activePlayers => players.where((p) => p.isInHand).toList();
  List<Player> get playersWhoCanAct => players.where((p) => p.canAct).toList();

  int get amountToCall => currentBet - currentPlayer.currentBet;

  bool get isHeadsUp => players.length == 2;

  bool get allPlayersActed {
    var active = playersWhoCanAct;
    if (active.isEmpty) return true;
    return active.every((p) => p.hasTakenAction && p.currentBet == currentBet);
  }

  bool get onlyOnePlayerLeft {
    return activePlayers.length <= 1;
  }

  void addToLog(String action) {
    actionLog.add(action);
    lastAction = action;
    if (actionLog.length > 50) {
      actionLog.removeAt(0);
    }
  }

  void resetForNewHand() {
    deck.reset();
    deck.shuffle();
    communityCards.clear();
    pot = 0;
    currentBet = 0;
    minRaise = bigBlind;
    lastRaiserIndex = -1;
    handInProgress = true;
    phase = GamePhase.waiting;
    winner = null;
    lastAction = null;

    for (var player in players) {
      player.resetForNewHand();
    }
  }

  void moveToNextPlayer() {
    int startIndex = currentPlayerIndex;
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (!players[currentPlayerIndex].canAct &&
             currentPlayerIndex != startIndex);
  }

  void advancePhase() {
    // Reset betting for new round
    for (var player in players) {
      player.currentBet = 0;
      if (player.canAct) player.hasTakenAction = false;
    }
    currentBet = 0;
    minRaise = bigBlind;
    lastRaiserIndex = -1;

    // Set first player to act (left of dealer for post-flop)
    currentPlayerIndex = (dealerIndex + 1) % players.length;
    while (!players[currentPlayerIndex].canAct) {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }

    switch (phase) {
      case GamePhase.preFlop:
        phase = GamePhase.flop;
        break;
      case GamePhase.flop:
        phase = GamePhase.turn;
        break;
      case GamePhase.turn:
        phase = GamePhase.river;
        break;
      case GamePhase.river:
        phase = GamePhase.showdown;
        break;
      default:
        break;
    }
  }

  GameState copyWith({
    List<Player>? players,
    Deck? deck,
    List<PlayingCard>? communityCards,
    int? smallBlind,
    int? bigBlind,
    GamePhase? phase,
    int? pot,
    int? currentBet,
    int? dealerIndex,
    int? currentPlayerIndex,
    int? lastRaiserIndex,
    int? minRaise,
    bool? handInProgress,
    String? lastAction,
    List<String>? actionLog,
    Player? winner,
  }) {
    return GameState(
      players: players ?? this.players,
      deck: deck ?? this.deck,
      communityCards: communityCards ?? List.from(this.communityCards),
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      phase: phase ?? this.phase,
      pot: pot ?? this.pot,
      currentBet: currentBet ?? this.currentBet,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      lastRaiserIndex: lastRaiserIndex ?? this.lastRaiserIndex,
      minRaise: minRaise ?? this.minRaise,
      handInProgress: handInProgress ?? this.handInProgress,
      lastAction: lastAction ?? this.lastAction,
      actionLog: actionLog ?? List.from(this.actionLog),
      winner: winner ?? this.winner,
    );
  }
}
