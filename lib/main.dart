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





import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  }
}


