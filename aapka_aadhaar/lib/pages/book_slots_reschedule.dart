import 'dart:math';

import 'package:aapka_aadhaar/pages/booking_details.dart';
import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:aapka_aadhaar/pages/service_req.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookSlotsReschedule extends StatefulWidget {
  const BookSlotsReschedule({Key? key}) : super(key: key);

  @override
  State<BookSlotsReschedule> createState() => _BookSlotsRescheduleState();
}

class _BookSlotsRescheduleState extends State<BookSlotsReschedule> {
  final _currentDate = DateTime.now();
  final _dayFormatter = DateFormat('dd-MM-yyyy');
  Location currentLocation = Location();
  List dates = [];
  String? dayG;
  List status = [];
  var uid;
  List timings = [
    '10:00 AM to 11:00 AM',
    '11:00 AM to 12:00 PM',
    '12:00 PM to 1:00 PM',
    '1:00 PM to 2:00 PM',
    '2:00 PM to 3:00 PM',
    '3:00 PM to 4:00 PM',
    '4:00 PM to 5:00 PM',
    '5:00 PM to 6:00 PM'
  ];
  List slot = [
    '10_11',
    '11_12',
    '12_1',
    '2_3',
    '3_4',
    '4_5',
    '5_6',
  ];
  List activeColor = [true, false, false, false];
  bool booked = false;
  dynamic keys_list1;

  bookAppointment(int i, String uORe, var data) async {
    print('called $i');
    print('called $data');
    var location = await currentLocation.getLocation();
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    var rng = new Random();
    var serviceOtp = rng.nextInt(9000) + 1000;
    print('called $dayG');

    setState(() {
      uORe == 'update'
          ? databaseReference
              .child('operators')
              .child(key.toString())
              .child('slots')
              .child(dayG.toString())
              .child(
                i > 3 ? slot[i - 1] : slot[i],
              )
              .set(data)
          : databaseReference
              .child('operators')
              .child(key.toString())
              .child('slots')
              .child(dayG.toString())
              .child(
                i > 3 ? slot[i - 1] : slot[i],
              )
              .set(data);

      boo();
    });
    databaseReference
        .child('users')
        .child(uid)
        .child('location')
        .set({"latitude": location.latitude, "longitude": location.longitude});

    pref.remove('arg0');
    pref.remove('arg1');
    pref.remove('arg2');

    // buildShowDialog(context);
  }

  getData(String day) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    uid = user.uid;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    print('key 2 ---$key');
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> slotData = databaseData['operators'][key]['slots'];
      print('SLOT ==== $slot');
      print('DAY - $day');
      dynamic keys_list = slotData.keys.toList();

      status.clear();
      status.addAll([
        slotData[day]['10_11'],
        slotData[day]['11_12'],
        slotData[day]['12_1'],
        false,
        slotData[day]['2_3'],
        slotData[day]['3_4'],
        slotData[day]['4_5'],
        slotData[day]['5_6']
      ]);

