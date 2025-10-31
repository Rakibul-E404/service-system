// class AppUrl {
//   AppUrl._();
//
//   static const String baseUrl = 'https://d7001.sobhoy.com/api/v1';
//   static const String imageBaseUrl = 'https://d7001.sobhoy.com';  // Base URL for images
//
//   // Auth URLs
//   static const String signUpUrl = '$baseUrl/auth/signup';
//   static const String signInUrl = '$baseUrl/auth/signin';
//   static const String logoutUrl = '$baseUrl/auth/logout';
//   static const String forgotPassword = '$baseUrl/auth/forgot_password';
//   static const String resetPasswordUrl = '$baseUrl/auth/reset_password';
//   static const String updatePasswordUrl = '$baseUrl/auth/update_password';
//   static const String verifyOtpUrl = '$baseUrl/auth/verify_otp';
//
//   // User URLs
//   static const String selfProfileUrl = '$baseUrl/user/self';
//   static const String updateSelfProfileUrl = '$baseUrl/user/update-profile';
//   static const String getUserProfileUrl = '$baseUrl/user/profile';
//   static  String getUserProfileImageUrl(String imagePath) {
//     if (imagePath.startsWith('/')) {
//       imagePath = imagePath.substring(1);  // Remove leading slash
//     }
//     return '$imageBaseUrl/$imagePath';  // Construct the full URL
//   }
//
//   // Settings URLs
//   static const String privacyPolicy = "$baseUrl/settings/privacy_policy";
//   static const String termsAndConditions = "$baseUrl/settings/terms_and_conditions";
//   static const String aboutUs = "$baseUrl/settings/about_us";
//   static const String hostPolicy = "$baseUrl/settings/host_policy";
//   static const String contactUs = "$baseUrl/settings/contact_us";
//
//   // Home screens URLs
//   static const String allCategory = "$baseUrl/category";
//
//   // Dynamically fetch all subcategories based on category ID
//   static String getSubCategoriesUrl(String categoryId) {
//     return '$baseUrl/category/$categoryId/subcategories';
//   }
// ///------get review
//   static String getReviewsUrl(String providerServiceId) {
//     return '$baseUrl/review/all/$providerServiceId';
//   }
// }






// api_urls.dart

class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://d7001.sobhoy.com/api/v1';
  static const String imageBaseUrl = 'https://d7001.sobhoy.com';  // Base URL for images

  // Auth URLs
  static const String signUpUrl = '$baseUrl/auth/signup';
  static const String signInUrl = '$baseUrl/auth/signin';
  static const String logoutUrl = '$baseUrl/auth/logout';
  static const String forgotPassword = '$baseUrl/auth/forgot_password';
  static const String resetPasswordUrl = '$baseUrl/auth/reset_password';
  static const String updatePasswordUrl = '$baseUrl/auth/update_password';
  static const String verifyOtpUrl = '$baseUrl/auth/verify_otp';
  static const String favourite = '$baseUrl/favourite/?page=1&limit=10';
  // {{base_url}}/favorite/?page=1&limit=10

  // User URLs
  static const String selfProfileUrl = '$baseUrl/user/self';
  static const String updateSelfProfileUrl = '$baseUrl/user/update-profile';
  static const String getUserProfileUrl = '$baseUrl/user/profile';
  static String getUserProfileImageUrl(String imagePath) {
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);  // Remove leading slash
    }
    return '$imageBaseUrl/$imagePath';  // Construct the full URL
  }

  // Settings URLs
  static const String privacyPolicy = "$baseUrl/settings/privacy_policy";
  static const String termsAndConditions = "$baseUrl/settings/terms_and_conditions";
  static const String aboutUs = "$baseUrl/settings/about_us";
  static const String hostPolicy = "$baseUrl/settings/host_policy";
  static const String contactUs = "$baseUrl/settings/contact_us";

  // Home screens URLs
  static const String allCategory = "$baseUrl/category";

  // Dynamically fetch all subcategories based on category ID
  static String getSubCategoriesUrl(String categoryId) {
    return '$baseUrl/category/$categoryId/subcategories';
  }

  // Get reviews URL
  static String getReviewsUrl(String providerServiceId) {
    return '$baseUrl/review/all/$providerServiceId';
  }

  // Booking URLs
  static String getBookingsUrl(String status) {
    return '$baseUrl/booking/user?status=$status';
  }
}
