import 'dart:math';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/hand_rank.dart';
import '../models/card.dart';
import '../utils/hand_helper.dart';

class AIDecision {
  final PlayerAction action;
  final int amount;

  AIDecision(this.action, [this.amount = 0]);
}

enum Position { early, middle, late, button }

class AIPlayer {
  final Random _random = Random();

  AIDecision decideAction(GameState state) {
    var player = state.currentPlayer;
    var toCall = state.amountToCall;

    // Get position
    Position position = _getPosition(player, state);
    bool isLatePosition = position == Position.late || position == Position.button;

    // Evaluate hand strength using HandHelper for pre-flop
    double handStrength = _evaluateHandStrength(player, state);

    // Get pre-flop hand category
    HandStrength preflopStrength = HandHelper.evaluatePreflop(player.holeCards);

    // Adjust for position
    double positionBonus = _getPositionBonus(position);

    // Pot odds
    double potOdds = _calculatePotOdds(state);

    // Combined strength with position adjustment
    double strength = handStrength + positionBonus;

    // Add personality factors
    double aggression = player.aggressiveness;
    double tightness = player.tightness;
    double randomFactor = _random.nextDouble() * 0.15;
    strength += (aggression - 0.5) * 0.15 + randomFactor;

    // Pre-flop decision logic using hand categories
    if (state.communityCards.isEmpty) {
      return _makePreflopDecision(
        preflopStrength,
        position,
        toCall,
        state,
        player,
        aggression,
        tightness,
      );
    }

    // Post-flop decision logic
    return _makePostflopDecision(strength, potOdds, toCall, state, player, aggression);
  }

  AIDecision _makePreflopDecision(
    HandStrength handStrength,
    Position position,
    int toCall,
    GameState state,
    Player player,
    double aggression,
    double tightness,
  ) {
    bool isLatePosition = position == Position.late || position == Position.button;
    bool facingRaise = toCall > state.bigBlind;

    // Premium hands - always play aggressively
    if (handStrength == HandStrength.premium) {
      if (toCall == 0) {
        int raiseAmount = state.bigBlind * (3 + _random.nextInt(2));
        return AIDecision(PlayerAction.raise, raiseAmount);
      }
      if (facingRaise && toCall < player.chips * 0.3) {
        int raiseAmount = toCall * 2 + state.bigBlind;
        return AIDecision(PlayerAction.raise, raiseAmount.clamp(state.minRaise, player.chips));
      }
      return AIDecision(PlayerAction.call);
    }

    // Strong hands - raise or call depending on position
    if (handStrength == HandStrength.strong) {
      if (toCall == 0) {
        if (_random.nextDouble() < aggression) {
          int raiseAmount = state.bigBlind * (2 + _random.nextInt(2));
          return AIDecision(PlayerAction.raise, raiseAmount);
        }
        return AIDecision(PlayerAction.check);
      }
      if (!facingRaise || isLatePosition) {
        return AIDecision(PlayerAction.call);
      }
      // Facing raise in early position with strong hand
      if (_random.nextDouble() < 0.6) {
        return AIDecision(PlayerAction.call);
      }
      return AIDecision(PlayerAction.fold);
    }

    // Playable hands - position dependent
    if (handStrength == HandStrength.playable) {
      if (toCall == 0) {
        if (isLatePosition && _random.nextDouble() < aggression * 0.8) {
          int raiseAmount = state.bigBlind * 2;
          return AIDecision(PlayerAction.raise, raiseAmount);
        }
        return AIDecision(PlayerAction.check);
      }
      // Call if in late position and not facing big raise
      if (isLatePosition && toCall <= state.bigBlind * 3) {
        return AIDecision(PlayerAction.call);
      }
      // Tight players fold more often
      if (_random.nextDouble() < tightness) {
        return AIDecision(PlayerAction.fold);
      }
      if (toCall <= state.bigBlind * 2) {
        return AIDecision(PlayerAction.call);
      }
      return AIDecision(PlayerAction.fold);
    }

    // Marginal hands - only play in late position
    if (handStrength == HandStrength.marginal) {
      if (toCall == 0) {
        if (position == Position.button && _random.nextDouble() < aggression * 0.5) {
          int raiseAmount = state.bigBlind * 2;
          return AIDecision(PlayerAction.raise, raiseAmount);
        }
        return AIDecision(PlayerAction.check);
      }
      if (position == Position.button && toCall == state.bigBlind) {
        return AIDecision(PlayerAction.call);
      }
      return AIDecision(PlayerAction.fold);
    }

    // Trash hands - fold (but occasionally bluff from button)
    if (toCall == 0) {
      if (position == Position.button && _random.nextDouble() < aggression * 0.2) {
        int raiseAmount = state.bigBlind * 2;
        return AIDecision(PlayerAction.raise, raiseAmount);
      }
      return AIDecision(PlayerAction.check);
    }
    return AIDecision(PlayerAction.fold);
  }

