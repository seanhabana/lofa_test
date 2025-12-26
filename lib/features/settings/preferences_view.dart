import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// View Model
final darkModeProvider = StateProvider<bool>((ref) => false);
final emailNotificationsProvider = StateProvider<bool>((ref) => true);
final pushNotificationsProvider = StateProvider<bool>((ref) => true);
final courseRemindersProvider = StateProvider<bool>((ref) => true);
final languageProvider = StateProvider<String>((ref) => 'English');

class PreferencesView extends ConsumerWidget {
  const PreferencesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final emailNotifications = ref.watch(emailNotificationsProvider);
    final pushNotifications = ref.watch(pushNotificationsProvider);
    final courseReminders = ref.watch(courseRemindersProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Preferences',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize your learning experience',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            
            // Appearance Section
            _buildSection(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: [
                _buildSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Enable dark theme',
                  icon: Icons.dark_mode_outlined,
                  value: darkMode,
                  onChanged: (value) {
                    ref.read(darkModeProvider.notifier).state = value;
                    // TODO: Implement dark mode
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notifications Section
            _buildSection(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive updates via email',
                  icon: Icons.email_outlined,
                  value: emailNotifications,
                  onChanged: (value) {
                    ref.read(emailNotificationsProvider.notifier).state = value;
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive mobile notifications',
                  icon: Icons.notifications_active_outlined,
                  value: pushNotifications,
                  onChanged: (value) {
                    ref.read(pushNotificationsProvider.notifier).state = value;
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Course Reminders',
                  subtitle: 'Get reminders for your courses',
                  icon: Icons.alarm,
                  value: courseReminders,
                  onChanged: (value) {
                    ref.read(courseRemindersProvider.notifier).state = value;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Language & Region Section
            _buildSection(
              title: 'Language & Region',
              icon: Icons.language,
              children: [
                _buildDropdownTile(
                  title: 'Language',
                  subtitle: 'Choose your preferred language',
                  icon: Icons.translate,
                  value: language,
                  options: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
                  onChanged: (value) {
                    ref.read(languageProvider.notifier).state = value!;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Privacy Section
            _buildSection(
              title: 'Privacy & Data',
              icon: Icons.privacy_tip_outlined,
              children: [
                _buildActionTile(
                  title: 'Data Collection',
                  subtitle: 'Manage what data we collect',
                  icon: Icons.data_usage,
                  onTap: () {
                    _showDataCollectionDialog(context);
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  icon: Icons.cleaning_services,
                  onTap: () {
                    _showClearCacheDialog(context, ref);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // About Section
            _buildSection(
              title: 'About',
              icon: Icons.info_outline,
              children: [
                _buildInfoTile(
                  title: 'App Version',
                  subtitle: '1.0.0',
                  icon: Icons.app_settings_alt,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  icon: Icons.description_outlined,
                  onTap: () {
                    // TODO: Navigate to terms
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  icon: Icons.policy_outlined,
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 24, color: const Color(0xFF581C87)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF581C87).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF581C87)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF581C87),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF581C87).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF581C87)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF581C87)),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: Colors.grey[700]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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

  void _showDataCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Data Collection'),
        content: const Text(
          'We collect anonymous usage data to improve your experience. You can opt out at any time.',
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

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data and free up storage space. Your account data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear cache
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF581C87),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}