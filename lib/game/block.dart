import 'dart:math';

import 'package:flutter/material.dart';

import 'block_type.dart';

/// Represents a single Tetromino block in the game.
class Block {
  final BlockType type;
  List<List<int>> shape;
  final Color color;
  int rotationIndex;
  Point<int> position;

  Block(this.type)
      : position = const Point(3, 0),
        shape = _getShape(type),
        color = _getColor(type),
        rotationIndex = 0;

  /// Returns the 2D shape matrix for the current rotation.
  static List<List<int>> _getShape(BlockType type) {
    switch (type) {
      case BlockType.I:
        return [
          [1, 1, 1, 1]
        ];
      case BlockType.O:
        return [
          [1, 1],
          [1, 1]
        ];
      case BlockType.T:
        return [
          [0, 1, 0],
          [1, 1, 1]
        ];
      case BlockType.S:
        return [
          [0, 1, 1],
          [1, 1, 0]
        ];
      case BlockType.Z:
        return [
          [1, 1, 0],
          [0, 1, 1]
        ];
      case BlockType.J:
        return [
          [1, 0, 0],
          [1, 1, 1]
        ];
      case BlockType.L:
        return [
          [0, 0, 1],
          [1, 1, 1]
        ];
    }
  }

  /// Returns the color associated with a given BlockType.
  static Color _getColor(BlockType type) {
    switch (type) {
      case BlockType.I:
        return Colors.cyan;
      case BlockType.O:
        return Colors.yellow;
      case BlockType.T:
        return Colors.purple;
      case BlockType.S:
        return Colors.green;
      case BlockType.Z:
        return Colors.red;
      case BlockType.J:
        return Colors.blue;
      case BlockType.L:
        return Colors.orange;
    }
  }

  /// Rotates the block clockwise.
  void rotate() {
    final rows = shape.length;
    final cols = shape[0].length;
    // Use List.generate for better performance and readability
    final newShape = List.generate(
      cols,
      (x) => List.generate(rows, (y) => shape[rows - 1 - y][x]),
      growable: false,
    );
    shape = newShape;
    rotationIndex = (rotationIndex + 1) % 4;
  }
}
