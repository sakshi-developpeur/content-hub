import 'package:get/get.dart';
import 'package:estoriz/features/profile/controller/profile_selection_controller.dart';

class ProfileSelectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController(), permanent: true);
    }
  }
}