      return status;
    }
  }

  alreadyBooked() {
    final snackBar = SnackBar(
      content: const Text(
        'Slot not available!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  oneBookingSnack() {
    booked = false;
    final snackBar = SnackBar(
      content: const Text(
        'You already have an appointment for the day!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  boo() {
    booked = false;
    final snackBar = SnackBar(
      content: const Text(
        'Appointment rescheduled!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  oneBookingPerDay(String day) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    Map<dynamic, dynamic> slotData = databaseData['operators'][key]['slots'];
    keys_list1 = slotData.keys.toList();
    // day = dayG.toString();
    print('day $day');
    for (int j = 0; j < slot.length; j++) {
      if (databaseData['operators'][key]['slots'][day][slot[j]] != false) {
        if (databaseData['operators'][key]['slots'][day][slot[j]]
            .containsValue(uid)) {
          booked = true;
        }
      }
    }
  }

  int? index;
  String? day;

  getArgs() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    dynamic keys_list = databaseData['operators'].keys.toList();
    Map<dynamic, dynamic> slotData = databaseData['operators'][key]['slots'];
    List keys_list1 = slotData.keys.toList();
    keys_list1.sort((a, b) {
      return a.compareTo(b);
    });
    if (databaseData['operators'] != null) {
      for (int i = 0; i < slot.length; i++) {
        if (databaseData['operators'][key]['slots'][dayG][slot[i]] != false) {
          index = i > 3
              ? databaseData['operators'][key]['slots'][dayG.toString()]
                  [slot[i - 1]]['args'][0]
              : databaseData['operators'][key]['slots'][dayG.toString()]
                  [slot[i]]['args'][0];
          day = i > 3
              ? databaseData['operators'][key]['slots'][dayG.toString()]
                  [slot[i - 1]]['args'][1]
              : databaseData['operators'][key]['slots'][dayG.toString()][slot[i]]
                  ['args'][1];
        }
      }
    }

    //   index = databaseData['operators'][key]['slots'][dayG.toString()][];
    //   // for (int i = 0; i < slot.length; i++) {
    //   //   if (databaseData['operators'][key]['slots'][keys_list1[0]][slot[i]] !=
    //   //       false) {
    //   //     index = databaseData['operators'][key]['slots'][keys_list1[0]]
    //   //         [slot[i]]['args'][0];
    //   //     day = databaseData['operators'][key]['slots'][keys_list1[0]][slot[i]]
    //   //         ['args'][1];
    //   //   }
    //   }
    //   print('uid 1 $index');
    //   print('uid 2 $day');
    //   // index = databaseData['operators'][]
    // }
  }

  navigate(i) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ServiceRequest(),
            settings: RouteSettings(arguments: [i, dayG])));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dates.clear();
    for (int i = 0; i < 7; i++) {
      final date = _currentDate.add(Duration(days: i));
      if (DateFormat("EEEE").format(date) != 'Saturday' &&
          DateFormat("EEEE").format(date) != 'Sunday') {
        dates.add(
          _dayFormatter.format(date),
          // _monthFormatter.format(date),
        );
      }
    }
    dayG = dates[0];
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    print('args $args');
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xFFF23F44),
        foregroundColor: Color(0xFFFFFFFF),
        title: Text(
          'Aapka Aadhaar',
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
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.circle,
              color: Colors.red,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Booked',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.circle,
              color: Colors.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Available',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                )),
          )
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        dayG = dates[0];
                        activeColor = [true, false, false, false];
                      });
                    },
                    child: Container(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            dates[0],
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: activeColor[0]
                                    ? Color(0xFFF23F44)
                                    : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        dayG = dates[1];
                        activeColor = [false, true, false, false];
                      });
                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          dates[1],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: activeColor[1]
                                  ? Color(0xFFF23F44)
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        dayG = dates[2];
                        activeColor = [false, false, true, false];
                      });
                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          dates[2],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: activeColor[2]
                                  ? Color(0xFFF23F44)
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        dayG = dates[3];
                        activeColor = [false, false, false, true];
                      });
                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          dates[3],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: activeColor[3]
                                  ? Color(0xFFF23F44)
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                FutureBuilder(
                    future: getData(dayG.toString()),
                    builder: (context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Padding(
                              padding: EdgeInsets.only(top: 300),
                              child: CupertinoActivityIndicator());
                        case ConnectionState.none:
                          return Text('none');
                        case ConnectionState.active:
                          return Text('active');
                        case ConnectionState.done:
                          return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: status.length,
                              itemBuilder: (context, i) {
                                // print('snapshot ${snapshot.data[i]['user']}');
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      timings[i] == '1:00 PM to 2:00 PM'
                                          ? Card(
                                              child: ListTile(
                                                  title: Center(
                                                child: Text(
                                                  'LUNCH BREAK',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14),
                                                ),
                                              )),
                                            )
                                          : Card(
                                              child: ListTile(
                                                title: Text(timings[i]),
                                                trailing: ElevatedButton(
                                                  child: snapshot.data[i] ==
                                                          false
                                                      ? Text(
                                                          'Book',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 14),
                                                        )
                                                      : snapshot.data[i]
                                                                  ['user'] ==
                                                              uid
                                                          ? Text(
                                                              'Details',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14),
                                                            )
                                                          : Text(
                                                              'Booked',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14),
                                                            ),
                                                  onPressed: () async {
                                                    bookAppointment(
                                                        i, 'update', args);

                                                    if (snapshot.data[i] !=
                                                        false) {
                                                      getArgs()
                                                          .whenComplete(() {
                                                        print('index $index');
                                                        print('day $day');
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  BookingDetails(),
                                                              settings:
                                                                  RouteSettings(
                                                                      arguments: [
                                                                    index,
                                                                    day
                                                                  ])),
                                                        );
                                                      });
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor: snapshot
                                                                .data[i] ==
                                                            false
                                                        ? MaterialStateProperty
                                                            .all(Color(
                                                                0xFFF23F44))
                                                        : MaterialStateProperty
                                                            .all(Colors
                                                                .grey.shade300),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                tileColor: Color(0xffffffff),
                                                leading: Icon(Icons.circle,
                                                    color: snapshot.data[i] ==
                                                            false
                                                        ? Colors.green
                                                        : Colors.red),
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                                ;
                              });
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
