import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await _authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Profile Section
                  _buildProfileSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Settings List
                  _buildSettingsSection('Account', [
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'View and edit your profile',
                      onTap: () => _showProfileDialog(),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  _buildSettingsSection('Appearance', [
                    _buildSwitchTile(
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      title: 'Dark Mode',
                      subtitle: 'Toggle dark theme',
                      value: isDark,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  _buildSettingsSection('Support', [
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help with the app',
                      onTap: () => _showHelpDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'App version and information',
                      onTap: () => _showAboutDialog(),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  _buildSettingsSection('Account Actions', [
                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      subtitle: 'Sign out of your account',
                      onTap: _signOut,
                      textColor: Colors.red,
                      iconColor: Colors.red,
                    ),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  // App Version
                  Text(
                    'BizManager v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 BizManager. All rights reserved.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    if (_userData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _userData!.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData!.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _userData!.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Member since ${_userData!.createdAt.day}/${_userData!.createdAt.month}/${_userData!.createdAt.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).colorScheme.primary)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showProfileDialog() {
    if (_userData == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, size: 24),
            SizedBox(width: 8),
            Text('Profile Information'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', _userData!.fullName),
            const SizedBox(height: 16),
            _buildInfoRow('Email', _userData!.email),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', _userData!.uid),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Member Since',
              '${_userData!.createdAt.day}/${_userData!.createdAt.month}/${_userData!.createdAt.year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, size: 24),
            SizedBox(width: 8),
            Text('Help & Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Need help with BizManager?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                Icons.dashboard,
                'Dashboard',
                'View business overview and quick stats',
              ),
              _buildHelpItem(
                Icons.inventory_2,
                'Products',
                'Manage your product inventory',
              ),
              _buildHelpItem(
                Icons.point_of_sale,
                'Sales',
                'Process transactions at the point of sale',
              ),
              _buildHelpItem(
                Icons.insert_chart,
                'Inventory Tracking',
                'Track stock movements and alerts',
              ),
              _buildHelpItem(
                Icons.analytics,
                'Reports',
                'View detailed sales reports and analytics',
              ),
              const SizedBox(height: 16),
              Text(
                'For more assistance, please contact support.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, size: 24),
            SizedBox(width: 8),
            Text('About BizManager'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'BizManager',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'BizManager is a comprehensive business management solution designed to help you manage your inventory, track sales, and grow your business.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildAboutItem('Developer', 'BizManager Team'),
              _buildAboutItem('Release Date', 'January 2026'),
              _buildAboutItem('Platform', 'Flutter'),
              _buildAboutItem('License', 'Proprietary'),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '© 2026 BizManager. All rights reserved.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}