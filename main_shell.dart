import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_logo.dart';
import 'dictionary_screen.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';
import 'translator_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user});
  final AppUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _loadedProgress = false;

  static const _destinations = [
    _NavItem('Início', Icons.home_outlined, Icons.home_rounded),
    _NavItem('Aprender', Icons.school_outlined, Icons.school_rounded),
    _NavItem('Tradutor', Icons.translate_outlined, Icons.translate_rounded),
    _NavItem('Dicionário', Icons.menu_book_outlined, Icons.menu_book_rounded),
    _NavItem('Perfil', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedProgress) {
      _loadedProgress = true;
      context.read<ProgressProvider>().refresh(widget.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final pages = <Widget>[
      HomeScreen(user: widget.user, onNavigate: _select),
      const LearnScreen(),
      const TranslatorScreen(),
      const DictionaryScreen(),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(
          children: [
            AppLogo(compact: true, width: 38),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'EA LANGUAGE HUB',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: .5),
              ),
            ),
          ],
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width > 600)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: theme.colorScheme.secondary.withValues(alpha: .16), borderRadius: BorderRadius.circular(30)),
                child: Row(children: [Icon(Icons.wifi_off_rounded, size: 15, color: theme.colorScheme.secondary), const SizedBox(width: 5), Text('Offline', style: theme.textTheme.labelSmall)]),
              ),
            ),
          IconButton(
            tooltip: dark ? 'Activar modo claro' : 'Activar modo escuro',
            onPressed: () => context.read<SettingsProvider>().setDarkMode(!dark),
            icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.7,
              destinations: _destinations.map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon, color: AppConstants.navy),
                label: Text(item.label),
              )).toList(),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                child: IndexedStack(index: _selectedIndex, children: pages),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              destinations: _destinations.map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              )).toList(),
            ),
    );
  }

  void _select(int index) => setState(() => _selectedIndex = index);
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
