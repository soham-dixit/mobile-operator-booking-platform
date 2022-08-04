import 'package:aapka_aadhaar/pages/book_slots.dart';
import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
            onTap: () {
              print("ontap");
              getSlotData(key);
              openDialog();
            },
          ),
        );
      }
    }
  }

  getSlotData(String? key) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    Map<dynamic, dynamic> operatorData = databaseData['operators'][key];
    print('DATA ----------- ${operatorData['slots']}');
  }

  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller
          ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
        zoom: 16.0,
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

  @override
  void initState() {
    super.initState();
    getOperatorLocation();
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
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(19.0760, 72.8777),
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
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
                children: [
                  Expanded(
                    child: Text(
                      "Name",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 100.0,
                  ),
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
                              Text("28th Jun, 22",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text("Thursday",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20, color: Color(0xFF7FD958)),
                              Text("Available",
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
                              Text("29th Jun, 22",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text("Friday",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20, color: Color(0xFFF23F44)),
                              Text("Unavailable",
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
                              Text("30th Jun, 22",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text("Saturday",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20, color: Color(0xFF7FD958)),
                              Text("Available",
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
                              Text("31st Jun, 22",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Text("Sunday",
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12)),
                              Icon(Icons.circle,
                                  size: 20, color: Color(0xFF7FD958)),
                              Text("Available",
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
