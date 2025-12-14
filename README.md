# Texas Hold'em Poker Game

A fully-featured Texas Hold'em Poker game built with Flutter. Play against AI opponents with realistic poker gameplay, hand evaluation, and strategic AI decisions.

## Screenshots

```
+--------------------------------------------------+
|  PRE-FLOP    [POT: 30]                      [=]  |
|                                                   |
|        [Alex]        [Sam]        [Jordan]        |
|         1000          1000          1000          |
|        [??][??]      [??][??]      [??][??]       |
|                                                   |
|     +---------------------------------------+     |
|     |                                       |     |
|     |    [?] [?] [?] [?] [?]               |     |
|     |         Community Cards               |     |
|     +---------------------------------------+     |
|                                                   |
|                    [You]                          |
|                     980                           |
|                  [A][K]                          |
|                 PREMIUM                           |
|              "Big Slick"                          |
|                                                   |
|  [FOLD]      [CALL 20]      [RAISE 40]           |
+--------------------------------------------------+
```

## Features

### Core Gameplay
- Full Texas Hold'em rules implementation
- 4 players (1 human + 3 AI opponents)
- Blinds system (Small Blind: 10, Big Blind: 20)
- All betting actions: Fold, Check, Call, Raise, All-In
- Proper pot management and side pots
- Showdown with hand comparison

### Hand Evaluation
- All 10 poker hand rankings supported:
  1. Royal Flush
  2. Straight Flush
  3. Four of a Kind
  4. Full House
  5. Flush
  6. Straight
  7. Three of a Kind
  8. Two Pair
  9. One Pair
  10. High Card

### Smart AI Opponents
- Position-aware decision making
- Different AI personalities (aggressive, tight, loose)
- Pre-flop hand strength evaluation
- Pot odds calculation
- Bluffing capabilities

### UI Features
- Hand strength indicator (PREMIUM, STRONG, PLAYABLE, MARGINAL, WEAK)
- Hand nicknames ("Pocket Rockets" for AA, "Big Slick" for AK, etc.)
- 5 community card slots always visible
- Current player highlighting
- Pot and chip displays
- Action log

### Tutorial
- Complete poker tutorial built-in
- Hand rankings reference
- Starting hand chart
- Position strategy guide
- Common hand nicknames

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Chrome (for web) or Android/iOS device

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kopi111/poker_game.git
cd poker_game
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web (Chrome)
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

### Build

```bash
# Web
flutter build web

# Android APK
flutter build apk

# iOS
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── card.dart            # Playing card model
│   ├── deck.dart            # Deck management
│   ├── player.dart          # Player model
│   ├── hand_rank.dart       # Hand evaluation
│   └── game_state.dart      # Game state management
├── engine/
│   ├── game_engine.dart     # Core game logic
│   └── ai_player.dart       # AI decision making
├── providers/
│   └── game_provider.dart   # State management
├── screens/
│   ├── game_screen.dart     # Main game UI
│   └── tutorial_screen.dart # Tutorial/help
├── widgets/
│   ├── playing_card_widget.dart  # Card display
│   ├── player_widget.dart        # Player info
│   └── action_buttons.dart       # Betting controls
└── utils/
    └── hand_helper.dart     # Hand strength utilities
```

## How to Play

1. **Start**: Click "DEAL" to begin a new hand
2. **Your Cards**: View your 2 hole cards at the bottom
3. **Hand Strength**: Check the indicator below your cards
4. **Actions**:
   - **Fold**: Give up your hand
   - **Check**: Pass (when no bet to call)
   - **Call**: Match the current bet
   - **Raise**: Increase the bet (use slider)
5. **Community Cards**: Watch as Flop (3), Turn (1), and River (1) are dealt
6. **Showdown**: Best 5-card hand wins!

## Hand Nicknames

| Cards | Nickname |
|-------|----------|
| AA | Pocket Rockets |
| KK | Cowboys |
| QQ | Ladies |
| JJ | Fishhooks |
| AK | Big Slick |
| AQ | Big Chick |
| KQ | Marriage |
| 88 | Snowmen |
| 22 | Ducks |
| 72 | Beer Hand |

## Technologies Used

- **Flutter** - UI framework
- **Dart** - Programming language
- **Provider** - State management
- **Equatable** - Value equality

## License

This project is open source and available under the MIT License.

## Author

Built with Claude Code

---

**Enjoy the game!**
