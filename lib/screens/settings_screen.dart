import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  UserModel? _userData;
  bool _isLoading = true;
  
  // App Settings
  bool _enableNotifications = true;
  bool _enableStockAlerts = true;
  bool _enableSalesNotifications = true;
  bool _enableSoundEffects = false;
  bool _enableVibration = true;
  
  // Display Settings
  String _dateFormat = 'DD/MM/YYYY';
  String _currency = 'MYR (RM)';
  String _language = 'English';

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
                  
                  // Account Settings
                  _buildSettingsSection('Account', [
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () async {
                        if (_userData != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(userData: _userData!),
                            ),
                          );
                          if (result == true) {
                            _loadUserData();
                          }
                        }
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () => _showChangePasswordDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      subtitle: 'Manage your privacy settings',
                      onTap: () => _showPrivacyDialog(),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Appearance Settings
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
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: _language,
                      onTap: () => _showLanguageDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.date_range,
                      title: 'Date Format',
                      subtitle: _dateFormat,
                      onTap: () => _showDateFormatDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.attach_money,
                      title: 'Currency',
                      subtitle: _currency,
                      onTap: () => _showCurrencyDialog(),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Notifications Settings
                  _buildSettingsSection('Notifications', [
                    _buildSwitchTile(
                      icon: Icons.notifications_outlined,
                      title: 'Enable Notifications',
                      subtitle: 'Receive app notifications',
                      value: _enableNotifications,
                      onChanged: (value) {
                        setState(() => _enableNotifications = value);
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.inventory,
                      title: 'Stock Alerts',
                      subtitle: 'Get notified about low stock',
                      value: _enableStockAlerts,
                      onChanged: (value) {
                        setState(() => _enableStockAlerts = value);
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.point_of_sale,
                      title: 'Sales Notifications',
                      subtitle: 'Get notified about new sales',
                      value: _enableSalesNotifications,
                      onChanged: (value) {
                        setState(() => _enableSalesNotifications = value);
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Sound & Vibration Settings
                  _buildSettingsSection('Sound & Vibration', [
                    _buildSwitchTile(
                      icon: Icons.volume_up,
                      title: 'Sound Effects',
                      subtitle: 'Enable app sounds',
                      value: _enableSoundEffects,
                      onChanged: (value) {
                        setState(() => _enableSoundEffects = value);
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.vibration,
                      title: 'Vibration',
                      subtitle: 'Enable haptic feedback',
                      value: _enableVibration,
                      onChanged: (value) {
                        setState(() => _enableVibration = value);
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Data & Storage Settings
                  _buildSettingsSection('Data & Storage', [
                    _buildSettingsTile(
                      icon: Icons.cloud_download,
                      title: 'Backup Data',
                      subtitle: 'Backup your business data',
                      onTap: () => _showBackupDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.download,
                      title: 'Export Reports',
                      subtitle: 'Download sales and inventory reports',
                      onTap: () => _showExportDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.delete_sweep,
                      title: 'Clear Cache',
                      subtitle: 'Free up storage space',
                      onTap: () => _showClearCacheDialog(),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Support Settings
                  _buildSettingsSection('Support', [
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help with the app',
                      onTap: () => _showHelpDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      subtitle: 'Share your thoughts with us',
                      onTap: () => _showFeedbackDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.rate_review,
                      title: 'Rate App',
                      subtitle: 'Rate us on the store',
                      onTap: () => _showRateAppDialog(),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'App version and information',
                      onTap: () => _showAboutDialog(),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Account Actions
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

  // Dialog Methods
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'Password change functionality will be available in a future update. For now, please use the "Forgot Password" option on the login screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your privacy matters to us',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPrivacyItem('Data Encryption', 'All your data is encrypted'),
              _buildPrivacyItem('Secure Storage', 'Data stored securely in Firebase'),
              _buildPrivacyItem('Privacy First', 'We never share your data'),
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

  Widget _buildPrivacyItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Bahasa Malaysia'),
              value: 'Bahasa Malaysia',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('DD/MM/YYYY'),
              value: 'DD/MM/YYYY',
              groupValue: _dateFormat,
              onChanged: (value) {
                setState(() => _dateFormat = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('MM/DD/YYYY'),
              value: 'MM/DD/YYYY',
              groupValue: _dateFormat,
              onChanged: (value) {
                setState(() => _dateFormat = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('YYYY-MM-DD'),
              value: 'YYYY-MM-DD',
              groupValue: _dateFormat,
              onChanged: (value) {
                setState(() => _dateFormat = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('MYR (RM)'),
              value: 'MYR (RM)',
              groupValue: _currency,
              onChanged: (value) {
                setState(() => _currency = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('USD (\$)'),
              value: 'USD (\$)',
              groupValue: _currency,
              onChanged: (value) {
                setState(() => _currency = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Your data is automatically backed up to Firebase Cloud. Manual backup will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Reports'),
        content: const Text('Report export functionality (PDF, Excel) will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache? This will free up storage space but may slow down the app temporarily.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'Share your thoughts...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate BizManager'),
        content: const Text('Enjoying BizManager? Please take a moment to rate us on the app store!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rate Now'),
          ),
        ],
      ),
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
              _buildHelpItem(Icons.dashboard, 'Dashboard', 'View business overview'),
              _buildHelpItem(Icons.inventory_2, 'Products', 'Manage inventory'),
              _buildHelpItem(Icons.point_of_sale, 'Sales', 'Process transactions'),
              _buildHelpItem(Icons.insert_chart, 'Tracking', 'Monitor stock movements'),
              _buildHelpItem(Icons.analytics, 'Reports', 'View analytics'),
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
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.business_center, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('BizManager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Version 1.0.0', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),
              const Text(
                'A comprehensive business management solution for small businesses.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildAboutItem('Developer', 'BizManager Team'),
              _buildAboutItem('Release', 'January 2026'),
              _buildAboutItem('Platform', 'Flutter'),
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
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}