import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    setState(() {
      if (FirebaseAuth.instance.currentUser != null) {
        print("logged in");
        getLocation();
      } else {
        print("not logged in");
      }
    });
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

  @override
  Widget build(BuildContext context) {
    dates.clear();
    for (int i = 0; i < 4; i++) {
      final date = _currentDate.add(Duration(days: i));
      dates.add(
        _dayFormatter.format(date),
        // _monthFormatter.format(date),
      );
    }
    print('DATES ------- $dates');
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
              backgroundImage: AssetImage('assets/operator_app_logo.png'),
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
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[0],
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[1],
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[2],
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[3],
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: Text('10AM to 11AM'),
                      trailing: ElevatedButton(
                        child: Text('Details'),
                        onPressed: () {},
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xFFF23F44)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                      ),
                      tileColor: Color(0xffffffff),
                      leading: Icon(
                        Icons.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('11AM to 12AM'),
                      trailing: ElevatedButton(
                        child: Text('Vacant'),
                        onPressed: () {},
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xffffffff)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                      ),
                      tileColor: Color(0xffffffff),
                      leading: Icon(
                        Icons.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
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
