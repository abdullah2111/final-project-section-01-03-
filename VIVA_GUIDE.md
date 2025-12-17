# 🎮 Tic Tac Toe Game - Beginner's Viva Guide

## Project Overview

A simple Tic Tac Toe game where two friends play on one phone. The game is built with **Flutter**, **Firebase**, and **Provider** for state management. All match results are saved to Firebase Firestore.

---

## 🏗️ Project Architecture (Easy to Explain)

```
Project Structure:
├── lib/
│   ├── main.dart                    # App entry point & routes
│   ├── models/
│   │   └── game_models.dart         # Data models (Player, GameState, Match)
│   ├── providers/
│   │   ├── game_provider.dart       # Game state management
│   │   ├── player_provider.dart     # Player names management
│   │   ├── auth_provider.dart       # Login/Signup
│   │   └── history_provider.dart    # Scores & History
│   ├── screens/
│   │   ├── login_screen.dart        # Login page
│   │   ├── signup_screen.dart       # Registration page
│   │   ├── player_entry_screen.dart # Enter player names
│   │   ├── game_board_screen.dart   # Main game UI
│   │   └── match_history_screen.dart# View past games
│   └── services/
│       └── game_service.dart        # Firebase operations
```

---

## 📊 CRUD Operations Explained (Beginner Level)

### What is CRUD?

- **C**reate → Save new data
- **R**ead → Get data from database
- **U**pdate → Modify existing data
- **D**elete → Remove data

### CRUD in Our Project

#### 1️⃣ **CREATE** - Save Match to Firebase

```dart
// File: lib/services/game_service.dart
Future<void> saveMatch(Match match) async {
  // Adds a new document to 'matches' collection in Firebase
  await _firestore.collection('matches').add(match.toMap());
}
```

**What happens:** When a game ends, we save the winner, player names, and board to Firebase.

#### 2️⃣ **READ** - Get Match History from Firebase

```dart
// File: lib/services/game_service.dart
Stream<List<Match>> getMatchHistory() {
  return _firestore
      .collection('matches')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => /* convert to Match objects */);
}
```

**What happens:** We read all past games from Firebase and display them in order (newest first).

#### 3️⃣ **UPDATE** - Currently not needed

We don't update matches (games can't be changed after they end). But if needed:

```dart
// Example (not used in project):
await _firestore.collection('matches').doc(matchId).update({'winner': 'X'});
```

#### 4️⃣ **DELETE** - Currently not needed

We keep all match history. If needed:

```dart
// Example (not used in project):
await _firestore.collection('matches').doc(matchId).delete();
```

---

## 🔐 Authentication Flow (Easy Explanation)

### 1. Signup (User Registration)

```dart
// User enters email and password
// Firebase checks if email already exists
// If not, creates new account
Future<bool> signUp(String email, String password) async {
  await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  return true;
}
```

### 2. Login (User Authentication)

```dart
// User enters email and password
// Firebase checks if credentials are correct
// If yes, user is logged in
Future<bool> login(String email, String password) async {
  await _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return true;
}
```

### 3. Auto-Detection

```dart
// When app starts, checks if user is already logged in
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return PlayerEntryScreen(); // User logged in
    } else {
      return LoginScreen(); // User not logged in
    }
  },
)
```

---

## 🎮 Game Logic (Simple Explanation)

### Game State

```dart
class GameState {
  List<String> board;        // 9 cells: ['X', 'O', '', ...]
  String currentPlayer;      // 'X' or 'O' - whose turn?
  bool gameOver;             // true when someone wins or tie
  String? winner;            // 'X', 'O', or 'tie'
}
```

### Making a Move

```dart
void makeMove(int index) {
  // 1. Check if cell is empty and game is not over
  if (board[index].isEmpty && !gameOver) {
    // 2. Place current player's symbol
    board[index] = currentPlayer;

    // 3. Check if game ended (win or tie)
    _checkGameStatus();

    // 4. If game not over, switch to other player
    if (!gameOver) {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }
  }
}
```

### Checking Win Conditions

