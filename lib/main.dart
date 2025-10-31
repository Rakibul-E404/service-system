/**
    import 'package:flutter/material.dart';
    import 'package:get/get_instance/src/bindings_interface.dart';
    import 'package:get/get_navigation/src/root/get_material_app.dart';
    import 'package:manx_mate/features/mainBottomNav/screens/mainbottomnav_screen.dart';
    import 'package:manx_mate/features/message/screens/message_screen.dart';
    import 'core/config/app_theme.dart';
    import 'core/routes/app_navigation.dart';
    import 'core/routes/app_routes.dart';
    import 'features/booking/screens/booking_screen.dart';
    import 'features/favorite/screens/favorite_screen.dart';
    import 'features/profile/screens/profile_screen.dart';
    import 'features/provider/screens/availablity_page.dart';
    import 'features/provider/screens/provider_dashboard_screen.dart';
    import 'features/provider/screens/provider_profile_page.dart';
    import 'features/provider/screens/provider_services.dart';
    import 'features/role_selection/screens/role_selection_screen.dart';
    import 'features/splash_screen/screens/splash_screen_screen.dart';

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
    return GetMaterialApp(
    // initialRoute: AppRoutes.splashRoute,
    initialRoute: AppRoutes.splashRoute,
    // home: BookingScreen(),
    // home: FavoriteScreen(),
    // home: MessageScreen(),
    // home: ProfileScreen(),
    // home: MainBottomNavScreen(),
    // home: ProviderDashboardScreen(),
    // home: ProviderProfilePage(),
    // home: SplashScreenScreen(),
    // home: CalendarAvailabilityPage(),
    theme: AppTheme.defaultThemeData,
    navigatorKey: navigatorKey,
    // initialRoute: AppRoutes.homeRoute,
    getPages: AppNavigation.routes,

    // initialBinding: ControllerBinder(),
    debugShowCheckedModeBanner: false,
    );
    }
    }

    class ControllerBinder extends Bindings {
    /// GLOBAL controller ====>
    @override
    void dependencies() {}
    }*/

///
///
///
///
/// todo:::::: updating for auto signin via token
///
///
///
///

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'core/config/app_theme.dart';
// import 'core/routes/app_navigation.dart';
// import 'core/routes/app_routes.dart';
// import 'core/utils/token_service/token_storage_service.dart';
//
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Check login status before running the app
//   String initialRoute = await checkLoginStatus();
//
//   runApp(MyApp(initialRoute: initialRoute));
// }
//
// Future<String> checkLoginStatus() async {
//   final SharedPrefService sharedPrefService = SharedPrefService();
//   bool isLoggedIn = await sharedPrefService.isLoggedIn();
//
//   debugPrint('═══════════════════════════════════════');
//   debugPrint('🔐 CHECKING LOGIN STATUS');
//   debugPrint('Is Logged In: $isLoggedIn');
//   debugPrint('═══════════════════════════════════════');
//
//   // Return the appropriate initial route based on login status
//   if (isLoggedIn) {
//     debugPrint('✅ User is logged in - Navigating to MainBottomNav');
//     return AppRoutes.mainBottomNavPage; // Navigate to main app screen
//   } else {
//     debugPrint('❌ User is not logged in - Navigating to Role Selection');
//     return AppRoutes.roleSelectionRoute; // Navigate to role selection/login
//   }
// }
//
// class MyApp extends StatelessWidget {
//   final String initialRoute;
//
//   const MyApp({super.key, required this.initialRoute});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       initialRoute: initialRoute,
//       theme: AppTheme.defaultThemeData,
//       navigatorKey: navigatorKey,
//       getPages: AppNavigation.routes,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/favorite/controllers/favorite_controller.dart';
import 'core/config/app_theme.dart';
import 'core/routes/app_navigation.dart';
import 'core/routes/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.splashRoute,
      // Always start from splash screen
      theme: AppTheme.defaultThemeData,
      navigatorKey: navigatorKey,
      getPages: AppNavigation.routes,
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsClass(),
    );
  }
}

class BindingsClass extends Bindings {
  @override
  void dependencies() {
    Get.put(FavoriteController());
  }
}
