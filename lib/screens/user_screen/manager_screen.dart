import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_se/screens/main_screen/checkbill_screen.dart';
import 'package:test_se/screens/main_screen/manager_function.dart';
import 'package:test_se/screens/main_screen/menu_screen.dart';
import 'package:test_se/screens/main_screen/order_list_screen.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:test_se/screens/promotion/promotion_screen.dart';
import 'package:test_se/screens/main_screen/status_order.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  int _currentIndex = 0;

  List<Widget> body = [
    const Status(),
    const ManagerFunc(),
  ];

  void _checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userRole');
    if (userRole != 'manager') {
      FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (FirebaseAuth.instance.currentUser != null) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: body[_currentIndex]),
        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          buttonBackgroundColor: Color.fromARGB(255, 240, 210, 120),
          backgroundColor: Color.fromARGB(255, 240, 240, 240),
          color: const Color.fromARGB(255, 201, 225, 221),
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items: const [
            //  Icon(
            //     Icons.celebration,
            //     color: Colors.black,
            //   ),
            // Icon(
            //   Icons.new_releases,
            //   color: Colors.black,
            // ),
            Icon(
              Icons.checklist,
              color: Colors.black,
            ),
            Icon(
              Icons.manage_accounts,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
