import 'package:aapka_aadhaar_operator/pages/booking_details.dart';
import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _currentDate = DateTime.now();
  final _dayFormatter = DateFormat('dd-MM-yyyy');
  final _monthFormatter = DateFormat('MMM');
  List dates = [];
  Location currentLocation = Location();
  String? dayG;
  List status = [];
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

  @override
  void initState() {
    super.initState();
    saveUid();
    updateSlots();
    setState(() {
      if (FirebaseAuth.instance.currentUser != null) {
        print("logged in");
        getLocation();
      } else {
        print("not logged in");
      }
    });
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

  saveUid() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
    databaseReference.child("operators").child(uid).update({"loggedin": true});
  }

  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) async {
      print(loc.latitude);
      print(loc.longitude);
      final databaseReference = FirebaseDatabase.instance.ref();
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User user = await auth.currentUser!;
      final uid = user.uid;
      // print(uid);
      databaseReference
          .child("operators")
          .child(uid)
          .child("location")
          .update({"latitude": loc.latitude, "longitude": loc.longitude});
    });
  }

  updateSlots() async {
    print('called update ---');
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> slotData = databaseData['operators'][uid]['slots'];
      List keys_list = slotData.keys.toList();
      keys_list.sort((a, b) {
        return a.compareTo(b);
      });
      print(keys_list);
      var _currentDate = DateTime.now();
      final _dayFormatter = DateFormat('dd-MM-yyyy');

      if (_dayFormatter.format(_currentDate) == keys_list[1]) {
        databaseReference
            .child("operators")
            .child(uid)
            .child("slots")
            .child(keys_list[0])
            .remove();

        String? day;

        day = DateFormat("dd-MM-yyyy")
            .parse(keys_list[3])
            .add(Duration(days: 1))
            .toString();
        print('Day 1 day- $day');
        print('Day 1 ${DateFormat('EEEE').format(DateTime.parse(day))}');

        if (DateFormat('EEEE').format(DateTime.parse(day)) == 'Sunday') {
          print('sunday');
          day = DateTime.parse(day).add(Duration(days: 2)).toString();
        } else if (DateFormat('EEEE').format(DateTime.parse(day)) ==
            'Saturday') {
          print('sat');
          day = DateTime.parse(day).add(Duration(days: 2)).toString();
        }
        String? final_day =
            _dayFormatter.format(DateTime.parse(day)).toString();

        databaseReference.child("operators").child(uid).child("slots").update({
          final_day: {
            "10_11": false,
            "11_12": false,
            "12_1": false,
            "2_3": false,
            "3_4": false,
            "4_5": false,
            "5_6": false,
          }
        });

        print('called');

        // databaseReference.child("operators").child(uid).child("slots").update({
        //   final_day: {
        //     "10_11": false,
        //     "11_12": false,
        //     "12_1": false,
        //     "2_3": false,
        //     "3_4": false,
        //     "4_5": false,
        //     "5_6": false,
        //   },
        // });
      } else {}
    }
  }

  getData(String day) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> slotData = databaseData['operators'][uid]['slots'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xFFF23F44),
        foregroundColor: Color(0xFFFFFFFF),
        title: const Text(
          'Aapka Aadhaar Operator',
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
            child: Text('Vacant',
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
                                                          'Vacant',
                                                          style: TextStyle(
                                                              // fontFamily:
                                                              //     'Poppins',
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14),
                                                        )
                                                      : Text(
                                                          'Details',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 14),
                                                        ),
                                                  onPressed: () {
                                                    if (snapshot.data[i] !=
                                                        false) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  BookingDetails(),
                                                              settings:
                                                                  RouteSettings(
                                                                      arguments: [
                                                                    i,
                                                                    dayG
                                                                  ])));
                                                    } else {
                                                      //show snackbar
                                                      final snackBar = SnackBar(
                                                        content: Text(
                                                          'Vacant slot',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      );
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackBar);
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
                                                            .all(Colors
                                                                .grey.shade300)
                                                        : MaterialStateProperty
                                                            .all(Color(
                                                                0xFFF23F44)),
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
                                                leading: Icon(
                                                  Icons.circle,
                                                  color:
                                                      snapshot.data[i] == false
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                                ;
                              });
                      }
                    })
              ],
            ),
          ),
    
          // TableCalendar(
          //   firstDay: DateTime.parse(dates[0]),
          //   lastDay: DateTime.parse(dates[3]),
          //   focusedDay: DateTime.parse(dates[0]),
          // ),
          // MyCardWidget(time: '10AM - 11AM'),
        ],
      ),
    );
  }
}

class MyCardWidget extends StatefulWidget {
  String? time;

  MyCardWidget({Key? key, this.time}) : super(key: key);

  @override
  State<MyCardWidget> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: 130,
      height: 90,
      padding: new EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.greenAccent,
        elevation: 10,
        child: ListTile(
          title: Text(
            widget.time.toString(),
            style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
          ),
        ),
      ),
    ));
  }
}
