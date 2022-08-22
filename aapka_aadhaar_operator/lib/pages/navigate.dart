import 'dart:async';

import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
import 'package:aapka_aadhaar_operator/services/network_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class NavigateToUser extends StatefulWidget {
  const NavigateToUser({Key? key}) : super(key: key);

  @override
  State<NavigateToUser> createState() => _NavigateToUserState();
}

class _NavigateToUserState extends State<NavigateToUser> {
  final Completer<GoogleMapController> mapController = Completer();
  List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};
  final Set<Marker> markers = {};
  var data;
  var duration, distance;
  Location currentLocation = Location();
  var location;

  double op_lat = 0.0;
  double op_lng = 0.0;
  double u_lat = 0.0;
  double u_lng = 0.0;

  getData() async {
    final pref = await SharedPreferences.getInstance();
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    String user_id = '';
    String? date = pref.getString('date');
    String? slot = pref.getString('time');
    print('date slot ---- $date $slot');
    if (databaseData['operators'] != null) {
      Map<dynamic, dynamic> locData =
          databaseData['operators'][uid]['location'];
      op_lat = locData['latitude'];
      op_lng = locData['longitude'];
      user_id = databaseData['operators'][uid]['slots'][date][slot]['user'];
      print('called $op_lat');
      print('called $op_lng');
    }

    if (databaseData['users'] != null) {
      Map<dynamic, dynamic> locData =
          databaseData['users'][user_id]['location'];
      u_lat = locData['latitude'];
      u_lng = locData['longitude'];
      print('user - $u_lat');
      print('user --- $u_lng');
    }
  }

  getCurrentLocation() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    location = await currentLocation.getLocation();

    GoogleMapController gmc = await mapController.future;

    currentLocation.onLocationChanged.listen((newLoc) {
      location = newLoc;
      gmc.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(location.latitude, location.longitude),
          ),
        ),
      );
      databaseReference.child('operators').child(uid).child('location').update(
          {'latitude': location.latitude, 'longitude': location.longitude});
      // databaseReference.child('operators').child(uid).child('location').onValue.listen((event){
      //   var snapshot = event.snapshot;
      // });
      setState(() {
        markers.add(
          Marker(
            infoWindow: InfoWindow(title: 'Live Location'),
            markerId: MarkerId('live'),
            position: LatLng(
              location.latitude,
              location.longitude,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () async {},
          ),
        );
      });
    });
  }

  addMarker() {
    print('called');
    setState(() {
      markers.addAll([
        Marker(
          infoWindow: InfoWindow(title: 'Your location'),
          markerId: MarkerId('Operator'),
          position: LatLng(op_lat, op_lng),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () async {},
        ),
        Marker(
          infoWindow: InfoWindow(title: 'Destination'),
          markerId: MarkerId('User'),
          position: LatLng(u_lat, u_lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () async {},
        ),
        Marker(
          infoWindow: InfoWindow(title: 'Live Location'),
          markerId: MarkerId('live'),
          position: LatLng(
            location.latitude,
            location.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () async {},
        ),
      ]);
    });
  }

  void getJsonData() async {
    NetworkHelper network = NetworkHelper(
      startLat: op_lat,
      startLng: op_lng,
      endLat: u_lat,
      endLng: u_lng,
    );

    try {
      data = await network.getData();
      print('data ${data}');
      duration =
          (data['features'][0]['properties']['summary']['duration']) / 60;
      distance =
          (data['features'][0]['properties']['summary']['distance']) / 1000;
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      setPolyLines();
    } catch (e) {
      print(e);
    }
  }

  setPolyLines() {
    Polyline polyline = Polyline(
      polylineId: PolylineId("polyline"),
      color: Colors.lightBlue,
      width: 5,
      points: polyPoints,
    );
    polyLines.add(polyline);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData().whenComplete(() {
      getCurrentLocation().whenComplete(() {
        addMarker();
      });

      getJsonData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xFFF23F44),
        foregroundColor: Color(0xFFFFFFFF),
        title: Text(
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
              backgroundImage: AssetImage('assets/logo/logo.png'),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(19.0760, 72.8777),
              zoom: 11.5,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController.complete(controller);
            },
            polylines: polyLines,
            markers: markers,
            // Marker(
            //   infoWindow: InfoWindow(title: 'Your location'),
            //   markerId: MarkerId('Operator'),
            //   position: LatLng(op_lat, op_lng),
            //   icon: BitmapDescriptor.defaultMarkerWithHue(
            //       BitmapDescriptor.hueGreen),
            //   onTap: () async {},
            // ),
            // Marker(
            //   infoWindow: InfoWindow(title: 'Destination'),
            //   markerId: MarkerId('User'),
            //   position: LatLng(u_lat, u_lng),
            //   icon: BitmapDescriptor.defaultMarkerWithHue(
            //       BitmapDescriptor.hueRed),
            //   onTap: () async {},
            // )
          ),
          if (duration != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF23F44),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 50.0,
                    )
                  ],
                ),
                child: Text(
                  "${distance.toStringAsFixed(2)} KM, ${duration.toStringAsFixed(2)} Mins",
                  style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontFamily: 'Poppins'),
                ),
              ),
            )
        ],
      ),
    );
  }
}