import 'package:aapka_aadhaar_operator/authentication/login_page.dart';
import 'package:aapka_aadhaar_operator/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool change = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUid();
  }

  navigateToLogin() async {
    await Future.delayed(Duration(milliseconds: 2800), () {});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperatorLogin(),
      ),
    );
  }

  checkUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('uid');
    if (uid != null) {
      print(uid);
      await Future.delayed(Duration(milliseconds: 2800), () {});
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xfff23f44),
      body: TweenAnimationBuilder(
        tween: Tween<double>(begin: 1, end: 2),
        duration: Duration(milliseconds: 800),
        builder: (context, double scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Center(
          child: Container(
              child: Image.asset(
            'assets/operator_app_logo.png',
            width: width * 0.38,
          )),
        ),
      ),
    );
  }
}
