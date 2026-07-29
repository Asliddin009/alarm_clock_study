import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/features/alarm/ui/screens/alarm_screen_new.dart';
import 'package:alearn/features/category/ui/words_screen.dart';
import 'package:alearn/features/profile/ui/profile_screen.dart';
import 'package:alearn/features/pronunciation/ui/pronunciation_screen.dart';
import 'package:flutter/material.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('root-screen'),
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: const [
          AlarmScreen(),
          WordsScreen(),
          PronunciationScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: AppContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          borderRadius: 28,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.alarm_outlined,
                  selectedIcon: Icons.alarm_rounded,
                  selected: _selectedIndex == 0,
                  onTap: () => _onDestinationSelected(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book_rounded,
                  selected: _selectedIndex == 1,
                  onTap: () => _onDestinationSelected(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.mic_none_rounded,
                  selectedIcon: Icons.mic_rounded,
                  selected: _selectedIndex == 2,
                  onTap: () => _onDestinationSelected(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  selected: _selectedIndex == 3,
                  onTap: () => _onDestinationSelected(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark
        ? ColorResource.forestAccent.withValues(alpha: 0.35)
        : ColorResource.mint.withValues(alpha: 0.35);
    final activeFg = isDark ? ColorResource.white : ColorResource.forest;
    final inactiveFg = isDark
        ? ColorResource.white.withValues(alpha: 0.5)
        : ColorResource.muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            selected ? selectedIcon : icon,
            color: selected ? activeFg : inactiveFg,
            size: 24,
          ),
        ),
      ),
    );
  }
}
