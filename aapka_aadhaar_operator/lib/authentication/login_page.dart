import 'package:aapka_aadhaar_operator/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class OperatorLogin extends StatefulWidget {
  const OperatorLogin({Key? key}) : super(key: key);

  @override
  State<OperatorLogin> createState() => _OperatorLoginState();
}

class _OperatorLoginState extends State<OperatorLogin> {
  final formKey = GlobalKey<FormState>();
  bool showPass = false;
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  var key = '';
  String encrypted = '', decrypted = '';
  var password = '';
  bool showSnack_account = false, showSnack_pass = false;
  bool isEmailVerified = false;

  // PlatformStringCryptor cryptor = PlatformStringCryptor();

  showSnackPass() {
    showSnack_pass = false;
    final snackBar = SnackBar(
      content: Text(
        'Incorrect password!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showSnackAcc() {
    showSnack_account = false;
    final snackBar = SnackBar(
      content: Text(
        'Account not registered.',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  // encrypt() async {
  //   final salt = await cryptor.generateSalt();
  //   password = pass.text;
  //   key = await cryptor.generateKeyFromPassword(password, salt);
  //   encrypted = await cryptor.encrypt(password, key);
  //   print(encrypted);
  // }

  // decrypt() async {
  //   try {
  //     decrypted = await cryptor.decrypt(encrypted, key);
  //     print(decrypted);
  //   } on MacMismatchException {}
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendEmailVerificationLink();
    }
  }

  Future sendEmailVerificationLink() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFBF9F6),
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
                  "Enter your Email ID and Password",
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
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            label: const Text('Email ID'),
                            labelStyle: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
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
                          validator: (value) {
                            try {
                              if (value!.isEmpty ||
                                  !RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$')
                                      .hasMatch(value)) {
                                return 'Please enter a valid Email Address';
                              } else {
                                return null;
                              }
                            } catch (e) {}
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: pass,
                          obscureText: !showPass,
                          keyboardType: TextInputType.visiblePassword,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            labelStyle: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
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
                            suffixIcon: IconButton(
                              icon: showPass
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                              color: Colors.grey.shade700,
                              onPressed: () {
                                setState(() {
                                  if (showPass) {
                                    showPass = false;
                                  } else {
                                    showPass = true;
                                  }
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            try {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              } else {
                                return null;
                              }
                            } catch (e) {}
                          },
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {}
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFFF23F44)),
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
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     Navigator.of(context).pushReplacement(
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
                        // SizedBox(
                        //   height: 18,
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       'New user? ',
                        //       style: TextStyle(
                        //         fontFamily: 'Poppins',
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //         color: Color(0xFF000000),
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //     GestureDetector(
                        //       onTap: () {},
                        //       child: Text(
                        //         'Register now',
                        //         style: TextStyle(
                        //           fontFamily: 'Poppins',
                        //           fontSize: 18,
                        //           fontWeight: FontWeight.bold,
                        //           color: Color(0xFFF23F44),
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //     ),
                        //   ],
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
