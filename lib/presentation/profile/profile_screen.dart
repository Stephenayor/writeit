import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/core/utils/routes.dart';
import 'package:writeit/providers/providers.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final user = ref.watch(userSessionProvider);

    bool notificationsEnabled = true;
    final notificationsProvider = StateProvider<bool>((ref) => true);
    final profileState = ref.watch(profileViewModelProvider);

    if (profileState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (profileState.hasError) {
      return Center(child: Text("Failed to load profile"));
    }

    final user = profileState.value!;

    String userName = user.displayName ?? "update profile...";
    String userEmail = user.email ?? 'noemail@gmail.com';
    String userBio = user.bio ?? "...";

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
                      user.photoURL != null && user.photoURL!.isNotEmpty
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : AssetImage("assets/default_avatar.png")
                                        as ImageProvider,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF81D4FA),
                                    Color(0xFF4FC3F7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final result = await context.pushNamed(
                              'edit-profile',
                              extra: {
                                'name': userName,
                                'email': userEmail,
                                'bio': userBio,
                                'photoUrl': user.photoURL,
                              },
                            );
                          },
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      userBio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
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
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                name: userName,
                                email: userEmail,
                                bio: userBio,
                                photoUrl: user.photoURL,
                              ),
                            ),
                          );
                          if (result != null) {
                            // Update profile using the provider
                            await ref
                                .read(userSessionProvider.notifier)
                                .updateProfile(
                                  displayName: result['name'],
                                  bio: result['bio'],
                                );
                          }
                        },
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        isDark: isDark,
                        trailing: Switch(
                          value: notificationsEnabled,
                          onChanged: (value) {
                            ref.read(notificationsProvider.notifier).state =
                                value;
                          },
                          activeColor: Colors.blue,
                        ),
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        isDark: isDark,
                        isLast: true,
                        onTap: () async {
                          await ref.read(userSessionProvider.notifier).logout();
                          context.go(Routes.signIn);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Appearance Group
                  _MenuGroup(
                    isDark: isDark,
                    children: [
                      _MenuItem(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        isDark: isDark,
                        trailing: Text(
                          isDark ? 'Dark mode' : 'Light mode',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        isLast: true,
                        onTap: () {
                          _showThemeDialog(context);
                        },
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
                        onTap: () {
                          _showHelpSupportModal(context, isDark);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Contact us',
                        isDark: isDark,
                        onTap: () {
                          _showContactUsModal(context, isDark);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.lock_outline,
                        title: 'Privacy policy',
                        isDark: isDark,
                        isLast: true,
                        onTap: () {
                          _showPrivacyPolicyModal(context, isDark);
                        },
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
    );
  }

  void _showThemeDialog(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Choose Theme',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.black12),
                title: Text(
                  'Light Mode',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.purple,
                  ),
                ),
                onTap: () {
                  // themeProvider.setThemeMode(ThemeMode.light);
                  context.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.black12),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.purple,
                  ),
                ),
                onTap: () {
                  // themeProvider.setThemeMode(ThemeMode.dark);
                  context.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpSupportModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _HelpItem(
                icon: Icons.question_answer,
                title: 'FAQs',
                description: 'Find answers to common questions',
                isDark: isDark,
              ),
              _HelpItem(
                icon: Icons.chat,
                title: 'Live Chat',
                description: 'Chat with our support team',
                isDark: isDark,
              ),
              _HelpItem(
                icon: Icons.email,
                title: 'Email Support',
                description: 'Send us an email',
                isDark: isDark,
              ),
              _HelpItem(
                icon: Icons.video_library,
                title: 'Tutorial Videos',
                description: 'Watch helpful video guides',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showContactUsModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _ContactItem(
                icon: Icons.email,
                title: 'Email',
                value: 'support@writeit.com',
                isDark: isDark,
              ),
              _ContactItem(
                icon: Icons.phone,
                title: 'Phone',
                value: '+1 (555) 123-4567',
                isDark: isDark,
              ),
              _ContactItem(
                icon: Icons.location_on,
                title: 'Address',
                value: 'top Street, Lagos, Nigeria',
                isDark: isDark,
              ),
              _ContactItem(
                icon: Icons.access_time,
                title: 'Business Hours',
                value: 'Mon-Fri: 9AM - 6PM',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: December 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        '''1. Information We Collect
We collect information you provide directly to us, including name, email, and profile information.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services.

3. Information Sharing
We do not share your personal information with third parties except as described in this policy.

4. Data Security
We implement appropriate security measures to protect your personal information.

5. Your Rights
You have the right to access, update, or delete your personal information at any time.

6. Cookies
We use cookies to enhance your experience on our platform.

7. Changes to This Policy
We may update this privacy policy from time to time. We will notify you of any changes.

8. Contact Us
If you have questions about this privacy policy, please contact us at privacy@writeit.com.''',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFA726), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
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
            if (trailing == null)
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
