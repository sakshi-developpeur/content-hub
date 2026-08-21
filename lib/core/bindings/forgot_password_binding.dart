import 'package:get/get.dart';
import 'package:estoriz/features/auth/forgot_password/controller/forgot_password_controller.dart';
import 'package:estoriz/features/auth/service/auth_service.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut(() => ForgotPasswordController());
  }
}
