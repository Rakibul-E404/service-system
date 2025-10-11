class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  // Auth URLs
  static const String signUpUrl = '$baseUrl/auth/signup';
  static const String signInUrl = '$baseUrl/auth/signin';
  static const String logoutUrl = '$baseUrl/auth/logout';
  static const String forgotPassword = '$baseUrl/auth/forgot_password';
  static const String resetPasswordUrl = '$baseUrl/auth/reset_password';
  static const String updatePasswordUrl = '$baseUrl/auth/update_password';
  static const String verifyOtpUrl = '$baseUrl/auth/verify_otp';

  // User URLs
  static const String selfProfileUrl = '$baseUrl/user/self';
  static const String updateSelfProfileUrl = '$baseUrl/user/update-profile';
  static const String getUserProfileUrl = '$baseUrl/user/profile';
}