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

  getOperatorLocation() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      dynamic keys_list = databaseData['operators'].keys.toList();
      for (int i = 0; i < keys_list.length; i++) {
        if (databaseData['operators'][keys_list[i]]['latitude'] != null) {
          latitudes.add(databaseData['operators'][keys_list[i]]['latitude']);
        }
        if (databaseData['operators'][keys_list[i]]['longitude'] != null) {
          longitudes.add(databaseData['operators'][keys_list[i]]['longitude']);
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
            title: Text("Operator Details"),
          ));
}
