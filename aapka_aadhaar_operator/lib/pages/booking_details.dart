import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({Key? key}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final list = [];
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

  getData(int i, String date) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final address =
        databaseData['operators'][uid]['slots'][date][slot[i]]['address'];
    final name = databaseData['operators'][uid]['slots'][date][slot[i]]['name'];
    final phone =
        databaseData['operators'][uid]['slots'][date][slot[i]]['phone'];
    final service =
        databaseData['operators'][uid]['slots'][date][slot[i]]['service'];
    list.addAll([name, phone, address, service]);
    print(list);
    return list;
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
                                      Text('21st July, Thursday',
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
                                      Text('4:00 PM to 5:00 PM',
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
                          height: 22,
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
                          height: 22,
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
                          height: 22,
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
                          height: 22,
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
                          height: 70,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFFFFFFF)),
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
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Navigate Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFFFFFFF)),
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
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Notify User For Arrival',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
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
