import 'package:flutter/material.dart';

import 'game_board.dart';
import 'tic_tac_toe_ai.dart';

enum GameMode {
  singlePlayer,
  twoPlayer,
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // ------------------------------------------------------------
  // GAME SETTINGS
  // ------------------------------------------------------------

  GameMode gameMode = GameMode.singlePlayer;

  AiDifficulty aiDifficulty = AiDifficulty.medium;

  // ------------------------------------------------------------
  // GAME STATE
  // ------------------------------------------------------------

  List<String?> board = List.filled(9, null);

  String currentPlayer = 'X';

  String? winner;

  List<int> winningCells = [];

  bool draw = false;

  // ------------------------------------------------------------
  // PLAYER MOVE
  // ------------------------------------------------------------

  void makeMove(int index) {
    // Don't allow a move if the square is occupied.
    if (board[index] != null) {
      return;
    }

    // Don't allow moves after the game ends.
    if (winner != null || draw) {
      return;
    }

    // In single-player mode, don't let the player move
    // while it is the computer's turn.
    if (gameMode == GameMode.singlePlayer &&
        currentPlayer == 'O') {
      return;
    }

    setState(() {
      board[index] = currentPlayer;

      checkGameState();

      if (winner == null && !draw) {
        switchPlayer();
      }
    });

    // In single-player mode, let the computer move.
    if (gameMode == GameMode.singlePlayer &&
        winner == null &&
        !draw &&
        currentPlayer == 'O') {
      Future.delayed(
        const Duration(milliseconds: 400),
        computerMove,
      );
    }
  }

  // ------------------------------------------------------------
  // COMPUTER MOVE
  // ------------------------------------------------------------

  void computerMove() {
    if (winner != null || draw) {
      return;
    }

    if (currentPlayer != 'O') {
      return;
    }

    final availableMoves =
        board.where((cell) => cell == null).length;

    if (availableMoves == 0) {
      return;
    }

    final move = TicTacToeAI.findMove(
      board,
      aiDifficulty,
    );

    setState(() {
      board[move] = 'O';

      checkGameState();

      if (winner == null && !draw) {
        currentPlayer = 'X';
      }
    });
  }

  // ------------------------------------------------------------
  // SWITCH PLAYER
  // ------------------------------------------------------------

  void switchPlayer() {
    if (currentPlayer == 'X') {
      currentPlayer = 'O';
    } else {
      currentPlayer = 'X';
    }
  }

  // ------------------------------------------------------------
  // CHECK GAME STATE
  // ------------------------------------------------------------

  void checkGameState() {
  const winningCombinations = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  for (final combination in winningCombinations) {
    final a = combination[0];
    final b = combination[1];
    final c = combination[2];

    if (board[a] != null &&
        board[a] == board[b] &&
        board[a] == board[c]) {
      winner = board[a];
      winningCells = combination;
      return;
    }
  }

  if (!board.contains(null)) {
    draw = true;
  }
}

  // ------------------------------------------------------------
  // RESET GAME
  // ------------------------------------------------------------

  void resetGameState() {
    board = List.filled(9, null);
    currentPlayer = 'X';
    winner = null;
    draw = false;
    winningCells = [];
  }

  void resetGame() {
    setState(() {
      resetGameState();
    });
  }

  // ------------------------------------------------------------
  // CHANGE GAME MODE
  // ------------------------------------------------------------

  void changeGameMode(GameMode? mode) {
    if (mode == null || mode == gameMode) return;

    setState(() {
      gameMode = mode;
      resetGameState();
    });
  }

  // ------------------------------------------------------------
  // CHANGE AI DIFFICULTY
  // ------------------------------------------------------------

  void changeDifficulty(AiDifficulty? difficulty) {
    if (difficulty == null || difficulty == aiDifficulty) return;

    setState(() {
      aiDifficulty = difficulty;
      resetGameState();
    });
  }

  // ------------------------------------------------------------
  // STATUS TEXT
  // ------------------------------------------------------------

  String get status {
    if (winner == 'X') {
      return gameMode == GameMode.singlePlayer
          ? 'You win!'
          : 'Player X wins!';
    }

    if (winner == 'O') {
      return gameMode == GameMode.singlePlayer
          ? 'Computer wins!'
          : 'Player O wins!';
    }

    if (draw) {
      return "It's a draw!";
    }

    if (gameMode == GameMode.singlePlayer) {
      if (currentPlayer == 'X') {
        return 'Your turn';
      }

      return 'Computer is thinking...';
    }

    return "Player $currentPlayer's turn";
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // ------------------------------------------------
                  // GAME MODE
                  // ------------------------------------------------

                  SegmentedButton<GameMode>(
                    segments: const [
                      ButtonSegment(
                        value: GameMode.singlePlayer,
                        label: Text('1 Player'),
                        icon: Icon(Icons.person),
                      ),
                      ButtonSegment(
                        value: GameMode.twoPlayer,
                        label: Text('2 Players'),
                        icon: Icon(Icons.people),
                      ),
                    ],

                    selected: {gameMode},

                    onSelectionChanged: (selection) {
                      changeGameMode(selection.first);
                    },
                  ),

                  // ------------------------------------------------
                  // AI DIFFICULTY
                  // ------------------------------------------------

                  if (gameMode == GameMode.singlePlayer) ...[
                    const SizedBox(height: 16),

                    DropdownButtonFormField<AiDifficulty>(
                      initialValue: aiDifficulty,

                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: AiDifficulty.easy,
                          child: Text('Easy'),
                        ),
                        DropdownMenuItem(
                          value: AiDifficulty.medium,
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: AiDifficulty.hard,
                          child: Text('Hard'),
                        ),
                      ],

                      onChanged: changeDifficulty,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // STATUS
                  // ------------------------------------------------

                  Text(
                    status,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),

                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // BOARD
                  // ------------------------------------------------

                  GameBoard(
                    board: board,
                    winningCells: winningCells,
                    onCellTap: makeMove,
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // NEW GAME
                  // ------------------------------------------------

                  FilledButton.icon(
                    onPressed: resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
