import 'package:aapka_aadhaar_operator/authentication/register_page.dart';
import 'package:aapka_aadhaar_operator/pages/home_page.dart';
import 'package:aapka_aadhaar_operator/services/otp_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
    String gender = args[3];
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
    // databaseReference.child("operators").push().set({
    //   "fullname": fullname,
    //   "email": email,
    //   "phoneNumber": phoneNumber,
    //   "gender" : gender
    // }).whenComplete(() {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => HomePage(),
    //     ),
    //   );
    // });

    databaseReference.child("operators").child(uid).set({
      "fullname": fullname,
      "email": email,
      "phoneNumber": phoneNumber,
      "gender": gender,
      "avgRating": 0,
      "totalRating": 0,
      "ratingCount": 0
    });

    addSlots();

    // print('Contains --- ${databaseData['users']['keys_list[0]']}');

    //push data to database
  }

  void addSlots() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    final _currentDate = DateTime.now();
    final _dayFormatter = DateFormat('dd-MM-yyyy');
    List dates = [];
    for (int i = 0; i < 7; i++) {
      final date = _currentDate.add(Duration(days: i));
      if (DateFormat("EEEE").format(date) != 'Saturday' &&
          DateFormat("EEEE").format(date) != 'Sunday') {
        dates.add(
          _dayFormatter.format(date),
          // _monthFormatter.format(date),
        );
      }
    }
    // print(uid);
    databaseReference.child("operators").child(uid).child("slots").update({
      dates[0]: "",
    });
    databaseReference.child("operators").child(uid).child("slots").update({
      dates[1]: "",
    });
    databaseReference.child("operators").child(uid).child("slots").update({
      dates[2]: "",
    });
    databaseReference.child("operators").child(uid).child("slots").update({
      dates[3]: "",
    });
    databaseReference
        .child("operators")
        .child(uid)
        .child("slots")
        .child(dates[0])
        .update({
      "10_11": false,
      "11_12": false,
      "12_1": false,
      "2_3": false,
      "3_4": false,
      "4_5": false,
      "5_6": false,
    });
    databaseReference
        .child("operators")
        .child(uid)
        .child("slots")
        .child(dates[1])
        .update({
      "10_11": false,
      "11_12": false,
      "12_1": false,
      "2_3": false,
      "3_4": false,
      "4_5": false,
      "5_6": false,
    });
    databaseReference
        .child("operators")
        .child(uid)
        .child("slots")
        .child(dates[2])
        .update({
      "10_11": false,
      "11_12": false,
      "12_1": false,
      "2_3": false,
      "3_4": false,
      "4_5": false,
      "5_6": false,
    });
    databaseReference
        .child("operators")
        .child(uid)
        .child("slots")
        .child(dates[3])
        .update({
      "10_11": false,
      "11_12": false,
      "12_1": false,
      "2_3": false,
      "3_4": false,
      "4_5": false,
      "5_6": false,
    }).whenComplete(() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    });
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

    final snackBar = const SnackBar(
      content: Text(
        'Incorrect OTP',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  login_or_register(args) {
    args.length == 4
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
                    child: const Icon(
                      Icons.arrow_back,
                      size: 32,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(
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
                    'assets/operator_app_logo.png',
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
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
                const Text(
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
                        child: const Padding(
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
                const SizedBox(
                  height: 18,
                ),
                const Text(
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
                      const snackBar = SnackBar(
                        content: Text(
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
                  child: const Text(
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
