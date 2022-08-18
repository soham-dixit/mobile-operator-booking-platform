import 'package:aapka_aadhaar/authentication/login_page.dart';
import 'package:aapka_aadhaar/pages/booking_details.dart';
import 'package:aapka_aadhaar/pages/home_page.dart';
import 'package:aapka_aadhaar/pages/press-releases.dart';
import 'package:aapka_aadhaar/pages/contact_page.dart';
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

  getData() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    print('uid -- $uid');
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['users'] != null) {
      info.add(databaseData['users'][uid]['fullname']);
      info.add(databaseData['users'][uid]['phoneNumber']);
      print(info);
    }
    return info;
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
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
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
                          Navigator.pushReplacement(
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
                              Text(
                                snapshot.data[1],
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
            // GestureDetector(
            //   onTap: () {},
            //   child: Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         CircleAvatar(
            //           backgroundColor: Color(0xFFF23F44),
            //           radius: 45,
            //         ),
            //         SizedBox(
            //           height: 10,
            //         ),
            //         Text(
            //           'userName',
            //           style: TextStyle(
            //             fontFamily: 'Poppins',
            //             fontSize: 18,
            //           ),
            //         ),
            //         Text(
            //           '+91',
            //           style: TextStyle(
            //             fontFamily: 'Poppins',
            //             fontSize: 18,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
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
              onTap: () {},
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
              onTap: () {},
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
              text: 'Booking Details',
              icon: Icons.chat,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetails(),
                    ));
              },
            ),
            // SizedBox(
            //   height: 11,
            // ),
            // buildMenuItem(
            //   text: 'Update Page',
            //   icon: Icons.chat,
            //   onTap: () {
            //     redirectToUpdatePage();
            //   },
            // ),
            // SizedBox(
            //   height: 11,
            // ),
            // buildMenuItem(
            //   text: 'Book Slots (test)',
            //   icon: Icons.book_online,
            //   onTap: () {
            //     //call book slots
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => BookSlots(),
            //       ),
            //     );
            //   },
            // ),
            SizedBox(
              height: 11,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  Widget cancelButton = FlatButton(
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
