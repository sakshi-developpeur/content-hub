import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/utils/app_colors.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Introduction'),
                _content(
                  'These Terms & Conditions ("Terms") govern your use of the website, applications, and services operated by Asia Vision Pacific Private Limited ("Company", "we", "our", or "us"), including its platform Estoriz.\n\nBy accessing or using our services, you agree to be bound by these Terms. If you do not agree, please do not use our services.',
                ),
                _sectionTitle('Eligibility'),
                _bulletPoint('You must be at least 18 years old to use our services.'),
                _bulletPoint('By using our platform, you confirm that you have the legal capacity to enter into a binding agreement.'),
                _sectionTitle('User Accounts'),
                _bulletPoint('Users must provide accurate and complete information during registration.'),
                _bulletPoint('You are responsible for maintaining the confidentiality of your account credentials.'),
                _bulletPoint('We reserve the right to suspend or terminate accounts for false information or misuse.'),
                _sectionTitle('Platform Usage (Estoriz)'),
                _content('You agree to use Estoriz and related services only for lawful purposes.'),
                _subTitle('You Must NOT:'),
                _bulletPoint('Post illegal, harmful, or misleading content'),
                _bulletPoint('Violate intellectual property rights'),
                _bulletPoint('Engage in spam, fraud, or manipulation'),
                _bulletPoint('Attempt to hack, disrupt, or reverse-engineer the platform'),
                _sectionTitle('User-Generated Content'),
                _bulletPoint('You retain ownership of your content.'),
                _bulletPoint('By posting content, you grant us a non-exclusive, worldwide, royalty-free license to use, display, and distribute it for platform operations and promotion.'),
                _bulletPoint('We reserve the right to remove content that violates our policies.'),
                _sectionTitle('Monetization & Earnings'),
                _content('Estoriz may provide earning opportunities through content and engagement.'),
                _bulletPoint('Earnings are subject to platform rules and eligibility criteria.'),
                _bulletPoint('Payments may require identity verification (KYC).'),
                _bulletPoint('We reserve the right to modify earning models.'),
                _bulletPoint('We reserve the right to withhold or cancel earnings in case of fraud or violations.'),
                _sectionTitle('Payments & Withdrawals'),
                _bulletPoint('Users must provide valid payment details.'),
                _bulletPoint('Withdrawal requests are processed within a reasonable time.'),
                _bulletPoint('Applicable fees, taxes, or charges may apply.'),
                _bulletPoint('The Company is not responsible for delays caused by payment providers.'),
                _sectionTitle('Intellectual Property'),
                _content('All platform content (excluding user content), including logos, design, software, and branding, is the property of Asia Vision Pacific Private Limited and protected by applicable laws.'),
                _subTitle('Notice'),
                _content('Unauthorized use of any Company intellectual property is strictly prohibited and may result in legal action.'),
                _sectionTitle('Termination'),
                _content('We reserve the right to suspend or terminate accounts and restrict access to services if users violate these Terms or engage in harmful activities.'),
                _sectionTitle('Limitation of Liability'),
                _content('To the maximum extent permitted by law:'),
                _bulletPoint('We are not liable for indirect, incidental, or consequential damages.'),
                _bulletPoint('We do not guarantee uninterrupted or error-free services.'),
                _bulletPoint('Users use the platform at their own risk.'),
                _sectionTitle('Indemnification'),
                _content('You agree to indemnify and hold harmless Asia Vision Pacific Private Limited from any claims, damages, or losses arising from:'),
                _bulletPoint('Your use of the platform'),
                _bulletPoint('Violation of these Terms'),
                _bulletPoint('Infringement of third-party rights'),
                _sectionTitle('Third-Party Services'),
                _content('Our platform may integrate third-party services (payment gateways, analytics, etc.). We are not responsible for their actions or policies. Please review the privacy and terms of any third-party service you interact with through our platform.'),
                _sectionTitle('Changes to Terms'),
                _content('We may update these Terms at any time. Continued use of the platform after updates constitutes acceptance of the revised Terms. We encourage you to review this page periodically.'),
                _sectionTitle('Governing Law & Jurisdiction'),
                _content('These Terms shall be governed by the laws of India. All disputes shall be subject to the exclusive jurisdiction of courts in Jaipur, Rajasthan.'),
                _sectionTitle('Contact Us'),
                _content('Asia Vision Pacific Private Limited'),
                _contactRow(Icons.email_rounded, 'legal@asiavisionpacific.com'),
                _contactRow(Icons.location_on_rounded, 'Jaipur, Rajasthan, India'),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _subTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _content(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13.sp,
        height: 1.6,
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
