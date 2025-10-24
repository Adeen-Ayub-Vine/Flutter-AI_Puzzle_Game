import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_service.dart';
import 'package:image/image.dart' as img;

final puzzleProvider = StateNotifierProvider<PuzzleNotifier, PuzzleState>(
  (ref) => PuzzleNotifier(),
);

class PuzzleState {
  final bool isLoading;
  final bool isSolved;
  final List<Uint8List>? tiles;
  final List<int> pieces;

  PuzzleState({
    this.isLoading = false,
    this.isSolved = false,
    this.tiles,
    this.pieces = const [],
  });

  PuzzleState copyWith({
    bool? isLoading,
    bool? isSolved,
    List<Uint8List>? tiles,
    List<int>? pieces,
  }) {
    return PuzzleState(
      isLoading: isLoading ?? this.isLoading,
      isSolved: isSolved ?? this.isSolved,
      tiles: tiles ?? this.tiles,
      pieces: pieces ?? this.pieces,
    );
  }
}

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  PuzzleNotifier() : super(PuzzleState());

  Future<void> newPuzzle() async {
    state = state.copyWith(isLoading: true);

    try {
      // 1️⃣ Download image as bytes
      final bytes = await ImageService().getRandomImage();

      // 2️⃣ Process the image in background isolate
      final result = await compute(_processImage, bytes);

      state = PuzzleState(
        isLoading: false,
        isSolved: false,
        tiles: result.tiles,
        pieces: result.pieces,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void placePiece(int fromIndex, int toIndex) {
    final newPieces = [...state.pieces];
    final temp = newPieces[fromIndex];
    newPieces[fromIndex] = newPieces[toIndex];
    newPieces[toIndex] = temp;

    state = state.copyWith(
      pieces: newPieces,
      isSolved: _checkSolved(newPieces),
    );
  }

  bool _checkSolved(List<int> pieces) =>
      pieces.every((pieceIndex) => pieceIndex == pieces.indexOf(pieceIndex));
}

class PuzzleResult {
  final List<Uint8List> tiles;
  final List<int> pieces;

  PuzzleResult(this.tiles, this.pieces);
}

PuzzleResult _processImage(Uint8List bytes) {
  final image = img.decodeImage(bytes)!;
  const gridSize = 6;
  final tileWidth = image.width ~/ gridSize;
  final tileHeight = image.height ~/ gridSize;

  final tiles = <Uint8List>[];

  for (int i = 0; i < gridSize * gridSize; i++) {
    final row = i ~/ gridSize;
    final col = i % gridSize;
    final piece = img.copyCrop(
      image,
      x: col * tileWidth,
      y: row * tileHeight,
      width: tileWidth,
      height: tileHeight,
    );
    tiles.add(Uint8List.fromList(img.encodePng(piece)));
  }

  final pieces = List<int>.generate(36, (i) => i)..shuffle();

  return PuzzleResult(tiles, pieces);
}
