import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manx_mate/features/message/screens/message_screen.dart';
import 'package:manx_mate/features/provider/screens/provider_dashboard_screen.dart';
import 'package:manx_mate/features/provider/screens/provider_services.dart';
import '../../../core/config/app_colors.dart';
import '../../profile/screens/profile_screen.dart';

class ProviderMainBottomNavScreen extends StatefulWidget {
  const ProviderMainBottomNavScreen({super.key});

  @override
  State<ProviderMainBottomNavScreen> createState() => _ProviderMainBottomNavScreenState();
}

class _ProviderMainBottomNavScreenState extends State<ProviderMainBottomNavScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = <Widget>[
    const ProviderDashboardScreen(),
    const ProviderServicesScreen(),
     const MessageScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = <IconData>[
    Icons.grid_view_outlined,
    Icons.calendar_month_rounded,
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
        itemCount: 1, // Only one page containing IndexedStack
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
