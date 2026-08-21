import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/settings/controller/settings_controller.dart';
import 'package:estoriz/features/settings/view/widgets/settings_menu_tile.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _menuGroup([
                      SettingsMenuTile(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Upgrade Plan',
                        onTap: controller.openUpgradePlan,
                      ),
                      SizedBox(height: 10.h),
                      SettingsMenuTile(
                        icon: Icons.person_rounded,
                        title: 'Profile View',
                        onTap: controller.openProfileView,
                      ),
                      SizedBox(height: 10.h),
                      SettingsMenuTile(
                        icon: Icons.share_rounded,
                        title: 'Refer & Share',
                        onTap: () {
                          controller.onReferTap();
                        },
                      ),
                      SizedBox(height: 10.h),
                      // SettingsMenuTile(
                      //   icon: Icons.flag_rounded,
                      //   title: 'Reports',
                      //   onTap: controller.onReportsTap,
                      // ),
                      // SizedBox(height: 10.h),
                      SettingsMenuTile(
                        icon: Icons.info_rounded,
                        title: 'About Us',
                        onTap: controller.openAboutUs,
                      ),
                      SizedBox(height: 10.h),
                      SettingsMenuTile(
                        icon: Icons.headset_mic_rounded,
                        title: 'Contact Us',
                        onTap: controller.openContactUs,
                      ),
                      SizedBox(height: 10.h),
                      Obx(
                        () => SettingsMenuTile(
                          icon: Icons.delete_forever_rounded,
                          title: 'Account Delete',
                          onTap: controller.isDeletingAccount.value
                              ? null
                              : controller.onDeleteAccountTap,
                          showDivider: false,
                          trailing: controller.isDeletingAccount.value
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.error,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textHint,
                                  size: 22.sp,
                                ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text(
                        'Are you sure you want to logout from your account?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            controller.logout();
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Obx(
                () => Text(
                  'App Version ${controller.appVersion.value}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterAction(
                    text: 'Privacy Policy',
                    onTap: controller.openPrivacyPolicy,
                  ),
                  Text(
                    '  |  ',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12.sp,
                    ),
                  ),
                  _FooterAction(
                    text: 'Terms & Condition',
                    onTap: controller.openTermsConditions,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuGroup(List<Widget> children) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.78),
            AppColors.surfaceContainer.withValues(alpha: 0.58),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(children: children),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
