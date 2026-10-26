import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/navigation_state.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import 'home/screens/home_screen.dart';
import 'categories/screens/categories_overview_screen.dart';
import 'tracking/screens/live_tracking_screen.dart';
import 'profile/screens/profile_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationState>(
      builder: (context, navState, _) {
        return Scaffold(
          body: IndexedStack(
            index: navState.currentIndex,
            children: const [
              HomeScreen(),
              CategoriesOverviewScreen(),
              LiveTrackingScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: TanizBottomNavBar(
            currentIndex: navState.currentIndex,
            onTap: (index) => navState.setIndex(index),
          ),
        );
      },
    );
  }
}
