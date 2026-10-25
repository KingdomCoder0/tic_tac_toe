import 'dart:async';

import 'package:flutter/foundation.dart';

import '../tic_tac_toe_ai.dart';
import 'game_settings.dart';

class GameController extends ChangeNotifier {
  GameController({
    this._gameMode = GameMode.singlePlayer,
    this._aiDifficulty = AiDifficulty.medium,
    this._humanSymbol = PlayerSymbol.x,
    this._turnOrder = TurnOrder.alwaysFirst,
  }) {
    _startNewRound();
  }

  GameMode _gameMode;
  AiDifficulty _aiDifficulty;
  PlayerSymbol _humanSymbol;
  TurnOrder _turnOrder;

  GameMode get gameMode => _gameMode;
  AiDifficulty get aiDifficulty => _aiDifficulty;
  PlayerSymbol get humanSymbol => _humanSymbol;
  TurnOrder get turnOrder => _turnOrder;

  String get humanMark => _humanSymbol.value;
  String get computerMark => _humanSymbol.other.value;

  List<String?> board = List.filled(9, null);
  String currentPlayer = 'X';
  String? winner;
  List<int> winningCells = [];
  bool draw = false;

  bool _nextHumanStarts = true;
  bool _roundCompleted = false;
  int _generation = 0;

  bool get isGameOver => winner != null || draw;

  /// Call after the UI has subscribed to this controller.
  void start() {
    if (_gameMode == GameMode.singlePlayer &&
        currentPlayer == computerMark) {
      _scheduleComputerMove();
    }
  }

  void makeMove(int index) {
    if (index < 0 || index >= board.length) return;
    if (board[index] != null || isGameOver) return;
    if (_gameMode == GameMode.singlePlayer && currentPlayer != humanMark) {
      return;
    }

    board[index] = currentPlayer;
    _checkGameState();

    if (!isGameOver) _switchPlayer();
    notifyListeners();

    if (_gameMode == GameMode.singlePlayer &&
        !isGameOver &&
        currentPlayer == computerMark) {
      _scheduleComputerMove();
    }
  }

  void _scheduleComputerMove() {
    final generation = _generation;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (generation != _generation ||
          _gameMode != GameMode.singlePlayer ||
          isGameOver ||
          currentPlayer != computerMark) {
        return;
      }
      _computerMove();
    });
  }

  void _computerMove() {
    final move = TicTacToeAI.findMove(
      board,
      _aiDifficulty,
      aiSymbol: computerMark,
      humanSymbol: humanMark,
    );

    board[move] = computerMark;
    _checkGameState();
    if (!isGameOver) _switchPlayer();
    notifyListeners();
  }

  void _switchPlayer() {
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
  }

  bool get _humanStartsThisRound {
    switch (_turnOrder) {
      case TurnOrder.alwaysFirst:
        return true;
      case TurnOrder.alwaysSecond:
        return false;
      case TurnOrder.alternate:
        return _nextHumanStarts;
    }
  }

  void _checkGameState() {
    const combinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (final line in combinations) {
      final a = line[0], b = line[1], c = line[2];
      if (board[a] != null && board[a] == board[b] && board[a] == board[c]) {
        winner = board[a];
        winningCells = List<int>.from(line);
        _registerCompletedRound();
        return;
      }
    }

    if (!board.contains(null)) {
      draw = true;
      _registerCompletedRound();
    }
  }

  void _registerCompletedRound() {
    if (_roundCompleted) return;
    _roundCompleted = true;
    if (_turnOrder == TurnOrder.alternate) {
      _nextHumanStarts = !_nextHumanStarts;
    }
  }

  void newGame() {
    _generation++;
    _startNewRound();
    notifyListeners();
    if (_gameMode == GameMode.singlePlayer && currentPlayer == computerMark) {
      _scheduleComputerMove();
    }
  }

  void _startNewRound() {
    board = List.filled(9, null);
    winner = null;
    draw = false;
    winningCells = [];
    _roundCompleted = false;

    if (_gameMode == GameMode.twoPlayer) {
      currentPlayer = 'X';
    } else {
      currentPlayer = _humanStartsThisRound ? humanMark : computerMark;
    }
  }

  void changeGameMode(GameMode mode) {
    if (mode == _gameMode) return;
    _gameMode = mode;
    newGame();
  }

  void changeDifficulty(AiDifficulty difficulty) {
    if (difficulty == _aiDifficulty) return;
    _aiDifficulty = difficulty;
    newGame();
  }

  void changeHumanSymbol(PlayerSymbol symbol) {
    if (symbol == _humanSymbol) return;
    _humanSymbol = symbol;
    newGame();
  }

  void changeTurnOrder(TurnOrder order) {
    if (order == _turnOrder) return;
    _turnOrder = order;
    if (order == TurnOrder.alternate) _nextHumanStarts = true;
    newGame();
  }

  String get status {
    if (winner != null) {
      if (_gameMode == GameMode.twoPlayer) return 'Player $winner wins!';
      return winner == humanMark ? 'You win!' : 'Computer wins!';
    }
    if (draw) return "It's a draw!";
    if (_gameMode == GameMode.singlePlayer) {
      return currentPlayer == humanMark ? 'Your turn ($humanMark)' : 'Computer is thinking...';
    }
    return "Player $currentPlayer's turn";
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}
