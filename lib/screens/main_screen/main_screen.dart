import 'package:e_commerce_admin/screens/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dashboard/dashboard.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main_screen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: snapshot.hasData ? const Dashboard() : const Login(),
          ),
          // body: Center(
          //   child: Text(
          //     'HEy',
          //     style: Get.textTheme.headline6,
          //   ),
          // ),
        );
      },
    );
  }
}
