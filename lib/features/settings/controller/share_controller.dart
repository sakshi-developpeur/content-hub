import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:estoriz/core/utils/user_data.dart';

class ShareController extends GetxController {
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.asiavisionpacificprivatelimited.estoriz';

  final UserData _userData = UserData();

  Future<void> shareApp() async {
    final referralCode = _resolveReferralCode();
    final message =
        'Try Estoriz and start learning with premium content!\n\n'
        'Download now: $_playStoreUrl\n\n'
        'Use my referral code: $referralCode';

    try {
      await Share.share(message, subject: 'Join me on Estoriz');
    } catch (e) {
      Get.snackbar('Share failed', e.toString());
    }
  }

  String _resolveReferralCode() {
    final user = _userData.currentUser;
    final id = user?.id?.trim();
    if (id != null && id.isNotEmpty) {
      return 'EST-${id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}';
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      final prefix = email.split('@').first;
      final normalized = prefix
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toUpperCase();
      if (normalized.isNotEmpty) {
        return 'EST-${normalized.length > 8 ? normalized.substring(0, 8) : normalized}';
      }
    }

    final fallback = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    return 'EST-${fallback.length > 8 ? fallback.substring(fallback.length - 8) : fallback}';
  }
  Future<void> shareVideo(String title, {String? videoId}) async {
    final referralCode = _resolveReferralCode();
    String message = 'Check out "$title" on Estoriz!\n\n';

    if (videoId != null && videoId.isNotEmpty) {
      // If we have a web-based viewing URL, we could include it here.
      // For now, we'll direct them to the app.
      message += 'Watch it here: $_playStoreUrl\n\n';
    } else {
      message += 'Download Estoriz to watch: $_playStoreUrl\n\n';
    }

    message += 'Use my referral code: $referralCode';

    try {
      await Share.share(message, subject: 'Share Video: $title');
    } catch (e) {
      Get.snackbar('Share failed', e.toString());
    }
  }
}

