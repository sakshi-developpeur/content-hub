import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/utils/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                  'Asia Vision Pacific Private Limited ("Company", "we", "our", or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our website, applications, and services, including our platform Estoriz.\n\nBy accessing or using our services, you agree to the terms of this Privacy Policy.',
                ),
                _sectionTitle('Information We Collect'),
                _content('We may collect the following types of information:'),
                _subTitle('a. Personal Information'),
                _bulletPoint('Full name'),
                _bulletPoint('Email address'),
                _bulletPoint('Phone number'),
                _bulletPoint('Payment and billing details'),
                _bulletPoint('Identity verification details (if required)'),
                _subTitle('b. Non-Personal Information'),
                _bulletPoint('Browser type and device information'),
                _bulletPoint('IP address'),
                _bulletPoint('Usage data and analytics'),
                _bulletPoint('Cookies and tracking data'),
                _subTitle('c. User-Generated Content'),
                _bulletPoint('Content uploaded, posted, or shared on our platform'),
                _bulletPoint('Comments, messages, and interactions'),
                _sectionTitle('How We Use Your Information'),
                _content('We use the collected data to:'),
                _bulletPoint('Provide and maintain our services'),
                _bulletPoint('Enable user accounts and transactions'),
                _bulletPoint('Process payments and withdrawals'),
                _bulletPoint('Improve platform performance and user experience'),
                _bulletPoint('Personalize content and recommendations'),
                _bulletPoint('Communicate updates, offers, and support'),
                _bulletPoint('Prevent fraud and ensure security'),
                _sectionTitle('Sharing of Information'),
                _subTitle('Our Commitment'),
                _content('We do not sell your personal data.\n\nHowever, we may share information with:'),
                _bulletPoint('Trusted service providers (payment gateways, hosting, analytics)'),
                _bulletPoint('Legal authorities when required by law'),
                _bulletPoint('Business partners in case of mergers or acquisitions'),
                _sectionTitle('Cookies & Tracking Technologies'),
                _content(
                  'We use cookies and similar technologies to:\n\n'
                  '• Enhance user experience\n'
                  '• Track usage patterns\n'
                  '• Improve platform functionality\n\n'
                  'You can control cookie settings through your browser preferences. Please note that disabling cookies may affect some features of our platform.',
                ),
                _sectionTitle('Data Security'),
                _content(
                  'We implement appropriate technical and organizational measures to protect your data, including:\n\n'
                  '• Secure servers and encryption\n'
                  '• Access controls\n'
                  '• Regular monitoring',
                ),
                _subTitle('Important Notice'),
                _content('No system is 100% secure. While we strive to protect your data, we cannot guarantee absolute security against all threats.'),
                _sectionTitle('User Rights'),
                _content('As a user, you have the right to:'),
                _bulletPoint('Access your personal data'),
                _bulletPoint('Request correction or deletion'),
                _bulletPoint('Withdraw consent'),
                _bulletPoint('Opt-out of marketing communications'),
                _content('When an account deletion request is completed, all data related to the user is permanently deleted and nothing is kept.\n\nTo exercise your rights, please contact us at the details provided in Section 13.'),
                _sectionTitle('Data Retention'),
                _content('We retain your information only as long as necessary for:'),
                _bulletPoint('Service delivery'),
                _bulletPoint('Legal and regulatory compliance'),
                _bulletPoint('Business purposes'),
                _sectionTitle('Third-Party Links'),
                _content('Our platform may contain links to third-party websites. We are not responsible for their privacy practices and encourage you to review the privacy policies of any third-party site you visit.'),
                _sectionTitle('Children\'s Privacy'),
                _content('Our services are not intended for individuals under the age of 18. We do not knowingly collect data from children. If we become aware that a minor has provided us with personal information, we will take steps to delete such information promptly.'),
                _sectionTitle('Changes to This Policy'),
                _content('We may update this Privacy Policy from time to time. Updates will be posted on this page with a revised effective date. We encourage you to review this page periodically to stay informed.'),
                _sectionTitle('Governing Law & Jurisdiction'),
                _content('This Privacy Policy shall be governed by and interpreted in accordance with the laws of India. Any disputes arising shall be subject to the exclusive jurisdiction of courts located in Jaipur, Rajasthan.'),
                _sectionTitle('Contact Us'),
                _content('Asia Vision Pacific Private Limited'),
                _contactRow(Icons.email_rounded, 'privacy@asiavisionpacific.com'),
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
