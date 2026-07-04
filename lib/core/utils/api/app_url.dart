class AppUrl {
  AppUrl._();

  // static const String baseUrl = 'https://d7001.sobhoy.com/api/v1';
  // static const String baseUrl = 'https://dipu5003.sobhoy.com/api/v1';
  static const String baseUrl = 'https://5003.dipudebnath.tech/api/v1';
  // static const String baseUrlV1 = 'https://d7001.sobhoy.com';
  // static const String baseUrlV1 = 'https://dipu5003.sobhoy.com';
  static const String baseUrlV1 = 'https://5003.dipudebnath.tech';
  static const String version1 = 'api/v1';
  // static const String imageBaseUrl = 'https://d7001.sobhoy.com';
  // static const String imageBaseUrl = 'https://dipu5003.sobhoy.com';
  static const String imageBaseUrl = 'https://5003.dipudebnath.tech';
  // static const String socketBaseUrl = 'https://d7002.sobhoy.com';
  // static const String socketBaseUrl = 'https://dipu4003.sobhoy.com';
  static const String socketBaseUrl = 'https://4003.dipudebnath.tech';

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
  static const String postInquiryQuote = '$baseUrlV1/$version1/service-inquiry';
  static const String getMyQuote = '$baseUrlV1/$version1/service-inquiry/self';
  static const String getAllAdvertisement = '$baseUrlV1/$version1/adds/all';

  // nurujjaman
  static const String getBusinessProfile = '$baseUrl/business_profile/self';
  static const String featuredProviders = '$baseUrlV1/$version1/business_profile/featured-providers';
  static const String putAvailabilityPart = '$baseUrl/business_profile/ability';
  static const String updateBusinessProfile = '$baseUrl/business_profile';
  static const String createService = '$baseUrl/service/';
  static const String subCategorySelfService = '$baseUrl/service/self';
  static const String createAddProvider = '$baseUrl/adds/create';
  static const String getAddsDetails = '$baseUrl/adds/self';
  static const String subscriptionGlobalGet = '$baseUrl/subscription-purchase/current-plan';
  static String subscriptionDirectPurchase(String planId) =>
      '$baseUrl/subscription-purchase/$planId/direct';
  static String singleService(String serviceId) =>
      '$baseUrl/service/single/$serviceId';
  static const String userConfirmBookingService = '$baseUrl/booking';

  static String userProviderProfile(String profileId) =>
      '$baseUrl/service/provider/$profileId';





  static String serviceByCategorySubcategory(String category, String subCategory,int page) {
    return '$baseUrlV1/$version1/service/all?category=$category&subCategory=$subCategory&page=$page&limit=10';
  }
  static String serviceBySubcategoryOnly(String subCategory, int page) {
    return '$baseUrlV1/$version1/service/all?subCategory=$subCategory&page=$page&limit=10';
  }

  static String providerJObRequested(int page) {
    return '$baseUrlV1/$version1/booking/provider?status=pending&page=$page&limit=10';
  }
  static String providerJObOngoing(int page) {
    return '$baseUrlV1/$version1/booking/provider?status=accepted&page=$page&limit=10';
  }
  static String providerJobCompleted(int page) {
    return '$baseUrlV1/$version1/booking/provider?status=completed&page=$page&limit=10';
  }



  static String activeJob(int page) {
    return '$baseUrlV1/$version1/booking/user/?status=pending&page=$page&limit=10';
  }
  static String ongoingJob(int page) {
    return '$baseUrlV1/$version1/booking/user/?status=accepted&page=$page&limit=10';
  }
  static String pastJob(int page) {
    return '$baseUrlV1/$version1/booking/user/?status=completed&page=$page&limit=10';
  }
  static String userCanceledBooking(String bookingId) {
    return '$baseUrlV1/$version1/booking/respond/$bookingId';
  }
  static String userQuoteDelete(String requestedQuoteId) {
    return '$baseUrlV1/$version1/service-inquiry/$requestedQuoteId/delete';
  }
  static const String bookingUrl = '$baseUrl/booking';
  static const String bookingUrlV1 = '$baseUrlV1/$version1/booking/user';
  static const String notificationUrl = '$baseUrl/notification';

  static String getUserProfileImageUrl(String imagePath) {
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }
    return '$imageBaseUrl/$imagePath';
  }

  // Settings URLs
  static const String privacyPolicy = '$baseUrl/settings/privacyPolicy';
  static const String termsAndConditions = '$baseUrl/settings/termsAndConditions';
  static const String aboutUs = '$baseUrl/settings/about';
  static const String hostPolicy = '$baseUrl/settings/hostPolicy';
  static const String contactUs = '$baseUrl/settings/contactUs';

  // Home screens URLs
  static const String allCategory = '$baseUrlV1/$version1/category';
  static String allSubCategory(String categoryId) {
    return '$baseUrlV1/$version1/category/$categoryId/subcategories';
}


  static String allService({String? categoryId, String? subCategoryId, int page = 1, int limit = 10}) {
    String url = '$baseUrlV1/$version1/service/all?page=$page&limit=$limit';

    if (categoryId != null && categoryId.isNotEmpty) {
      url += '&category=$categoryId';
    }

    if (subCategoryId != null && subCategoryId.isNotEmpty) {
      url += '&subCategory=$subCategoryId';
    }

    return url;
  }
  static String getSubCategoriesUrl(String categoryId) {
    return '$baseUrl/category/$categoryId/subcategories';
  }

  static String getServicesBySubCategoryUrl(String subCategoryId) {
    return '$baseUrl/service/all/?subcategory=$subCategoryId';
  }

  // Business Profile URL
  static String getBusinessProfileUrl(String authorId) {
    return '$baseUrl/business_profile/$authorId';
  }

  // Reviews URL
  static String addReviewsUrl(String serviceId) {
    return '$baseUrlV1/$version1/review/$serviceId';
  }

  static String getReviewsUrl(String providerServiceId) {
    return '$baseUrl/review/all/$providerServiceId';
  }

  // Favorites URL
  static String allFavoritesId() {
    return '$baseUrlV1/$version1/favorite/ids';
  }

  static String getAllFavoritesUrl(int page) {
    return '$baseUrlV1/$version1/favorite/?page=$page&limit=10';
  }

  static String addFavoriteUrl(String serviceId) {
    return '$baseUrlV1/$version1/favorite/$serviceId';
  }

  static String favToDetail(String serviceId) {
    return '$baseUrlV1/$version1/service/single/$serviceId';
  }

  static String deleteFavoriteUrl(String serviceId) {
    return '$baseUrlV1/$version1/favorite/$serviceId';
  }

  // static String removeFavoriteUrl(String favoriteId) {
  //   return '$baseUrl/favorite/$favoriteId';
  // }

  // Helper for business profile images
  static String getBusinessProfileImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    String cleanPath = imagePath;
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return '$imageBaseUrl/$cleanPath';
  }
}