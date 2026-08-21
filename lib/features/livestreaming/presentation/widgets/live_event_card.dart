import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import '../../data/models/live_event_model.dart';

class LiveEventCard extends StatelessWidget {
  final LiveEvent event;
  final VoidCallback onEnroll;
  final VoidCallback onJoin;

  const LiveEventCard({
    super.key,
    required this.event,
    required this.onEnroll,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: Image.network(
                  event.thumbnailUrl ?? '',
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180.h,
                    color: AppColors.surface,
                    child: Icon(Icons.live_tv_rounded,
                        size: 48.sp, color: AppColors.textHint),
                  ),
                ),
              ),
              if (event.isLive)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (event.isLive)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, color: Colors.white, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${event.viewerCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (event.hostName != null) ...[
                      SizedBox(width: 8.w),
                      Text(
                        'by ${event.hostName}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    event.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (event.scheduledAt != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14.sp, color: AppColors.textSecondary),
                          SizedBox(width: 4.w),
                          Text(
                            '${event.scheduledAt!.day}/${event.scheduledAt!.month} at ${event.scheduledAt!.hour}:${event.scheduledAt!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(),
                    _ActionButton(
                      label: event.isLive ? 'Join Now' : 'Enroll Now',
                      onPressed: event.isLive ? onJoin : onEnroll,
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isEnabled;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : AppColors.surface,
        foregroundColor: isPrimary ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: isPrimary ? BorderSide.none : BorderSide(color: AppColors.outline),
        ),
        padding: EdgeInsets.symmetric(vertical: 10.h),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
