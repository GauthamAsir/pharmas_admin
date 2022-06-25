import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'screens/login/login.dart';
import 'screens/main_screen/dashboard/dashboard.dart';
import 'screens/main_screen/main_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appName,
      // Don't show debug banner in debug builds.
      debugShowCheckedModeBanner: false,
      enableLog: true,
      theme: ThemeData(
          // fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSwatch(primarySwatch: appPrimaryColor)),
      darkTheme: ThemeData(
          // fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSwatch(primarySwatch: appPrimaryColor)),
      getPages: [
        GetPage(name: Login.routeName, page: () => const Login()),
        GetPage(name: MainScreen.routeName, page: () => const MainScreen()),
        GetPage(name: Dashboard.routeName, page: () => const Dashboard()),
      ],
      initialRoute: MainScreen.routeName,
    );
  }
}
