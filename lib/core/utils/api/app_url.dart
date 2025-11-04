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
//
//   static String getServicesBySubCategoryUrl(String subCategoryId) {
//     return '$baseUrl/service/all/?subcategory=$subCategoryId';
//   }
//
//
// ///------get review
//   static String getReviewsUrl(String providerServiceId) {
//     return '$baseUrl/review/all/$providerServiceId';
//   }
// }
//
//
//
//
//
//




///
///
///
/// todo:: addign teh favorite api
///
///
///
///




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
//
//   static String getServicesBySubCategoryUrl(String subCategoryId) {
//     return '$baseUrl/service/all/?subcategory=$subCategoryId';
//   }
//
//   // Reviews URL
//   static String getReviewsUrl(String providerServiceId) {
//     return '$baseUrl/review/all/$providerServiceId';
//   }
//
//   // Favorites URL
//   static String getFavoritesUrl(int page) {
//     return '$baseUrl/favorite/?page=$page&limit=10';
//   }
//
//   static String removeFavoriteUrl(String favoriteId) {
//     return '$baseUrl/favorite/$favoriteId';
//   }
// }




///
///
///
///
/// todo:: adding the delete favorite api
///
///
///
///




import 'package:http/http.dart' as dio;

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

  // User URLs
  static const String selfProfileUrl = '$baseUrl/user/self';
  static const String updateSelfProfileUrl = '$baseUrl/user/update-profile';
  static const String getUserProfileUrl = '$baseUrl/user/profile';
  static  String getUserProfileImageUrl(String imagePath) {
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

  static String getServicesBySubCategoryUrl(String subCategoryId) {
    return '$baseUrl/service/all/?subcategory=$subCategoryId';
  }

  // Reviews URL
  static String getReviewsUrl(String providerServiceId) {
    return '$baseUrl/review/all/$providerServiceId';
  }

  // Favorites URL
  static String getFavoritesUrl(int page) {
    return '$baseUrl/favorite/?page=$page&limit=10';
  }

  static String toggleFavoriteUrl(String serviceId) {
    return '$baseUrl/favorite/$serviceId';
  }


  // Remove favorite by ID
  static String removeFavoriteUrl(String favoriteId) {
    return '$baseUrl/favorite/$favoriteId';
  }
}