  AIDecision _makePostflopDecision(
    double strength,
    double potOdds,
    int toCall,
    GameState state,
    Player player,
    double aggression,
  ) {
    if (toCall == 0) {
      // Can check
      if (strength > 0.7 && _random.nextDouble() < aggression) {
        int raiseAmount = _calculateRaiseAmount(state, strength);
        return AIDecision(PlayerAction.raise, raiseAmount);
      }
      if (strength > 0.5 && _random.nextDouble() < aggression * 0.5) {
        int raiseAmount = (state.pot * 0.5).round().clamp(state.minRaise, player.chips);
        return AIDecision(PlayerAction.raise, raiseAmount);
      }
      return AIDecision(PlayerAction.check);
    } else {
      // Must call or fold
      bool shouldCall = strength > potOdds || strength > 0.4;

      if (!shouldCall && strength < 0.25) {
        return AIDecision(PlayerAction.fold);
      }

      if (strength > 0.8 && _random.nextDouble() < aggression) {
        int raiseAmount = _calculateRaiseAmount(state, strength);
        return AIDecision(PlayerAction.raise, raiseAmount);
      }

      if (shouldCall) {
        // Check if should go all-in
        if (strength > 0.9 && toCall >= player.chips * 0.5) {
          return AIDecision(PlayerAction.allIn);
        }
        return AIDecision(PlayerAction.call);
      }

      // Bluff occasionally
      if (_random.nextDouble() < aggression * 0.1) {
        return AIDecision(PlayerAction.call);
      }

      return AIDecision(PlayerAction.fold);
    }
  }

  Position _getPosition(Player player, GameState state) {
    int playerIndex = state.players.indexOf(player);
    int dealerIndex = state.dealerIndex;
    int numPlayers = state.activePlayers.length;

    if (numPlayers <= 2) return Position.button;

    int positionFromDealer = (playerIndex - dealerIndex + state.players.length) % state.players.length;

    // Button
    if (positionFromDealer == 0) return Position.button;

    // Calculate relative position
    double relativePos = positionFromDealer / state.players.length;

    if (relativePos < 0.33) return Position.early;
    if (relativePos < 0.66) return Position.middle;
    return Position.late;
  }

  double _getPositionBonus(Position position) {
    switch (position) {
      case Position.early: return -0.05;
      case Position.middle: return 0.0;
      case Position.late: return 0.08;
      case Position.button: return 0.12;
    }
  }

  double _evaluateHandStrength(Player player, GameState state) {
    if (player.holeCards.isEmpty) return 0.0;

    // Pre-flop: use HandHelper
    if (state.communityCards.isEmpty) {
      return HandHelper.getApproxEquity(player.holeCards);
    }

    // Post-flop: use actual hand ranking
    List<PlayingCard> allCards = [...player.holeCards, ...state.communityCards];
    var handRank = HandEvaluator.evaluate(allCards);

    // Convert hand type to strength (0.0 - 1.0)
    double baseStrength = (handRank.typeValue + 1) / 10.0;

    // Adjust for kicker strength
    if (handRank.kickers.isNotEmpty) {
      baseStrength += (handRank.kickers.first - 2) / 120.0;
    }

    return baseStrength.clamp(0.0, 1.0);
  }

  double _calculatePotOdds(GameState state) {
    int toCall = state.amountToCall;
    if (toCall == 0) return 0.0;

    int potAfterCall = state.pot + toCall;
    return toCall / potAfterCall;
  }

  int _calculateRaiseAmount(GameState state, double strength) {
    int minRaise = state.minRaise;
    int maxRaise = state.currentPlayer.chips - state.amountToCall;

    if (maxRaise <= minRaise) return minRaise;

    // Stronger hand = bigger raise (between 0.5x and 1.5x pot)
    double potMultiplier = 0.5 + (strength * 1.0);
    int raiseAmount = (state.pot * potMultiplier).round();

    // Add some randomness
    raiseAmount += _random.nextInt(state.bigBlind * 2);

    // Round to big blind
    raiseAmount = (raiseAmount ~/ state.bigBlind) * state.bigBlind;

    return raiseAmount.clamp(minRaise, maxRaise);
  }
}
