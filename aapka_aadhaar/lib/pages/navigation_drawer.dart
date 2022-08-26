import 'dart:io';

import 'package:aapka_aadhaar/authentication/login_page.dart';
import 'package:aapka_aadhaar/pages/about_us.dart';
import 'package:aapka_aadhaar/pages/booking_details.dart';
import 'package:aapka_aadhaar/pages/home_page.dart';
import 'package:aapka_aadhaar/pages/intro_carousel.dart';
import 'package:aapka_aadhaar/pages/press-releases.dart';
import 'package:aapka_aadhaar/pages/contact_page.dart';
import 'package:aapka_aadhaar/pages/previous_bookings.dart';
import 'package:aapka_aadhaar/pages/profile.dart';
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

  getData() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.once();
    final FirebaseAuth auth = FirebaseAuth.instance;
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    final keys_list = databaseData['users'].keys.toList();
    final User user = await auth.currentUser!;
    final uid = user.uid;
    print('uid -- $uid');
    if (databaseData['users'] != null && keys_list.contains(uid)) {
      info.add(databaseData['users'][uid]['fullname']);
      print(info);
      return info;
    } else {
      info.add('Guest, Please Register');
      return info;
    }

    //    final databaseReference = FirebaseDatabase.instance.ref();
    // DatabaseEvent event = await databaseReference.once();
    // final FirebaseAuth auth = FirebaseAuth.instance;
    // Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    // final keys_list = databaseData['users'].keys.toList();
    // final User user = await auth.currentUser!;
    // final uid = user.uid;
    // print('uid -- $uid');
    // if (databaseData['users'] != null && keys_list.contains(uid)) {

    // } else {
    //   data = getData1();
    // }
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

  pressReleaseRedirect(BuildContext context) {
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
            builder: (context) => PressReleases(),
          ));
    });
  }

  previousBookingsRedirect(BuildContext context) {
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
            builder: (context) => PreviousBookings(),
          ));
    });
  }

  logout(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        });
    Future.delayed(Duration(seconds: 1), () async {
      FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('uid-user');
      print("logged out");
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      print("logged in");
      getData();
    } else {
      print("Not logged in");
    }
    data = getData();
    checkPreviousPhoto();
  }

  // checkUser() async {

  // }

  // getData1() {
  //   info.add('null');
  // }

  checkPreviousPhoto() async {
    final pref = await SharedPreferences.getInstance();
    path = pref.getString('profile-img');
    print('profile ${path}');
  }

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
                          snapshot.data[0] == 'Guest, Please Register'
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()))
                              : Navigator.push(
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
                                backgroundImage: path == null
                                    ? AssetImage('assets/logo/profile.png')
                                        as ImageProvider
                                    : FileImage(File(path.toString())),
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
//  FutureBuilder(
//                     future: data,
//                     builder: (context, AsyncSnapshot snapshot) {
//                       switch (snapshot.connectionState) {
//                         case ConnectionState.waiting:
//                           return Padding(
//                               padding: EdgeInsets.all(10),
//                               child: CupertinoActivityIndicator());
//                         case ConnectionState.none:
//                           return Text('none');
//                         case ConnectionState.active:
//                           return Text('active');
//                         case ConnectionState.done:
//                           if (snapshot.data[0] == 'null') {
//                             return GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => Profile()));
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Text(
//                                       snapshot.data[0],
//                                       style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           } else {
//                             return GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => Profile()));
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundImage: path == null
//                                           ? AssetImage(
//                                                   'assets/logo/profile.png')
//                                               as ImageProvider
//                                           : FileImage(File(path.toString())),
//                                       radius: 45,
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Text(
//                                       snapshot.data[0],
//                                       style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }
//                       }
//
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
                previousBookingsRedirect(context);
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
                }),
            SizedBox(
              height: 11,
            ),
            buildMenuItem(
              text: 'About Us',
              icon: Icons.person,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutUs()));
              },
            ),
            SizedBox(
              height: 11,
            ),
            buildMenuItem(
              text: 'Recent Blogs',
              icon: Icons.chat,
              onTap: () {
                pressReleaseRedirect(context);
              },
            ),
            SizedBox(
              height: 11,
            ),
            buildMenuItem(
              text: 'How to Use?',
              icon: Icons.info_outline,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IntroCarousel()));
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
                    onPressed: () {
                      logout(context);
                    },
                    child: Text('Log out'),
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(), primary: Color(0xFFF23F44)),
                  );

                  AlertDialog alert = AlertDialog(
                    title: const Text("Are you sure you want to log out?",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 18)),
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
