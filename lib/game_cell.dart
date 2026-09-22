import 'package:flutter/material.dart';

class GameCell extends StatelessWidget {
  final String? value;
  final bool isWinningCell;
  final VoidCallback onTap;

  const GameCell({
    super.key,
    required this.value,
    required this.isWinningCell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color? symbolColor;

    if (value == 'X') {
      symbolColor = colorScheme.primary;
    } else if (value == 'O') {
      symbolColor = colorScheme.error;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isWinningCell
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isWinningCell
              ? Border.all(
                  color: colorScheme.primary,
                  width: 3,
                )
              : null,
          boxShadow: isWinningCell
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            value ?? '',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: symbolColor,
            ),
          ),
        ),
      ),
    );
  }
}