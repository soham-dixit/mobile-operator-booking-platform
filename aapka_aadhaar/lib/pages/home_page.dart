import 'dart:async';
import 'dart:io';
import 'package:aapka_aadhaar/pages/book_slots.dart';
import 'package:aapka_aadhaar/pages/booking_details.dart';
import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:aapka_aadhaar/pages/operator_verification.dart';
import 'package:aapka_aadhaar/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _controller;
  Location currentLocation = Location();
  Set<Marker> _markers = {};
  late BitmapDescriptor mapMarker, femaleMarker, maleMarker, transgenderMarker;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List latitudes = [];
  List longitudes = [];
  List genders = [];
  List operatorNames = [];
  String? key;
  int operatorRating = 0;
  List dates = [];
  List days = [];
  final _currentDate = DateTime.now();
  final dayFormatter = DateFormat.yMMMd();
  bool firstDay = false, secondDay = false, thirdDay = false, fourthDay = false;
  String? name;
  Set<Circle> _circles = {};
  Timer? timer;
  String? path;
  bool showActive = false;
  List slot = [
    '10_11',
    '11_12',
    '12_1',
    '2_3',
    '3_4',
    '4_5',
    '5_6',
  ];
  String? profileUrl;

  addDates() {
    print('addDates');
    dates.clear();
    for (int i = 0; i < 7; i++) {
      final date = _currentDate.add(Duration(days: i));
      if (DateFormat("EEEE").format(date) != 'Saturday' &&
          DateFormat("EEEE").format(date) != 'Sunday') {
        dates.add(
          dayFormatter.format(date),
          // _monthFormatter.format(date),
        );
      }

      print('Dates ---$dates');

      if (DateFormat("EEEE").format(date) != 'Saturday' &&
          DateFormat("EEEE").format(date) != 'Sunday') {
        days.add(DateFormat("EEEE").format(date));
      }
      //days.add(DateFormat("EEEE").format(date));

      print('DATES ------ $days');
    }
  }

  getOperatorLocation() async {
    print('operators location updated');
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    dynamic keys_list = databaseData['operators'].keys.toList();

    if (databaseData['operators'] != null) {
      for (int i = 0; i < keys_list.length; i++) {
        key = keys_list[i];
        if (databaseData['operators'][keys_list[i]]['loggedin'] == true) {
          if (databaseData['operators'][keys_list[i]]['location']['latitude'] !=
              null) {
            // latitudes.clear();
            latitudes.add(databaseData['operators'][keys_list[i]]['location']
                ['latitude']);
            print('leng ${latitudes.length}');
          }
          if (databaseData['operators'][keys_list[i]]['location']
                  ['longitude'] !=
              null) {
            longitudes.add(databaseData['operators'][keys_list[i]]['location']
                ['longitude']);
            print(longitudes);
          }
          if (databaseData['operators'][keys_list[i]]['gender'] != null) {
            genders.add(databaseData['operators'][keys_list[i]]['gender']);
          }
          if (databaseData['operators'][keys_list[i]]['fullname'] != null) {
            operatorNames
                .add(databaseData['operators'][keys_list[i]]['fullname']);
          }
        }
      }
      int count = 0;
      for (int i = 0; i < latitudes.length; i++) {
        checkMarker() {
          if (genders[i] == 'Male') {
            return maleMarker;
          } else if (genders[i] == 'Female') {
            return femaleMarker;
          } else {
            return transgenderMarker;
          }
        }

        //computer distance between two markers
        //get current user location
        geolocator.Position position =
            await geolocator.Geolocator.getCurrentPosition(
                desiredAccuracy: geolocator.LocationAccuracy.high);
        print("Print position------- $position");

        double distanceInMeters = geolocator.Geolocator.distanceBetween(
            position.latitude, position.longitude, latitudes[i], longitudes[i]);
        print('distance in meters $distanceInMeters');
        if (distanceInMeters <= 3000) {
          count++;
          _markers.add(
            Marker(
              markerId: MarkerId(operatorNames[i]),
              position: LatLng(latitudes[i], longitudes[i]),
              icon: checkMarker(),
              onTap: () async {
                final pref = await SharedPreferences.getInstance();
                pref.setString('operator-key', keys_list[i].toString());
                openDialog();
              },
            ),
          );
        }
      }
      if (count == 0) {
        for (int i = 0; i < latitudes.length; i++) {
          checkMarker() {
            if (genders[i] == 'Male') {
              return maleMarker;
            } else if (genders[i] == 'Female') {
              return femaleMarker;
            } else {
              return transgenderMarker;
            }
          }

          _markers.add(
            Marker(
              markerId: MarkerId(operatorNames[i]),
              position: LatLng(latitudes[i], longitudes[i]),
              icon: checkMarker(),
              onTap: () async {
                final pref = await SharedPreferences.getInstance();
                pref.setString('operator-key', keys_list[i].toString());
                openDialog();
              },
            ),
          );
        }
      }
    }
    getLocation();
  }

  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller
          ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude!, loc.longitude!),
        zoom: 13,
      )));
      print('location updated');
      print(loc.latitude);
      print(loc.longitude);

      setState(() {
        _markers.addAll([
          Marker(
              markerId: MarkerId('User Location'),
              position: LatLng(loc.latitude!, loc.longitude!),
              icon: mapMarker),
        ]);
        _circles.add(
          Circle(
            circleId: CircleId("user circle"),
            center: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
            radius: 3000,
            fillColor: Colors.blue.shade100.withOpacity(0.5),
            strokeColor: Colors.blue.withAlpha(70),
            strokeWidth: 2,
          ),
        );
      });
    });
  }

  void setCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/user-marker.png');
    femaleMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/Female-Operator.png');
    maleMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/Male-Operator.png');
    transgenderMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/Others-Operator.png');
  }

  getAvailablity() async {
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    print('Key $key');
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> slotData = databaseData['operators'][key]['slots'];
      List keys_list = slotData.keys.toList();
      keys_list.sort((a, b) {
        return a.compareTo(b);
      });
      print('key --- $keys_list');
      final _currentDate = DateTime.now();
      final _dayFormatter = DateFormat('dd-MM-yyyy');

      name = databaseData['operators'][key]['fullname'];
      operatorRating = databaseData['operators'][key]['avgRating'] ?? 0;
      if (databaseData['operators'][key]['profileImage'] != null) {
        profileUrl = databaseData['operators'][key]['profileImage'];
      }
      print('profile url $profileUrl');

      if (slotData[keys_list[0]].containsValue(false)) {
        firstDay = true;
      }
      if (slotData[keys_list[1]].containsValue(false)) {
        secondDay = true;
      }
      if (slotData[keys_list[2]].containsValue(false)) {
        thirdDay = true;
      }
      if (slotData[keys_list[3]].containsValue(false)) {
        fourthDay = true;
      }
    }

    return name;
  }

  updateSlots() async {
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    print('OP KEY $key');
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> slotData = databaseData['operators'][key]['slots'];
      List keys_list = slotData.keys.toList();
      keys_list.sort((a, b) {
        return a.compareTo(b);
      });
      print('Day 1$keys_list');
      var _currentDate = DateTime.now();
      final _dayFormatter = DateFormat('dd-MM-yyyy');

      if (_dayFormatter.format(_currentDate) == keys_list[1]) {
        print('executed');
        databaseReference
            .child("operators")
            .child(key.toString())
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

        print('Day 1 final $final_day');

        databaseReference
            .child("operators")
            .child(key.toString())
            .child("slots")
            .update({
          final_day: {
            "10_11": false,
            "11_12": false,
            "12_1": false,
            "2_3": false,
            "3_4": false,
            "4_5": false,
            "5_6": false,
          },
        });

        print('called');

        // databaseReference
        //     .child("operators")
        //     .child(key.toString())
        //     .child("slots")
        //     .update({
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

  getActiveBooking() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    dynamic keys_list = databaseData['operators'].keys.toList();
    if (databaseData['operators'] != null) {
      for (int i = 0; i < keys_list.length; i++) {
        key = keys_list[i];
        Map<dynamic, dynamic> slotData =
            databaseData['operators'][keys_list[i]]['slots'];
        print('slot $slotData');
        List keys_list1 = slotData.keys.toList();
        keys_list1.sort((a, b) {
          return a.compareTo(b);
        });
        print('slot $keys_list1');
        for (int j = 0; j < slot.length; j++) {
          print(
              'slot ${databaseData['operators'][keys_list[i]]['slots'][keys_list1[0]][slot[j]]}');
          if (databaseData['operators'][keys_list[i]]['slots'][keys_list1[0]]
                  [slot[j]] !=
              false) {
            if (databaseData['operators'][keys_list[i]]['slots'][keys_list1[0]]
                    [slot[j]]
                .containsValue(uid)) {
              if (databaseData['operators'][keys_list[i]]['slots']
                      [keys_list1[0]][slot[j]]['status'] ==
                  'pending') {
                print(
                    'slot ${databaseData['operators'][keys_list[i]]['slots'][keys_list1[0]][slot[j]]}');
                showActive = true;
              } else {
                showActive = false;
              }
            }
          }
        }
      }
    }
    print('show active $showActive');
  }

  saveUid() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid-user', uid);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (FirebaseAuth.instance.currentUser != null) {
        print("logged in");
        getLocation();
        setCustomMarker();
      } else {
        print("not logged in");
      }
    });
    getActiveBooking();
    saveUid();
    timer = Timer.periodic(
        Duration(seconds: 3), (Timer t) => getOperatorLocation());
    addDates();
    // checkOperatorPhoto();
  }

  // checkOperatorPhoto() async {
  //   final pref = await SharedPreferences.getInstance();
  //   path = pref.getString('profile-img');
  //   print('profile ${path}');
  // }

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
        if (databaseData['operators'][key]['slots'][keys_list1[0]][slot[i]] !=
            false) {
          index = databaseData['operators'][key]['slots'][keys_list1[0]]
              [slot[i]]['args'][0];
          day = databaseData['operators'][key]['slots'][keys_list1[0]][slot[i]]
              ['args'][1];
        }
      }
      print('uid 1 $index');
      print('uid 2 $day');
      // index = databaseData['operators'][]
    }
  }

  checkTime(){
    if(DateTime.now().hour > 12){
      return 'pm';
    }else{
      return 'am';
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // getLocation();
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     null;
      //   },
      //   child: Icon(
      //     Icons.history,
      //   ),
      // ),
      bottomNavigationBar: showActive
          ? InkWell(
              onTap: () async {
                getArgs().whenComplete(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookingDetails(),
                        settings: RouteSettings(arguments: [index, day])),
                  );
                });
              },
              child: Container(
                width: double.infinity,
                color: Color(0xFFF23F44),
                height: 50,
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      Text(
                        'Check your appointment status here',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.navigate_next)
                    ],
                  ),
                ),
              ),
            )
          : null,
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
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(19.0760, 72.8777),
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
            circles: _circles,
          ),
        ],
      ),
    );
  }

  Future openDialog() => showDialog(
      context: context,
      builder: (context) {
        getAvailablity();
        updateSlots();
        return FutureBuilder(
          future: getAvailablity(),
          builder: (context, AsyncSnapshot snapshot) {
            String d1 = dates[0].toString();
            String day1 = d1.substring(0, d1.lastIndexOf('20'));
            String d2 = dates[1].toString();
            String day2 = d2.substring(0, d2.lastIndexOf('20'));
            String d3 = dates[2].toString();
            String day3 = d3.substring(0, d3.lastIndexOf('20'));
            String d4 = dates[3].toString();
            String day4 = d4.substring(0, d4.lastIndexOf('20'));
            String y = d1.substring(d1.length - 2);
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('none');
              case ConnectionState.active:
                return Text('active');
              case ConnectionState.waiting:
                return Center(child: CupertinoActivityIndicator());
              case ConnectionState.done:
                return AlertDialog(
                  insetPadding: EdgeInsets.all(20),
                  contentPadding: EdgeInsets.all(10),
                  actions: [
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          print("clicked on book");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookSlots(),
                            ),
                          );
                        },
                        child: Text('BOOK',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(), primary: Color(0xFFF23F44)),
                      ),
                    ),
                  ],
                  title: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder(
                            future: getAvailablity(),
                            builder: (context, AsyncSnapshot snapshot) {
                              print('Snap ${snapshot.data}');
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Text('none');
                                case ConnectionState.active:
                                  return Text('active');
                                case ConnectionState.waiting:
                                  return Center(
                                      child: CupertinoActivityIndicator());
                                case ConnectionState.done:
                                  return Row(
                                    children: [
                                      Column(
                                        children: [
                                          Text(name.toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          RatingBarIndicator(
                                            rating: operatorRating.toDouble(),
                                            itemBuilder: (context, index) =>
                                                Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 22.0,
                                            direction: Axis.horizontal,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 100,
                                      ),
                                      CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: profileUrl != null
                                            ? NetworkImage(
                                                profileUrl.toString())
                                            : AssetImage(
                                                    'assets/logo/profile.png')
                                                as ImageProvider,
                                      ),
                                    ],
                                  );
                              }
                            }),
                      ],
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        color: Color(0xFF808080),
                        thickness: 1,
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(day1 + y,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12)),
                                    Text(days[0],
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10)),
                                    Icon(Icons.circle,
                                        size: 20,
                                        color: firstDay
                                            ? Color(0xFF7FD958)
                                            : Color(0xFFF23F44)),
                                    firstDay
                                        ? Text("Available",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12))
                                        : Text("Unvailable",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 14.0,
                                height: 80.0,
                                child: VerticalDivider(
                                  thickness: 1,
                                  width: 20,
                                  color: Color(0xFF808080),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(day2 + y,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12)),
                                    Text(days[1],
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10)),
                                    Icon(Icons.circle,
                                        size: 20,
                                        color: secondDay
                                            ? Color(0xFF7FD958)
                                            : Color(0xFFF23F44)),
                                    secondDay
                                        ? Text("Available",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12))
                                        : Text("Unvailable",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 14.0,
                                height: 80.0,
                                child: VerticalDivider(
                                  thickness: 1,
                                  width: 20,
                                  color: Color(0xFF808080),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(day3 + y,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12)),
                                    Text(days[2],
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10)),
                                    Icon(Icons.circle,
                                        size: 20,
                                        color: thirdDay
                                            ? Color(0xFF7FD958)
                                            : Color(0xFFF23F44)),
                                    thirdDay
                                        ? Text("Available",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12))
                                        : Text("Unvailable",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 14.0,
                                height: 80.0,
                                child: VerticalDivider(
                                  thickness: 1,
                                  width: 20,
                                  color: Color(0xFF808080),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(day4 + y,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12)),
                                    Text(days[3],
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10)),
                                    Icon(Icons.circle,
                                        size: 20,
                                        color: fourthDay
                                            ? Color(0xFF7FD958)
                                            : Color(0xFFF23F44)),
                                    fourthDay
                                        ? Text("Available",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12))
                                        : Text("Unvailable",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12)),
                                  ],
                                ),
                              ),
                            ]),
                            Divider(
                              color: Color(0xFF808080),
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
            }
          },
        );
      });
}
