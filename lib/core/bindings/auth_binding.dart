import 'package:estoriz/features/auth/service/auth_service.dart';
import 'package:get/get.dart';

import '../../features/auth/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<AuthService>(() => AuthService());
  }
}