```dart
void _checkGameStatus() {
  // Winning patterns: rows, columns, diagonals
  const List<List<int>> winPatterns = [
    [0, 1, 2], // top row
    [3, 4, 5], // middle row
    [6, 7, 8], // bottom row
    [0, 3, 6], // left column
    [1, 4, 7], // middle column
    [2, 5, 8], // right column
    [0, 4, 8], // diagonal
    [2, 4, 6], // anti-diagonal
  ];

  // Check each pattern
  for (var pattern in winPatterns) {
    if (board[pattern[0]] == board[pattern[1]] &&
        board[pattern[1]] == board[pattern[2]] &&
        board[pattern[0]].isNotEmpty) {
      winner = board[pattern[0]]; // 'X' or 'O'
      gameOver = true;
      return;
    }
  }

  // If all cells filled and no winner, it's a tie
  if (board.every((cell) => cell.isNotEmpty)) {
    winner = 'tie';
    gameOver = true;
  }
}
```

---

## 🔄 Provider State Management (How Data Flows)

### What is Provider?

Provider helps share data across the app without passing it through every screen.

### 1. GameProvider (Game State)

```dart
class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();

  void makeMove(int index) {
    _gameState.makeMove(index);
    notifyListeners(); // Tell UI to rebuild
  }
}
```

### 2. PlayerProvider (Player Names)

```dart
class PlayerProvider extends ChangeNotifier {
  Player _player1;
  Player _player2;

  void setPlayers(Player player1, Player player2) {
    _player1 = player1;
    _player2 = player2;
    notifyListeners();
  }
}
```

### 3. HistoryProvider (Match History)

```dart
class HistoryProvider extends ChangeNotifier {
  List<Match> _matches = [];

  void loadMatches() {
    // Listen to Firebase for real-time updates
    _gameService.getMatchHistory().listen((matches) {
      _matches = matches;
      notifyListeners(); // Update UI
    });
  }
}
```

### How to Use Provider in UI

```dart
// Read data
final gameProvider = context.read<GameProvider>();

// Listen for changes and rebuild
Consumer<GameProvider>(
  builder: (context, gameProvider, _) {
    return Text(gameProvider.gameState.currentPlayer);
  },
)
```

---

## 💾 Firebase Firestore Structure

### Database Collections

```
Firestore Database:
└── matches (collection)
    ├── doc1
    │   ├── winner: "X"
    │   ├── player1Name: "Ali"
    │   ├── player2Name: "Ahmed"
    │   ├── board: ["X", "O", "X", "", "", "", "", "", ""]
    │   ├── date: 2025-12-17 18:30:00
    │   └── userEmail: "ali@example.com"
    │
    └── doc2
        ├── winner: "tie"
        ├── player1Name: "Sara"
        ├── player2Name: "Zara"
        └── ...
```

---

## 🔐 Authentication with Firebase

### How Authentication Works

```
User Registration Flow:
1. User enters email & password
2. Firebase creates account
3. Password is encrypted (Firebase handles)
4. User can now login

User Login Flow:
1. User enters email & password
2. Firebase checks credentials
3. If correct → login successful
4. If wrong → show error message

User Logout Flow:
1. User clicks logout button
2. Firebase signs out
3. Redirect to login screen
```

---

## 📱 Screen Navigation (App Flow)

```
┌─────────────────┐
│   Login Screen  │  (First screen)
└────────┬────────┘
         │
         ├─→ New user? → Sign Up
         │
         └─→ Existing user? → Enter Password
                    │
                    ↓
         ┌──────────────────────┐
         │ Player Entry Screen  │  (Enter names)
         └──────────┬───────────┘
                    │
                    ↓
         ┌──────────────────────┐
         │  Game Board Screen   │  (Play game)
         └────┬────────────┬────┘
              │            │
              ↓            ↓
         Play Again    View History
```

---

## 🎯 Viva Question Preparation

### Easy Questions (You Will Get These)

1. **What is the project about?**

   - "It's a Tic Tac Toe game where two friends play on one phone. We save game history to Firebase."

2. **What are the main screens?**

   - "Login, Signup, Player Entry, Game Board, and Match History."

