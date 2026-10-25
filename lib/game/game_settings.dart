enum GameMode {
  singlePlayer,
  twoPlayer,
}

enum PlayerSymbol {
  x,
  o,
}

enum TurnOrder {
  alwaysFirst,
  alwaysSecond,
  alternate,
}

extension PlayerSymbolValue on PlayerSymbol {
  String get value => switch (this) {
        PlayerSymbol.x => 'X',
        PlayerSymbol.o => 'O',
      };

  PlayerSymbol get other => switch (this) {
        PlayerSymbol.x => PlayerSymbol.o,
        PlayerSymbol.o => PlayerSymbol.x,
      };
}