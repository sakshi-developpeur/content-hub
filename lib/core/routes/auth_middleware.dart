import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/user_data.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.priority = 1});

  @override
  final int priority;

  final UserData _userData = UserData();

  @override
  RouteSettings? redirect(String? route) {
    if (_userData.isLoggedIn) {
      return null;
    }

    return const RouteSettings(name: AppRoutes.login);
  }
}

