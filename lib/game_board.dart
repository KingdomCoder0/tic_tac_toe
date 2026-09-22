import 'package:flutter/material.dart';
import 'game_cell.dart';

class GameBoard extends StatelessWidget {
  final List<String?> board;
  final List<int> winningCells;
  final Function(int) onCellTap;

  const GameBoard({
    super.key,
    required this.board,
    required this.winningCells,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return GameCell(
            value: board[index],
            isWinningCell: winningCells.contains(index),
            onTap: () => onCellTap(index),
          );
        },
      ),
    );
  }
}