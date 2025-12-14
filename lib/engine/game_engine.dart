import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/hand_rank.dart';
import 'ai_player.dart';

class GameEngine {
  GameState state;
  final AIPlayer aiPlayer = AIPlayer();

  GameEngine({required this.state});

  void startNewHand() {
    // Rotate dealer
    state.dealerIndex = (state.dealerIndex + 1) % state.players.length;

    state.resetForNewHand();

    // Mark positions
    state.players[state.dealerIndex].isDealer = true;
    state.players[state.smallBlindIndex].isSmallBlind = true;
    state.players[state.bigBlindIndex].isBigBlind = true;

    // Post blinds
    _postBlinds();

    // Deal hole cards
    _dealHoleCards();

    state.phase = GamePhase.preFlop;

    // Set first player (left of big blind for pre-flop)
    state.currentPlayerIndex = (state.bigBlindIndex + 1) % state.players.length;
    while (!state.players[state.currentPlayerIndex].canAct) {
      state.currentPlayerIndex = (state.currentPlayerIndex + 1) % state.players.length;
    }

    state.addToLog('--- New Hand Started ---');
    state.addToLog('${state.dealer.name} is the dealer');
  }

  void _postBlinds() {
    var sbPlayer = state.players[state.smallBlindIndex];
    var bbPlayer = state.players[state.bigBlindIndex];

    int sbAmount = sbPlayer.call(state.smallBlind);
    state.pot += sbAmount;
    state.addToLog('${sbPlayer.name} posts small blind (${state.smallBlind})');

    int bbAmount = bbPlayer.call(state.bigBlind);
    state.pot += bbAmount;
    state.currentBet = state.bigBlind;
    state.addToLog('${bbPlayer.name} posts big blind (${state.bigBlind})');
  }

  void _dealHoleCards() {
    for (int i = 0; i < 2; i++) {
      for (var player in state.players) {
        if (player.status != PlayerStatus.eliminated) {
          var card = state.deck.deal();
          if (card != null) {
            player.holeCards.add(card);
          }
        }
      }
    }

    // Show human player's cards
    for (var player in state.players) {
      if (player.isHuman) {
        for (var card in player.holeCards) {
          card.isFaceUp = true;
        }
      }
    }

    state.addToLog('Hole cards dealt');
  }

  void dealCommunityCards() {
    switch (state.phase) {
      case GamePhase.preFlop:
        // Deal flop (3 cards)
        state.deck.deal(); // Burn
        for (int i = 0; i < 3; i++) {
          var card = state.deck.deal(faceUp: true);
          if (card != null) state.communityCards.add(card);
        }
        state.addToLog('--- Flop: ${state.communityCards.map((c) => c.toString()).join(' ')} ---');
        break;
      case GamePhase.flop:
        // Deal turn (1 card)
        state.deck.deal(); // Burn
        var turnCard = state.deck.deal(faceUp: true);
        if (turnCard != null) state.communityCards.add(turnCard);
        state.addToLog('--- Turn: ${turnCard} ---');
        break;
      case GamePhase.turn:
        // Deal river (1 card)
        state.deck.deal(); // Burn
        var riverCard = state.deck.deal(faceUp: true);
        if (riverCard != null) state.communityCards.add(riverCard);
        state.addToLog('--- River: ${riverCard} ---');
        break;
      default:
        break;
    }
  }

  void playerFold() {
    var player = state.currentPlayer;
    player.fold();
    state.addToLog('${player.name} folds');

    _afterAction();
  }

  void playerCheck() {
    var player = state.currentPlayer;
    player.check();
    state.addToLog('${player.name} checks');

    _afterAction();
  }

  void playerCall() {
    var player = state.currentPlayer;
    int toCall = state.amountToCall;
    int called = player.call(toCall);
    state.pot += called;

    if (player.isAllIn) {
      state.addToLog('${player.name} calls $called (All-In!)');
    } else {
      state.addToLog('${player.name} calls $called');
    }

    _afterAction();
  }

  void playerRaise(int raiseAmount) {
    var player = state.currentPlayer;
    int totalBet = state.currentBet + raiseAmount;
    int amountToAdd = totalBet - player.currentBet;

    int raised = player.raise(amountToAdd);
    state.pot += raised;
    state.currentBet = player.currentBet;
    state.minRaise = raiseAmount;
    state.lastRaiserIndex = state.currentPlayerIndex;

    // Reset hasTakenAction for other players
    for (var p in state.players) {
      if (p != player && p.canAct) {
        p.hasTakenAction = false;
      }
    }

    if (player.isAllIn) {
      state.addToLog('${player.name} raises to ${player.currentBet} (All-In!)');
    } else {
      state.addToLog('${player.name} raises to ${player.currentBet}');
    }

    _afterAction();
  }

