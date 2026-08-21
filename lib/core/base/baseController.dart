import 'package:get/get.dart';
import 'package:estoriz/api_helper/retry_helper.dart';
import 'api_helper_mixin.dart';

import 'package:flutter/material.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/auth/widgets/login_required_bottom_sheet.dart';

abstract class BaseController extends GetxController
    with ApiHelperMixin, ApiRetryHelper {
  /// Checks if user is logged in, if not shows login required popup. Returns true if logged in, false otherwise.
  Future<bool> ensureLoggedIn({Map<String, dynamic>? postLoginArgs}) async {
    final _userData = UserData();
    final isLoggedIn = await _userData.checkLoginStatus();
    final hasToken = (_userData.accessToken ?? '').isNotEmpty;
    if (isLoggedIn && hasToken) return true;

    await Get.bottomSheet<void>(
      LoginRequiredBottomSheet(
        onLoginPressed: () {
          Get.back<void>();
          Get.toNamed(
            AppRoutes.login,
            arguments: postLoginArgs != null
                ? {'postLoginArgs': postLoginArgs}
                : null,
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    return false;
  }
}

abstract class BasePage<T extends BaseController> extends GetView<T> {
  const BasePage({super.key});
}
