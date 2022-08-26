import 'dart:math';

import 'package:aapka_aadhaar/pages/book_slots.dart';
import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:location/location.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceRequest extends StatefulWidget {
  const ServiceRequest({Key? key}) : super(key: key);

  @override
  State<ServiceRequest> createState() => _ServiceRequestState();
}

class _ServiceRequestState extends State<ServiceRequest> {
  late Razorpay razorpay;

  String? _value = 'Cash On Service';
  String? _value2 = 'Cash On Service';

  final GlobalKey<FormState> updationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> enrollmentFormKey = GlobalKey<FormState>();

  final nameValidator = MultiValidator([
    PatternValidator(r'^[a-zA-Z ]*$',
        errorText: 'Please Enter a valid Full Name'),
    RequiredValidator(errorText: 'Please Enter a valid Full Name')
  ]);

  final addressValidator = MultiValidator([
    // EmailValidator(errorText: 'Please Enter a valid Email ID'),
    RequiredValidator(errorText: 'Please Enter an Address')
  ]);

  final mobileValidator = MultiValidator([
    RequiredValidator(errorText: 'Please enter a mobile number!!'),
    PatternValidator(r'^[6-9]\d{9}$',
        errorText: 'Please Enter a valid 10 digit Mobile Number')
  ]);

  final aadhaarValidator = MultiValidator([
    RequiredValidator(errorText: 'Please enter a aadhaar number!!'),
    PatternValidator(r'^\d{12}$',
        errorText: 'Please Enter a valid 12 digit Aadhaar Number')
  ]);