  void playerAllIn() {
    var player = state.currentPlayer;
    int allInAmount = player.goAllIn();
    state.pot += allInAmount;

    if (player.currentBet > state.currentBet) {
      state.minRaise = player.currentBet - state.currentBet;
      state.currentBet = player.currentBet;
      state.lastRaiserIndex = state.currentPlayerIndex;

      for (var p in state.players) {
        if (p != player && p.canAct) {
          p.hasTakenAction = false;
        }
      }
    }

    state.addToLog('${player.name} goes All-In for $allInAmount');

    _afterAction();
  }

  void _afterAction() {
    // Check if only one player left
    if (state.onlyOnePlayerLeft) {
      _awardPotToWinner();
      return;
    }

    // Check if betting round is complete
    if (_isBettingRoundComplete()) {
      if (state.phase == GamePhase.river) {
        _goToShowdown();
      } else {
        state.advancePhase();
        dealCommunityCards();

        // If all remaining players are all-in, deal remaining cards
        if (state.playersWhoCanAct.isEmpty) {
          _runOutBoard();
        }
      }
    } else {
      state.moveToNextPlayer();
    }
  }

  bool _isBettingRoundComplete() {
    var active = state.playersWhoCanAct;
    if (active.isEmpty) return true;

    return active.every((p) =>
      p.hasTakenAction &&
      (p.currentBet == state.currentBet || p.isAllIn)
    );
  }

  void _runOutBoard() {
    while (state.communityCards.length < 5) {
      state.advancePhase();
      dealCommunityCards();
    }
    _goToShowdown();
  }

  void _goToShowdown() {
    state.phase = GamePhase.showdown;
    state.addToLog('--- Showdown ---');

    // Reveal all hands
    for (var player in state.activePlayers) {
      for (var card in player.holeCards) {
        card.isFaceUp = true;
      }

      // Evaluate hand
      List<PlayingCard> allCards = [...player.holeCards, ...state.communityCards];
      player.handRank = HandEvaluator.evaluate(allCards);
      state.addToLog('${player.name}: ${player.handRank}');
    }

    _determineWinner();
  }

  void _determineWinner() {
    var contenders = state.activePlayers;
    if (contenders.isEmpty) return;

    // Sort by hand strength
    contenders.sort((a, b) => b.handRank!.compareTo(a.handRank!));

    // Find winners (handle ties)
    List<Player> winners = [contenders.first];
    for (int i = 1; i < contenders.length; i++) {
      if (contenders[i].handRank!.compareTo(winners.first.handRank!) == 0) {
        winners.add(contenders[i]);
      } else {
        break;
      }
    }

    // Distribute pot
    int share = state.pot ~/ winners.length;
    int remainder = state.pot % winners.length;

    for (int i = 0; i < winners.length; i++) {
      int winAmount = share + (i == 0 ? remainder : 0);
      winners[i].addChips(winAmount);
      state.addToLog('${winners[i].name} wins $winAmount with ${winners[i].handRank}');
    }

    state.winner = winners.first;
    state.phase = GamePhase.handComplete;
    state.handInProgress = false;
  }

  void _awardPotToWinner() {
    var winner = state.activePlayers.first;
    winner.addChips(state.pot);
    state.addToLog('${winner.name} wins ${state.pot} (others folded)');

    state.winner = winner;
    state.phase = GamePhase.handComplete;
    state.handInProgress = false;
  }

  // AI Actions
  Future<void> processAITurn() async {
    if (!state.currentPlayer.isAI || !state.handInProgress) return;

    await Future.delayed(Duration(milliseconds: 800)); // Thinking delay

    var action = aiPlayer.decideAction(state);

    switch (action.action) {
      case PlayerAction.fold:
        playerFold();
        break;
      case PlayerAction.check:
        playerCheck();
        break;
      case PlayerAction.call:
        playerCall();
        break;
      case PlayerAction.raise:
        playerRaise(action.amount);
        break;
      case PlayerAction.allIn:
        playerAllIn();
        break;
      default:
        playerFold();
    }
  }

  bool get isHumanTurn => state.handInProgress && state.currentPlayer.isHuman;

  bool get canCheck => state.amountToCall == 0;
  bool get canCall => state.amountToCall > 0 && state.amountToCall < state.currentPlayer.chips;
  bool get canRaise => state.currentPlayer.chips > state.amountToCall;
}
