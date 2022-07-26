import 'package:aapka_aadhaar/authentication/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future getCurrentUser() async {
    print(auth.currentUser!.displayName);
    print(auth.currentUser!.email);
    setState(() {});
    return auth.currentUser;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color(0xFFFBF9F6),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {},
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
                    auth.currentUser!.displayName != null
                        ? Text(
                            auth.currentUser!.displayName.toString(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Center(
                            child: CupertinoActivityIndicator(),
                          ),
                    auth.currentUser!.email != null
                        ? Text(
                            auth.currentUser!.email.toString(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Center(
                            child: CupertinoActivityIndicator(),
                          ),
                  ],
                ),
              ),
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
              onTap: () {},
            ),
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
              onTap: () {},
            ),
            SizedBox(
              height: 11,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  print("logged out");
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()));
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
