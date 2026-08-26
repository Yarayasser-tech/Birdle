enum HitType {
  hit,
  partial,
  miss,
  empty,
}

class Letter {
  final String char;
  final HitType type;

  Letter(this.char, this.type);
}

class Game {
  final String answer = 'TABLE';

  static const int maxGuesses = 6;

  final List<List<Letter>> guesses = [];

  bool get hasWon {
    if (guesses.isEmpty) {
      return false;
    }

    final lastGuess = guesses.last;

    return lastGuess.every(
          (letter) => letter.type == HitType.hit,
    );
  }

  bool get isGameOver {
    return guesses.length >= maxGuesses || hasWon;
  }

  void guess(String input) {
    if (isGameOver) {
      return;
    }

    final word = input.trim().toUpperCase();

    if (word.length != 5) {
      return;
    }

    final result = <Letter>[];

    for (int i = 0; i < word.length; i++) {
      final letter = word[i];

      if (letter == answer[i]) {
        result.add(
          Letter(letter, HitType.hit),
        );
      } else if (answer.contains(letter)) {
        result.add(
          Letter(letter, HitType.partial),
        );
      } else {
        result.add(
          Letter(letter, HitType.miss),
        );
      }
    }

    guesses.add(result);
  }

  void reset() {
    guesses.clear();
  }
}