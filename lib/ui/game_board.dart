import 'package:flutter/material.dart';

import '../game/block.dart';
import '../game/grid.dart';

/// Widget that draws the Blocks grid and current block.
class GameBoard extends StatelessWidget {
  final Grid grid;
  final double blockSize;
  final List<int>? highlightRows;

  const GameBoard({
    Key? key,
    required this.grid,
    this.blockSize = 20.0,
    this.highlightRows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Grid.columns * blockSize,
      height: Grid.rows * blockSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Draw placed blocks
          for (int y = 0; y < Grid.rows; y++)
            for (int x = 0; x < Grid.columns; x++)
              if (grid.cells[y][x] != null)
                Positioned(
                  left: x * blockSize,
                  top: y * blockSize,
                  child: _buildBlock(grid.cells[y][x]!, blockSize),
                ),

          // Draw current falling block
          if (grid.currentBlock != null)
            for (int y = 0; y < grid.currentBlock!.shape.length; y++)
              for (int x = 0; x < grid.currentBlock!.shape[y].length; x++)
                if (grid.currentBlock!.shape[y][x] == 1)
                  _buildFallingBlock(x, y, blockSize),

          if (highlightRows != null)
            for (final row in highlightRows!)
              Positioned(
                left: 0,
                top: row * blockSize,
                child: Container(
                  width: Grid.columns * blockSize,
                  height: blockSize,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.6),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.orangeAccent,
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// Renders a single colored block.
  Widget _buildBlock(Block block, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: block.color,
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  /// Renders a single cell of the falling block at the correct position.
  Widget _buildFallingBlock(int x, int y, double size) {
    final block = grid.currentBlock!;
    return Positioned(
      left: (block.position.x + x) * size,
      top: (block.position.y + y) * size,
      child: _buildBlock(block, size),
    );
  }
}
