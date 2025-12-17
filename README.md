# 🎮 Tic Tac Toe Game - Flutter + Firebase

A beginner-friendly **Tic Tac Toe** game where two friends play on one phone and all match results are saved to **Firebase Firestore**.

## 📋 Features

- ✅ **User Authentication** - Login/Signup with Firebase Auth
- ✅ **Player Management** - Enter two player names
- ✅ **Interactive Game Board** - 3×3 grid with tap-to-play
- ✅ **Win Detection** - Checks 8 winning patterns (rows, columns, diagonals)
- ✅ **Scoreboard** - Tracks wins and ties
- ✅ **Match History** - Saves all games to Firebase Firestore
- ✅ **Real-time Updates** - History updates instantly
- ✅ **Simple UI** - Material Design 3 with easy navigation

## 🏗️ Project Architecture

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── game_models.dart         # Player, GameState, Match classes
├── providers/
│   ├── auth_provider.dart       # Login/Signup logic
│   ├── game_provider.dart       # Game state management
│   ├── player_provider.dart     # Player names
│   └── history_provider.dart    # Score & History tracking
├── screens/
│   ├── login_screen.dart        # Login page
│   ├── signup_screen.dart       # Signup page
│   ├── player_entry_screen.dart # Enter player names
│   ├── game_board_screen.dart   # Game UI
│   └── match_history_screen.dart# View past games
└── services/
    └── game_service.dart        # Firebase operations
```

## 🔄 CRUD Operations (Beginner-Friendly)

### CREATE - Save Match

```dart
// When game ends, save to Firebase
await gameService.saveMatch(Match(
  player1Name: "Ali",
  player2Name: "Ahmed",
  winner: "X",
  board: [...],
  date: DateTime.now(),
  userEmail: user.email,
));
```

### READ - Get Match History

```dart
// Read all matches from Firebase
Stream<List<Match>> matches = gameService.getMatchHistory();
// Shows newest games first
```

### UPDATE - Not Used

(Games can't be modified after they end)

### DELETE - Not Used

(We keep all match history)

## 🎮 Game Logic (Simple & Clear)

1. **Player takes turn** → Taps empty cell
2. **Place symbol** → 'X' or 'O' appears
3. **Check win condition** → 8 patterns (rows, cols, diagonals)
4. **Next player's turn** → Alternates between X and O
5. **Game ends** → Win detected or all cells filled (tie)
6. **Save result** → Match saved to Firebase

## 🔐 Firebase Structure

```
Firestore Database:
└── matches/
    ├── {auto-generated-id}
    │   ├── winner: "X" or "O" or "tie"
    │   ├── player1Name: string
    │   ├── player2Name: string
    │   ├── board: [9 strings representing grid]
    │   ├── date: timestamp
    │   └── userEmail: user's email
```

## 📱 App Flow

```
Login → Signup (if new) → Enter Player Names → Play Game → Save History → View History
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.9.2+)
- Dart SDK
- Firebase Project (optional for testing locally)

### Installation

```bash
# 1. Navigate to project
cd demo

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (Web)
flutter run -d chrome

# 4. Or run on emulator
flutter run
```

### First Time Setup

1. Create account with email & password
2. Enter two player names
3. Tap cells to play
4. View match history after games end

## 📊 State Management - Provider Pattern

**What is Provider?**
Provider helps share data across the app easily without passing it through every screen.

**How we use it:**

- `GameProvider` - Manages game state (board, winner, current player)
- `PlayerProvider` - Stores player names
- `HistoryProvider` - Tracks scores and match history
- `AuthProvider` - Handles login/logout

## 🎯 Key Classes Explained

### Player

```dart
class Player {
  final String name;      // Player name
  final String symbol;    // 'X' or 'O'
}
```

### GameState

```dart
class GameState {
  List<String> board;      // 9 cells
  String currentPlayer;    // 'X' or 'O'
  bool gameOver;          // true when game ends
  String? winner;         // 'X', 'O', or 'tie'
}
```

### Match

```dart
class Match {
  final String player1Name;
  final String player2Name;
  final String winner;     // Game result
  final List<String> board; // Final board state
  final DateTime date;      // When played
  final String? userEmail;  // Who played
}
```

## 📚 Code Quality

- ✅ **Readable** - Simple variable and method names
- ✅ **Organized** - Files separated by feature
- ✅ **Documented** - Comments on complex logic
- ✅ **Beginner-Friendly** - No complex patterns
- ✅ **Error Handling** - Graceful error messages

## 🎓 Perfect for Learning

This project teaches:

- ✅ Flutter basics (Widgets, State, Navigation)
- ✅ Firebase integration (Auth, Firestore)
- ✅ State management (Provider pattern)
- ✅ Game logic (Win detection)
- ✅ CRUD operations (Save/Read from database)
- ✅ Real-time updates (Firestore streams)

## 📖 For Your Viva

See [VIVA_GUIDE.md](VIVA_GUIDE.md) for detailed explanations and example answers.

## 📁 Important Files to Review

1. `lib/models/game_models.dart` - Data structure
2. `lib/services/game_service.dart` - Database operations
3. `lib/providers/game_provider.dart` - Game logic
4. `lib/screens/game_board_screen.dart` - UI & game display

## 🤝 Contributing

This is an educational project. Feel free to extend with features like:

- Player profiles
- Global statistics
- Multiplayer mode
- Sound effects
- Different difficulties

## 📝 License

Educational project for learning Flutter + Firebase.

## ✨ Summary

Perfect beginner project that covers:

- **Frontend**: Flutter UI
- **Backend**: Firebase Firestore + Auth
- **Database**: Real data persistence
- **State Management**: Provider pattern
- **Game Logic**: Simple algorithms

Everything is explained simply. You can confidently present this in your viva! 🎉
