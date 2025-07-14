import 'dart:math';

import 'package:flutter/scheduler.dart';

import 'grid.dart';

/// Controls the Blocks game loop and interactions.
class BlcoksGame {
  final Grid grid;
  late final Ticker _ticker;
  Duration _previous = Duration.zero;
  double _accumulator = 0.0;

  VoidCallback? onUpdate;
  final LinesClearedCallback? onTetris;
  bool isPaused = false;
  Duration _pauseAt = Duration.zero;

  BlcoksGame(TickerProvider vsync, {this.onUpdate, this.onTetris})
      : grid = Grid(onTetris: onTetris) {
    _ticker = vsync.createTicker(tick);
    _ticker.muted = false;
    _ticker.start();
  }

  /// Start the game.
  void start() {
    _previous = Duration.zero;
    _ticker.muted = false;
  }

  /// Pause the game.
  void pause() {
    isPaused = true;
    _ticker.muted = true;
    _pauseAt = _previous;
  }

  /// Resume the game.
  void resume() {
    isPaused = false;
    _ticker.muted = false;
    // Reset _previous to now so time doesn't accumulate during pause
    _previous = Duration.zero;
  }

  /// Move current block horizontally.
  void move(int dx) {
    final block = grid.currentBlock!;
    if (grid.canMove(block, dx, 0)) {
      block.position = Point(block.position.x + dx, block.position.y);
      onUpdate?.call();
    }
  }

  /// Rotate current block.
  void rotate() {
    final block = grid.currentBlock!;
    block.rotate();
    if (!grid.canMove(block, 0, 0)) {
      block.rotate();
      block.rotate();
      block.rotate(); // undo
    } else {
      onUpdate?.call();
    }
  }

  /// Drop block by one cell.
  void softDrop() {
    final block = grid.currentBlock!;
    if (grid.canMove(block, 0, 1)) {
      block.position = Point(block.position.x, block.position.y + 1);
    } else {
      grid.lockBlock(block);
    }
    onUpdate?.call();
  }

  /// Main game loop logic, triggered by the Ticker.
  void tick(Duration elapsed) {
    if (isPaused || grid.isGameOver() || grid.isVictory()) return;
    if (_previous == Duration.zero) {
      _previous = elapsed;
      return;
    }
    final dt = (elapsed - _previous).inMilliseconds / 1000.0;
    _previous = elapsed;
    _accumulator += dt;
    final speed = grid.getDropSpeed();
    if (_accumulator >= speed) {
      _accumulator -= speed;
      softDrop();
    }
  }

  /// Binds the instance-specific tick function to the ticker.
  void bind() {
    // No-op: ticker is already bound to tick in constructor
  }

  void dispose() {
    _ticker.dispose();
  }
}
