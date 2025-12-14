import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../engine/game_engine.dart';

class GameProvider extends ChangeNotifier {
  late GameEngine _engine;
  bool _isProcessing = false;

  GameState get state => _engine.state;
  bool get isProcessing => _isProcessing;
  bool get isHumanTurn => _engine.isHumanTurn;
  bool get canCheck => _engine.canCheck;
  bool get canCall => _engine.canCall;
  bool get canRaise => _engine.canRaise;

  GameProvider() {
    _initGame();
  }

  void _initGame() {
    List<Player> players = [
      Player(
        id: '1',
        name: 'You',
        type: PlayerType.human,
        avatar: '😎',
        chips: 1000,
      ),
      Player(
        id: '2',
        name: 'Alex',
        type: PlayerType.ai,
        avatar: '🤖',
        chips: 1000,
        aggressiveness: 0.6,
        tightness: 0.5,
      ),
      Player(
        id: '3',
        name: 'Sam',
        type: PlayerType.ai,
        avatar: '🎭',
        chips: 1000,
        aggressiveness: 0.4,
        tightness: 0.7,
      ),
      Player(
        id: '4',
        name: 'Jordan',
        type: PlayerType.ai,
        avatar: '🃏',
        chips: 1000,
        aggressiveness: 0.8,
        tightness: 0.3,
      ),
    ];

    _engine = GameEngine(
      state: GameState(
        players: players,
        smallBlind: 10,
        bigBlind: 20,
      ),
    );
  }

  void startNewHand() async {
    _engine.startNewHand();
    notifyListeners();

    await _processAITurns();
  }

  Future<void> _processAITurns() async {
    while (state.handInProgress && state.currentPlayer.isAI) {
      _isProcessing = true;
      notifyListeners();

      await _engine.processAITurn();

      _isProcessing = false;
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  void fold() async {
    if (!isHumanTurn || _isProcessing) return;

    _engine.playerFold();
    notifyListeners();

    await _processAITurns();
  }

  void check() async {
    if (!isHumanTurn || _isProcessing || !canCheck) return;

    _engine.playerCheck();
    notifyListeners();

    await _processAITurns();
  }

  void call() async {
    if (!isHumanTurn || _isProcessing) return;

    _engine.playerCall();
    notifyListeners();

    await _processAITurns();
  }

  void raise(int amount) async {
    if (!isHumanTurn || _isProcessing || !canRaise) return;

    _engine.playerRaise(amount);
    notifyListeners();

    await _processAITurns();
  }

  void allIn() async {
    if (!isHumanTurn || _isProcessing) return;

    _engine.playerAllIn();
    notifyListeners();

    await _processAITurns();
  }

  void newGame() {
    _initGame();
    notifyListeners();
  }

  String get phaseText {
    switch (state.phase) {
      case GamePhase.waiting:
        return 'Press Deal to Start';
      case GamePhase.preFlop:
        return 'Pre-Flop';
      case GamePhase.flop:
        return 'Flop';
      case GamePhase.turn:
        return 'Turn';
      case GamePhase.river:
        return 'River';
      case GamePhase.showdown:
        return 'Showdown';
      case GamePhase.handComplete:
        return state.winner != null ? '${state.winner!.name} Wins!' : 'Hand Complete';
    }
  }
}
