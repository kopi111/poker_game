import 'package:flutter/material.dart';
import '../models/card.dart';

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard? card;
  final double width;
  final double height;
  final bool showBack;
  final bool isHighlighted;

  const PlayingCardWidget({
    super.key,
    this.card,
    this.width = 60,
    this.height = 84,
    this.showBack = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    bool shouldShowBack = showBack || (card != null && !card!.isFaceUp);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shouldShowBack ? Color(0xFF1a237e) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlighted ? Colors.yellow : Colors.grey.shade400,
          width: isHighlighted ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: shouldShowBack ? _buildCardBack() : _buildCardFront(),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a237e),
            Color(0xFF3949ab),
            Color(0xFF1a237e),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: width * 0.7,
          height: height * 0.7,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '♠♥\n♦♣',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white24,
                fontSize: width * 0.25,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    if (card == null) return SizedBox();

    Color cardColor = card!.isRed ? Colors.red : Colors.black;

    return Padding(
      padding: EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${card!.rankString}${card!.suitSymbol}',
              style: TextStyle(
                color: cardColor,
                fontSize: width * 0.22,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                card!.suitSymbol,
                style: TextStyle(
                  color: cardColor,
                  fontSize: width * 0.45,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              angle: 3.14159,
              child: Text(
                '${card!.rankString}${card!.suitSymbol}',
                style: TextStyle(
                  color: cardColor,
                  fontSize: width * 0.22,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
