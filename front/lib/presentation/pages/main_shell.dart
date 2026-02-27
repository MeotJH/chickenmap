import 'package:flutter/material.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';

// 하단 탭을 공통으로 제공하는 셸 위젯이다.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  // 현재 라우트 위치로 탭 인덱스를 계산한다.
  int _currentIndex(String location) {
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/activity')) return 2;
    return 0;
  }

  // 탭 선택에 따라 라우트를 이동한다.
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/ranking');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/activity');
        break;
    }
  }

  @override
  // 하단 탭과 자식 화면을 함께 구성한다.
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: AppStrings.rankingTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: AppStrings.mapTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.activityTab,
          ),
        ],
      ),
    );
  }
}
