import 'package:get/get.dart';
import 'package:manx_mate/features/booking/bindings/booking_binding.dart';
import 'package:manx_mate/features/booking/screens/booking_screen.dart';
import 'package:manx_mate/features/booking/screens/review_for_service.dart';
import 'package:manx_mate/features/favorite/bindings/favorite_binding.dart';
import 'package:manx_mate/features/favorite/screens/favorite_screen.dart';
import 'package:manx_mate/features/home/bindings/home_binding.dart';
import 'package:manx_mate/features/home/screens/home_screen.dart';
import 'package:manx_mate/features/home/screens/home_service_details_page.dart';
import 'package:manx_mate/features/home/screens/notification_page.dart';
import 'package:manx_mate/features/home/screens/provider_details_screen.dart';
import 'package:manx_mate/features/home/screens/sub_categories_page.dart';
import 'package:manx_mate/features/mainBottomNav/bindings/mainbottomnav_binding.dart';
import 'package:manx_mate/features/mainBottomNav/screens/mainbottomnav_screen.dart';
import 'package:manx_mate/features/mainBottomNav/screens/provider_main_bottom_nav.dart';
import 'package:manx_mate/features/message/bindings/message_binding.dart';
import 'package:manx_mate/features/message/screens/individual_chat_screen.dart';
import 'package:manx_mate/features/message/screens/message_screen.dart';
import 'package:manx_mate/features/profile/bindings/profile_binding.dart';
import 'package:manx_mate/features/profile/screens/change_password.dart';
import 'package:manx_mate/features/profile/screens/my_review_ratings_page.dart';
import 'package:manx_mate/features/profile/screens/privacy_policy_template_page.dart';
import 'package:manx_mate/features/profile/screens/report_page.dart';
import 'package:manx_mate/features/profile/screens/setting_page.dart';
import 'package:manx_mate/features/profile/screens/personal_profile_information.dart';
import 'package:manx_mate/features/profile/screens/profile_screen.dart';
import 'package:manx_mate/features/provider/bindings/provider_binding.dart';
import 'package:manx_mate/features/provider/screens/availablity_page.dart';
import 'package:manx_mate/features/provider/screens/provider_dashboard_screen.dart';
import 'package:manx_mate/features/role_selection/bindings/role_selection_binding.dart';
import 'package:manx_mate/features/role_selection/screens/role_selection_screen.dart';
import 'package:manx_mate/features/splash_screen/bindings/splash_screen_binding.dart';
import 'package:manx_mate/features/splash_screen/screens/splash_screen_screen.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/screens/forgot_password_page.dart';
import '../../features/auth/screens/reset_password.dart';
import '../../features/auth/screens/sign_in_page.dart';
import '../../features/auth/screens/sign_up_page.dart';
import '../../features/auth/screens/verify_mail.dart';
import '../../features/home/screens/search_screen.dart';
import '../../features/provider/screens/provider_profile_page.dart';
import 'app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.initialRoute,
      page: () => const SignInScreen(),
      transition: Transition.noTransition,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.loginRoute,
      page: () => const SignInScreen(),
      transition: Transition.upToDown,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.signUpRoute,
      page: () => const SignUpScreen(),
      transition: Transition.leftToRight,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.forgotPasswordRoute,
      page: () =>   ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.verifyEmailRoute,
      page: () => const VerifyEmailScreen(),
      transition: Transition.zoom,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.resetPasswordRoute,
      page: () => const ResetPasswordPage(),
      transition: Transition.rightToLeft,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.homeRoute,
      page: () => const HomeScreen(),
      transition: Transition.downToUp,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.homeSearchRoute,
      page: () => HomeSearchScreen(),
      transition: Transition.noTransition,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.homeServiceDetailsRoute,
      page: () => HomeServiceDetailsPage(),
      transition: Transition.noTransition,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.homeSubCategoriesPage,
      page: () => SubCategoriesPage(),
      transition: Transition.rightToLeft,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.notificationPage,
      page: () => const NotificationPage(),
      transition: Transition.fadeIn,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.providerDetailsPage,
      page: () => const ProviderDetailsScreen(),
      transition: Transition.fadeIn,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.bookingPage,
      page: () => const BookingScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: BookingBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.reviewPage,
      page: () => const ReviewForServiceScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: BookingBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.favoritePage,
      page: () => const FavoriteScreen(),
      transition: Transition.leftToRightWithFade,
      binding: FavoriteBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.messagePage,
      page: () => const MessageScreen(),
      transition: Transition.fadeIn,
      binding: MessageBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.individualMessagePage,
      page: () => IndividualChatScreen(),
      transition: Transition.zoom,
      binding: MessageBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.profilePage,
      page: () => const ProfileScreen(),
      transition: Transition.noTransition,
      binding: ProfileBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.personalProfileInformationPage,
      page: () => const PersonalInformationScreen(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.settingsPage,
      page: () => const SettingPage(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.myReviewPage,
      page: () => const MyReviewRatingsPage(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.changePasswordPage,
      page: () => ChangePassword(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.privacyPolicyTemplatePage,
      page: () => const PrivacyPolicyTemplatePage(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.reportPage,
      page: () => const ReportPage(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.mainBottomNavPage,
      page: () => const MainBottomNavScreen(),
      transition: Transition.zoom,
      binding: MainBottomNavBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.providerDashboardRoute,
      page: () => const ProviderDashboardScreen(),
      transition: Transition.rightToLeft,
      binding: ProviderBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.providerProfileRoute,
      page: () => const ProviderProfilePage(),
      transition: Transition.rightToLeft,
      binding: ProviderBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.providerAvailabilityRoute,
      page: () => const ProviderAvailabilityPage(),
      transition: Transition.rightToLeft,
      binding: ProviderBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.roleSelectionRoute,
      page: () => const RoleSelectionScreen(),
      transition: Transition.upToDown,
      binding: RoleSelectionBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.providerMainBottomNavPage,
      page: () => const ProviderMainBottomNavScreen(),
      transition: Transition.zoom,
      binding: RoleSelectionBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.splashRoute,
      page: () => const SplashScreenScreen(),
      transition: Transition.circularReveal,
      binding: SplashScreenBinding(),
    ),
  ];
}
