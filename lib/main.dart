import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'providers/puzzle_provider.dart';
import 'widgets/puzzle_tile.dart';

void main() {
  runApp(const ProviderScope(child: PuzzleApp()));
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Puzzle',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const PuzzleScreen(),
    );
  }
}

class PuzzleScreen extends ConsumerWidget {
  const PuzzleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = ref.watch(puzzleProvider);
    final notifier = ref.read(puzzleProvider.notifier);

    final gridSize = 6;
    final screenWidth = MediaQuery.of(context).size.width;
    final tileSize = screenWidth / gridSize;

    // helper: whether tiles are available
    final hasTiles = puzzle.tiles != null && puzzle.tiles!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("🧩 AI Puzzle")),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: puzzle.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !hasTiles
                  ? const Center(child: Text("Press 'New Puzzle' to start"))
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 8.0,
                            ),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6,
                                    childAspectRatio: 1.0,
                                  ),
                              itemCount: 36,
                              itemBuilder: (context, index) {
                                return Consumer(
                                  builder: (context, ref, _) {
                                    final puzzle = ref.watch(puzzleProvider);
                                    final notifier = ref.read(
                                      puzzleProvider.notifier,
                                    );
                                    final pieceIndex = puzzle.pieces[index];
                                    final tileBytes = puzzle.tiles![pieceIndex];
                                    final isCorrect = pieceIndex == index;

                                    return DragTarget<int>(
                                      onWillAcceptWithDetails: (details) {
                                        final fromIndex = details.data;
                                        final fromCorrect =
                                            puzzle.pieces[fromIndex] ==
                                            fromIndex;

                                        // Only accept if both source and target are not locked
                                        return !isCorrect && !fromCorrect;
                                      },
                                      onAcceptWithDetails: (details) {
                                        notifier.placePiece(
                                          details.data,
                                          index,
                                        );
                                      },
                                      builder:
                                          (
                                            context,
                                            candidateData,
                                            rejectedData,
                                          ) {
                                            if (isCorrect) {
                                              return PuzzleTile(
                                                imageBytes: tileBytes,
                                                isCorrect: true,
                                                showBorder: !puzzle
                                                    .isSolved, // 👈 hide when solved
                                              );
                                            }

                                            // ✅ Movable tile
                                            return Draggable<int>(
                                              data: index,
                                              feedback: SizedBox(
                                                width: tileSize,
                                                height: tileSize,
                                                child: PuzzleTile(
                                                  imageBytes: tileBytes,
                                                  showBorder: !puzzle.isSolved,
                                                ),
                                              ),
                                              childWhenDragging: Container(
                                                color: Colors.black12,
                                              ),
                                              child: PuzzleTile(
                                                imageBytes: tileBytes,
                                              ),
                                            );
                                          },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        if (puzzle.isSolved)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "🎉 Congratulations! Puzzle Solved!",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => notifier.newPuzzle(),
                icon: const Icon(Icons.auto_awesome),
                label: const Text("New Puzzle"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
