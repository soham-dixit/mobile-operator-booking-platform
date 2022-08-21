import 'dart:math';
import 'package:aapka_aadhaar/pages/book_slots.dart';
import 'package:aapka_aadhaar/pages/feedback_form.dart';
import 'package:aapka_aadhaar/pages/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({Key? key}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  String cancelBookingDate = '';
  late int cancelBookingSlot;
  int currentRating = 0;
  final list = [];
  String opName = '';
  String opPhone = '';
  late int serviceOtp;
  String status = '';
  int count = 1;
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

  void cancelBooking(BuildContext context) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    if (cancelBookingSlot > 3) {
      databaseReference
          .child('operators')
          .child(key!)
          .child('slots')
          .child(cancelBookingDate)
          .update({slot[cancelBookingSlot - 1]: false});
      redirectBookSlots(context);
    } else {
      databaseReference
          .child('operators')
          .child(key!)
          .child('slots')
          .child(cancelBookingDate)
          .update({slot[cancelBookingSlot]: false});
      redirectBookSlots(context);
    }
  }

  redirectBookSlots(BuildContext context) {
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
    showSnack();
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
              Navigator.pushReplacement(
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
    if (cancelBookingSlot > 3) {
      databaseReference
          .child('operators')
          .child(key)
          .child('slots')
          .child(cancelBookingDate)
          .child(slot[cancelBookingSlot - 1])
          .update({'ratingSubmitted': true});
    } else {
      databaseReference
          .child('operators')
          .child(key)
          .child('slots')
          .child(cancelBookingDate)
          .child(slot[cancelBookingSlot])
          .update({'ratingSubmitted': true});
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
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }

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
                              Widget noButton = TextButton(
                                child: Text("No"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              );
                              Widget yesButton = ElevatedButton(
                                onPressed: () {
                                  cancelBooking(context);
                                },
                                child: Text('Yes'),
                                style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    primary: Color(0xFFF23F44)),
                              );
                              AlertDialog alert = AlertDialog(
                                title: const Text(
                                    "Are you sure you want cancel the booking?",
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
                                'Cancel Booking',
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
