import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_utils.dart';
import 'bookmarks_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  String get _userInitial {
    final user = _authService.currentUser;
    if (user?.userMetadata?['full_name'] != null) {
      return (user!.userMetadata!['full_name'] as String)
          .substring(0, 1)
          .toUpperCase();
    }
    if (user?.email != null) {
      return user!.email!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  String get _userName {
    final user = _authService.currentUser;
    return user?.userMetadata?['full_name'] ?? 'User';
  }

  String get _userEmail {
    final user = _authService.currentUser;
    return user?.email ?? '';
  }

  String get _memberSince {
    final user = _authService.currentUser;
    if (user?.createdAt != null) {
      final dateString = user!.createdAt;
      try {
        final date = DateTime.parse(dateString);
        return 'Member since ${date.month}/${date.year}';
      } catch (e) {
        return 'New member';
      }
    }
    return 'New member';
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        AppUtils.showSuccessMessage(context, 'Logged out successfully');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        AppUtils.showErrorMessage(context, 'Logout failed');
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About NewsWatch'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NewsWatch v1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Stay updated with the latest news from around the world.'),
              SizedBox(height: 16),
              Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Browse news by categories'),
              Text('• Save articles to bookmarks'),
              Text('• Clean and modern interface'),
              Text('• Real-time updates'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Image (Circle with Initial)
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2196F3),
                    child: Text(
                      _userInitial,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // User Email
                  Text(
                    _userEmail,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // Member Since
                  Text(
                    _memberSince,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Items
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // My Bookmarks
                  _buildMenuItem(
                    icon: Icons.bookmark,
                    title: 'My Bookmarks',
                    subtitle: 'View saved articles',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookmarksScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  // Theme
                  _buildMenuItem(
                    icon: Icons.palette,
                    title: 'Theme',
                    subtitle: 'Light',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Theme settings coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  // About
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App information',
                    onTap: _showAboutDialog,
                  ),

                  const Divider(height: 1),

                  // Logout
                  _buildMenuItem(
                    icon: Icons.exit_to_app,
                    title: 'Log Out',
                    subtitle: 'Sign out of your account',
                    iconColor: Colors.red,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // App Version
            Text(
              'NewsWatch v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: iconColor ?? Colors.grey[600], size: 24),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
