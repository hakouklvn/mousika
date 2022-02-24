import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_play/screens/Search/search_page.dart';

import 'manager/page_manager.dart';
import 'screens/Home/home_page.dart';
import 'screens/musicPlayer/services/favourite_music_service.dart';
import 'services/service_locator.dart';
import 'theme.dart';

void main() async {
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;
  List screens = const [
    HomePage(),
    SearchPage(),
  ];

  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
    getIt<FavouriteSongs>().init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      home: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: navBar(),
      ),
    );
  }

  NavigationBar navBar() {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
      ],
      onDestinationSelected: (index) => setState(() {
        selectedIndex = index;
      }),
      height: 70,
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
