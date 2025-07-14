import 'dart:html' as html;
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/grid.dart';
import 'game/blocks.dart';
import 'ui/controller_panel.dart';
import 'ui/game_board.dart';
import 'ui/info_panel.dart';

void main() {
  runApp(const CyberBlocksApp());
}

class CyberBlocksApp extends StatelessWidget {
  const CyberBlocksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Blcoks',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(),
      ),
      home: const BlocksGamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BlocksGamePage extends StatefulWidget {
  const BlocksGamePage({super.key});

  @override
  State<BlocksGamePage> createState() => _BlocksGamePageState();
}

class _BlocksGamePageState extends State<BlocksGamePage>
    with SingleTickerProviderStateMixin {
  late BlcoksGame game;
  final FocusNode _focusNode = FocusNode();
  List<int>? _tetrisRows;
  final AudioPlayer _tetrisPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    game = BlcoksGame(this,
        onUpdate: () => setState(() {}), onTetris: _handleTetris);
    game.bind();
  }

  @override
  void dispose() {
    game.dispose();
    _tetrisPlayer.dispose();
    super.dispose();
  }

  void _restartGame() {
    game.dispose();
    setState(() {
      game = BlcoksGame(this,
          onUpdate: () => setState(() {}), onTetris: _handleTetris);
      // Do NOT call game.bind() or create another ticker
    });
  }

  void _handleTetris(List<int> rows) {
    _tetrisPlayer.play(AssetSource('sound/thunder.mp3'));
    Future.delayed(const Duration(seconds: 1), () {
      _tetrisPlayer.stop();
    });

    setState(() {
      _tetrisRows = rows;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _tetrisRows = null;
        });
      }
    });
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyLabel.toLowerCase()) {
        case 'arrow left':
        case 'a':
          game.move(-1);
          break;
        case 'arrow right':
        case 'd':
          game.move(1);
          break;
        case 'arrow down':
        case 's':
          game.softDrop();
          break;
        case 'arrow up':
        case 'w':
        case ' ': // Spacebar for rotate
          game.rotate();
          break;
        case 'q':
          setState(() {
            game.isPaused ? game.resume() : game.pause();
          });
          break;
        case 'r':
          _restartGame();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isPaused = game.isPaused;
    final isGameOver = game.grid.isGameOver();
    final isVictory = game.grid.isVictory();

    Widget infoPanelBox = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoPanel(grid: game.grid),
          const SizedBox(height: 24),
          // Pause-Button: Icon oben, Text darunter, linksbündig
          GestureDetector(
            onTap: () {
              setState(() {
                game.isPaused ? game.resume() : game.pause();
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  game.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.blueGrey.shade200,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  game.isPaused ? 'Resume' : 'Pause',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Restart-Button: Icon oben, Text darunter, linksbündig
          GestureDetector(
            onTap: () {
              html.window.location.reload();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.redAccent,
                  size: 32,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Restart',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget gameContent = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Responsive GameBoard row
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available width for GameBoard
              // Reserve 24px for spacing and 180px for infoPanelBox
              double sidePanelWidth = 24 + 180;
              double maxBoardWidth = constraints.maxWidth - sidePanelWidth;
              // Use Grid.columns and Grid.rows for board size
              final int numCols = Grid.columns;
              final int numRows = Grid.rows;
              double blockSize = maxBoardWidth / numCols;
              blockSize = blockSize.clamp(16.0, 32.0); // min 16, max 32 px
              double boardWidth = blockSize * numCols;
              double boardHeight = blockSize * numRows;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GameBoard takes available space but is centered and never exceeds its max width
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SizedBox(
                        width: boardWidth.clamp(0, constraints.maxWidth - 204),
                        height: boardHeight,
                        child: GameBoard(
                          grid: game.grid,
                          blockSize: blockSize,
                          highlightRows: _tetrisRows,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // InfoPanelBox takes only as much as needed
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: infoPanelBox,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          if (isGameOver)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Game Over',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isVictory)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'You Win!',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
    Widget mobileControls = Positioned(
      right: 60,
      bottom: MediaQuery.of(context).size.height * 0.13,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // D-Pad with modern look
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.92),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: ControllerPanel(
              onLeft: () => game.move(-1),
              onRight: () => game.move(1),
              onDown: () => game.softDrop(),
              onRotate: () => game.rotate(),
              onDrop: () {
                while (game.grid.canMove(game.grid.currentBlock!, 0, 1)) {
                  game.grid.currentBlock!.position = Point(
                    game.grid.currentBlock!.position.x,
                    game.grid.currentBlock!.position.y + 1,
                  );
                }
                game.softDrop();
              },
              dpadOnly: true,
            ),
          ),
          const SizedBox(width: 24),
          // A/B Buttons with modern look
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => game.rotate(),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(22),
                    backgroundColor: Colors.blueAccent,
                    elevation: 8,
                    shadowColor: Colors.blueAccent,
                  ),
                  child: const Text('A',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    while (game.grid.canMove(game.grid.currentBlock!, 0, 1)) {
                      game.grid.currentBlock!.position = Point(
                        game.grid.currentBlock!.position.x,
                        game.grid.currentBlock!.position.y + 1,
                      );
                    }
                    game.softDrop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(22),
                    backgroundColor: Colors.orangeAccent,
                    elevation: 8,
                    shadowColor: Colors.orangeAccent,
                  ),
                  child: const Text('B',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Blocks'),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: isMobile
              ? Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 140),
                        child: gameContent,
                      ),
                    ),
                    if (!isPaused && !isGameOver && !isVictory) mobileControls,
                  ],
                )
              : (isPaused || isGameOver || isVictory
                  ? gameContent
                  : RawKeyboardListener(
                      focusNode: _focusNode,
                      autofocus: true,
                      onKey: isPaused || isGameOver || isVictory
                          ? null
                          : _handleKey,
                      child: gameContent,
                    )),
        ),
      ),
    );
  }
}
