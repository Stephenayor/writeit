import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.access_time,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2C2C)
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser!.displayName ?? 'Guest',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser.email ?? '@gmail.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Profile Settings Group
                  _MenuGroup(
                    isDark: isDark,
                    children: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit profile information',
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        isDark: isDark,
                        trailing: const Text(
                          'ON',
                          style: TextStyle(
                            color: Color(0xFFFFA726),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.language,
                        title: 'Language',
                        isDark: isDark,
                        trailing: const Text(
                          'English',
                          style: TextStyle(
                            color: Color(0xFFFFA726),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        isLast: true,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Appearance Group
                  _MenuGroup(
                    isDark: isDark,
                    children: [
                      _MenuItem(
                        icon: Icons.security_outlined,
                        title: 'Security',
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        isDark: isDark,
                        trailing: const Text(
                          'Light mode',
                          style: TextStyle(
                            color: Color(0xFFFFA726),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        isLast: true,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Support Group
                  _MenuGroup(
                    isDark: isDark,
                    children: [
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Contact us',
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.lock_outline,
                        title: 'Privacy policy',
                        isDark: isDark,
                        isLast: true,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xFFFFA726),
        unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
        currentIndex: 4,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Trans.',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Feeds'),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _MenuGroup({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool isLast;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFF0F0F0),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
