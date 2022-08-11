import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class UserEnrollmentPage extends StatefulWidget {
  const UserEnrollmentPage({Key? key}) : super(key: key);

  @override
  State<UserEnrollmentPage> createState() => _UserEnrollmentPageState();
}

class _UserEnrollmentPageState extends State<UserEnrollmentPage> {
  late bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Update OR Enrollment"),
          backgroundColor: Color(0xFFF23F44),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Updation'),
              Tab(text: 'Enrollment'),
            ],
            indicatorColor: Colors.white,
            indicatorWeight: 3,
          ),
        ),
        body: TabBarView(children: [
          SingleChildScrollView(
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
                  // Text(
                  //   'Register',
                  //   style: TextStyle(
                  //     fontFamily: 'Poppins',
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Text(
                  //   "Enter your credentials, we will send you OTP to verify",
                  //   style: TextStyle(
                  //     fontFamily: 'Poppins',
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black38,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // SizedBox(
                  //   height: 28,
                  // ),
                  Container(
                    padding: EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Form(
                      child: Column(
                        children: [
                          TextFormField(
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
                            maxLength: 12,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: (value) {
                              try {
                                // if (value!.isEmpty ||
                                //     !RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$')
                                //         .hasMatch(value)) {
                                //   return 'Please Enter a valid Email ID';
                                // } else {
                                //   return null;
                                // }
                              } catch (e) {}
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              label: Text('Aadhaar Number'),
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
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                                fillColor: MaterialStateProperty.all(
                                    Color(0xFFF23F44)),
                              ),
                              Text('Address'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                                fillColor: MaterialStateProperty.all(
                                    Color(0xFFF23F44)),
                              ),
                              Text('Mobile Number'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                                fillColor: MaterialStateProperty.all(
                                    Color(0xFFF23F44)),
                              ),
                              Text('Biometrics'),
                            ],
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: (value) {
                              try {
                                // if (value!.isEmpty ||
                                //     !RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$')
                                //         .hasMatch(value)) {
                                //   return 'Please Enter a valid Email ID';
                                // } else {
                                //   return null;
                                // }
                              } catch (e) {}
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              label: Text('Address'),
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
                          // SizedBox(
                          //   height: 22,
                          // ),
                          // TextFormField(
                          //   textInputAction: TextInputAction.done,
                          //   keyboardType: TextInputType.number,
                          //   maxLength: 10,
                          //   style: TextStyle(
                          //     fontFamily: 'Poppins',
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          //   validator: (value) {
                          //     try {
                          //       if (value!.isEmpty ||
                          //           !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                          //         return 'Please Enter a valid Mobile Number';
                          //       } else {
                          //         return null;
                          //       }
                          //     } catch (e) {}
                          //   },
                          //   cursorColor: Colors.black,
                          //   decoration: InputDecoration(
                          //     errorBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.red),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     focusedErrorBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.red),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     label: Text('Mobile'),
                          //     labelStyle: TextStyle(
                          //       color: Colors.grey.shade700,
                          //     ),

                          //     enabledBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.black12),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     focusedBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.black12),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     prefix: Padding(
                          //       padding: EdgeInsets.symmetric(horizontal: 8),
                          //       child: Text(
                          //         '(+91)',
                          //         style: TextStyle(
                          //           fontFamily: 'Poppins',
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ),
                          //     // suffixIcon: Icon(
                          //     //   Icons.check_circle,
                          //     //   color: Colors.green,
                          //     //   size: 32,
                          //     // ),
                          //   ),
                          // ),
                          SizedBox(
                            height: 22,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFFFFFFFF)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFFF23F44)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Text(
                                      'Book',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: 18,
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       'Already a user? ',
                          //       style: TextStyle(
                          //         fontFamily: 'Poppins',
                          //         fontSize: 18,
                          //         fontWeight: FontWeight.bold,
                          //         color: Color(0xFF000000),
                          //       ),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //     GestureDetector(
                          //       child: Text(
                          //         'Login now',
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
          SingleChildScrollView(
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
                  // Text(
                  //   'Register',
                  //   style: TextStyle(
                  //     fontFamily: 'Poppins',
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Text(
                  //   "Enter your credentials, we will send you OTP to verify",
                  //   style: TextStyle(
                  //     fontFamily: 'Poppins',
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black38,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // SizedBox(
                  //   height: 28,
                  // ),
                  Container(
                    padding: EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Form(
                      child: Column(
                        children: [
                          TextFormField(
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
                            maxLength: 12,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: (value) {
                              try {
                                // if (value!.isEmpty ||
                                //     !RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$')
                                //         .hasMatch(value)) {
                                //   return 'Please Enter a valid Email ID';
                                // } else {
                                //   return null;
                                // }
                              } catch (e) {}
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              label: Text('Mobile Number'),
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
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: (value) {
                              try {
                                // if (value!.isEmpty ||
                                //     !RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$')
                                //         .hasMatch(value)) {
                                //   return 'Please Enter a valid Email ID';
                                // } else {
                                //   return null;
                                // }
                              } catch (e) {}
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              label: Text('Address'),
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
                          // SizedBox(
                          //   height: 22,
                          // ),
                          // TextFormField(
                          //   textInputAction: TextInputAction.done,
                          //   keyboardType: TextInputType.number,
                          //   maxLength: 10,
                          //   style: TextStyle(
                          //     fontFamily: 'Poppins',
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          //   validator: (value) {
                          //     try {
                          //       if (value!.isEmpty ||
                          //           !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                          //         return 'Please Enter a valid Mobile Number';
                          //       } else {
                          //         return null;
                          //       }
                          //     } catch (e) {}
                          //   },
                          //   cursorColor: Colors.black,
                          //   decoration: InputDecoration(
                          //     errorBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.red),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     focusedErrorBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.red),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     label: Text('Mobile'),
                          //     labelStyle: TextStyle(
                          //       color: Colors.grey.shade700,
                          //     ),

                          //     enabledBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.black12),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     focusedBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: Colors.black12),
                          //         borderRadius: BorderRadius.circular(10)),
                          //     prefix: Padding(
                          //       padding: EdgeInsets.symmetric(horizontal: 8),
                          //       child: Text(
                          //         '(+91)',
                          //         style: TextStyle(
                          //           fontFamily: 'Poppins',
                          //           fontSize: 18,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ),
                          //     // suffixIcon: Icon(
                          //     //   Icons.check_circle,
                          //     //   color: Colors.green,
                          //     //   size: 32,
                          //     // ),
                          //   ),
                          // ),
                          SizedBox(
                            height: 22,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFFFFFFFF)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFFF23F44)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Text(
                                      'Book',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: 18,
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       'Already a user? ',
                          //       style: TextStyle(
                          //         fontFamily: 'Poppins',
                          //         fontSize: 18,
                          //         fontWeight: FontWeight.bold,
                          //         color: Color(0xFF000000),
                          //       ),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //     GestureDetector(
                          //       child: Text(
                          //         'Login now',
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
        ]),
      ),
    );
  }
}
