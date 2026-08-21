import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/common/responsive_text.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/core/value/dimension.dart';
import 'package:estoriz/features/profile/controller/profile_selection_controller.dart';
import 'package:estoriz/features/profile/model/profile_model.dart';

class ProfileSelectionView extends BasePage<ProfileController> {
  const ProfileSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: ResponsiveText.bodyLarge(
            controller.isEditMode.value ? 'Edit Profile' : "Who's watching?",
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          centerTitle: true,
          actions: [
            if (controller.isEditMode.value)
              TextButton(
                onPressed: controller.toggleEditMode,
                child: ResponsiveText.bodyMedium(
                  'Cancel',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              TextButton(
                onPressed: controller.toggleEditMode,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18.w,
                      color: AppColors.textPrimary,
                    ),
                    Spacing.w(6),
                    ResponsiveText.bodyMedium(
                      'Edit',
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            Spacing.w(16),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: AppPaddings.symmetric(h: 50),
            child: Column(
              children: [
                Spacing.h(40),
                Spacing.h(60),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: controller.profiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.profiles.length) {
                        return _buildAddProfileButton();
                      }
                      return _buildProfileItem(controller.profiles[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(ProfileModel profile) {
    return GestureDetector(
      onTap: () => controller.onProfileSelected(profile),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: profile.isKids ? Colors.amber : AppColors.outline,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48.w,
                  backgroundImage: AssetImage(profile.avatar),
                ),
              ),
              if (controller.isEditMode.value)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF40C4FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          Spacing.h(12),
          ResponsiveText.bodyMedium(
            profile.name,
            color: profile.isKids ? Colors.amber : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildAddProfileButton() {
    return GestureDetector(
      onTap: controller.onAddProfile,
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 1.5),
            ),
            child: Icon(Icons.add, size: 40.w, color: AppColors.textPrimary),
          ),
          Spacing.h(12),
          ResponsiveText.bodyMedium(
            'Add profile',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
