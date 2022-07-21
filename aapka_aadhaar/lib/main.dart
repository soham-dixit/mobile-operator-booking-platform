import 'package:aapka_aadhaar/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    AapkaAadhaar(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    ),
  );
}

class AapkaAadhaar extends StatefulWidget {
  final Widget? child;

  AapkaAadhaar({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AapkaAadhaarState>()!.restartApp();
  }

  @override
  State<AapkaAadhaar> createState() => _AapkaAadhaarState();
}

class _AapkaAadhaarState extends State<AapkaAadhaar> {
  Key key = UniqueKey();
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
