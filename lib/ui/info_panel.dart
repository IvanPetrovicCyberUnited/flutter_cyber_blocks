import 'package:flutter/material.dart';

import '../game/grid.dart';

/// Displays the score, level, and preview of the next block.
class InfoPanel extends StatelessWidget {
  final Grid grid;
  final double blockSize;

  const InfoPanel({
    Key? key,
    required this.grid,
    this.blockSize = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final next = grid.nextBlock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Score: ${grid.score}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text('Level: ${grid.level}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        const Text('Next:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        if (next != null)
          SizedBox(
            width: blockSize * 4,
            height: blockSize * 4,
            child: Stack(
              children: [
                for (int y = 0; y < next.shape.length; y++)
                  for (int x = 0; x < next.shape[y].length; x++)
                    if (next.shape[y][x] == 1)
                      Positioned(
                        left: x * blockSize,
                        top: y * blockSize,
                        child: Container(
                          width: blockSize,
                          height: blockSize,
                          decoration: BoxDecoration(
                            color: next.color,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                        ),
                      )
              ],
            ),
          ),
      ],
    );
  }
}
