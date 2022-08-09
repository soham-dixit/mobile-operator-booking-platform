import 'package:aapka_aadhaar/pages/book_slots.dart';
import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  late BitmapDescriptor mapMarker, femaleMarker, maleMarker;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List latitudes = [];
  List longitudes = [];
  List genders = [];
  List operatorNames = [];
  String? key;
  List dates = [];
  List days = [];
  final _currentDate = DateTime.now();
  final dayFormatter = DateFormat.yMMMd();
  bool firstDay = false, secondDay = false, thirdDay = false, fourthDay = false;
  String? name;
  Set<Circle> _circles = {};

  addDates() {
    dates.clear();
    for (int i = 0; i < 4; i++) {
      final date = _currentDate.add(Duration(days: i));
      dates.add(
        dayFormatter.format(date),
        // _monthFormatter.format(date),
      );
      days.add(DateFormat("EEEE").format(date));
      print('DATES ------ $days');
    }
  }

  getOperatorLocation() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      dynamic keys_list = databaseData['operators'].keys.toList();
      for (int i = 0; i < keys_list.length; i++) {
        key = keys_list[i];
        if (databaseData['operators'][keys_list[i]]['location']['latitude'] !=
            null) {
          latitudes.add(
              databaseData['operators'][keys_list[i]]['location']['latitude']);
        }
        if (databaseData['operators'][keys_list[i]]['location']['longitude'] !=
            null) {
          longitudes.add(
              databaseData['operators'][keys_list[i]]['location']['longitude']);
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

      for (int i = 0; i < latitudes.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId(operatorNames[i]),
            position: LatLng(latitudes[i], longitudes[i]),
            icon: genders[i] == 'Male' ? maleMarker : femaleMarker,
            onTap: () async {
              final pref = await SharedPreferences.getInstance();
              pref.setString('operator-key', key.toString());
              print("ontap");
              openDialog();
            },
          ),
        );
      }
    }
  }

  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller
          ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
        zoom: 12,
      )));
      print(loc.latitude);
      print(loc.longitude);

      setState(() {
        _markers.addAll([
          Marker(
              markerId: MarkerId('User Location'),
              position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
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
  }

  getAvailablity() async {
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('operator-key');
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> slotData = databaseData['operators'][key]['slots'];
      dynamic keys_list = slotData.keys.toList();
      name = databaseData['operators'][key]['fullname'];
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
  }

  @override
  void initState() {
    super.initState();
    getOperatorLocation();
    addDates();
    getAvailablity();
    setState(() {
      getLocation();
      setCustomMarker();
      if (FirebaseAuth.instance.currentUser != null) {
        print("logged in");
      } else {
        print("not logged in");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // getLocation();
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
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
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
      builder: (context) => AlertDialog(
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
                      style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(), primary: Color(0xFFF23F44)),
                ),
              ),
            ],
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: name == ''
                        ? Center(child: CupertinoActivityIndicator())
                        : Text(
                            name.toString(),
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  // SizedBox(
                  //   width: 80.0,
                  // ),
                  Expanded(
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFF23F44),
                    ),
                  ),
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
                              Text(dates[0],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text(days[0],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20,
                                  color: firstDay
                                      ? Color(0xFF7FD958)
                                      : Color(0xFFF23F44)),
                              firstDay
                                  ? Text("Available",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12))
                                  : Text("Unvailable",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12)),
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
                              Text(dates[1],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text(days[1],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20,
                                  color: secondDay
                                      ? Color(0xFF7FD958)
                                      : Color(0xFFF23F44)),
                              secondDay
                                  ? Text("Available",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12))
                                  : Text("Unvailable",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12)),
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
                              Text(dates[2],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text(days[2],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20,
                                  color: thirdDay
                                      ? Color(0xFF7FD958)
                                      : Color(0xFFF23F44)),
                              thirdDay
                                  ? Text("Available",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12))
                                  : Text("Unvailable",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12)),
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
                              Text(dates[3],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text(days[3],
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20,
                                  color: fourthDay
                                      ? Color(0xFF7FD958)
                                      : Color(0xFFF23F44)),
                              fourthDay
                                  ? Text("Available",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12))
                                  : Text("Unvailable",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 12)),
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
          ));
}
