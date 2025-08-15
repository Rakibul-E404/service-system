import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    HomeScreen(),
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
      /*      body: IndexedStack(
        index: selectedIndex,
        children: _screens
      ),*/
      // body: PageView.builder(
      //   controller: _pageController,
      //   onPageChanged: (int index) {
      //     setState(() {
      //       selectedIndex = index;
      //     });
      //   },
      //   itemCount: _screens.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     return _screens[index];
      //     // return IndexedStack(index: selectedIndex, children: _screens);
      //   },
      // ),
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
                  // setState(() {
                  //   selectedIndex = index;
                  //   _pageController.jumpToPage(index);
                  // });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );

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
