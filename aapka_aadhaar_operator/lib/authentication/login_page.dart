import 'package:aapka_aadhaar_operator/authentication/otp.dart';
import 'package:aapka_aadhaar_operator/authentication/register_page.dart';
import 'package:aapka_aadhaar_operator/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aapka_aadhaar_operator/services/otp_verification.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
// import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class OperatorLogin extends StatefulWidget {
  const OperatorLogin({Key? key}) : super(key: key);

  @override
  State<OperatorLogin> createState() => _OperatorLoginState();
}

class _OperatorLoginState extends State<OperatorLogin> {
  void navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperatorRegister(),
      ),
    );
  }

  final mobileValidator = MultiValidator([
    RequiredValidator(errorText: 'Please enter a mobile number!!'),
    PatternValidator(r'^[6-9]\d{9}$',
        errorText: 'Please Enter a valid 10 digit Mobile Number')
  ]);

  OTPVerification otpVerification = OTPVerification();
  TextEditingController phone = TextEditingController();
  bool phone_exists = false;

  check_phone_exists(phoneNumber) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      dynamic keys_list = databaseData['operators'].keys.toList();

      for (int i = 0; i < keys_list.length; i++) {
        if (databaseData['operators'][keys_list[i]]
            .containsValue(phoneNumber)) {
          phone_exists = true;
        }
      }
    }
  }

  showSnackBar() {
    const snackBar = SnackBar(
      content: Text(
        'Account not registered!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFFBF9F6),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              children: [
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
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Enter your phone number, we will send you OTP to verify",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 28,
                ),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                            keyboardType: TextInputType.phone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            maxLength: 10,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            cursorColor: Colors.black,
                            controller: phone,
                            decoration: InputDecoration(
                              label: Text('Mobile'),
                              labelStyle: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10)),
                              prefix: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '(+91)',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // suffixIcon: Icon(
                              //   Icons.check_circle,
                              //   color: Colors.green,
                              //   size: 32,
                              // ),
                            ),
                            validator: mobileValidator),
                        const SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                check_phone_exists(phone.text)
                                    .whenComplete(() {
                                  phone_exists
                                      ? otpVerification
                                          .verifyPhone(phone.text)
                                          .whenComplete(() {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => Otp(),
                                              settings: RouteSettings(
                                                  arguments: []),
                                            ),
                                          );
                                        })
                                      : showSnackBar();
                                });
                              }
                              // showDialog(
                              //     context: context,
                              //     barrierDismissible: false,
                              //     builder: (BuildContext c) {
                              //       return ProgressDialog(
                              //           message: 'Processing',);
                              //     });
                            },
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.white),
                              backgroundColor: MaterialStateProperty.all(
                                  Color(0xFFF23F44)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Send',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'New operator? ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 17.2,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000000),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: navigateToRegister,
                              child: const Text(
                                'Register now',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17.2,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF23F44),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     Navigator.of(context).push(
                        //         MaterialPageRoute(
                        //             builder: ((context) => HomePage())));
                        //   },
                        //   child: Text(
                        //     'Home Page',
                        //     style: TextStyle(
                        //       fontFamily: 'Poppins',
                        //       fontSize: 18,
                        //       fontWeight: FontWeight.bold,
                        //       color: Color(0xFFF23F44),
                        //     ),
                        //     textAlign: TextAlign.center,
                        //   ),
                        // ),
                      ],
                    ),
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
