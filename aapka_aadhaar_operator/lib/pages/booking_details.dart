import 'package:aapka_aadhaar_operator/pages/home_page.dart';
import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'navigate.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({Key? key}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  String cancelBookingDate = '';
  late int cancelBookingSlot;
  late int serviceOtp;
  final list = [];

  String? mode;
  String? dayG;
  bool cannotCancel = true;
  DateTime _currentDate = DateTime.now();

  String? _reason;

  List slot = [
    '10_11',
    '11_12',
    '12_1',
    '2_3',
    '3_4',
    '4_5',
    '5_6',
  ];

  bool notValid = false;
  List timings = [
    '10:00 AM to 11:00 AM',
    '11:00 AM to 12:00 PM',
    '12:00 PM to 1:00 PM',
    '2:00 PM to 3:00 PM',
    '3:00 PM to 4:00 PM',
    '4:00 PM to 5:00 PM',
    '5:00 PM to 6:00 PM'
  ];
  List timingsCheck = [9, 10, 11, 13, 14, 15, 16];

  checkValidCancellation(int slot) {
    print('invalid ${timingsCheck[slot]}');
    for (int i = 0; i < timingsCheck.length; i++) {
      if (_currentDate.hour > timingsCheck[slot]) {
        notValid = true;
      }
    }
  }

  invalidCancellationSnack() async {
    final snackBar = SnackBar(
      content: const Text(
        'Too late to cancel!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
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

    cancelBookingDate = date;
    cancelBookingSlot = i;

    final address = i > 3
        ? databaseData['operators'][uid]['slots'][date][slot[i - 1]]['address']
        : databaseData['operators'][uid]['slots'][date][slot[i]]['address'];
    final name = i > 3
        ? databaseData['operators'][uid]['slots'][date][slot[i - 1]]['name']
        : databaseData['operators'][uid]['slots'][date][slot[i]]['name'];
    final phone = i > 3
        ? databaseData['operators'][uid]['slots'][date][slot[i - 1]]['phone']
        : databaseData['operators'][uid]['slots'][date][slot[i]]['phone'];
    final service = i > 3
        ? databaseData['operators'][uid]['slots'][date][slot[i - 1]]['service']
        : databaseData['operators'][uid]['slots'][date][slot[i]]['service'];
    final serviceOtp = i > 3
        ? databaseData['operators'][uid]['slots'][date][slot[i - 1]]['otp']
        : databaseData['operators'][uid]['slots'][date][slot[i]]['otp'];
    mode = i > 3
        ? databaseData['operators'][uid]['slots'][date][slot[i - 1]]['mode']
        : databaseData['operators'][uid]['slots'][date][slot[i]]['mode'];

    if (service == 'update') {
      final aadhaar = i > 3
          ? databaseData['operators'][uid]['slots'][date][slot[i - 1]]
              ['aadhaar_num']
          : databaseData['operators'][uid]['slots'][date][slot[i]]
              ['aadhaar_num'];
      list.addAll(
          [name, phone, address, service, i, date, serviceOtp, aadhaar, mode]);
      final pref = await SharedPreferences.getInstance();
      pref.setString('date', date);
      i > 3
          ? pref.setString('time', slot[i - 1])
          : pref.setString('time', slot[i]);
      print(list);
      dayG = list[5];
      return list;
    } else {
      list.addAll([name, phone, address, service, i, date, serviceOtp, null]);
      final pref = await SharedPreferences.getInstance();
      pref.setString('date', date);
      i > 3
          ? pref.setString('time', slot[i - 1])
          : pref.setString('time', slot[i]);
      print(list);
      dayG = list[5];
      print('dayG $dayG');
      return list;
    }
  }

  void cancelBooking(BuildContext context) async {
    print('cancelled called');
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    final key = pref.getString('operator-key');
    List keys_list = databaseData['operators'].keys.toList();
    var data;
    List latitudes = [];
    List longitudes = [];

    if (cancelBookingSlot > 3) {
      data = databaseData['operators'][uid]['slots'][cancelBookingDate]
          [slot[cancelBookingSlot - 1]];
      // print('data 1 $data');
      print('uid $uid');

      for (int i = 0; i < keys_list.length; i++) {
        if (keys_list[i] != key) {
          if (databaseData['operators'][keys_list[i]]['loggedin'] == true) {
            if (databaseData['operators'][keys_list[i]]['location']
                    ['latitude'] !=
                null) {
              latitudes.clear();
              latitudes.add(databaseData['operators'][keys_list[i]]['location']
                  ['latitude']);
            }
            if (databaseData['operators'][keys_list[i]]['location']
                    ['longitude'] !=
                null) {
              longitudes.clear();
              longitudes.add(databaseData['operators'][keys_list[i]]['location']
                  ['longitude']);
              // print(longitudes);
            }
            if (data != false) {
              String? user_id = data['user'];
              print('user $user_id');
              double distanceInMeters = geolocator.Geolocator.distanceBetween(
                  databaseData['users'][user_id]['location']['latitude'],
                  databaseData['users'][user_id]['location']['longitude'],
                  databaseData['operators'][uid]['location']['latitude'],
                  databaseData['operators'][uid]['location']['longitude']);
              // print('distance in meters $distanceInMeters');
              if (distanceInMeters <= 3000) {
                // print('key ${keys_list[i]}');
                databaseReference
                    .child('operators')
                    .child(keys_list[i])
                    .child('slots')
                    .child(cancelBookingDate)
                    .child(
                      slot[cancelBookingSlot - 1],
                    )
                    .set(data);
                databaseReference
                    .child('operators')
                    .child(uid)
                    .child('slots')
                    .child(cancelBookingDate)
                    .update({slot[cancelBookingSlot - 1]: false});
              }
            }
          } else {
            data = databaseData['operators'][uid]['slots'][cancelBookingDate]
                [slot[cancelBookingSlot]];
            // print('data 2 $data');
            print('uid $uid');
            databaseReference
                .child('operators')
                .child(uid)
                .child('slots')
                .child(cancelBookingDate)
                .update({slot[cancelBookingSlot]: false});
            // .update({slot[cancelBookingSlot]: false});

            for (int i = 0; i < keys_list.length; i++) {
              if (keys_list[i] != key) {
                if (databaseData['operators'][keys_list[i]]['loggedin'] ==
                    true) {
                  if (databaseData['operators'][keys_list[i]]['location']
                          ['latitude'] !=
                      null) {
                    latitudes.clear();
                    latitudes.add(databaseData['operators'][keys_list[i]]
                        ['location']['latitude']);
                    // print('lat $latitudes');
                  }
                  if (databaseData['operators'][keys_list[i]]['location']
                          ['longitude'] !=
                      null) {
                    longitudes.clear();
                    longitudes.add(databaseData['operators'][keys_list[i]]
                        ['location']['longitude']);
                    // print('lat 2 $longitudes');
                  }
                  if (data != false) {
                    String? user_id = data['user'];
                    // print('user $user_id');
                    double distanceInMeters =
                        geolocator.Geolocator.distanceBetween(
                            databaseData['users'][user_id]['location']
                                ['latitude'],
                            databaseData['users'][user_id]['location']
                                ['longitude'],
                            databaseData['operators'][uid]['location']
                                ['latitude'],
                            databaseData['operators'][uid]['location']
                                ['longitude']);
                    // print('distance in meters $distanceInMeters');
                    if (distanceInMeters <= 3000) {
                      // print('key ${keys_list[i]}');
                      if (databaseData['operators'][keys_list[i]]['slots']
                              [cancelBookingDate][slot[cancelBookingSlot]] ==
                          false) {
                        databaseReference
                            .child('operators')
                            .child(keys_list[i])
                            .child('slots')
                            .child(cancelBookingDate)
                            .child(slot[cancelBookingSlot])
                            .set(data);

                        databaseReference
                            .child('operators')
                            .child(uid)
                            .child('slots')
                            .child(cancelBookingDate)
                            .update({slot[cancelBookingSlot]: false});
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    // Navigator.pop(context);
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
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
    showSnack();
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

  completeAppt(BuildContext context) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    final verifyStatus = cancelBookingSlot > 3
        ? databaseData['operators'][uid]['slots'][cancelBookingDate]
            [slot[cancelBookingSlot - 1]]['verifyStatus']
        : databaseData['operators'][uid]['slots'][cancelBookingDate]
            [slot[cancelBookingSlot]]['verifyStatus'];
    if (verifyStatus == 'verified') {
      if (cancelBookingSlot > 3) {
        databaseReference
            .child('operators')
            .child(uid)
            .child('slots')
            .child(cancelBookingDate)
            .child(slot[cancelBookingSlot - 1])
            .update({'status': 'completed'});
        redirectBookSlotsComplete(context);
      } else {
        databaseReference
            .child('operators')
            .child(uid)
            .child('slots')
            .child(cancelBookingDate)
            .child(slot[cancelBookingSlot])
            .update({'status': 'completed'});
        redirectBookSlotsComplete(context);
      }
    } else {
      Navigator.pop(context);
      final snackBar = SnackBar(
        content: const Text(
          'Please do the verification before completing appointment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  redirectBookSlotsComplete(BuildContext context) {
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
    showSnackCompleted();
  }

  showSnackCompleted() async {
    final snackBar = SnackBar(
      content: const Text(
        'Appointment has been completed',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    print('Args : $args');
    return Scaffold(
      drawer: NavigationDrawer(),
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
                        if (snapshot.data[7] != null)
                          SizedBox(
                            height: 30,
                          ),
                        if (snapshot.data[7] != null)
                          TextFormField(
                            initialValue: snapshot.data[7],
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
                          height: 0,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Verification Pin: ',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                snapshot.data[6].toString(),
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF23F44)),
                              ),
                              SizedBox(
                                height: 90,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mode of Payment ' + mode!,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Text(
                              //   snapshot.data[8].toString(),
                              //   style: TextStyle(
                              //       fontFamily: 'Poppins',
                              //       fontSize: 16,
                              //       fontWeight: FontWeight.bold,
                              //       color: Color(0xFFF23F44)),
                              // ),
                              SizedBox(
                                height: 90,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NavigateToUser(),
                                    ),
                                  );
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
                                      borderRadius: BorderRadius.circular(24.0),
                                      side: BorderSide(
                                        width: 2,
                                        color: Color(0xFFF23F44),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Navigate to Location',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
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
                                      completeAppt(context);
                                    },
                                    child: Text('Yes'),
                                    style: ElevatedButton.styleFrom(
                                        shape: StadiumBorder(),
                                        primary: Color(0xFFF23F44)),
                                  );
                                  AlertDialog alert = AlertDialog(
                                    title: const Text(
                                        "Are you sure you want to complete the booking?",
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18)),
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
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xFFFFFFFF)),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.0),
                                      side: BorderSide(
                                        width: 2,
                                        color: Color(0xFFF23F44),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Complete Appointment',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              checkValidCancellation(args[0]);
                              notValid
                                  ? invalidCancellationSnack()
                                  : showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        cannotCancel = false;
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text(
                                                "Please select a reason for cancellation",
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 18)),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio<String>(
                                                      activeColor:
                                                          Color(0xFFF23F44),
                                                      value: 'Unable To Reach',
                                                      groupValue: _reason,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          _reason = value;
                                                          cannotCancel = false;
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text('Unable To Reach'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio<String>(
                                                      activeColor:
                                                          Color(0xFFF23F44),
                                                      value: 'Health Issues',
                                                      groupValue: _reason,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          _reason = value;
                                                          cannotCancel = false;
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text('Health Issues'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio<String>(
                                                      activeColor:
                                                          Color(0xFFF23F44),
                                                      value: 'Server Down',
                                                      groupValue: _reason,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          _reason = value;
                                                          cannotCancel = false;
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text('Server Down'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    cannotCancel
                                                        ? Text(
                                                            'Please select a reason',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          )
                                                        : Text(''),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Discard'),
                                                style: ElevatedButton.styleFrom(
                                                    shape: StadiumBorder(),
                                                    primary: Color(0xFFFFFFFF),
                                                    onPrimary: Colors.black),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (_reason == null) {
                                                    // setState(() {
                                                    setState(() {
                                                      cannotCancel = true;
                                                    });

                                                    // });
                                                  } else {
                                                    cancelBooking(context);
                                                  }
                                                },
                                                child: Text('Confirm'),
                                                style: ElevatedButton.styleFrom(
                                                    shape: StadiumBorder(),
                                                    primary: Color(0xFFF23F44)),
                                              )
                                            ],
                                          );
                                          ;
                                        });
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
