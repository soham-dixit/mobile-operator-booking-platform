import 'package:aapka_aadhaar_operator/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
