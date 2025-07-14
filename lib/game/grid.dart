import 'dart:math';

import 'block.dart';
import 'block_type.dart';

/// Manages the Blocks grid state, block placement, line clearing, and scoring.
class Grid {
  static const int rows = 20;
  static const int columns = 10;

  final List<List<Block?>> cells = List.generate(
    rows,
    (_) => List.filled(columns, null),
  );

  Block? currentBlock;
  Block? nextBlock;
  final Random _random = Random();

  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool gameOver = false;
  bool victory = false;

  Grid() {
    spawnBlock();
  }

  void spawnBlock() {
    currentBlock = nextBlock ?? Block(_randomType());
    nextBlock = Block(_randomType());
    // Game over if new block overlaps top row
    if (!_canPlace(currentBlock!)) {
      gameOver = true;
    }
  }

  BlockType _randomType() {
    return BlockType.values[_random.nextInt(BlockType.values.length)];
  }

  bool canMove(Block block, int dx, int dy) {
    final shape = block.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 0) continue;
        int newX = block.position.x + dx + x;
        int newY = block.position.y + dy + y;
        if (newX < 0 || newX >= columns || newY >= rows) return false;
        if (newY >= 0 && cells[newY][newX] != null) return false;
      }
    }
    return true;
  }

  void lockBlock(Block block) {
    final shape = block.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          int px = block.position.x + x;
          int py = block.position.y + y;
          if (py >= 0 && py < rows && px >= 0 && px < columns) {
            cells[py][px] = block;
          }
        }
      }
    }
    clearLines();
    if (!victory && !gameOver) spawnBlock();
  }

  void clearLines() {
    int cleared = 0;
    for (int y = 0; y < rows; y++) {
      if (cells[y].every((cell) => cell != null)) {
        cells.removeAt(y);
        cells.insert(0, List.filled(columns, null));
        cleared++;
      }
    }
    if (cleared > 0) {
      // Scoring: points = (2^linesClearedAtOnce) * level
      score += pow(2, cleared).toInt() * level;
      // Leveling: +1 level per line cleared
      level += cleared;
      linesCleared += cleared;
      if (level >= 100) {
        victory = true;
      }
    }
  }

  bool _canPlace(Block block) {
    final shape = block.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 0) continue;
        int px = block.position.x + x;
        int py = block.position.y + y;
        if (py < 0 || py >= rows || px < 0 || px >= columns) return false;
        if (cells[py][px] != null) return false;
      }
    }
    return true;
  }

  bool isGameOver() => gameOver;
  bool isVictory() => victory;

  double getDropSpeed() {
    // Falling speed: 1.0 * pow(0.9, level ~/ 10)
    return 1.0 * pow(0.9, level ~/ 10);
  }
}
