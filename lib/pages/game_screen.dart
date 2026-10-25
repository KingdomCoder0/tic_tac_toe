import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_settings.dart';
import '../widgets/game_board.dart';
import '../tic_tac_toe_ai.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                selected: {controller.gameMode},
                onSelectionChanged: (selection) =>
                    controller.changeGameMode(selection.first),
              ),
              if (controller.gameMode == GameMode.singlePlayer) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<AiDifficulty>(
                  key: ValueKey(controller.aiDifficulty),
                  initialValue: controller.aiDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: AiDifficulty.easy, child: Text('Easy')),
                    DropdownMenuItem(value: AiDifficulty.medium, child: Text('Medium')),
                    DropdownMenuItem(value: AiDifficulty.hard, child: Text('Hard')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.changeDifficulty(value);
                  },
                ),
              ],
              const SizedBox(height: 24),
              Text(
                controller.status,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              GameBoard(
                board: controller.board,
                winningCells: controller.winningCells,
                onCellTap: controller.makeMove,
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: controller.newGame,
                icon: const Icon(Icons.refresh),
                label: const Text('New Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
