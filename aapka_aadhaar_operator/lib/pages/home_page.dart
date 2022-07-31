import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
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
  Location currentLocation = Location();
  String userid = '';

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
    currentLocation.onLocationChanged.listen((LocationData loc) {
      print(loc.latitude);
      print(loc.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
