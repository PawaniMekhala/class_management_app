import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showCameraIcon;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.radius = 38,
    this.onTap,
    this.showCameraIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      if (photoUrl!.startsWith('http')) {
        image = NetworkImage(photoUrl!);
      } else {
        image = FileImage(File(photoUrl!));
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.profileIconBackground,
            backgroundImage: image,
            child: image == null
                ? Icon(Icons.person, size: radius, color: AppColors.authHeading)
                : null,
          ),
          if (showCameraIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 11,
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.camera_alt,
                  size: 12,
                  color: AppColors.surface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
