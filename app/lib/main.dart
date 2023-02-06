import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:racquet_fun/screens/counter_page/counter_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Racquet Fun',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          backgroundColor: Colors.blueGrey,
          activeColor: Colors.white,
          inactiveColor: Colors.grey,
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
