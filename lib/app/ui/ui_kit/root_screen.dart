// import 'package:flutter/material.dart';
// import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

// class RootScreen extends StatelessWidget {
//   const RootScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: navigationShell,
//       bottomNavigationBar: SalomonBottomBar(
//         items: _buildBottomNavBarItems,
//         currentIndex: navigationShell.currentIndex,
//         onTap: (index) => navigationShell.goBranch(
//           index,
//           initialLocation: index == navigationShell.currentIndex,
//         ),
//       ),
//     );
//   }

//   // Возвращает лист элементов для нижнего навигационного бара.
//   List<SalomonBottomBarItem> get _buildBottomNavBarItems => [
//         SalomonBottomBarItem(
//           icon: const Icon(Icons.list_alt),
//           title: const Text('Категории'),
//         ),
//         SalomonBottomBarItem(
//           icon: const Icon(Icons.alarm),
//           title: const Text('Будильник'),
//         ),
//         SalomonBottomBarItem(
//           icon: const Icon(Icons.home),
//           title: const Text('Главный экран '),
//         ),
//         SalomonBottomBarItem(
//           icon: const Icon(Icons.settings),
//           title: const Text('Настройки'),
//         ),
//       ];
// }
