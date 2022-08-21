import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviousBookings extends StatefulWidget {
  const PreviousBookings({Key? key}) : super(key: key);

  @override
  State<PreviousBookings> createState() => _PreviousBookingsState();
}



class _PreviousBookingsState extends State<PreviousBookings> {
  List status = [];
  var uid;
  
  List timings = [
    '10:00 - 11:00 AM',
    '11:00 - 12:00 PM',
    '12:00 - 1:00 PM',
    '2:00 - 3:00 PM',
    '3:00 - 4:00 PM',
    '4:00 - 5:00 PM',
    '5:00 - 6:00 PM'
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

  getData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    uid = user.uid;
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    if (databaseData['previousBookings'] != null) {
      Map<String, dynamic> operatorBookings =
          databaseData['previousBookings'][key];
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
          'Previous Bookings',
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 30,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Previous Bookings',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ],
            ),
            SizedBox(
              height: 22,
            ),
            FutureBuilder(
                future: getData(),
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
                            return Card(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            softWrap: true,
                                            textAlign: TextAlign.justify,
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                    text: 'Date: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                  text: '15/08/2022',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            softWrap: true,
                                            textAlign: TextAlign.justify,
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                    text: 'Time: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                  text: '15:00 PM',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    RichText(
                                      softWrap: true,
                                      textAlign: TextAlign.justify,
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                              text: 'Operator Name: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                            text: 'Operator Name',
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    RichText(
                                      softWrap: true,
                                      textAlign: TextAlign.justify,
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                              text: 'Purpose: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                            text: 'Updation/Enrollment',
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    RichText(
                                      softWrap: true,
                                      textAlign: TextAlign.justify,
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                              text: 'Status: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: 'Completed',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                          TextSpan(
                                              text: '/',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          TextSpan(
                                              text: 'Cancelled',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        RichText(
                                          softWrap: true,
                                          textAlign: TextAlign.justify,
                                          text: TextSpan(
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text: 'Rating: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        RatingBarIndicator(
                                          rating: 3,
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          itemCount: 5,
                                          itemSize: 20.0,
                                          direction: Axis.horizontal,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                  }
                })
          ],
        ),
      ),
    );
  }
}
