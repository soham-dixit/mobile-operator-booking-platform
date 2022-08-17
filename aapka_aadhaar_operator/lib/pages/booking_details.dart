import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({Key? key}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final list = [];
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
    list.addAll([name, phone, address, service, i, date]);
    print(list);
    return list;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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
                height: 11,
              ),
              Text(
                'Name',
                textAlign: TextAlign.left,
              ),
              TextFormField(
                readOnly: true,
              ),
              SizedBox(
                height: 11,
              ),
              Text(
                'Contact Number',
                textAlign: TextAlign.left,
              ),
              TextFormField(
                readOnly: true,
              ),
              SizedBox(
                height: 11,
              ),
              Text(
                'Address',
                textAlign: TextAlign.left,
              ),
              TextFormField(
                maxLines: null,
                readOnly: true,
              ),
              SizedBox(
                height: 11,
              ),
              Text(
                'Purpose',
                textAlign: TextAlign.left,
              ),
              TextFormField(
                maxLines: null,
                readOnly: true,
              ),
              SizedBox(
                height: 70,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFFFFFFFF)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFFFFFFFF)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFFF23F44)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
      ),
    );
  }
}
