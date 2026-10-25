import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.controller,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final GameController controller;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<ThemeMode>(
                key: ValueKey(themeMode),
                initialValue: themeMode,
                decoration: const InputDecoration(
                  labelText: 'Theme',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (mode) {
                  if (mode != null) onThemeModeChanged(mode);
                },
              ),
              const SizedBox(height: 28),
              Text('Single-player game', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<PlayerSymbol>(
                key: ValueKey(controller.humanSymbol),
                initialValue: controller.humanSymbol,
                decoration: const InputDecoration(
                  labelText: 'Play as',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: PlayerSymbol.x, child: Text('X')),
                  DropdownMenuItem(value: PlayerSymbol.o, child: Text('O')),
                ],
                onChanged: controller.gameMode == GameMode.singlePlayer
                    ? (symbol) {
                        if (symbol != null) controller.changeHumanSymbol(symbol);
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TurnOrder>(
                key: ValueKey(controller.turnOrder),
                initialValue: controller.turnOrder,
                decoration: const InputDecoration(
                  labelText: 'Turn order',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: TurnOrder.alwaysFirst, child: Text('Always go first')),
                  DropdownMenuItem(value: TurnOrder.alwaysSecond, child: Text('Always go second')),
                  DropdownMenuItem(value: TurnOrder.alternate, child: Text('Alternate each game')),
                ],
                onChanged: controller.gameMode == GameMode.singlePlayer
                    ? (order) {
                        if (order != null) controller.changeTurnOrder(order);
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                controller.gameMode == GameMode.singlePlayer
                    ? 'These options apply to 1 Player mode.'
                    : 'Switch to 1 Player mode to change these options.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
