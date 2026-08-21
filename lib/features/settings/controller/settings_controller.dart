import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:estoriz/api_helper/api_client.dart';
import 'package:estoriz/api_helper/endpoints.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/settings/controller/share_controller.dart';
import 'package:estoriz/features/settings/model/support_ticket_model.dart';
import 'package:estoriz/features/settings/service/setting_service.dart';
import 'package:estoriz/features/settings/view/submit_ticket_view.dart';

class SettingsController extends GetxController {
  static const _darkModeKey = 'isDarkMode';
  static const String deleteConfirmationPhrase = 'DELETE MY ACCOUNT';

  final _storage = GetStorage();
  final UserData _userData = UserData();
  final ShareController _shareController = Get.find<ShareController>();
  final SettingService _settingService;
  final RxBool isDarkMode = true.obs;
  final RxBool isDeletingAccount = false.obs;
  final RxBool isTicketsLoading = false.obs;
  final RxBool isSubmittingTicket = false.obs;
  final RxBool isSubmittingReply = false.obs;
  final RxString appVersion = '...'.obs;
  final RxString selectedTicketStatus = ''.obs;
  final RxString selectedPriority = 'low'.obs;
  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;

  final GlobalKey<FormState> ticketFormKey = GlobalKey<FormState>();
  final TextEditingController ticketSubjectController = TextEditingController();
  final TextEditingController ticketDescriptionController =
      TextEditingController();

  SettingsController({SettingService? settingService})
    : _settingService = settingService ?? SettingService();

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read<bool>(_darkModeKey) ?? Get.isDarkMode;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      // Fallback to default
    }
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _storage.write(_darkModeKey, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void openDownloads() {
    Get.toNamed(AppRoutes.myDownloads);
  }

  void openUpgradePlan() {
    Get.toNamed(AppRoutes.subscription);
  }

  void openProfileView() {
    Get.toNamed(AppRoutes.profileView);
  }

  Future<void> onReferTap() async {
    try {
      await _shareController.shareApp();
    } catch (e) {
      Get.snackbar('Share failed', e.toString());
    }
  }

  void onReportsTap() {
    // Intentionally left blank for now.
  }

  void openAboutUs() {
    Get.toNamed(AppRoutes.aboutUs);
  }

  void openContactUs() {
    Get.toNamed(AppRoutes.contactUs);
    fetchTickets();
  }

  void openPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void openTermsConditions() {
    Get.toNamed(AppRoutes.termsConditions);
  }

  Future<void> fetchTickets({int page = 1, int limit = 20}) async {
    isTicketsLoading.value = true;
    try {
      final data = await _settingService.fetchTickets(
        page: page,
        limit: limit,
        status: selectedTicketStatus.value,
      );
      tickets.assignAll(data);
    } catch (e) {
      Get.snackbar('Tickets', e.toString());
    } finally {
      isTicketsLoading.value = false;
    }
  }

  Future<void> applyTicketStatusFilter(String status) async {
    final normalized = status.trim().toLowerCase();
    selectedTicketStatus.value = normalized == 'all' ? '' : normalized;
    await fetchTickets();
  }

  void openCreateTicketPage() {
    Get.to(() => const SubmitTicketView());
  }

  Future<void> submitTicket() async {
    final form = ticketFormKey.currentState;
    if (form == null || !form.validate()) return;

    isSubmittingTicket.value = true;
    try {
      final ok = await _settingService.createTicket(
        subject: ticketSubjectController.text,
        description: ticketDescriptionController.text,
        priority: selectedPriority.value,
      );

      if (!ok) {
        Get.snackbar('Ticket', 'Failed to create ticket');
        return;
      }

      ticketSubjectController.clear();
      ticketDescriptionController.clear();
      selectedPriority.value = 'low';
      Get.back();
      Get.snackbar('Ticket', 'Ticket submitted successfully');
      await fetchTickets();
    } catch (e) {
      Get.snackbar('Ticket', e.toString());
    } finally {
      isSubmittingTicket.value = false;
    }
  }

  Future<void> submitTicketReply({
    required String ticketId,
    required String message,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      Get.snackbar('Reply', 'Please enter a reply message');
      return;
    }

    isSubmittingReply.value = true;
    try {
      final ok = await _settingService.replyToTicket(
        ticketId: ticketId,
        message: normalizedMessage,
      );

      if (!ok) {
        Get.snackbar('Reply', 'Failed to send reply');
        return;
      }

      Get.back();
      Get.snackbar('Reply', 'Reply sent successfully');
      await fetchTickets();
    } catch (e) {
      Get.snackbar('Reply', e.toString());
    } finally {
      isSubmittingReply.value = false;
    }
  }

  Future<void> logout() async {
    await UserData().clearAllUserData();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> onDeleteAccountTap() async {
    if (isDeletingAccount.value) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. Do you want to delete your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          Obx(
            () => TextButton(
              onPressed: isDeletingAccount.value
                  ? null
                  : () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
      barrierDismissible: !isDeletingAccount.value,
    );

    if (confirmed != true) return;

    try {
      isDeletingAccount.value = true;

      final response = await ApiClient().delete(
        Endpoints.accountDelete,
        data: {'confirmPhrase': deleteConfirmationPhrase},
      );

      final success = response is Map<String, dynamic>
          ? response['success'] == true
          : false;
      final message = response is Map<String, dynamic>
          ? (response['message']?.toString() ?? 'Account deleted successfully')
          : 'Account deleted successfully';

      if (!success) {
        Get.snackbar('Delete failed', message);
        return;
      }

      await _userData.clearAllUserData();
      Get.snackbar('Success', message);
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Delete failed', e.toString());
    } finally {
      isDeletingAccount.value = false;
    }
  }

  @override
  void onClose() {
    ticketSubjectController.dispose();
    ticketDescriptionController.dispose();
    super.onClose();
  }
}
