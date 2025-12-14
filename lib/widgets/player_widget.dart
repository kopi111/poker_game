import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/hand_helper.dart';
import 'playing_card_widget.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isCompact;

  const PlayerWidget({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(isCompact ? 6 : 10),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? Colors.yellow : Colors.transparent,
          width: 3,
        ),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: isCompact ? 4 : 8),
          _buildCards(),
          // Show hand strength for human player
          if (player.isHuman && player.holeCards.length >= 2 && player.holeCards.first.isFaceUp) ...[
            SizedBox(height: 4),
            _buildHandStrength(),
          ],
          // Show nickname for human player
          if (player.isHuman && player.holeCards.length >= 2) ...[
            _buildNickname(),
          ],
          if (player.currentBet > 0) ...[
            SizedBox(height: 4),
            _buildBet(),
          ],
          if (player.handRank != null && player.holeCards.isNotEmpty && player.holeCards.first.isFaceUp) ...[
            SizedBox(height: 4),
            _buildHandRank(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.avatar,
          style: TextStyle(fontSize: isCompact ? 20 : 28),
        ),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 12 : 14,
                  ),
                ),
                if (player.isDealer)
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: isCompact ? 12 : 16),
                SizedBox(width: 2),
                Text(
                  '${player.chips}',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: isCompact ? 11 : 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCards() {
    if (player.holeCards.isEmpty) {
      return SizedBox(height: isCompact ? 50 : 60);
    }

    double cardWidth = isCompact ? 35 : 50;
    double cardHeight = isCompact ? 49 : 70;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayingCardWidget(
          card: player.holeCards[0],
          width: cardWidth,
          height: cardHeight,
        ),
        SizedBox(width: 4),
        PlayingCardWidget(
          card: player.holeCards.length > 1 ? player.holeCards[1] : null,
          width: cardWidth,
          height: cardHeight,
        ),
      ],
    );
  }

  Widget _buildHandStrength() {
    var strength = HandHelper.evaluatePreflop(player.holeCards);
    String strengthText = HandHelper.getStrengthText(strength);
    Color strengthColor = _parseColor(HandHelper.getStrengthColor(strength));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: strengthColor.withValues(alpha: 0.3),
        border: Border.all(color: strengthColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        strengthText,
        style: TextStyle(
          color: strengthColor,
          fontSize: isCompact ? 9 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNickname() {
    String? nickname = HandHelper.getNickname(player.holeCards);
    if (nickname == null) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 3),
      child: Text(
        '"$nickname"',
        style: TextStyle(
          color: Colors.amber.shade300,
          fontSize: isCompact ? 8 : 10,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildBet() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Bet: ${player.currentBet}',
        style: TextStyle(
          color: Colors.white,
          fontSize: isCompact ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHandRank() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        player.handRank!.typeName,
        style: TextStyle(
          color: Colors.white,
          fontSize: isCompact ? 9 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (player.hasFolded) return Colors.grey.shade800.withValues(alpha: 0.5);
    if (player.isAllIn) return Colors.red.shade900.withValues(alpha: 0.8);
    if (player.isEliminated) return Colors.grey.shade900.withValues(alpha: 0.3);
    return Colors.green.shade900.withValues(alpha: 0.8);
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
