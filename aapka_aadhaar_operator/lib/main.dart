import 'dart:io';

import 'package:aapka_aadhaar_operator/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var uid = prefs.getString('uid');
  print(uid);
  runApp(const AapkaAadhaarOperator());
}

class AapkaAadhaarOperator extends StatefulWidget {
  const AapkaAadhaarOperator({Key? key}) : super(key: key);

  @override
  State<AapkaAadhaarOperator> createState() => _AapkaAadhaarOperatorState();
}

class _AapkaAadhaarOperatorState extends State<AapkaAadhaarOperator> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