3. **How do you save a game?**

   - "When game ends, we create a Match object with winner, player names, and board, then save to Firebase using `saveMatch()` method."

4. **How do you read game history?**

   - "We use `getMatchHistory()` which reads from Firebase and returns a stream of matches, automatically updating when new games are saved."

5. **What is Provider?**
   - "Provider is a state management library that lets different screens share data without passing it manually."

### Medium Questions

6. **What is CRUD?**

   - "Create (save match), Read (get history), Update (not used), Delete (not used)."

7. **How does authentication work?**

   - "Firebase Auth handles login/signup. We check if email exists, verify password, and create session."

8. **How do you check if someone won?**

   - "We check 8 winning patterns (3 rows, 3 columns, 2 diagonals). If any pattern has same symbol, that player wins."

9. **What happens when app starts?**
   - "AuthWrapper checks if user is logged in. If yes, show game. If no, show login."

### Hard Questions (Less likely)

10. **How does real-time update work?**

    - "Firebase Firestore uses snapshots(). When database changes, it automatically sends new data to our app."

11. **Why use notifyListeners()?**
    - "It tells Flutter to rebuild the UI when data changes. Without it, UI won't update."

---

## 💡 Code Quality for Beginners

### ✅ Beginner-Friendly Aspects

- ✅ Simple variable names: `board`, `winner`, `player1Name`
- ✅ Clear method names: `makeMove()`, `saveMatch()`, `getMatchHistory()`
- ✅ Organized into folders by feature
- ✅ Each file has single responsibility
- ✅ Comments explain complex logic
- ✅ No complex design patterns

### ✅ Easy to Explain

- ✅ Game logic is straightforward (check 8 patterns)
- ✅ Firebase operations are simple (add, read)
- ✅ Provider pattern is basic (just notifyListeners)
- ✅ UI is standard Material widgets

---

## 🚀 How to Run Project

```bash
# 1. Navigate to project
cd demo

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (web)
flutter run -d chrome

# 4. Run on Android/iOS emulator
flutter run

# 5. Login/Signup with test email (e.g., test@example.com)
# 6. Enter two player names
# 7. Play game
# 8. View history in Firebase Console
```

---

## 📚 Files to Review Before Viva

**Read these files in this order:**

1. `lib/main.dart` - Entry point
2. `lib/models/game_models.dart` - Data structures
3. `lib/providers/game_provider.dart` - Game logic
4. `lib/services/game_service.dart` - Firebase operations
5. `lib/screens/game_board_screen.dart` - Game UI

**Total time to understand: ~30 minutes**

---

## 💬 Example Viva Answers

### Question: "Explain your project in 2 minutes"

**Answer:**
"Our project is a Tic Tac Toe game built with Flutter and Firebase. Two players enter their names and play on the same phone. When a game ends, we save the result (winner, player names, board, timestamp) to Firebase Firestore. Players can view their match history anytime. We use Provider for state management, which helps share game data across screens easily. Firebase Authentication handles user login and signup."

### Question: "How do you save and retrieve data?"

**Answer:**
"When a game ends, we create a `Match` object containing winner, player names, board, and date. We call `saveMatch()` in the GameService which uses `_firestore.collection('matches').add()` to save to Firebase. To retrieve, we call `getMatchHistory()` which uses `snapshots()` to listen for real-time updates. Whenever a new game is saved, Firebase automatically sends it to our app and we update the UI."

### Question: "How do you check if someone won?"

**Answer:**
"We have 8 winning patterns: 3 rows, 3 columns, and 2 diagonals. After each move, we loop through all 8 patterns and check if all 3 cells have the same symbol and are not empty. If yes, that player wins. If no pattern matches and all 9 cells are full, it's a tie."

---

## ✅ This Project IS Beginner-Friendly!

Your project is perfect for a viva because:

- ✅ Code is simple and readable
- ✅ Concepts are basic (game logic, CRUD, auth)
- ✅ Well-organized file structure
- ✅ Easy to explain each part
- ✅ No complex algorithms or patterns
- ✅ Real-world application (game + Firebase)

**You can confidently explain this project!** 🎉