  List<bool?> checkedValue = [false, false, false, false, false, false];
  List selectedValues = [];
  Location currentLocation = Location();
  TextEditingController name = TextEditingController();
  TextEditingController add = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController a_num = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _phone = TextEditingController();
  List slot = [
    '10_11',
    '11_12',
    '12_1',
    '2_3',
    '3_4',
    '4_5',
    '5_6',
  ];
  List timingsForPB = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM'
  ];
  String? index;
  String? dayG;

  bookAppointment(int i, String day, String uORe) async {
    var location = await currentLocation.getLocation();
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    var rng = new Random();
    var serviceOtp = rng.nextInt(9000) + 1000;
    print('called bookapt');

    setState(() {
      uORe == 'update'
          ? databaseReference
              .child('operators')
              .child(key.toString())
              .child('slots')
              .child(day)
              .child(
                i > 3 ? slot[i - 1] : slot[i],
              )
              .update({
              'name': name.text,
              'address': add.text,
              'aadhaar_num': a_num.text.replaceRange(0, 8, 'XXXXXXXX'),
              'phone': phone.text,
              'req': selectedValues,
              'service': uORe,
              'otp': serviceOtp,
              'status': 'pending',
              'ratingSubmitted': false,
              'user': uid,
              'args': [i, day],
              'mode': 'Online'
            })
          : databaseReference
              .child('operators')
              .child(key.toString())
              .child('slots')
              .child(day)
              .child(
                i > 3 ? slot[i - 1] : slot[i],
              )
              .update({
              'name': _name.text,
              'address': _address.text,
              'phone': _phone.text,
              'service': uORe,
              'otp': serviceOtp,
              'status': 'pending',
              'ratingSubmitted': false,
              'user': uid,
              'args': [i, day],
              'mode': 'Online'
            });

      index = i > 3 ? slot[i - 1] : slot[i];
      dayG = day;
    });
    databaseReference
        .child('users')
        .child(uid)
        .child('location')
        .set({"latitude": location.latitude, "longitude": location.longitude});

    // pref.remove('arg0');
    // pref.remove('arg1');
    // pref.remove('arg2');

    buildShowDialog(context);
  }

  buildShowDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        });
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookSlots(),
        ));
    showSnack();
  }

  cancelAppt(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookSlots(),
        ));
  }

  showSnack() async {
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

  navigate() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookSlots(),
        ));
  }

  @override
  void initState() {
    super.initState();
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    var options = {
      "key": "rzp_test_TWnK1D5r7DV05M",
      "amount": 100 * 100,
      "name": "Aapka Aadhaar",
      "description": "Door Step Aadhaar Card Service",
      "timeout": 120,
      "prefill": {
        "contact": databaseData['users'][uid]['phoneNumber'],
        "email": databaseData['users'][uid]['email'],
      },
      "external": {
        "wallets": ["paytm"]
      }
    };
    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) async {
    final pref = await SharedPreferences.getInstance();
    String? i = pref.getString('arg0');
    int i1 = int.parse(i!);
    String? day = pref.getString('arg1');
    String? uORe = pref.getString('arg2');
    bookAppointment(i1, day!, uORe!);
    print('Payment Success');
  }

  void handlerErrorFailure(PaymentFailureResponse response) async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('arg0');
    pref.remove('arg1');
    pref.remove('arg2');
    print('payment error');
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print('external wallet');
  }

  cosBook(int i, String day, String uORe) async {
    var location = await currentLocation.getLocation();
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    var rng = new Random();
    var serviceOtp = rng.nextInt(9000) + 1000;

    setState(() {
      uORe == 'update'
          ? databaseReference
              .child('operators')
              .child(key.toString())
              .child('slots')
              .child(day)
              .child(
                i > 3 ? slot[i - 1] : slot[i],
              )
              .update({
              'name': name.text,
              'address': add.text,
              'aadhaar_num': a_num.text.replaceRange(0, 8, 'XXXXXXXX'),
              'phone': phone.text,
              'req': selectedValues,
              'service': uORe,
              'otp': serviceOtp,
              'status': 'pending',
              'ratingSubmitted': false,
              'user': uid,
              'args': [i, day],
              'mode': 'Cash on Service'
            })
          : databaseReference
              .child('operators')
              .child(key.toString())
              .child('slots')
              .child(day)
              .child(
                i > 3 ? slot[i - 1] : slot[i],
              )
              .update({
              'name': _name.text,
              'address': _address.text,
              'phone': _phone.text,
              'service': uORe,
              'otp': serviceOtp,
              'status': 'pending',
              'ratingSubmitted': false,
              'user': uid,
              'args': [i, day],
              'mode': 'Cash on Service'
            });
    });
    databaseReference
        .child('users')
        .child(uid)
        .child('location')
        .set({"latitude": location.latitude, "longitude": location.longitude});
    buildShowDialog(context);
  }

  showError() {
    Widget saveButton = ElevatedButton(
      onPressed: () async {
        Navigator.pop(context);
      },
      child: Text('OK'),
      style: ElevatedButton.styleFrom(
          shape: StadiumBorder(), primary: Color(0xFFF23F44)),
    );

    AlertDialog alert = AlertDialog(
      // title: const Text("",
      //     style: TextStyle(fontFamily: 'Poppins', fontSize: 18)),
      content: Text(
        'Please select atleast one checkbox',
        style:
            TextStyle(fontSize: 18, fontFamily: 'Poppins', color: Colors.black),
      ),
      actions: [
        saveButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    print('Args : $args');
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: NavigationDrawer(),
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/logo/logo.png'),
              ),
            ),
          ],
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
                      key: updationFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
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
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            controller: a_num,
                            maxLength: 12,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: aadhaarValidator,
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
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            controller: phone,
                            maxLength: 10,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: mobileValidator,
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
                            maxLength: null,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.streetAddress,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: addressValidator,
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
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Text(
                            'Note: You cannot reschedule/cancel this booking after ${timingsForPB[args[0]]} on ${args[1]}',
                          ),
                          SizedBox(height: 20),
                          Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Radio<String>(
                                    activeColor: Color(0xFFF23F44),
                                    value: 'Cash On Service',
                                    groupValue: _value,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _value = value;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Cash On Service'),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    activeColor: Color(0xFFF23F44),
                                    value: 'Online Payment',
                                    groupValue: _value,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _value = value;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Online Payment'),
                                ],
                              ),
                            ],
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
                                  onPressed: () {
                                    cancelAppt(context);
                                  },
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
                                  onPressed: () async {
                                    // bookAppointment(args[0], args[1], 'update')
                                    //     .then((value) {
                                    //   showSnack();
                                    // });
                                    if (updationFormKey.currentState!
                                        .validate()) {
                                      if (selectedValues.isNotEmpty) {
                                        // print('Updation - ${_value2}');
                                        if (_value == 'Online Payment') {
                                          print('Updation - ${_value}');
                                          // cosBook(args[0], args[1], 'update');
                                          bookAppointment(
                                              args[0], args[1], 'update');
                                          // final pref = await SharedPreferences
                                          //     .getInstance();
                                          // pref.setString(
                                          //     'arg0', args[0].toString());
                                          // pref.setString('arg1', args[1]);
                                          // pref.setString('arg2', 'update');
                                          // openCheckout();
                                        } else if (_value ==
                                            'Cash On Service') {
                                          cosBook(args[0], args[1], 'update');
                                        }
                                      } else {
                                        showError();
                                      }
                                    }
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
                  Container(
                    padding: EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Form(
                      key: enrollmentFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: _name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
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
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            controller: _phone,
                            maxLength: 10,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: mobileValidator,
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
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.streetAddress,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: _address,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: addressValidator,
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
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Text(
                            'Note: You cannot reschedule/cancel this booking after ${timingsForPB[args[0]]} on ${args[1]}',
                          ),
                          SizedBox(height: 20),
                          Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Radio<String>(
                                    activeColor: Color(0xFFF23F44),
                                    value: 'Cash On Service',
                                    groupValue: _value2,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _value2 = value;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Cash On Service'),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    activeColor: Color(0xFFF23F44),
                                    value: 'Online Payment',
                                    groupValue: _value2,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _value2 = value;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Online Payment'),
                                ],
                              ),
                            ],
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
                                  onPressed: () {
                                    cancelAppt(context);
                                  },
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
                                  onPressed: () async {
                                    // buildShowDialog(context);
                                    // bookAppointment(
                                    //         args[0], args[1], 'enrollment')
                                    //     .then((value) {
                                    //   showSnack();
                                    // });
                                    if (enrollmentFormKey.currentState!
                                        .validate()) {
                                      // print('Enrollment - ${_value2}');
                                      if (_value2 == 'Online Payment') {
                                        print('Enrollment - ${_value2}');
                                        bookAppointment(
                                            args[0], args[1], 'enrollment');
                                      } else if (_value2 == 'Cash On Service') {
                                        cosBook(args[0], args[1], 'enrollment');
                                      }
                                    }
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
        ]),
      ),
    );
  }
}
