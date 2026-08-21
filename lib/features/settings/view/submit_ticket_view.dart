import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/settings/controller/settings_controller.dart';

class SubmitTicketView extends GetView<SettingsController> {
  const SubmitTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('New Support Ticket'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: controller.ticketFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: controller.ticketSubjectController,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please enter subject';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: controller.ticketDescriptionController,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 14.h),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.selectedPriority.value,
                    dropdownColor: AppColors.surface,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.sp,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      controller.selectedPriority.value = value;
                    },
                  ),
                ),
                const Spacer(),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSubmittingTicket.value
                          ? null
                          : controller.submitTicket,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: controller.isSubmittingTicket.value
                          ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit Ticket'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
