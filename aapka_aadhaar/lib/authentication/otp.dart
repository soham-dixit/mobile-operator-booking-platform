import 'package:aapka_aadhaar/authentication/register_page.dart';
import 'package:aapka_aadhaar/pages/home_page.dart';
import 'package:aapka_aadhaar/services/otp_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otp extends StatefulWidget {
  const Otp({Key? key}) : super(key: key);

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verification_id = '';
  String _smsCode = '';
  bool incorrect_otp = false;
  OTPVerification otpVerification = OTPVerification();

  saveUserInfo(args) async {
    String fullname = args[0];
    String email = args[1];
    String phoneNumber = args[2];

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext c) {
    //       return ProgressDialog(
    //         message: "Processing, please wait...",
    //       );
    //     });

    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;

    //push data to database
    databaseReference.child("users").child(uid).set({
      "fullname": fullname,
      "email": email,
      "phoneNumber": phoneNumber
    }).whenComplete(() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    });

    // print('Contains --- ${databaseData['users']['keys_list[0]']}');

    //push data to database
  }

  verifyOtp(String verificationCode1, String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationCode1, smsCode: smsCode);
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
    } catch (exception) {
      incorrect_otp = true;
      print(exception);
    }
  }

  show_incorrect_otp() {
    incorrect_otp = false;

    final snackBar = SnackBar(
      content: const Text(
        'Incorrect OTP',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  login_or_register(args) {
    args.length == 3
        ? saveUserInfo(args)
        : Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
    ;
  }

  @override
  Widget build(BuildContext context) {
    final List args = ModalRoute.of(context)!.settings.arguments as List;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFFBF9F6),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 32,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/user_app_logo.png',
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  'Verification',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your OTP to verify",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 28,
                ),
                Column(
                  children: [
                    OtpTextField(
                      autoFocus: true,
                      numberOfFields: 6,
                      focusedBorderColor: Color(0xFFF23F44),
                      //set to true to show as box or false to show as dash
                      showFieldAsBox: true,
                      //runs when a code is typed in
                      onCodeChanged: (String code) {
                        //handle validation or checks here
                      },
                      //runs when every textfield is filled
                      onSubmit: (String code) async {
                        final pref = await SharedPreferences.getInstance();
                        verification_id =
                            pref.getString('verification_id').toString();
                        _smsCode = code;
                        print('veri $verification_id');
                        print('sms $_smsCode');
                      }, // end onSubmit
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          verifyOtp(verification_id, _smsCode).whenComplete(() {
                            incorrect_otp
                                ? show_incorrect_otp()
                                : login_or_register(args);
                          });
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xFFF23F44)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Text(
                  "Didn't you receive any code?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 18,
                ),
                InkWell(
                  onTap: () {
                    otpVerification.verifyPhone(args[2]).whenComplete(() {
                      final snackBar = SnackBar(
                        content: const Text(
                          'Code has been sent',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  },
                  child: Text(
                    "Resend new code",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF23F44),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
