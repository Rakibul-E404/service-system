/**

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
*/








///
///
///
///
/// todo::: update for to get the notificaiton dot
///
///
///
///
///
///





/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/auth/screens/profile_service.dart';
import 'package:manx_mate/features/favorite/controllers/favorite_controller.dart';
import 'core/config/app_theme.dart';
import 'core/routes/app_navigation.dart';
import 'core/routes/app_routes.dart';
import 'features/home/controllers/notification_controller.dart';
import 'features/profile/controllers/profile_controller.dart';

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
    Get.put(NotificationController()); // Add this line
    Get.put(ProfileController());
    Get.put(ProfileService());
  }
}


*/





///
///
///
///
///
///
///
/// todo::::::::: trying to get the profile infromations perfectly
///
///
///
///
///
///
///
///







import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_theme.dart';
import 'package:manx_mate/core/routes/app_navigation.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';
import 'package:manx_mate/features/auth/screens/profile_service.dart';
import 'package:manx_mate/features/favorite/controllers/favorite_controller.dart';
import 'package:manx_mate/features/home/controllers/notification_controller.dart';
import 'package:manx_mate/features/provider/screens/provider_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.splashRoute,
      theme: AppTheme.defaultThemeData,
      navigatorKey: navigatorKey,
      getPages: AppNavigation.routes,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize services first
    Get.put(SharedPrefService(), permanent: true);
    Get.put(ProfileService(), permanent: true);

    // Initialize controllers
    Get.put(FavoriteController(), permanent: true);
    Get.put(NotificationController());
  }
}
