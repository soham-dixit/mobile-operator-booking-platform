import 'dart:io';

import 'package:aapka_aadhaar_operator/authentication/login_page.dart';
import 'package:aapka_aadhaar_operator/pages/booking_details.dart';
import 'package:aapka_aadhaar_operator/pages/contact_page.dart';
import 'package:aapka_aadhaar_operator/pages/home_page.dart';
import 'package:aapka_aadhaar_operator/pages/navigate.dart';
import 'package:aapka_aadhaar_operator/pages/previous_bookings.dart';
import 'package:aapka_aadhaar_operator/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List info = [];
  late Future data;
  String? path;
  late String url = '';

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      print("logged in");
      fetchDetails();
    } else {
      print("Not logged in");
    }
    data = fetchDetails();
    // checkPreviousPhoto();
  }

  fetchDetails() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      info.add(databaseData['operators'][uid]['fullname']);
      print(info);
      if (databaseData['operators'][uid]['profileImage'] != null) {
        url = databaseData['operators'][uid]['profileImage'];
      }
    }
    return info;
  }

  void removeLocation() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    databaseReference.child("operators").child(uid).update({"loggedin": false});
  }

  // checkPreviousPhoto() async {
  //   final pref = await SharedPreferences.getInstance();
  //   path = pref.getString('profile-img');
  //   print('profile ${path}');
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color(0xFFFBF9F6),
        child: ListView(
          children: [
            FutureBuilder(
                future: data,
                builder: (context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Padding(
                          padding: EdgeInsets.all(10),
                          child: CupertinoActivityIndicator());
                    case ConnectionState.none:
                      return Text('none');
                    case ConnectionState.active:
                      return Text('active');
                    case ConnectionState.done:
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: url != null
                                    ? NetworkImage(url)
                                    : AssetImage('assets/logo/profile.png')
                                        as ImageProvider,
                                backgroundColor: Color(0xFFF23F44),
                                radius: 45,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data[0],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                  }
                }),
            Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            SizedBox(
              height: 22,
            ),
            buildMenuItem(
              text: 'Home',
              icon: Icons.home,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
            ),
            SizedBox(
              height: 22,
            ),
            buildMenuItem(
              text: 'Previous Bookings',
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PreviousBookings()));
              },
            ),
            SizedBox(
              height: 11,
            ),
            buildMenuItem(
              text: 'Contact Us',
              icon: Icons.call,
              onTap: () {
                contactRedirect(context);
              },
            ),
            SizedBox(
              height: 11,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  Widget cancelButton = TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  );

                  Widget logoutButton = ElevatedButton(
                    onPressed: () async {
                      removeLocation();
                      FirebaseAuth.instance.signOut();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove('uid');
                      print('logged out');
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OperatorLogin()));
                    },
                    child: Text('Log out'),
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(), primary: Color(0xFFF23F44)),
                  );

                  AlertDialog alert = AlertDialog(
                    title: const Text("Are you sure you want to log out?",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 18)),
                    content: const Text(
                        "(Note: You will no longer be available to users looking for operator near your location.)",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Color(0xFFF23F44))),
                    actions: [
                      cancelButton,
                      logoutButton,
                    ],
                  );
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                },
                icon: Icon(Icons.logout),
                label: Text('Log Out'),
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Color(0xFFF23F44)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(
      {required String text,
      required IconData icon,
      required void Function() onTap}) {
    final color = Colors.black;
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}

contactRedirect(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CupertinoActivityIndicator(),
        );
      });
  Future.delayed(Duration(seconds: 1), () {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ContactPage(),
        ));
  });
}
