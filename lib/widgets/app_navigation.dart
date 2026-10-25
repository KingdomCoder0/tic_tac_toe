import 'package:flutter/material.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({
    super.key,
    required this.isWide,
    required this.expanded,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onToggleExpanded,
  });

  final bool isWide;
  final bool expanded;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const ListTile(
            leading: Icon(Icons.grid_3x3),
            title: Text('Tic-Tac-Toe',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          _drawerItem(Icons.gamepad_outlined, 'Game', 0),
          _drawerItem(Icons.settings_outlined, 'Settings', 1),
          _drawerItem(Icons.info_outline, 'About', 2),
        ],
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: expanded ? 220 : 72,
      child: Column(
        children: [
          Align(
            alignment: expanded ? Alignment.centerRight : Alignment.center,
            child: IconButton(
              tooltip: expanded ? 'Collapse sidebar' : 'Expand sidebar',
              icon: Icon(expanded ? Icons.menu_open : Icons.menu),
              onPressed: onToggleExpanded,
            ),
          ),
          Expanded(
            child: NavigationRail(
              extended: expanded,
              minWidth: 72,
              minExtendedWidth: 220,
              selectedIndex: selectedIndex,
              labelType: expanded ? null : NavigationRailLabelType.none,
              onDestinationSelected: onDestinationSelected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.gamepad_outlined),
                  selectedIcon: Icon(Icons.gamepad),
                  label: Text('Game'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: Text('About'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selectedIndex == index,
      onTap: () => onDestinationSelected(index),
    );
  }
}
