import 'package:flutter/material.dart';

import '../widgets/custom_bottom_nav_bar.dart';
import 'home_page.dart';
import '../../../garage/presentation/pages/garage_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';

class MainTabsPage extends StatefulWidget {
  const MainTabsPage({super.key});

  @override
  State<MainTabsPage> createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  int _currentIndex = 1;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          GaragePage(),
          HomePage(),
          StatisticsPage(),
        ],
      ),
      bottomNavigationBar: LiquidGlassNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          NavBarItem(
            iconPath: 'assets/icons/home-6-fill.svg',
            label: 'Гараж',
          ),
          NavBarItem(
            iconPath: 'assets/icons/roadster-fill.svg',
            label: 'Главная',
          ),
          NavBarItem(
            iconPath: 'assets/icons/bubble-chart-fill.svg',
            label: 'Статистика',
          ),
        ],
      ),
    );
  }
}
