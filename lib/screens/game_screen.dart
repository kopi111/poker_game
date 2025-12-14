import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../models/card.dart';
import '../widgets/player_widget.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/action_buttons.dart';
import 'tutorial_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a472a),
              Color(0xFF0d260f),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, game, child) {
              return Column(
                children: [
                  _buildHeader(context, game),
                  Expanded(
                    child: _buildPokerTable(context, game),
                  ),
                  ActionButtons(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameProvider game) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Phase indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              game.phaseText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Pot
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade800,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'POT: ${game.state.pot}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Menu button
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showMenu(context, game),
          ),
        ],
      ),
    );
  }

  Widget _buildPokerTable(BuildContext context, GameProvider game) {
    var players = game.state.players;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Table felt
            Center(
              child: Container(
                width: constraints.maxWidth * 0.85,
                height: constraints.maxHeight * 0.55,
                decoration: BoxDecoration(
                  color: Color(0xFF2d5a3d),
                  borderRadius: BorderRadius.circular(120),
                  border: Border.all(
                    color: Color(0xFF8b4513),
                    width: 12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: _buildCommunityCards(game),
                ),
              ),
            ),

            // Players positioned around the table
            ..._buildPlayerPositions(constraints, players, game),

            // Deal button (when waiting)
            if (game.state.phase == GamePhase.waiting ||
                game.state.phase == GamePhase.handComplete)
              Center(
                child: ElevatedButton(
                  onPressed: () => game.startNewHand(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    game.state.phase == GamePhase.handComplete
                        ? 'NEXT HAND'
                        : 'DEAL',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPlayerPositions(
    BoxConstraints constraints,
    List<dynamic> players,
    GameProvider game,
  ) {
    List<Widget> positioned = [];

    // Define positions for up to 6 players
    List<Map<String, double>> positions = [
      {'left': 0.5, 'top': 0.85}, // Bottom (human)
      {'left': 0.1, 'top': 0.6},  // Left
      {'left': 0.1, 'top': 0.15}, // Top left
      {'left': 0.5, 'top': 0.02}, // Top
      {'left': 0.75, 'top': 0.15}, // Top right
      {'left': 0.75, 'top': 0.6}, // Right
    ];

    for (int i = 0; i < players.length && i < positions.length; i++) {
      var pos = positions[i];
      bool isCurrentPlayer = game.state.currentPlayerIndex == i &&
          game.state.handInProgress;

      positioned.add(
        Positioned(
          left: constraints.maxWidth * pos['left']! - 60,
          top: constraints.maxHeight * pos['top']!,
          child: PlayerWidget(
            player: players[i],
            isCurrentPlayer: isCurrentPlayer,
            isCompact: i != 0, // Human player is larger
          ),
        ),
      );
    }

    return positioned;
  }

  Widget _buildCommunityCards(GameProvider game) {
    // Always show 5 card slots
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        PlayingCard? card;
        if (index < game.state.communityCards.length) {
          card = game.state.communityCards[index];
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: card != null
            ? PlayingCardWidget(
                card: card,
                width: 55,
                height: 77,
              )
            : _buildEmptyCardSlot(),
        );
      }),
    );
  }

  Widget _buildEmptyCardSlot() {
    return Container(
      width: 55,
      height: 77,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white24,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.refresh, color: Colors.white),
                title: Text('New Game', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  game.newGame();
                },
              ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.white),
                title: Text('Action Log', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showActionLog(context, game);
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline, color: Colors.white),
                title: Text('Hand Rankings', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showHandRankings(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.school, color: Colors.amber),
                title: Text('Poker Tutorial', style: TextStyle(color: Colors.amber)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TutorialScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActionLog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text('Action Log', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              reverse: true,
              itemCount: game.state.actionLog.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    game.state.actionLog[game.state.actionLog.length - 1 - index],
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showHandRankings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text('Hand Rankings', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _rankingItem('1. Royal Flush', 'A-K-Q-J-10 same suit'),
                _rankingItem('2. Straight Flush', 'Five sequential, same suit'),
                _rankingItem('3. Four of a Kind', 'Four cards same rank'),
                _rankingItem('4. Full House', 'Three of a kind + pair'),
                _rankingItem('5. Flush', 'Five cards same suit'),
                _rankingItem('6. Straight', 'Five sequential cards'),
                _rankingItem('7. Three of a Kind', 'Three cards same rank'),
                _rankingItem('8. Two Pair', 'Two different pairs'),
                _rankingItem('9. One Pair', 'Two cards same rank'),
                _rankingItem('10. High Card', 'Highest card wins'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _rankingItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
