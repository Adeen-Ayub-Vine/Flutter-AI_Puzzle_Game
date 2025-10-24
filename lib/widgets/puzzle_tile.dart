import 'package:flutter/material.dart';
import 'dart:typed_data';

class PuzzleTile extends StatelessWidget {
  final Uint8List imageBytes;
  final bool isCorrect;
  final bool showBorder;

  const PuzzleTile({
    super.key,
    required this.imageBytes,
    this.isCorrect = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: (isCorrect && showBorder)
          ? BoxDecoration(border: Border.all(color: Colors.green, width: 2))
          : const BoxDecoration(border: Border.fromBorderSide(BorderSide.none)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.memory(imageBytes, fit: BoxFit.cover),
      ),
    );
  }
}
