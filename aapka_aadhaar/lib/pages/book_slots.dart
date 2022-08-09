import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookSlots extends StatefulWidget {
  const BookSlots({Key? key}) : super(key: key);

  @override
  State<BookSlots> createState() => _BookSlotsState();
}

class _BookSlotsState extends State<BookSlots> {
  final _currentDate = DateTime.now();
  final _dayFormatter = DateFormat('dd-MM-yyyy');
  Location currentLocation = Location();
  List dates = [];
  String? dayG;
  List status = [];
  List timings = [
    '10AM - 11AM',
    '11AM - 12PM',
    '12PM - 1PM ',
    '1PM - 2PM',
    '2PM - 3PM',
    '3PM - 4PM',
    '4PM - 5PM',
    '5PM - 6PM'
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

  getData(String day) async {
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> slotData = databaseData['operators'][key]['slots'];
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

  bookAppointment(int i) async {
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
          .child(dayG.toString())
          .child(
            slot[i],
          )
          .set(true);
    });
    databaseReference
        .child('users')
        .child(uid)
        .child('location')
        .set({"latitude": location.latitude, "longitude": location.longitude});
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dates.clear();
    for (int i = 0; i < 4; i++) {
      final date = _currentDate.add(Duration(days: i));
      dates.add(
        _dayFormatter.format(date),
        // _monthFormatter.format(date),
      );
    }
    dayG = dates[0];
  }

  @override
  Widget build(BuildContext context) {
    

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
              backgroundImage: AssetImage('assets/user_app_logo.png'),
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
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      timings[i] == '1PM - 2PM'
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
                                                  child: snapshot.data[i]
                                                      ? Text(
                                                          'Booked',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 14),
                                                        )
                                                      : Text(
                                                          'Book',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 14),
                                                        ),
                                                  onPressed: () {
                                                    snapshot.data[i]
                                                        ? alreadyBooked()
                                                        : bookAppointment(i);
                                                  },
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor: snapshot
                                                            .data[i]
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
                                                  color: snapshot.data[i]
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
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
