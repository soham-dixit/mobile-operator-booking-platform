import 'package:aapka_aadhaar_operator/authentication/login_page.dart';
import 'package:aapka_aadhaar_operator/authentication/otp.dart';
import 'package:aapka_aadhaar_operator/services/otp_verification.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class OperatorRegister extends StatefulWidget {
  const OperatorRegister({Key? key}) : super(key: key);

  @override
  State<OperatorRegister> createState() => _OperatorRegisterState();
}

class _OperatorRegisterState extends State<OperatorRegister> {
  void navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OperatorLogin(),
      ),
    );
  }

  final nameValidator = MultiValidator([
    PatternValidator(r'^[a-zA-Z ]*$',
        errorText: 'Please Enter a valid Full Name'),
    RequiredValidator(errorText: 'Please Enter a valid Full Name')
  ]);

  final emailValidator = MultiValidator([
    EmailValidator(errorText: 'Please Enter a valid Email ID'),
    RequiredValidator(errorText: 'Please Enter a valid Email ID')
  ]);

  final mobileValidator = MultiValidator([
    RequiredValidator(errorText: 'Please enter a mobile number!!'),
    PatternValidator(r'^[6-9]\d{9}$',
        errorText: 'Please Enter a valid 10 digit Mobile Number')
  ]);

  final genderValidator = MultiValidator([
    RequiredValidator(errorText: 'Please select a gender!!'),
  ]);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  bool already_exists_phone = false;
  bool already_exists_email = false;
  bool already_exists = false;
  OTPVerification otpVerification = OTPVerification();

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
    if (databaseData['operatorsEmailList'] != null &&
        databaseData['operatorsPhoneList'] != null) {
      // dynamic keys_list = databaseData['operators'].keys.toList();
      // print('Res --- ${databaseData['operatorsPhoneList'][5].runtimeType}');
      int i = int.parse(_phoneController.text.toString());
      if (databaseData['operatorsPhoneList'].contains(i)) {
        already_exists_phone = true;
      }

      if (databaseData['operatorsEmailList'].contains(_emailController.text)) {
        already_exists_email = true;
      }
    }
  }

  already_registered() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      dynamic keys_list = databaseData['operators'].keys.toList();
      for (int i = 0; i < keys_list.length; i++) {
        if (databaseData['operators'][keys_list[i]]
                .containsValue(_phoneController.text) ||
            databaseData['operators'][keys_list[i]]
                .containsValue(_emailController.text)) {
          already_exists = true;
        }
      }
    }
  }

  showSnack() {
    already_exists = false;
    const snackBar = SnackBar(
      content: Text(
        'Already registered, please login',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showSnackBar() {
    already_exists_email = false;
    already_exists_phone = false;
    const snackBar = SnackBar(
      content: Text(
        'Invalid Operator',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  final List<String> genderItems = [
    'Male',
    'Female',
    'Transgender',
  ];

  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFBF9F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            children: [
              const SizedBox(
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
              const Text(
                'Register',
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
                "Enter your credentials, we will send you OTP to verify",
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: nameValidator,
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
                      const SizedBox(
                        height: 22,
                      ),
                      TextFormField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: emailValidator,
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
                        keyboardType: TextInputType.phone,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        maxLength: 10,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: mobileValidator,
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
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      DropdownButtonFormField2(
                        decoration: InputDecoration(
                          //Add isDense true and zero Padding.
                          //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: -8),
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
                          //Add more decoration as you want here
                          //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                        ),
                        isExpanded: true,
                        hint: const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF616161),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 30,
                        buttonHeight: 60,
                        buttonPadding:
                            const EdgeInsets.only(left: 20, right: 10),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        items: genderItems
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                        validator: genderValidator,
                        onChanged: (value) {
                          //Do something when changing the item if you want.
                          selectedValue = value.toString();
                        },
                        onSaved: (value) {
                          selectedValue = value.toString();
                          controller:
                          _genderController;
                        },
                      ),
                      const SizedBox(
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
                                selectedValue
                              ];
                              check_if_already_exists().whenComplete(() {
                                already_registered().whenComplete(() {
                                  already_exists
                                      ? showSnack()
                                      : already_exists_phone &&
                                              already_exists_email
                                          ? otpVerification
                                              .verifyPhone(
                                                  _phoneController.text)
                                              .whenComplete(() {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Otp(),
                                                      settings: RouteSettings(
                                                        arguments: inputs,
                                                      )));
                                            })
                                          : showSnackBar();
                                });
                              });
                              // check_if_already_exists().whenComplete(() {
                              //   already_exists
                              //       ? null
                              //       : otpVerification.verifyPhone(_phoneController.text)
                              //           .whenComplete(() {
                              //           Navigator.of(context).push(
                              //             MaterialPageRoute(
                              //                 builder: (context) => Otp(),
                              //                 settings: RouteSettings(
                              //                   arguments: inputs,
                              //                 )),
                              //           );
                              //         });
                              // });
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
                          child: const Padding(
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
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already operator? ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.7,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          GestureDetector(
                            onTap: navigateToLogin,
                            child: const Text(
                              'Login now',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.7,
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
