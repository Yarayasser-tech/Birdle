import 'package:flutter/material.dart';

import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Birdle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Game _game = Game();

  void _submitGuess(String guess) {
    if (guess.length != 5) {
      _showMessage('Guess must contain 5 letters.');
      return;
    }

    if (_game.isGameOver) {
      return;
    }

    setState(() {
      _game.guess(guess);
    });

    if (_game.hasWon) {
      _showMessage('🎉 You won!');
    } else if (_game.guesses.length >= Game.maxGuesses) {
      _showMessage(
        'Game over! The answer was ${_game.answer}.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _newGame() {
    setState(() {
      _game.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Birdle',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'New Game',
            icon: const Icon(Icons.refresh),
            onPressed: _newGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Game board
            Expanded(
              child: GameBoard(
                guesses: _game.guesses,
              ),
            ),

            // Input
            GuessInput(
              enabled: !_game.isGameOver,
              onSubmitGuess: _submitGuess,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.guesses,
  });

  final List<List<Letter>> guesses;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Existing guesses
        for (var guess in guesses)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var letter in guess)
                Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Tile(
                    letter.char,
                    letter.type,
                  ),
                ),
            ],
          ),

        // Empty rows
        for (int i = guesses.length; i < Game.maxGuesses; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < 5; j++)
                const Padding(
                  padding: EdgeInsets.all(2.5),
                  child: Tile(
                    '',
                    HitType.empty,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class Tile extends StatelessWidget {
  const Tile(
      this.letter,
      this.hitType, {
        super.key,
      });

  final String letter;
  final HitType hitType;

  Color _getColor() {
    switch (hitType) {
      case HitType.hit:
        return Colors.green;

      case HitType.partial:
        return Colors.amber;

      case HitType.miss:
        return Colors.grey;

      case HitType.empty:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: hitType == HitType.empty
              ? Colors.grey.shade400
              : Colors.transparent,
          width: 2,
        ),
        color: _getColor(),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: hitType == HitType.empty
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

class GuessInput extends StatefulWidget {
  const GuessInput({
    super.key,
    required this.onSubmitGuess,
    this.enabled = true,
  });

  final void Function(String) onSubmitGuess;
  final bool enabled;

  @override
  State<GuessInput> createState() => _GuessInputState();
}

class _GuessInputState extends State<GuessInput> {
  final TextEditingController _textEditingController =
  TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!widget.enabled) {
      return;
    }

    final guess = _textEditingController.text.trim();

    if (guess.isEmpty) {
      return;
    }

    widget.onSubmitGuess(guess);

    _textEditingController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              enabled: widget.enabled,
              maxLength: 5,
              textCapitalization: TextCapitalization.characters,
              focusNode: _focusNode,
              autofocus: true,
              controller: _textEditingController,
              decoration: const InputDecoration(
                hintText: 'Enter a 5-letter word',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(35),
                  ),
                ),
              ),
              onSubmitted: (_) {
                _onSubmit();
              },
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_circle_up,
            size: 40,
          ),
          onPressed: widget.enabled ? _onSubmit : null,
        ),
      ],
    );
  }
}