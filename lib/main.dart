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
      initialRoute: AppRoutes.mainBottomNavPage,
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
}
