import 'package:aapka_aadhaar/pages/book_slots.dart';
import 'package:aapka_aadhaar/pages/book_slots_reschedule.dart';
import 'package:aapka_aadhaar/pages/feedback_form.dart';
import 'package:aapka_aadhaar/pages/home_page.dart';
import 'package:aapka_aadhaar/pages/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({Key? key}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  late Razorpay razorpay;
  String cancelBookingDate = '';
  late int cancelBookingSlot;
  int currentRating = 0;
  final list = [];
  String opName = '';
  String mode = '';
  String opPhone = '';
  String purpose = '';
  late int serviceOtp;
  String status = '';
  int count = 1;
  String? cancelledTime;
  // late Future data;
  List slot = [
    '10_11',
    '11_12',
    '12_1',
    '2_3',
    '3_4',
    '4_5',
    '5_6',
  ];

  List timings = [
    '10:00 AM to 11:00 AM',
    '11:00 AM to 12:00 PM',
    '12:00 PM to 1:00 PM',
    '2:00 PM to 3:00 PM',
    '3:00 PM to 4:00 PM',
    '4:00 PM to 5:00 PM',
    '5:00 PM to 6:00 PM'
  ];

  List timingsForPB = [
    '10:00 - 11:00 PM',
    '11:00 - 12:00 PM',
    '12:00 - 1:00 PM',
    '2:00 - 3:00 PM',
    '3:00 - 4:00 PM',
    '4:00 - 5:00 PM',
    '5:00 - 6:00 PM'
  ];

  bool invalid_booking = false;

  List timingsCheck = [11, 12, 13, 15, 16, 17, 18];

  checkTime(int slot) {
    final _currentDate = DateTime.now();
    // print('${_currentDate.hour}');
    for (int i = 0; i < timingsCheck.length; i++) {
      if (_currentDate.hour > timingsCheck[slot]) {
        invalid_booking = true;
      }
    }
  }

  showInvalidTimeSnack() async {
    final SnackBar snackBar = SnackBar(
      content: Text('Too late to cancel!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          )),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  getData(int i, String date) async {
    list.clear();
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');

    opName = databaseData['operators'][key]['fullname'];
    purpose = i > 3
        ? databaseData['operators'][key]['slots'][date][slot[i - 1]]['service']
        : databaseData['operators'][key]['slots'][date][slot[i]]['service'];
    opPhone = databaseData['operators'][key]['phoneNumber'];

    cancelBookingDate = date;
    cancelBookingSlot = i;

    final ratingSubmittedorNot = i > 3
        ? databaseData['operators'][key]['slots'][date][slot[i - 1]]
            ['ratingSubmitted']
        : databaseData['operators'][key]['slots'][date][slot[i]]
            ['ratingSubmitted'];

    databaseReference
        .child('operators')
        .child(key!)
        .child('slots')
        .child(date)
        .child(i > 3 ? slot[i - 1] : slot[i])
        .child('status')
        .onValue
        .listen((event) async {
      var snapshot = event.snapshot;
      if (snapshot.value.toString() == 'completed') {
        status = 'completed';
        if (ratingSubmittedorNot == false) {
          Widget reportButton = TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          );
          Widget okButton = ElevatedButton(
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
                shape: StadiumBorder(), primary: Color(0xFFF23F44)),
            onPressed: () {
              submitRating();
            },
          );

          AlertDialog alert = AlertDialog(
            title: Text("Kindly rate your experience with operator $opName",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            // content: const Text(
            //     "(NOTE: Please report if you doubt the authenticity of operator and your booking with this operator will be cancelled.)",
            //     textAlign: TextAlign.justify,
            //     style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
            content: RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
                currentRating = rating.toInt();
              },
            ),
            actions: [
              reportButton,
              okButton,
            ],
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
      }
    });
    // checkComplete();

    final address = i > 3
        ? databaseData['operators'][key]['slots'][date][slot[i - 1]]['address']
        : databaseData['operators'][key]['slots'][date][slot[i]]['address'];
    final name = i > 3
        ? databaseData['operators'][key]['slots'][date][slot[i - 1]]['name']
        : databaseData['operators'][key]['slots'][date][slot[i]]['name'];
    final phone = i > 3
        ? databaseData['operators'][key]['slots'][date][slot[i - 1]]['phone']
        : databaseData['operators'][key]['slots'][date][slot[i]]['phone'];
    final service = i > 3
        ? databaseData['operators'][key]['slots'][date][slot[i - 1]]['service']
        : databaseData['operators'][key]['slots'][date][slot[i]]['service'];
    mode = i > 3
        ? databaseData['operators'][key]['slots'][date][slot[i - 1]]['mode']
        : databaseData['operators'][key]['slots'][date][slot[i]]['mode'];
    if (service == 'update') {
      final aadhaar = i > 3
          ? databaseData['operators'][key]['slots'][date][slot[i - 1]]
              ['aadhaar_num']
          : databaseData['operators'][key]['slots'][date][slot[i]]
              ['aadhaar_num'];
      list.addAll([name, phone, address, service, i, date, aadhaar]);
      print('List $list');
      return list;
    } else {
      list.addAll([name, phone, address, service, i, date, null]);
      print('List $list');
      return list;
    }
  }

  void cancelBooking(BuildContext context, String cancelOrRes) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    final key = pref.getString('operator-key');
    var data;
    if (cancelBookingSlot > 3) {
      if (cancelOrRes == 'cancel') {
        databaseReference
            .child('operators')
            .child(key!)
            .child('slots')
            .child(cancelBookingDate)
            .update({slot[cancelBookingSlot - 1]: false});
      } else {
        data = databaseData['operators'][key]['slots'][cancelBookingDate]
            [slot[cancelBookingSlot - 1]];
        print('Data $data');
        databaseReference
            .child('operators')
            .child(key!)
            .child('slots')
            .child(cancelBookingDate)
            .update({slot[cancelBookingSlot - 1]: false});
      }

      // redirectHomePage(context);
      cancelledTime = timingsForPB[cancelBookingSlot - 1].toString();
    } else {
      if (cancelOrRes == 'cancel') {
        databaseReference
            .child('operators')
            .child(key!)
            .child('slots')
            .child(cancelBookingDate)
            .update({slot[cancelBookingSlot]: false});
      } else {
        data = databaseData['operators'][key]['slots'][cancelBookingDate]
            [slot[cancelBookingSlot]];
        print('Data $data');
        databaseReference
            .child('operators')
            .child(key!)
            .child('slots')
            .child(cancelBookingDate)
            .update({slot[cancelBookingSlot]: false});
      }
      // var data = databaseData['operators'][key]['slots'][cancelBookingDate]
      //     [slot[cancelBookingSlot]];
      // print('Data $data');

      cancelledTime = timingsForPB[cancelBookingSlot].toString();
      // redirectHomePage(context);
    }
    cancelOrRes == 'cancel'
        ? redirectHomePage(context)
        : redirectBookSlots(context, data);
  }

  redirectBookSlots(BuildContext context, var data) {
    final SnackBar snackBar = SnackBar(
      content: Text('Your booking for $cancelledTime has been cancelled.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          )),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookSlotsReschedule(),
        settings: RouteSettings(arguments: data),
      ),
    );
  }

  redirectHomePage(BuildContext context) {
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
          builder: (context) => HomePage(),
        ));
    showSnack();
  }

  redirectHomePageAfter(BuildContext context) {
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
          builder: (context) => HomePage(),
        ));
  }

  verifyServiceOtp() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    if (count <= 3) {
      if (cancelBookingSlot > 3) {
        final otp = databaseData['operators'][key]['slots'][cancelBookingDate]
            [slot[cancelBookingSlot - 1]]['otp'];
        if (serviceOtp == otp) {
          Navigator.pop(context);
          databaseReference
              .child('operators')
              .child(key!)
              .child('slots')
              .child(cancelBookingDate)
              .child(slot[cancelBookingSlot - 1])
              .update({'verifyStatus': 'verified'});
          final snackBar = SnackBar(
            content: const Text(
              'Operator has been successfully verified',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          final check = databaseData['operators'][key]['slots']
                  [cancelBookingDate][slot[cancelBookingSlot - 1]]['mode']
              .toString();
          // .child('operators')
          // .child(key)
          // .child('slots')
          // .child(cancelBookingDate)
          // .child(slot[cancelBookingSlot - 1])
          // .child('mode')
          // .toString();
          print('check $check');
          if (check == 'Online') {
            makePayment();
          }
        } else {
          Navigator.pop(context);
          final snackBar = SnackBar(
            content: const Text(
              'Invalid OTP, please try again',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          count++;
        }
      }
      if (cancelBookingSlot < 3) {
        final otp = databaseData['operators'][key]['slots'][cancelBookingDate]
            [slot[cancelBookingSlot]]['otp'];
        if (serviceOtp == otp) {
          Navigator.pop(context);
          databaseReference
              .child('operators')
              .child(key!)
              .child('slots')
              .child(cancelBookingDate)
              .child(slot[cancelBookingSlot])
              .update({'verifyStatus': 'verified'});
          final snackBar = SnackBar(
            content: const Text(
              'Operator has been successfully verified',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          final check = databaseData['operators'][key]['slots']
                  [cancelBookingDate][slot[cancelBookingSlot]]['mode']
              .toString();
          print('check $check');
          if (check == 'Online') {
            makePayment();
          }
        } else {
          Navigator.pop(context);
          final snackBar = SnackBar(
            content: const Text(
              'Invalid OTP, please try again',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          count++;
        }
      }
    } else {
      Navigator.pop(context);
      if (cancelBookingSlot > 3) {
        databaseReference
            .child('operators')
            .child(key!)
            .child('slots')
            .child(cancelBookingDate)
            .child(slot[cancelBookingSlot - 1])
            .update({'verifyStatus': 'unverified'});
      } else {
        databaseReference
            .child('operators')
            .child(key!)
            .child('slots')
            .child(cancelBookingDate)
            .child(slot[cancelBookingSlot])
            .update({'verifyStatus': 'unverified'});
      }
      Future.delayed(Duration(seconds: 1), () {
        Widget reportButton = ElevatedButton(
          child: Text("Report"),
          style: ElevatedButton.styleFrom(
              shape: StadiumBorder(), primary: Color(0xFFF23F44)),
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                });
            Future.delayed(Duration(seconds: 1), () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackForm(),
                  ));
            });
          },
        );
        Widget okButton = ElevatedButton(
          child: Text('Okay'),
          style: ElevatedButton.styleFrom(
              shape: StadiumBorder(), primary: Color(0xFFF23F44)),
          onPressed: () {
            Navigator.pop(context);
          },
        );

        AlertDialog alert = AlertDialog(
          title: const Text("Verification Pin did not match!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Color(0xFFF23F44),
                  fontWeight: FontWeight.bold)),
          content: const Text(
              "(NOTE: Please report if you doubt the authenticity of operator and your booking with this operator will be cancelled.)",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
          actions: [
            reportButton,
            okButton,
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      });
    }
  }

  makePayment() async {
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    openCheckout();
  }

  showSnack() async {
    final snackBar = SnackBar(
      content: const Text(
        'Appointment has been cancelled',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // checkComplete() async {
  //   final databaseReference = FirebaseDatabase.instance.ref();
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   final User user = await auth.currentUser!;
  //   final uid = user.uid;
  //   DatabaseEvent event = await databaseReference.once();
  //   Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
  //   final pref = await SharedPreferences.getInstance();
  //   final key = pref.getString('operator-key');

  //   status = cancelBookingSlot > 3
  //       ? databaseData['operators'][key]['slots'][cancelBookingDate]
  //           [slot[cancelBookingSlot - 1]]['status']
  //       : databaseData['operators'][key]['slots'][cancelBookingDate]
  //           [slot[cancelBookingSlot]]['status'];

  //   final ratingSubmittedorNot = cancelBookingSlot > 3
  //       ? databaseData['operators'][key]['slots'][cancelBookingDate]
  //           [slot[cancelBookingSlot - 1]]['ratingSubmitted']
  //       : databaseData['operators'][key]['slots'][cancelBookingDate]
  //           [slot[cancelBookingSlot]]['ratingSubmitted'];

  //   if (status == 'completed') {
  //     if (ratingSubmittedorNot == false) {
  //       Widget reportButton = TextButton(
  //         child: Text("Cancel"),
  //         onPressed: () {
  //           Navigator.pop(context);
  //         },
  //       );
  //       Widget okButton = ElevatedButton(
  //         child: Text('Submit'),
  //         style: ElevatedButton.styleFrom(
  //             shape: StadiumBorder(), primary: Color(0xFFF23F44)),
  //         onPressed: () {
  //           submitRating();
  //         },
  //       );

  //       AlertDialog alert = AlertDialog(
  //         title: Text("Kindly rate your experience with operator $opName",
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //                 fontFamily: 'Poppins',
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold)),
  //         // content: const Text(
  //         //     "(NOTE: Please report if you doubt the authenticity of operator and your booking with this operator will be cancelled.)",
  //         //     textAlign: TextAlign.justify,
  //         //     style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
  //         content: RatingBar.builder(
  //           initialRating: 0,
  //           minRating: 1,
  //           direction: Axis.horizontal,
  //           allowHalfRating: false,
  //           itemCount: 5,
  //           itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
  //           itemBuilder: (context, _) => Icon(
  //             Icons.star,
  //             color: Colors.amber,
  //           ),
  //           onRatingUpdate: (rating) {
  //             print(rating);
  //             currentRating = rating.toInt();
  //           },
  //         ),
  //         actions: [
  //           reportButton,
  //           okButton,
  //         ],
  //       );
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return alert;
  //         },
  //       );
  //     }
  //   }
  // }

  submitRating() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');

    int avgRating = databaseData['operators'][key]['avgRating'];
    int totalRating = databaseData['operators'][key]['totalRating'];
    int ratingCount = databaseData['operators'][key]['ratingCount'];

    totalRating = totalRating + currentRating;
    ratingCount = ratingCount + 1;
    avgRating = totalRating ~/ ratingCount;

    databaseReference
        .child('operators')
        .child(key!)
        .update({'avgRating': avgRating});
    databaseReference
        .child('operators')
        .child(key)
        .update({'totalRating': totalRating});
    databaseReference
        .child('operators')
        .child(key)
        .update({'ratingCount': ratingCount});
    databaseReference
        .child('operators')
        .child(key)
        .update({'ratingCount': ratingCount});
    if (cancelBookingSlot > 3) {
      databaseReference
          .child('operators')
          .child(key)
          .child('slots')
          .child(cancelBookingDate)
          .child(slot[cancelBookingSlot - 1])
          .update({'rating': currentRating});
      databaseReference
          .child('operators')
          .child(key)
          .child('slots')
          .child(cancelBookingDate)
          .child(slot[cancelBookingSlot - 1])
          .update({'ratingSubmitted': true});

      final customerName = databaseData['operators'][key]['slots']
          [cancelBookingDate][slot[cancelBookingSlot - 1]]['name'];

      int index = 0;
      dynamic previousBookingsData = databaseData['previousBookings'][key];
      dynamic key_list = previousBookingsData.keys;

      if (key_list.contains(uid)) {
        dynamic user_data = previousBookingsData[uid];

        index = user_data.length;
      } else {
        print('uid false');
      }

      databaseReference.child('previousBookings').child(key).child(uid).update({
        '$index': {
          'customerName': customerName,
          'purpose': purpose,
          'status': status,
          'rating': currentRating,
          'date': cancelBookingDate,
          'time': timingsForPB[cancelBookingSlot - 1]
        }
      });
    } else {
      databaseReference
          .child('operators')
          .child(key)
          .child('slots')
          .child(cancelBookingDate)
          .child(slot[cancelBookingSlot])
          .update({'rating': currentRating});
      databaseReference
          .child('operators')
          .child(key)
          .child('slots')
          .child(cancelBookingDate)
          .child(slot[cancelBookingSlot])
          .update({'ratingSubmitted': true});

      final customerName = databaseData['operators'][key]['slots']
          [cancelBookingDate][slot[cancelBookingSlot]]['name'];

      int index = 0;
      dynamic previousBookingsData = databaseData['previousBookings'];
      if (previousBookingsData != null) {
        if (previousBookingsData.containsValue(key)) {
          dynamic opdata = previousBookingsData[key];
          dynamic key_list = previousBookingsData.keys;

          if (key_list.contains(uid)) {
            dynamic user_data = previousBookingsData[uid];

            index = user_data.length;
          } else {
            print('uid false');
          }
        }
      }

      databaseReference.child('previousBookings').child(key).child(uid).update({
        '$index': {
          'customerName': customerName,
          'purpose': purpose,
          'status': status,
          'rating': currentRating,
          'date': cancelBookingDate,
          'time': timingsForPB[cancelBookingSlot]
        }
      });
    }
    Navigator.pop(context);
    final snackBar = SnackBar(
      content: const Text(
        'Your rating has been submitted, thank you!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    redirectHomePage(context);
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }

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
    // final pref = await SharedPreferences.getInstance();
    // String? i = pref.getString('arg0');
    // int i1 = int.parse(i!);
    // String? day = pref.getString('arg1');
    // String? uORe = pref.getString('arg2');
    // bookAppointment(i1, day!, uORe!);
    print('Payment Success');
  }

  void handlerErrorFailure(PaymentFailureResponse response) async {
    // final pref = await SharedPreferences.getInstance();
    // pref.remove('arg0');
    // pref.remove('arg1');
    // pref.remove('arg2');
    print('payment error');
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print('external wallet');
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    print('Args : $args');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF23F44),
        foregroundColor: Color(0xFFFFFFFF),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            // fontSize: 16
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/logo/logo.png'),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getData(args[0], args[1]),
          builder: (context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ));
              case ConnectionState.none:
                return Text('none');
              case ConnectionState.active:
                return Text('active');
              case ConnectionState.done:
                int index = snapshot.data[4];

                // var date = DateFormat('EEEE, d MMM, yyyy')
                //     .format(DateTime.parse(snapshot.data[5]));
                // print('null ${DateTime.parse(snapshot.data[5] + ' 00:00:00.000')}');
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // ListTile(
                            //   leading: Icon(
                            //     Icons.calendar_month
                            //   ),
                            //   title: Text('21st July, Thursday'),
                            // ),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 12,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(snapshot.data[5],
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, size: 12),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      index > 3
                                          ? Text(timings[index - 1],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                              ))
                                          : Text(timings[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                              )),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Text(
                        //   'Name',
                        //   textAlign: TextAlign.left,
                        //   style: TextStyle(
                        //       fontFamily: 'Poppins',
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        TextFormField(
                          initialValue: snapshot.data[0],
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Name',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Text(
                        //   'Contact Number',
                        //   textAlign: TextAlign.left,
                        //   style: TextStyle(
                        //       fontFamily: 'Poppins',
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        TextFormField(
                          initialValue: snapshot.data[1],
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Contact Number',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            isDense: true,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Text(
                        //   'Address',
                        //   textAlign: TextAlign.left,
                        //   style: TextStyle(
                        //       fontFamily: 'Poppins',
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        TextFormField(
                          initialValue: snapshot.data[2],
                          maxLines: null,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Address',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Text(
                        //   'Purpose',
                        //   textAlign: TextAlign.left,
                        //   style: TextStyle(
                        //       fontFamily: 'Poppins',
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        TextFormField(
                          initialValue: snapshot.data[3],
                          maxLines: null,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Purpose',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        if (snapshot.data[6] != null)
                          SizedBox(
                            height: 30,
                          ),
                        if (snapshot.data[6] != null)
                          TextFormField(
                            initialValue: snapshot.data[6],
                            maxLines: null,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Aadhaar Number',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            initialValue: 'Name of operator: ' + opName,
                            maxLines: null,
                            readOnly: true,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            initialValue: 'Contact No. of operator: ' + opPhone,
                            maxLines: null,
                            readOnly: true,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            initialValue: 'Mode of payment: ' + mode,
                            maxLines: null,
                            readOnly: true,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final pref =
                                  await SharedPreferences.getInstance();
                              pref.setInt('index', args[0]);
                              pref.setString('slot_date', args[1]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavigateToUser(),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFFFFFFF)),
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
                                'Navigate To Operator',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Widget cancelButton = TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              );
                              Widget verifyButton = ElevatedButton(
                                onPressed: () {
                                  verifyServiceOtp();
                                },
                                child: Text('Verify'),
                                style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    primary: Color(0xFFF23F44)),
                              );

                              AlertDialog alert = AlertDialog(
                                title: Column(
                                  children: [
                                    Text(
                                      'Operator Verification',
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
                                      "Please ask the operator for verification PIN, and allow them in your premise only if they're authenticate",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black38,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                content: OtpTextField(
                                  autoFocus: true,
                                  numberOfFields: 4,
                                  focusedBorderColor: Color(0xFFF23F44),
                                  //set to true to show as box or false to show as dash
                                  showFieldAsBox: true,
                                  //runs when a code is typed in
                                  onCodeChanged: (String code) {
                                    //handle validation or checks here
                                  },
                                  onSubmit: (String code) {
                                    serviceOtp = int.parse(code);
                                    print("printed service otp: $serviceOtp");
                                  },
                                  //runs when every textfield is filled
                                ),
                                actions: [
                                  cancelButton,
                                  verifyButton,
                                ],
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFFFFFFF)),
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
                                'Verify Operator',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Widget noButton = ElevatedButton(
                                onPressed: () {
                                  // checkTime(index);
                                  invalid_booking
                                      ? showInvalidTimeSnack()
                                      : cancelBooking(context, "res");

                                  // cancelBooking(context, "res");
                                },
                                child: Text('Reschedule'),
                                style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    primary: Color(0xFFFFFFFF),
                                    onPrimary: Color(0xFF000000)),
                              );
                              Widget yesButton = ElevatedButton(
                                onPressed: () {
                                  checkTime(index);
                                  invalid_booking
                                      ? showInvalidTimeSnack()
                                      : cancelBooking(context, "cancel");
                                },
                                child: Text('Cancel'),
                                style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    primary: Color(0xFFF23F44)),
                              );
                              AlertDialog alert = AlertDialog(
                                title: const Text(
                                    "Would you like to cancel or reschedule the booking?",
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 18)),
                                actions: [
                                  noButton,
                                  yesButton,
                                ],
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
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
                                'Cancel / Reschedule Booking',
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
                  ),
                );
            }
          }),
    );
  }
}
