import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/settings_account_model.dart';
import '../../providers/settings_account_provider.dart';

class AccountSettingsView extends ConsumerStatefulWidget {
  const AccountSettingsView({super.key});

  @override
  ConsumerState<AccountSettingsView> createState() =>
      _AccountSettingsViewState();
}

class _AccountSettingsViewState extends ConsumerState<AccountSettingsView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(accountSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(accountSettingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (settings) {
          if (!_isEditing) {
            _nameController.text = settings.name;
            _phoneController.text = settings.phone ?? '';
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Profile Avatar
                _buildAvatar(settings.name),

                const SizedBox(height: 32),

                // Personal Information Section
                _buildSection(
                  title: 'Personal Information',
                  children: [
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      enabled: _isEditing,
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email Address',
                      value: settings.email,
                      enabled: false,
                      prefixIcon: Icons.email_outlined,
                      suffixIcon: Icons.verified,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      enabled: _isEditing,
                      prefixIcon: Icons.phone_outlined,
                      placeholder: 'Add phone number',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Account Details Section
                _buildSection(
                  title: 'Account Details',
                  children: [
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Account Type',
                      value: settings.role.displayName,
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(
                      icon: Icons.security_outlined,
                      label: 'Two-Factor Auth',
                      value: settings.twoFactorEnabled ? 'Enabled' : 'Disabled',
                      trailing: _buildStatusChip(
                        settings.twoFactorEnabled,
                        settings.twoFactorEnabled ? 'Active' : 'Enable',
                      ),
                      onTap: settings.twoFactorEnabled
                          ? null
                          : () => _showEnableTwoFactorDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Security Section
                _buildSection(
                  title: 'Security',
                  children: [
                    _buildActionTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Save/Edit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleSaveOrEdit(settings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF581C87),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Edit Profile',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFF581C87),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF581C87).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
    required IconData prefixIcon,
    IconData? suffixIcon,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: value != null
              ? TextEditingController(text: value)
              : controller, // FIX HERE
          enabled: enabled,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey[600]),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 18, color: Colors.green)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF581C87),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _handleSaveOrEdit(AccountSettings settings) async {
  if (_isEditing) {
    // Save changes
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Name cannot be empty', isError: true);
      return;
    }

    try {
      await ref
          .read(accountSettingsProvider.notifier)
          .updateProfile(name: name, phone: phone.isEmpty ? null : phone);
      _showSnackBar('Profile updated successfully', isError: false); // CHANGED: Added isError: false
      setState(() => _isEditing = false);
    } catch (e) {
      _showSnackBar('Failed to update profile: $e', isError: true); // CHANGED: Added isError: true
    }
  } else {
    setState(() => _isEditing = true);
  }
}

 void _showChangePasswordDialog(BuildContext context) {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final currentPasswordVisible = ValueNotifier<bool>(false);
  final newPasswordVisible = ValueNotifier<bool>(false);
  final confirmPasswordVisible = ValueNotifier<bool>(false);
  final isLoading = ValueNotifier<bool>(false);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Added
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView( // Added wrapper
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF581C87).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF581C87).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: Color(0xFF581C87),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Secure your account with a new password',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current Password
                    ValueListenableBuilder<bool>(
                      valueListenable: currentPasswordVisible,
                      builder: (context, isVisible, _) => _buildPasswordField(
                        controller: currentPasswordController,
                        label: 'Current Password',
                        isVisible: isVisible,
                        onToggleVisibility: () => currentPasswordVisible.value = !isVisible,
                        prefixIcon: Icons.lock_outline,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // New Password
                    ValueListenableBuilder<bool>(
                      valueListenable: newPasswordVisible,
                      builder: (context, isVisible, _) => _buildPasswordField(
                        controller: newPasswordController,
                        label: 'New Password',
                        isVisible: isVisible,
                        onToggleVisibility: () => newPasswordVisible.value = !isVisible,
                        prefixIcon: Icons.lock_open_outlined,
                        helperText: 'Minimum 8 characters required',
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Confirm Password
                    ValueListenableBuilder<bool>(
                      valueListenable: confirmPasswordVisible,
                      builder: (context, isVisible, _) => _buildPasswordField(
                        controller: confirmPasswordController,
                        label: 'Confirm New Password',
                        isVisible: isVisible,
                        onToggleVisibility: () => confirmPasswordVisible.value = !isVisible,
                        prefixIcon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading.value ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLoading,
                        builder: (context, loading, _) => ElevatedButton(
                          onPressed: loading ? null : () async {
                            final currentPass = currentPasswordController.text.trim();
                            final newPass = newPasswordController.text.trim();
                            final confirmPass = confirmPasswordController.text.trim();

                            if (currentPass.isEmpty) {
                              _showSnackBar('Please enter your current password');
                              return;
                            }

                            if (newPass.isEmpty) {
                              _showSnackBar('Please enter a new password');
                              return;
                            }

                            if (newPass.length < 8) {
                              _showSnackBar('Password must be at least 8 characters');
                              return;
                            }

                            if (newPass != confirmPass) {
                              _showSnackBar('Passwords do not match');
                              return;
                            }

                            if (currentPass == newPass) {
                              _showSnackBar('New password must be different');
                              return;
                            }

                            isLoading.value = true;

                            try {
                              await ref.read(accountSettingsProvider.notifier).changePassword(
                                currentPassword: currentPass,
                                newPassword: newPass,
                                newPasswordConfirmation: confirmPass,
                              );
                              Navigator.pop(context);
                              _showSnackBar('Password changed successfully', isError: false);
                            } catch (e) {
                              isLoading.value = false;
                              String errorMessage = 'Failed to change password';
                              
                              if (e.toString().toLowerCase().contains('current password')) {
                                errorMessage = 'Current password is incorrect';
                              } else if (e.toString().contains('Exception:')) {
                                errorMessage = e.toString().replaceAll('Exception:', '').trim();
                              }
                              
                              _showSnackBar(errorMessage, isError: true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF581C87),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required IconData prefixIcon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            prefixIcon: Icon(
              prefixIcon,
              size: 20,
              color: const Color(0xFF581C87).withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF581C87), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                helperText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
        elevation: 3,
      ),
    );
  }

  void _showEnableTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enable Two-Factor Authentication',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: const Text('Choose your preferred 2FA method:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(accountSettingsProvider.notifier)
                    .enableTwoFactor('email');
                Navigator.pop(context);
                _showSnackBar('2FA enabled via email');
              } catch (e) {
                Navigator.pop(context);
                _showSnackBar('Failed to enable 2FA: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF581C87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Email'),
          ),
        ],
      ),
    );
  }
}
