import 'dart:math';

enum AiDifficulty {
  easy,
  medium,
  hard,
}

class TicTacToeAI {
  static final Random _random = Random();

  /// Returns the computer's chosen move.
  ///
  /// [aiSymbol] is the computer's symbol, either X or O.
  /// [humanSymbol] is the human player's symbol.
  static int findMove(
    List<String?> board,
    AiDifficulty difficulty, {
    required String aiSymbol,
    required String humanSymbol,
  }) {
    assert(aiSymbol != humanSymbol);
    assert(
      (aiSymbol == 'X' || aiSymbol == 'O') &&
      (humanSymbol == 'X' || humanSymbol == 'O'),
    );

    // All difficulties use the same randomised opening
    // when the AI plays first.
    if (board.every((cell) => cell == null)) {
      return _openingMove();
    }

    switch (difficulty) {
      case AiDifficulty.easy:
        return _randomMove(board);

      case AiDifficulty.medium:
        return _mediumMove(board, aiSymbol, humanSymbol);

      case AiDifficulty.hard:
        return _hardMove(board, aiSymbol, humanSymbol);
    }
  }

  /// Chooses a random opening:
  /// 33% corner, 33% side, 34% centre.
  static int _openingMove() {
    final category = _random.nextInt(100);

    if (category < 33) {
      // Random corner.
      const corners = [0, 2, 6, 8];
      return corners[_random.nextInt(corners.length)];
    }

    if (category < 66) {
      // Random side.
      const sides = [1, 3, 5, 7];
      return sides[_random.nextInt(sides.length)];
    }

    // Centre.
    return 4;
  }

  // EASY: choose any available square.
  static int _randomMove(List<String?> board) {
    final availableMoves = _availableMoves(board);

    return availableMoves[
        _random.nextInt(availableMoves.length)];
  }

  // MEDIUM: win if possible, otherwise block, otherwise play randomly.
  static int _mediumMove(
    List<String?> board,
    String aiSymbol,
    String humanSymbol,
  ) {
    final availableMoves = _availableMoves(board);

    // Take a winning move if one is available.
    for (final move in availableMoves) {
      final testBoard = List<String?>.from(board);
      testBoard[move] = aiSymbol;

      if (_checkWinner(testBoard) == aiSymbol) {
        return move;
      }
    }

    // Block the human from winning on their next move.
    for (final move in availableMoves) {
      final testBoard = List<String?>.from(board);
      testBoard[move] = humanSymbol;

      if (_checkWinner(testBoard) == humanSymbol) {
        return move;
      }
    }

    // Otherwise, choose randomly.
    return availableMoves[
        _random.nextInt(availableMoves.length)];
  }

  // HARD: use minimax and randomly choose between
  // moves with the same best score.
  static int _hardMove(
    List<String?> board,
    String aiSymbol,
    String humanSymbol,
  ) {
    var bestScore = -1000;
    final bestMoves = <int>[];

    for (final move in _availableMoves(board)) {
      final testBoard = List<String?>.from(board);
      testBoard[move] = aiSymbol;

      final score = _minimax(
        testBoard,
        false,
        aiSymbol,
        humanSymbol,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMoves
          ..clear()
          ..add(move);
      } else if (score == bestScore) {
        bestMoves.add(move);
      }
    }

    // Randomise between equally scored moves.
    return bestMoves[
        _random.nextInt(bestMoves.length)];
  }

  // MINIMAX: the AI maximizes the score; the human minimizes it.
  static int _minimax(
    List<String?> board,
    bool maximizing,
    String aiSymbol,
    String humanSymbol,
  ) {
    final winner = _checkWinner(board);

    if (winner == aiSymbol) return 10;
    if (winner == humanSymbol) return -10;
    if (!board.contains(null)) return 0;

    if (maximizing) {
      var bestScore = -1000;

      for (final move in _availableMoves(board)) {
        final testBoard = List<String?>.from(board);
        testBoard[move] = aiSymbol;

        final score = _minimax(
          testBoard,
          false,
          aiSymbol,
          humanSymbol,
        );

        bestScore = max(bestScore, score);
      }

      return bestScore;
    } else {
      var bestScore = 1000;

      for (final move in _availableMoves(board)) {
        final testBoard = List<String?>.from(board);
        testBoard[move] = humanSymbol;

        final score = _minimax(
          testBoard,
          true,
          aiSymbol,
          humanSymbol,
        );

        bestScore = min(bestScore, score);
      }

      return bestScore;
    }
  }

  // HELPERS

  static List<int> _availableMoves(List<String?> board) {
    final moves = <int>[];

    for (var i = 0; i < board.length; i++) {
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
