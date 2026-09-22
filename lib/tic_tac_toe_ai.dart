import 'dart:math';

enum AiDifficulty {
  easy,
  medium,
  hard,
}

class TicTacToeAI {
  static final Random _random = Random();

  /// Returns the computer's chosen move.
  static int findMove(
    List<String?> board,
    AiDifficulty difficulty,
  ) {
    switch (difficulty) {
      case AiDifficulty.easy:
        return _randomMove(board);

      case AiDifficulty.medium:
        return _mediumMove(board);

      case AiDifficulty.hard:
        return _hardMove(board);
    }
  }

  // ------------------------------------------------------------
  // EASY
  // ------------------------------------------------------------

  static int _randomMove(List<String?> board) {
    final availableMoves = _availableMoves(board);

    return availableMoves[
        _random.nextInt(availableMoves.length)];
  }

  // ------------------------------------------------------------
  // MEDIUM
  // ------------------------------------------------------------

  static int _mediumMove(List<String?> board) {
    final availableMoves = _availableMoves(board);

    // First, see if the computer can win.
    for (final move in availableMoves) {
      final testBoard = List<String?>.from(board);
      testBoard[move] = 'O';

      if (_checkWinner(testBoard) == 'O') {
        return move;
      }
    }

    // If we can't win, see if we need to block the player.
    for (final move in availableMoves) {
      final testBoard = List<String?>.from(board);
      testBoard[move] = 'X';

      if (_checkWinner(testBoard) == 'X') {
        return move;
      }
    }

    // Otherwise make a random move.
    return availableMoves[
        _random.nextInt(availableMoves.length)];
  }

  // ------------------------------------------------------------
  // HARD
  // ------------------------------------------------------------

  static int _hardMove(List<String?> board) {
    int bestScore = -1000;
    int bestMove = -1;

    for (final move in _availableMoves(board)) {
      final testBoard = List<String?>.from(board);

      testBoard[move] = 'O';

      final score = _minimax(
        testBoard,
        false,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  // ------------------------------------------------------------
  // MINIMAX
  // ------------------------------------------------------------

  static int _minimax(
    List<String?> board,
    bool maximizing,
  ) {
    final winner = _checkWinner(board);

    if (winner == 'O') {
      return 10;
    }

    if (winner == 'X') {
      return -10;
    }

    if (!board.contains(null)) {
      return 0;
    }

    if (maximizing) {
      int bestScore = -1000;

      for (final move in _availableMoves(board)) {
        final testBoard = List<String?>.from(board);

        testBoard[move] = 'O';

        final score = _minimax(
          testBoard,
          false,
        );

        bestScore = max(bestScore, score);
      }

      return bestScore;
    } else {
      int bestScore = 1000;

      for (final move in _availableMoves(board)) {
        final testBoard = List<String?>.from(board);

        testBoard[move] = 'X';

        final score = _minimax(
          testBoard,
          true,
        );

        bestScore = min(bestScore, score);
      }

      return bestScore;
    }
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  static List<int> _availableMoves(List<String?> board) {
    final moves = <int>[];

    for (int i = 0; i < board.length; i++) {
      if (board[i] == null) {
        moves.add(i);
      }
    }

    return moves;
  }

  static String? _checkWinner(List<String?> board) {
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
        return board[a];
      }
    }

    return null;
  }
}
