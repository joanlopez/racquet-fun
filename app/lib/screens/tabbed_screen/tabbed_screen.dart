import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:racquet_fun/screens/counter_page/counter_page.dart';

class TabbedScreen extends StatefulWidget {
  const TabbedScreen({Key? key}) : super(key: key);

  @override
  State<TabbedScreen> createState() => _TabbedScreenState();
}

class _TabbedScreenState extends State<TabbedScreen> {
  List<Widget> pages = [
    const CounterPage(),
    const CounterPage(),
    const CounterPage(),
    const CounterPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: const Color.fromRGBO(222, 164, 106, 1.0),
          activeColor: Colors.white,
          inactiveColor: const Color.fromRGBO(252, 204, 146, 1.0),
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: "Home",
            )
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) {
              return pages[index];
            },
          );
        },
      ),
    );
  }
}
