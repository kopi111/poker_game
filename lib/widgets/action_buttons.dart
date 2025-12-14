import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  double _raiseSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (!game.isHumanTurn || game.isProcessing) {
          return _buildWaitingState(game);
        }

        int minRaise = game.state.minRaise;
        int maxRaise = game.state.currentPlayer.chips - game.state.amountToCall;
        int toCall = game.state.amountToCall;

        if (_raiseSliderValue < minRaise) {
          _raiseSliderValue = minRaise.toDouble();
        }

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Raise slider
              if (game.canRaise && maxRaise > minRaise) ...[
                Row(
                  children: [
                    Text(
                      'Raise: ${_raiseSliderValue.round()}',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Expanded(
                      child: Slider(
                        value: _raiseSliderValue.clamp(minRaise.toDouble(), maxRaise.toDouble()),
                        min: minRaise.toDouble(),
                        max: maxRaise.toDouble(),
                        divisions: ((maxRaise - minRaise) / game.state.bigBlind).round().clamp(1, 100),
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _raiseSliderValue = (value / game.state.bigBlind).round() * game.state.bigBlind.toDouble();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _quickRaiseButton('Min', minRaise, game),
                    _quickRaiseButton('½ Pot', (game.state.pot / 2).round(), game),
                    _quickRaiseButton('Pot', game.state.pot, game),
                    _quickRaiseButton('All-In', maxRaise, game),
                  ],
                ),
                SizedBox(height: 12),
              ],

              // Main action buttons
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      'FOLD',
                      Colors.red.shade700,
                      () => game.fold(),
                    ),
                  ),
                  SizedBox(width: 8),
                  if (game.canCheck)
                    Expanded(
                      child: _actionButton(
                        'CHECK',
                        Colors.blue.shade700,
                        () => game.check(),
                      ),
                    )
                  else
                    Expanded(
                      child: _actionButton(
                        'CALL $toCall',
                        Colors.blue.shade700,
                        () => game.call(),
                      ),
                    ),
                  SizedBox(width: 8),
                  if (game.canRaise)
                    Expanded(
                      child: _actionButton(
                        'RAISE ${_raiseSliderValue.round()}',
                        Colors.orange.shade700,
                        () {
                          game.raise(_raiseSliderValue.round());
                          setState(() {
                            _raiseSliderValue = minRaise.toDouble();
                          });
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaitingState(GameProvider game) {
    String message = game.isProcessing
        ? '${game.state.currentPlayer.name} is thinking...'
        : game.phaseText;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (game.isProcessing)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _quickRaiseButton(String label, int amount, GameProvider game) {
    int maxRaise = game.state.currentPlayer.chips - game.state.amountToCall;
    int actualAmount = amount.clamp(game.state.minRaise, maxRaise);

    return TextButton(
      onPressed: () {
        setState(() {
          _raiseSliderValue = actualAmount.toDouble();
        });
      },
      child: Text(
        label,
        style: TextStyle(color: Colors.orange.shade300, fontSize: 12),
      ),
    );
  }
}
