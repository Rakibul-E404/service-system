class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  // Auth URLs
  static const String signUpUrl = '$baseUrl/auth/signup';
  static const String signInUrl = '$baseUrl/auth/signin';
  static const String logoutUrl = '$baseUrl/auth/logout';
  static const String forgotPasswordUrl = '$baseUrl/auth/forgot-password';
  static const String resetPasswordUrl = '$baseUrl/auth/reset-password';
  static const String verifyOtpUrl = '$baseUrl/auth/verify_otp';

  // User URLs
  static const String selfProfileUrl = '$baseUrl/user/self';
  static const String getUserProfileUrl = '$baseUrl/user/profile';
  static const String updateUserProfileUrl = '$baseUrl/user/profile/update';
}