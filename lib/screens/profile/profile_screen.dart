import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/profile_avatar.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../auth/change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showMessage(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePhoto(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final profile = provider.profile;
    if (profile == null || provider.isSaving) return;

    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (image == null || !context.mounted) return;

    // Students must request approval.
    final isStudent = profile.isStudent;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isStudent ? 'Request photo change' : 'Change profile photo',
        ),
        content: Text(
          isStudent
              ? 'Send this photo to the institute admin for approval? '
                    'Your current photo will remain until approval.'
              : 'Do you want to save this new profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isStudent ? 'Send Request' : 'Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = isStudent
        ? await provider.requestPhotoChange(image.path)
        : await provider.savePhoto(image.path);

    if (!context.mounted) return;

    await _showMessage(
      context,
      success
          ? (isStudent ? 'Request sent' : 'Photo updated')
          : 'Unable to continue',
      success
          ? (isStudent
                ? 'Your photo change request is waiting for admin approval.'
                : 'Your profile photo has been updated in the demo.')
          : (provider.errorMessage ?? 'Please try again.'),
    );
  }

  Future<void> _removePhoto(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    if (provider.profile?.isStudent != false) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove profile photo'),
        content: const Text(
          'Are you sure you want to remove your profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.removePhoto();

    if (!context.mounted) return;

    await _showMessage(
      context,
      success ? 'Photo removed' : 'Unable to remove photo',
      success
          ? 'Your profile photo has been removed.'
          : (provider.errorMessage ?? 'Please try again.'),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authHeading,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.profileMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 19, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: AppColors.authHeading),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.profileMuted,
              ),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.authHeading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? Center(child: Text(provider.errorMessage ?? 'Profile unavailable'))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              children: [
                const SizedBox(height: 10),

                Center(
                  child: ProfileAvatar(
                    photoUrl: profile.photoUrl,
                    radius: 34,
                    showCameraIcon: true,
                    onTap: () => _changePhoto(context),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Tap the photo to change it',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.profileMuted,
                    ),
                  ),
                ),

                if (!profile.isStudent &&
                    profile.photoUrl != null &&
                    profile.photoUrl!.isNotEmpty)
                  Center(
                    child: TextButton(
                      onPressed: () => _removePhoto(context),
                      child: const Text('Remove photo'),
                    ),
                  ),

                const SizedBox(height: 9),

                Center(
                  child: Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.authHeading,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                Center(
                  child: Text(
                    profile.role
                        .split('_')
                        .map(
                          (word) =>
                              '${word[0].toUpperCase()}${word.substring(1)}',
                        )
                        .join(' '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.profileMuted,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _infoRow(Icons.badge_outlined, 'Username', profile.username),
                _infoRow(Icons.mail_outline, 'Email', profile.email),
                _infoRow(Icons.phone_outlined, 'Mobile', profile.mobile),
                _infoRow(
                  Icons.apartment_outlined,
                  'Institute',
                  profile.instituteName,
                ),

                const Divider(color: AppColors.profileDivider),

                // TODO: Show this only if the user can
                // switch between multiple institutes.
                _actionRow(
                  icon: Icons.swap_horiz,
                  title: 'Switch institute',
                  onTap: () {
                    // TODO: Connect to the existing
                    // institute-selection flow.
                  },
                ),

                if (profile.googleEmail != null)
                  _actionRow(
                    icon: Icons.g_mobiledata,
                    title: 'Google sign-in',
                    subtitle: profile.googleEmail,
                    trailing: const Text(
                      'Unlink',
                      style: TextStyle(color: AppColors.primary, fontSize: 11),
                    ),
                    onTap: () {
                      // TODO: Add secure Google unlink API.
                    },
                  ),

                _actionRow(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  trailing: const Icon(
                    Icons.brightness_6_outlined,
                    color: AppColors.authIcon,
                  ),
                  onTap: () {
                    // TODO: Connect your app theme provider.
                  },
                ),

                _actionRow(
                  icon: Icons.password_outlined,
                  title: 'Change password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),

                _infoRow(
                  Icons.dns_outlined,
                  'Server',
                  'https://localhost:7237/',
                ),
              ],
            ),

      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 2,

        // Show the user's profile photo in the Profile tab.
        profilePhotoUrl: profile?.photoUrl,

        onTabSelected: (index) {
          if (index == 2) return;

          // Temporary navigation:
          // returns to the screen that opened Profile.
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
