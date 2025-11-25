
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/features/booking/screens/booking_screen.dart';
import 'package:manx_mate/features/favorite/screens/favorite_screen.dart';
import 'package:manx_mate/features/home/screens/home_screen.dart';
import 'package:manx_mate/features/message/screens/message_screen.dart';
import '../../../core/config/app_colors.dart';
import '../../profile/screens/profile_screen.dart';

class MainBottomNavScreen extends StatefulWidget {
  const MainBottomNavScreen({super.key});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = <Widget>[

    const HomeScreen(),
    const BookingScreen(),
    const FavoriteScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = <IconData>[
    Icons.search,
    Icons.calendar_month_rounded,
    CupertinoIcons.heart,
    CupertinoIcons.chat_bubble_text,
    CupertinoIcons.person_alt_circle,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        itemCount: _screens.length, // Only one page containing IndexedStack
        itemBuilder: (BuildContext context, int index) {
          // IndexedStack inside PageView
          return IndexedStack(
            index: selectedIndex,
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: Material(
        child: BottomAppBar(
          color: AppColors.blackColor,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List<GestureDetector>.generate(_icons.length, (int index) {
              return GestureDetector(
                onTap: () {

                  // _pageController.animateToPage(
                  //   index,
                  //   duration: const Duration(milliseconds: 500),
                  //   curve: Curves.easeInOut,
                  // );
                  _pageController.jumpToPage(index);

                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // color: AppColors.white,
                    color: selectedIndex == index ? Colors.white : Colors.transparent,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        offset: selectedIndex == index ? const Offset(0, 5) : Offset.zero,
                        color: selectedIndex == index ? AppColors.primaryColor : Colors.transparent,
                      ),
                    ],

                    borderRadius: BorderRadius.circular(10),
                  ),
                  // child: Icon(
                  //   selectedIndex == index ? _filledIcons[index] : _icons[index],
                  //   color: Colors.black87,
                  // ),
                  child: Icon(
                    _icons[index],
                    color: selectedIndex == index ? AppColors.blackColor : Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}









///
///
///
///
/// todo::: locking the error popup
///
///
///
///



// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manx_mate/core/extensions/widget_extensions.dart';
// import 'package:manx_mate/features/booking/screens/booking_screen.dart';
// import 'package:manx_mate/features/favorite/screens/favorite_screen.dart';
// import 'package:manx_mate/features/home/screens/home_screen.dart';
// import 'package:manx_mate/features/message/screens/message_screen.dart';
// import '../../../core/config/app_colors.dart';
// import '../../profile/screens/profile_screen.dart';
// import '../controllers/mainbottomnav_controller.dart';
//
// class MainBottomNavScreen extends StatefulWidget {
//   const MainBottomNavScreen({super.key});
//
//   @override
//   State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
// }
//
// class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
//   int selectedIndex = 0;
//   final PageController _pageController = PageController();
//   final MainBottomNavController _navController = Get.put(MainBottomNavController());
//
//   final List<Widget> _screens = <Widget>[
//     const HomeScreen(),
//     const BookingScreen(),
//     const FavoriteScreen(),
//     const MessageScreen(),
//     const ProfileScreen(),
//   ];
//
//   final List<IconData> _icons = <IconData>[
//     Icons.search,
//     Icons.calendar_month_rounded,
//     CupertinoIcons.heart,
//     CupertinoIcons.chat_bubble_text,
//     CupertinoIcons.person_alt_circle,
//   ];
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   // Method to check if screen requires authentication
//   bool _requiresAuth(int index) {
//     // Define which screens require authentication
//     // For example: Booking, Favorite, Message, Profile might require auth
//     return index >= 1; // All screens except Home (index 0) require auth
//   }
//
//   // Method to handle navigation with auth check
//   void _onItemTapped(int index) {
//     if (_requiresAuth(index)) {
//       // Check if user has valid authentication
//       final hasValidAuth = _navController.savedRole?.value?.isNotEmpty == true;
//
//       if (!hasValidAuth) {
//         // If not authenticated, redirect to home screen silently
//         // or show the home screen without any popup
//         _pageController.jumpToPage(0);
//         setState(() {
//           selectedIndex = 0;
//         });
//         return;
//       }
//     }
//
//     // If authenticated or screen doesn't require auth, proceed normally
//     _pageController.jumpToPage(index);
//     setState(() {
//       selectedIndex = index;
//     });
//   }
//
//   // Method to get the actual screen to display
//   Widget _getScreenForIndex(int index) {
//     if (_requiresAuth(index)) {
//       final hasValidAuth = _navController.savedRole?.value?.isNotEmpty == true;
//
//       if (!hasValidAuth) {
//         // Return home screen or a placeholder when not authenticated
//         return const HomeScreen();
//       }
//     }
//
//     // Return the actual screen if authenticated or no auth required
//     return _screens[index];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() {
//         // Use IndexedStack with dynamic screens based on auth
//         return IndexedStack(
//           index: selectedIndex,
//           children: List.generate(_screens.length, (index) {
//             return _getScreenForIndex(index);
//           }),
//         );
//       }),
//       bottomNavigationBar: Material(
//         child: BottomAppBar(
//           color: AppColors.blackColor,
//           elevation: 0,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: List<GestureDetector>.generate(_icons.length, (int index) {
//               return GestureDetector(
//                 onTap: () => _onItemTapped(index),
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: selectedIndex == index ? Colors.white : Colors.transparent,
//                     boxShadow: <BoxShadow>[
//                       BoxShadow(
//                         offset: selectedIndex == index ? const Offset(0, 5) : Offset.zero,
//                         color: selectedIndex == index ? AppColors.primaryColor : Colors.transparent,
//                       ),
//                     ],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     _icons[index],
//                     color: selectedIndex == index ? AppColors.blackColor : Colors.white,
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }