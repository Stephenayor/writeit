import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/core/utils/routes.dart';

// Main wrapper widget that contains the bottom navigation
class MainNavigationWrapper extends StatefulWidget {
  final Widget child;

  const MainNavigationWrapper({Key? key, required this.child})
    : super(key: key);

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  void _onNavTap(BuildContext context, int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.searchScreen); // You'll need to add this route
        break;
      case 2:
        // context.go(Routes.savedScreen); // You'll need to add this route
        break;
      case 3:
        context.go(Routes.profileScreen);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine current index based on route
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('profile')) {
      _currentIndex = 3;
    } else if (location.contains('search')) {
      _currentIndex = 1;
    } else if (location.contains('saved')) {
      _currentIndex = 2;
    } else if (location.contains('home')) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: widget.child,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                : [const Color(0xFF5B9FED), const Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.push(Routes.createArticleScreen);
            },
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomAppBar(
            color: const Color(0xFF357ABD),
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: _currentIndex == 0,
                    onTap: () => _onNavTap(context, 0),
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: Icons.search_rounded,
                    label: 'Search',
                    isSelected: _currentIndex == 1,
                    onTap: () => _onNavTap(context, 1),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 56), // Space for FAB
                  _buildNavItem(
                    icon: Icons.bookmark_rounded,
                    label: 'Saved',
                    isSelected: _currentIndex == 2,
                    onTap: () => _onNavTap(context, 2),
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isSelected: _currentIndex == 3,
                    onTap: () => _onNavTap(context, 3),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white70
                  : (isDark ? Colors.grey[200] : Colors.white),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4A90E2)
                    : (isDark ? Colors.grey[200] : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
