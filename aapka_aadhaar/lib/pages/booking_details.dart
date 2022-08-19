import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
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
  final list = [];
  String opName = '';
  String opPhone = '';
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
    list.addAll([name, phone, address, service, i, date]);
    print(list);
    return list;
  }

  void cancelBooking(BuildContext context) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    if(cancelBookingSlot>3){
      databaseReference.child('operators').child(key!).child('slots').child(cancelBookingDate).child(slot[cancelBookingSlot-1]).remove();
    }
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
                        SizedBox(
                          height: 20,
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
                          height: 15,
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
                          height: 90,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Widget noButton = FlatButton(
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
