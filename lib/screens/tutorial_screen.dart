import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a472a),
      appBar: AppBar(
        title: Text('Poker Tutorial'),
        backgroundColor: Colors.green.shade900,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'What Are Hole Cards?',
              'Hole cards are the 2 private cards dealt face-down to each player. Only you can see them - they\'re your secret weapon!',
              Icons.visibility_off,
            ),
            SizedBox(height: 20),
            _buildHandStrengthGuide(),
            SizedBox(height: 20),
            _buildStartingHandChart(),
            SizedBox(height: 20),
            _buildPositionGuide(),
            SizedBox(height: 20),
            _buildHandNicknames(),
            SizedBox(height: 20),
            _buildHandRankings(),
            SizedBox(height: 20),
            _buildTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHandStrengthGuide() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Hand Strength Categories',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _strengthItem('PREMIUM', Color(0xFFFFD700), 'AA, KK, QQ, AKs', 'Raise/Re-raise from any position'),
          _strengthItem('STRONG', Color(0xFF00FF00), 'JJ, TT, AQ, AJs, KQs, AK', 'Raise from most positions'),
          _strengthItem('PLAYABLE', Color(0xFF87CEEB), '22-99, Suited connectors, Suited aces', 'Play in position'),
          _strengthItem('MARGINAL', Color(0xFFFFA500), 'Weak suited, Off-suit connectors', 'Usually fold'),
          _strengthItem('WEAK', Color(0xFFFF4444), '72o, 83o, etc.', 'Always fold!'),
        ],
      ),
    );
  }

  Widget _strengthItem(String label, Color color, String hands, String advice) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hands, style: TextStyle(color: Colors.white, fontSize: 12)),
                Text(advice, style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartingHandChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_on, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Starting Hand Chart',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildMiniChart(),
        ],
      ),
    );
  }

  Widget _buildMiniChart() {
    List<String> ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              SizedBox(width: 20, height: 20),
              ...ranks.map((r) => Container(
                width: 22,
                height: 20,
                alignment: Alignment.center,
                child: Text(r, style: TextStyle(color: Colors.white70, fontSize: 10)),
              )),
            ],
          ),
          // Grid
          ...List.generate(13, (row) {
            return Row(
              children: [
                Container(
                  width: 20,
                  height: 22,
                  alignment: Alignment.center,
                  child: Text(ranks[row], style: TextStyle(color: Colors.white70, fontSize: 10)),
                ),
                ...List.generate(13, (col) {
                  Color cellColor = _getChartColor(row, col);
                  return Container(
                    width: 22,
                    height: 22,
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Color _getChartColor(int row, int col) {
    // Pairs on diagonal
    if (row == col) {
      if (row <= 2) return Color(0xFFFFD700); // Premium pairs
      if (row <= 4) return Color(0xFF00FF00); // Strong pairs
      return Color(0xFF87CEEB); // Playable pairs
    }

    // Suited hands (above diagonal)
    if (col < row) {
      if (row <= 1 && col == 0) return Color(0xFFFFD700); // AKs
      if (row <= 3 && col <= 1) return Color(0xFF00FF00); // Strong suited
      if (row - col <= 2) return Color(0xFF87CEEB); // Suited connectors
      if (col == 0) return Color(0xFFFFA500); // Suited aces
      return Color(0xFFFF4444).withOpacity(0.5);
    }

    // Off-suit hands (below diagonal)
    if (row == 0 && col <= 2) return Color(0xFF00FF00); // AK, AQ, AJ off
    if (row <= 1 && col <= 3) return Color(0xFFFFA500); // Some broadway
    return Color(0xFFFF4444).withOpacity(0.3);
  }

  Widget _buildPositionGuide() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Position Strategy',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _positionItem('Early Position', 'Play only premium hands: AA, KK, QQ, AK', Colors.red),
          _positionItem('Middle Position', 'Add strong hands: JJ, TT, AQ, AJs', Colors.orange),
          _positionItem('Late Position', 'Play wider: Any pair, suited connectors', Colors.green),
          _positionItem('Button (Dealer)', 'Widest range, best position!', Colors.amber),
        ],
      ),
    );
  }

  Widget _positionItem(String position, String advice, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(position, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(advice, style: TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandNicknames() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Hand Nicknames',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _nicknameChip('AA', 'Pocket Rockets'),
              _nicknameChip('KK', 'Cowboys'),
              _nicknameChip('QQ', 'Ladies'),
              _nicknameChip('JJ', 'Fishhooks'),
              _nicknameChip('TT', 'Dimes'),
              _nicknameChip('AK', 'Big Slick'),
              _nicknameChip('AQ', 'Big Chick'),
              _nicknameChip('KQ', 'Marriage'),
              _nicknameChip('88', 'Snowmen'),
              _nicknameChip('22', 'Ducks'),
              _nicknameChip('72', 'Beer Hand'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nicknameChip(String hand, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hand, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(width: 6),
          Text(name, style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildHandRankings() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Hand Rankings (Best to Worst)',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _rankingRow('1', 'Royal Flush', 'A-K-Q-J-10 same suit'),
          _rankingRow('2', 'Straight Flush', '5 sequential, same suit'),
          _rankingRow('3', 'Four of a Kind', '4 cards same rank'),
          _rankingRow('4', 'Full House', '3 of a kind + pair'),
          _rankingRow('5', 'Flush', '5 cards same suit'),
          _rankingRow('6', 'Straight', '5 sequential cards'),
          _rankingRow('7', 'Three of a Kind', '3 cards same rank'),
          _rankingRow('8', 'Two Pair', '2 different pairs'),
          _rankingRow('9', 'One Pair', '2 cards same rank'),
          _rankingRow('10', 'High Card', 'Highest card wins'),
        ],
      ),
    );
  }

  Widget _rankingRow(String num, String name, String desc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(num, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          SizedBox(width: 10),
          Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(width: 10),
          Expanded(
            child: Text(desc, style: TextStyle(color: Colors.white54, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Pro Tips',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _tipItem('Fold more than you play - most starting hands should be folded'),
          _tipItem('Position is power - same cards play differently based on position'),
          _tipItem('Don\'t overvalue weak aces (A2-A5) - they often lose to better aces'),
          _tipItem('Suited cards add only ~2% equity - don\'t overvalue them'),
          _tipItem('Watch your opponents - learn their patterns and tendencies'),
        ],
      ),
    );
  }

  Widget _tipItem(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.amber, fontSize: 14)),
          Expanded(
            child: Text(tip, style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
