import 'package:flutter/material.dart';

import 'game/game_controller.dart';
import 'pages/about_page.dart';
import 'pages/game_screen.dart';
import 'pages/settings_page.dart';
import 'widgets/app_navigation.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final GameController _controller;

  bool _sidebarExpanded = true;
  int _selectedDestination = 0;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _controller.addListener(_onControllerChanged);
    _initializeController();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _selectDestination(int index, {required bool isWide}) {
    setState(() => _selectedDestination = index);
    if (!isWide) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: AppNavigation(
                  isWide: false,
                  expanded: true,
                  selectedIndex: _selectedDestination,
                  onDestinationSelected: (index) =>
                      _selectDestination(index, isWide: false),
                  onToggleExpanded: () {},
                ),
              ),
            ),
      appBar: AppBar(
        leading: isWide
            ? null
            : IconButton(
                tooltip: 'Open navigation menu',
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: const Text('Tic-Tac-Toe'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  AppNavigation(
                    isWide: true,
                    expanded: _sidebarExpanded,
                    selectedIndex: _selectedDestination,
                    onDestinationSelected: (index) =>
                        _selectDestination(index, isWide: true),
                    onToggleExpanded: () => setState(
                      () => _sidebarExpanded = !_sidebarExpanded,
                    ),
                  ),
                  Expanded(child: _buildSelectedPage()),
                ],
              )
            : _buildSelectedPage(),
      ),
    );
  }

  Widget _buildSelectedPage() {
    switch (_selectedDestination) {
      case 1:
        return SettingsPage(
          controller: _controller,
          themeMode: widget.themeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
        );
      case 2:
        return const AboutPage();
      default:
        return GameScreen(controller: _controller);
    }
  }

  Future<void> _initializeController() async {
    await _controller.initialize();

    if (!mounted) return;

    _controller.start();
  }
}
