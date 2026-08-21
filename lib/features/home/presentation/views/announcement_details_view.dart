import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/announcement_model.dart';
import 'package:intl/intl.dart';

class AnnouncementDetailsView extends StatelessWidget {
  const AnnouncementDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnouncementItem announcement =
        Get.arguments ?? AnnouncementItem(id: '', title: 'Announcement');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 24.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Announcement',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Banner Image
              if ((announcement.imageUrl ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                    width: double.infinity,
                    height: 250.h,
                    color: AppColors.surfaceVariant,
                    child: Image.network(
                      announcement.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.campaign_rounded,
                          color: AppColors.textHint,
                          size: 64.sp,
                        ),
                      ),
                    ),
                  ),
                ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  announcement.title.isEmpty
                      ? 'Announcement'
                      : announcement.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Date Information
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    if (announcement.startAt != null) ...[
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Start: ${DateFormat('MMM dd, yyyy').format(announcement.startAt!)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                    if (announcement.endAt != null) ...[
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.event_available_rounded,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'End: ${DateFormat('MMM dd, yyyy').format(announcement.endAt!)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Divider
              Container(
                height: 1.h,
                color: AppColors.outline,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
              ),

              SizedBox(height: 20.h),

              // Description Section
              if ((announcement.description ?? '').isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    announcement.description!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // CTA Button only for long descriptions
              if ((announcement.ctaUrl ?? '').isNotEmpty &&
                  (announcement.description?.length ?? 0) > 250)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Implement URL launch
                        // You can use url_launcher package to open the URL
                        // launchUrl(Uri.parse(announcement.ctaUrl!));
                      },
                      child: Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
