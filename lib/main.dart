import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: TetrisBoard(),
        ),
      ),
    );
  }
}

class TetrisBoard extends StatefulWidget {
  const TetrisBoard({super.key});

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard> with SingleTickerProviderStateMixin {
  static const int rows = 20;
  static const int cols = 10;
  late List<List<int>> board;
  OverlayEntry? _tetrisEffect;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    board = List.generate(rows, (_) => List.filled(cols, 0));
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void placePieceAndCheckLines() {
    // Placeholder for piece placement logic
    // After placing, check for full lines
    final clearedLines = _clearFullLines();
    if (clearedLines == 4) {
      _triggerTetrisEffect();
    }
  }

  int _clearFullLines() {
    // Fake check: assume 4 lines cleared for demonstration
    return 4;
  }

  void _triggerTetrisEffect() {
    _tetrisEffect?.remove();
    _tetrisEffect = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: 1 - _controller.value,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.8),
                    blurRadius: 30 * (1 - _controller.value),
                    spreadRadius: 5 * (1 - _controller.value),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_tetrisEffect!);
    _controller.forward(from: 0).whenComplete(() => _tetrisEffect?.remove());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: placePieceAndCheckLines,
      child: Container(
        width: 200,
        height: 400,
        color: Colors.black,
        child: CustomPaint(
          painter: _BoardPainter(board),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final List<List<int>> board;

  _BoardPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;
    final cellWidth = size.width / _TetrisBoardState.cols;
    final cellHeight = size.height / _TetrisBoardState.rows;
    for (var y = 0; y < _TetrisBoardState.rows; y++) {
      for (var x = 0; x < _TetrisBoardState.cols; x++) {
        if (board[y][x] != 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellWidth, y * cellHeight, cellWidth, cellHeight),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
