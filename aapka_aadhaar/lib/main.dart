import 'package:aapka_aadhaar/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AapkaAadhaar());
}

class AapkaAadhaar extends StatefulWidget {
  const AapkaAadhaar({Key? key}) : super(key: key);

  @override
  State<AapkaAadhaar> createState() => _AapkaAadhaarState();
}

class _AapkaAadhaarState extends State<AapkaAadhaar> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}