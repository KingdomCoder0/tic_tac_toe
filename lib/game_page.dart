import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'game_board.dart';
import 'tic_tac_toe_ai.dart';

enum GameMode {
  singlePlayer,
  twoPlayer,
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey =
    GlobalKey<ScaffoldState>();

  bool _sidebarExpanded = true;

  int _selectedDestination = 0;

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
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      key: _scaffoldKey,

      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: _buildNavigation(isWide: false),
              ),
            ),

      appBar: AppBar(
        leading: isWide
            ? null
            : IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
        title: const Text('Tic-Tac-Toe'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  _buildNavigation(isWide: true),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: _buildSelectedPage(),
                  ),
                ],
              )
            : _buildSelectedPage(),
      ),
    );
  }

  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------
  void _selectDestination(int index, {required bool isWide}) {
    setState(() {
      _selectedDestination = index;
    });

    if (!isWide) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildNavigation({required bool isWide}) {
    if (!isWide) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const ListTile(
            leading: Icon(Icons.grid_3x3),
            title: Text(
              'Tic-Tac-Toe',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),

          _buildDrawerItem(
            icon: Icons.gamepad_outlined,
            label: 'Game',
            index: 0,
          ),

          _buildDrawerItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            index: 1,
          ),

          _buildDrawerItem(
            icon: Icons.info_outline,
            label: 'About',
            index: 2,
          ),
        ],
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: _sidebarExpanded ? 220 : 72,
      child: Column(
        children: [
          Align(
            alignment: _sidebarExpanded 
                ? Alignment.centerRight 
                : Alignment.center,
            child: IconButton(
              tooltip: _sidebarExpanded
                  ? 'Collapse sidebar'
                  : 'Expand sidebar',
              icon: Icon(
                _sidebarExpanded
                    ? Icons.menu_open
                    : Icons.menu,
              ),
              onPressed: () {
                setState(() {
                  _sidebarExpanded = !_sidebarExpanded;
                });
              },
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: NavigationRail(
              extended: _sidebarExpanded,
              minWidth: 72,
              minExtendedWidth: 220,
              selectedIndex: _selectedDestination,
              labelType: _sidebarExpanded
                  ? null
                  : NavigationRailLabelType.none,
              onDestinationSelected: (index) {
                _selectDestination(index, isWide: true);
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.gamepad_outlined),
                  selectedIcon: Icon(Icons.gamepad),
                  label: Text('Game'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: Text('About'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: _selectedDestination == index,
      onTap: () {
        _selectDestination(index, isWide: false);
      },
    );
  }

  // ------------------------------------------------------------
  // PAGE CONTENT
  // ------------------------------------------------------------
  Widget _buildSelectedPage() {
    switch (_selectedDestination) {
      case 1:
        return _buildSettingsPage();
      case 2:
        return _buildAboutPage();
      default:
        return _buildGamePage();
    }
  }

  // ------------------------------------------------------------
  // GAME PAGE
  // ------------------------------------------------------------
  Widget _buildGamePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
    );
  }

  // ------------------------------------------------------------
  // SETTINGS PAGE
  // ------------------------------------------------------------
  Widget _buildSettingsPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 24),

              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<ThemeMode>(
                initialValue: widget.themeMode,
                decoration: const InputDecoration(
                  labelText: 'Theme',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Default'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    widget.onThemeModeChanged(mode);
                  }
                },
              ),

              const SizedBox(height: 12),

              Text(
                'System Default follows your device or browser '
                'appearance. Light and Dark override it.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ABOUT PAGE
  // ------------------------------------------------------------  
  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://kingdomcoder0.github.io/tic_tac_toe/privacy-policy.html',
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the privacy policy.'),
        ),
      );
    }
  }

  Widget _buildAboutPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.grid_3x3, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Tic-Tac-Toe',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A Tic-Tac-Toe game built with Flutter.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Play against the computer or another player.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: _openPrivacyPolicy,
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Privacy Policy'),
          ),
        ],
      ),
    );
  }
}
