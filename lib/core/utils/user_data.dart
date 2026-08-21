import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:estoriz/models/auth_response_model.dart';
import 'package:estoriz/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_routes.dart';

class UserData {
  static const String loginStateKey = 'isLoggedIn';

  final loginData = GetStorage('loginData');
  var setOnboardingVal = GetStorage('onboardingVal');
  final baseUrl = GetStorage('baseUrl');

  // ============================================
  // AUTH DATA ACCESSORS
  // ============================================

  /// Parsed login/register response from local storage
  AuthResponseModel get getLoginData =>
      AuthResponseModel.fromJson({'data': loginData.read('loginData') ?? {}});

  /// Current user model
  UserModel? get currentUser => getLoginData.user;

  /// Access token for API calls
  String? get accessToken {
    final parsed = getLoginData.accessToken;
    if (parsed != null && parsed.isNotEmpty) return parsed;

    final raw = loginData.read('loginData');
    if (raw is Map<String, dynamic>) {
      return _readToken(raw);
    }
    if (raw is Map) {
      return _readToken(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  /// Refresh token for token renewal
  String? get refreshToken => getLoginData.refreshToken;

  /// Device ID from auth response
  String? get deviceId => getLoginData.deviceId;

  /// Whether user is logged in
  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  String? _readToken(Map<String, dynamic> map) {
    String? readFrom(Map<String, dynamic> source) {
      for (final key in ['accessToken', 'access_token', 'token', 'jwt']) {
        final value = source[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
      return null;
    }

    final direct = readFrom(map);
    if (direct != null) return direct;

    final nested = map['data'];
    if (nested is Map<String, dynamic>) {
      return readFrom(nested);
    }
    if (nested is Map) {
      return readFrom(Map<String, dynamic>.from(nested));
    }

    return null;
  }

  // ============================================
  // SAVE / UPDATE / CLEAR
  // ============================================

  /// Save auth response data locally
  void saveLoginData(AuthResponseModel authResponse) async {
    await loginData.write('loginData', authResponse.toJson());
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(loginStateKey, true);
  }

  /// Update tokens after refresh
  void updateTokens({required String accessToken, String? refreshToken}) async {
    final current = loginData.read('loginData') as Map<String, dynamic>? ?? {};
    current['accessToken'] = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      current['refreshToken'] = refreshToken;
    }
    await loginData.write('loginData', current);
  }

  /// Legacy method â€” saves raw map
  void addLoginData(dynamic val) async {
    await loginData.write('loginData', val);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(loginStateKey, true);
  }

  // ============================================
  // BASE URL / ONBOARDING
  // ============================================

  String? get getBaseUrl => baseUrl.read('baseUrl');

  void setBaseUrl(dynamic val) async {
    await baseUrl.write('baseUrl', val);
  }

  void setOnboardingScreen(dynamic val) async {
    await setOnboardingVal.write('onboardingVal', val);
  }

  int? get getOnboardingVal => setOnboardingVal.read('onboardingVal') ?? 0;

  Future<bool> checkLoginStatus() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(loginStateKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(loginStateKey, value);
  }

  // ============================================
  // LOGOUT
  // ============================================

  Future<void> clearAllUserData() async {
    // Write null explicitly so the debounced disk flush carries the cleared
    // state even if the app is killed immediately after logout.
    await loginData.write('loginData', null);
    await loginData.erase();
    await baseUrl.erase();

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(loginStateKey);
  }

  void removeUserData() async {
    await clearAllUserData();
    Get.offAllNamed(AppRoutes.login);
  }
}
