import 'package:aapka_aadhaar/pages/book_slots.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserEnrollmentPage extends StatefulWidget {
  const UserEnrollmentPage({Key? key}) : super(key: key);

  @override
  State<UserEnrollmentPage> createState() => _UserEnrollmentPageState();
}

class _UserEnrollmentPageState extends State<UserEnrollmentPage> {
  List<bool?> checkedValue = [false, false, false, false, false, false];
  List selectedValues = [];
  Location currentLocation = Location();
  TextEditingController name = TextEditingController();
  TextEditingController add = TextEditingController();
  TextEditingController a_num = TextEditingController();
  bool isLoading = false;
  List slot = [
    '10_11',
    '11_12',
    '12_1',
    '2_3',
    '3_4',
    '4_5',
    '5_6',
  ];

  bookAppointment(int i, String day) async {
    var location = await currentLocation.getLocation();
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;

    setState(() {
      databaseReference
          .child('operators')
          .child(key.toString())
          .child('slots')
          .child(day)
          .child(
            slot[i - 1],
          )
          .set({'name': name.text, 'address': add.text, 'req': selectedValues});
    });
    databaseReference
        .child('users')
        .child(uid)
        .child('location')
        .set({"latitude": location.latitude, "longitude": location.longitude});

    // final snackBar = SnackBar(
    //   content: const Text(
    //     'Appointment has been booked',
    //     style: TextStyle(
    //       fontFamily: 'Poppins',
    //       fontSize: 16,
    //     ),
    //   ),
    // );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  callMethod() async {
    buildShowDialog(context);
  }

  showSnack() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        });

    final snackBar = SnackBar(
      content: const Text(
        'Appointment has been booked',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    print('Args : $args');
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Book Appointment",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Color(0xFFF23F44),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Updation'),
              Tab(text: 'Enrollment'),
            ],
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 16),
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
                            controller: name,
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
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            controller: a_num,
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
                          Container(
                            child: Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Color(0xFFF23F44)),
                              child: CheckboxListTile(
                                title: Text(
                                  'Address',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                                value: checkedValue[0],
                                activeColor: Colors.white,
                                checkColor: Color(0xFFF23F44),
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedValue[0] = value!;
                                  });
                                  value!
                                      ? selectedValues.add('Address')
                                      : selectedValues.remove('Address');
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Color(0xFFF23F44)),
                              child: CheckboxListTile(
                                title: Text(
                                  'Mobile/Email',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                                value: checkedValue[1],
                                activeColor: Colors.white,
                                checkColor: Color(0xFFF23F44),
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedValue[1] = value!;
                                  });
                                  value!
                                      ? selectedValues.add('Mobile/Email')
                                      : selectedValues.remove('Mobile/Email');
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Color(0xFFF23F44)),
                              child: CheckboxListTile(
                                title: Text(
                                  'Biometric',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                                value: checkedValue[2],
                                activeColor: Colors.white,
                                checkColor: Color(0xFFF23F44),
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedValue[2] = value!;
                                  });
                                  value!
                                      ? selectedValues.add('Biometric')
                                      : selectedValues.remove('Biometric');
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Color(0xFFF23F44)),
                              child: CheckboxListTile(
                                title: Text(
                                  'Date of birth',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                                value: checkedValue[3],
                                activeColor: Colors.white,
                                checkColor: Color(0xFFF23F44),
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedValue[3] = value!;
                                  });
                                  value!
                                      ? selectedValues.add('Date of birth')
                                      : selectedValues.remove('Date of birth');
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Color(0xFFF23F44)),
                              child: CheckboxListTile(
                                title: Text(
                                  'Name',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                                value: checkedValue[4],
                                activeColor: Colors.white,
                                checkColor: Color(0xFFF23F44),
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedValue[4] = value!;
                                  });
                                  value!
                                      ? selectedValues.add('Name')
                                      : selectedValues.remove('Name');
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Color(0xFFF23F44)),
                              child: CheckboxListTile(
                                title: Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                                value: checkedValue[5],
                                activeColor: Colors.white,
                                checkColor: Color(0xFFF23F44),
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkedValue[5] = value!;
                                  });
                                  value!
                                      ? selectedValues.add('Gender')
                                      : selectedValues.remove('Gender');
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            controller: add,
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
                                  onPressed: () {
                                    var method1 =
                                        bookAppointment(args[0], args[1]);
                                    var method2 = buildShowDialog(context);
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
