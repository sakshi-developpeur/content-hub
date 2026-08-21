import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/utils/app_colors.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              'Our platform is your trusted hub for high-quality education, featuring courses, skill-based learning, and the latest industry insights. We are committed to providing a seamless and enriching learning experience through carefully curated content. Our mission is to empower learners worldwide by offering a diverse range of educational resources, fostering skill development, and keeping you informed about the latest trends in the industry. Join us on this journey of continuous learning and growth.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
