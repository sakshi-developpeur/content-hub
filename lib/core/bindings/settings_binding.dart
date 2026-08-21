import 'package:get/get.dart';
import 'package:estoriz/features/settings/controller/share_controller.dart';
import 'package:estoriz/features/settings/controller/settings_controller.dart';
import 'package:estoriz/features/settings/service/setting_service.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShareController>(() => ShareController());
    Get.lazyPut<SettingService>(() => SettingService());
    Get.lazyPut<SettingsController>(
      () => SettingsController(settingService: Get.find<SettingService>()),
    );
  }
}
