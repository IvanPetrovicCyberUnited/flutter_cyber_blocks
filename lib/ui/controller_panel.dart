import 'package:flutter/material.dart';

/// Gameboy-style controller with D-Pad and A/B buttons.
class ControllerPanel extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onDown;
  final VoidCallback onRotate;
  final VoidCallback onDrop;
  final bool dpadOnly;

  const ControllerPanel({
    Key? key,
    required this.onLeft,
    required this.onRight,
    required this.onDown,
    required this.onRotate,
    required this.onDrop,
    this.dpadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // D-Pad
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 40),
            _buildButton('↑', onRotate),
            const SizedBox(width: 40),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton('←', onLeft),
            const SizedBox(width: 8),
            _buildButton('↓', onDown),
            const SizedBox(width: 8),
            _buildButton('→', onRight),
          ],
        ),
        if (!dpadOnly) ...[
          const SizedBox(height: 20),
          // A / B Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton('A', onRotate, color: Colors.redAccent),
              const SizedBox(width: 16),
              _buildButton('B', onDrop, color: Colors.greenAccent),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: color ?? Colors.grey.shade800,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
