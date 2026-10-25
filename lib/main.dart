import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_page.dart';

const _themePreferenceKey = 'themeMode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved theme before starting the app.
  final preferences = await SharedPreferences.getInstance();
  final savedTheme = preferences.getString(_themePreferenceKey);

  final initialThemeMode = ThemeMode.values.firstWhere(
    (mode) => mode.name == savedTheme,
    orElse: () => ThemeMode.system,
  );

  // Initialize the window manager on desktop only.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      title: 'Tic-Tac-Toe',
      size: Size(700, 900),
      minimumSize: Size(300, 600),
      center: true,
    );

    windowManager.waitUntilReadyToShow(
      windowOptions,
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  runApp(TicTacToeApp(initialThemeMode: initialThemeMode));
}

class TicTacToeApp extends StatefulWidget {
  const TicTacToeApp({
    super.key,
    required this.initialThemeMode,
  });

  final ThemeMode initialThemeMode;

  @override
  State<TicTacToeApp> createState() => _TicTacToeAppState();
}

class _TicTacToeAppState extends State<TicTacToeApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themePreferenceKey, mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic-Tac-Toe',

      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      themeMode: _themeMode,

      home: GamePage(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}
