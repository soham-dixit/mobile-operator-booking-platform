import 'package:aapka_aadhaar/authentication/login_page.dart';
import 'package:aapka_aadhaar/authentication/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  bool already_exists = false;

  verifyPhone() async {
    PhoneVerificationCompleted verficationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      print("Verification completed");
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException exception) {
      print("Verification failed");
    };
    PhoneCodeSent codeSent =
        (String verificationId, int? forceResendingToken) async {
      print("Code has been sent");
      final pref = await SharedPreferences.getInstance();
      pref.setString('verification_id', verificationId);
      // setState(() {
      //   _verificationCode = verificationId;
      // });
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print("Time out");
    };

    try {
      print('+91 ${_phoneController.text}');
      await _auth.verifyPhoneNumber(
          phoneNumber: '+91 ${_phoneController.text}',
          verificationCompleted: verficationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      print('Catch block');
    }
  }

  final formKey = GlobalKey<FormState>();

  // saveUserInfo() async {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext c) {
  //         return ProgressDialog(
  //           message: "Processing, please wait...",
  //         );
  //       });
  // }

  List inputs = [];
  check_if_already_exists() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['users'] != null) {
      dynamic keys_list = databaseData['users'].keys.toList();
      for (int i = 0; i < keys_list.length; i++) {
        if (databaseData['users'][keys_list[i]]
                .containsValue(_phoneController.text) ||
            databaseData['users'][keys_list[i]]
                .containsValue(_emailController.text)) {
          already_exists = true;
        }
      }
    }

    final snackBar = SnackBar(
      content: const Text(
        'Email or mobile already exists!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    already_exists
        ? ScaffoldMessenger.of(context).showSnackBar(snackBar)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFBF9F6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            children: [
              SizedBox(
                height: 18,
              ),
              // Container(
              //   width: 200,
              //   height: 200,
              //   decoration: BoxDecoration(
              //     color: Colors.deepPurple.shade50,
              //     shape: BoxShape.circle,
              //   ),
              //   child: Image.asset(
              //     'assets/user_app_logo.png',
              //   ),
              // ),
              // SizedBox(
              //   height: 24,
              // ),
              Text(
                'Register',
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
                "Enter your credentials, we will send you OTP to verify",
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
              Container(
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          try {
                            if (value!.isEmpty ||
                                !RegExp(r'^[a-zA-Z ]*$').hasMatch(value)) {
                              return 'Please Enter a valid Full Name';
                            } else {
                              return null;
                            }
                          } catch (e) {}
                        },
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          label: Text('Full Name'),
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
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10)),
                          // prefix: Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 8),
                          //   child: Text(
                          //     '(+91)',
                          //     style: TextStyle(
                          //       fontFamily: 'Poppins',
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ),
                          // suffixIcon: Icon(
                          //   Icons.check_circle,
                          //   color: Colors.green,
                          //   size: 32,
                          // ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      TextFormField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          try {
                            if (value!.isEmpty ||
                                !RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$')
                                    .hasMatch(value)) {
                              return 'Please Enter a valid Email ID';
                            } else {
                              return null;
                            }
                          } catch (e) {}
                        },
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          label: Text('Email'),
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
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10)),
                          // prefix: Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 8),
                          //   child: Text(
                          //     '(+91)',
                          //     style: TextStyle(
                          //       fontFamily: 'Poppins',
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ),
                          // suffixIcon: Icon(
                          //   Icons.check_circle,
                          //   color: Colors.green,
                          //   size: 32,
                          // ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          try {
                            if (value!.isEmpty ||
                                !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                              return 'Please Enter a valid Mobile Number';
                            } else {
                              return null;
                            }
                          } catch (e) {}
                        },
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10)),
                          label: Text('Mobile'),
                          labelStyle: TextStyle(
                            color: Colors.grey.shade700,
                          ),

                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10)),
                          prefix: Padding(
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
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              inputs = [
                                _nameController.text,
                                _emailController.text,
                                _phoneController.text,
                              ];
                              check_if_already_exists().whenComplete(() {
                                already_exists
                                    ? null
                                    : verifyPhone().whenComplete(() {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => Otp(),
                                              settings: RouteSettings(
                                                arguments: inputs,
                                              )),
                                        );
                                      });
                              });
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFFF23F44)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already a user? ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          GestureDetector(
                            onTap: navigateToLogin,
                            child: Text(
                              'Login now',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
