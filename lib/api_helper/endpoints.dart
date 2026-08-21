class Endpoints {
  Endpoints._();

  // Auth
  static const String login = "auth/otp/send";
  static const String verifyLoginOtp = "auth/otp/verify-login";
  static const String forgotPassword = "auth/forgot-password";
  static const String verifyForgotPasswordOtp =
      "auth/verify-forgot-password-otp";
  static const String resetPassword = "auth/reset-password";
  static const String register = "auth/register";
  static const String accountDelete = "auth/account";

  // OAuth
  static const String googleLogin = "auth/oauth/google/login";
  static const String appleLogin = "auth/oauth/apple/login";

  // Home (base: http://13.203.145.200:8004/api/)
  static const String banners = "videos/banner";
  static const String videos = "videos";
  static const String watchLater = "videos/watch-later";
  static const String watchHistory = "videos/watch-history";

  // Content (base: http://13.203.145.200:8002/api/)
  static const String announcements = "content/announcements";
} 
