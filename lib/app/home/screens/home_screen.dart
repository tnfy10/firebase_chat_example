import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'chat_room_list_screen.dart';
import 'friend_list_screen.dart';
import 'more_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tabViewController = PersistentTabController(initialIndex: 0);

  int currentScreenIdx = 0;

  List<Widget> screens() =>
      [const FriendListScreen(), const ChatRoomListScreen(), const MoreScreen()];

  List<PersistentBottomNavBarItem> bottomNavBarItemList(BuildContext context) => [
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.account_circle),
            title: "친구",
            activeColorPrimary: Theme.of(context).colorScheme.primary,
            inactiveColorPrimary: Theme.of(context).colorScheme.secondary),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.chat),
            title: "채팅",
            activeColorPrimary: Theme.of(context).colorScheme.primary,
            inactiveColorPrimary: Theme.of(context).colorScheme.secondary),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.more_horiz),
            title: "더보기",
            activeColorPrimary: Theme.of(context).colorScheme.primary,
            inactiveColorPrimary: Theme.of(context).colorScheme.secondary)
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
            child: PersistentTabView(
          context,
          controller: _tabViewController,
          screens: screens(),
          items: bottomNavBarItemList(context),
          confineInSafeArea: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: false,
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true,
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Theme.of(context).colorScheme.background,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: const ItemAnimationProperties(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style9,
        )));
  }
}
