import 'package:aapka_aadhaar_operator/authentication/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static String operatorName = '', operatorEmail = '', operatorPhone = '';

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      print("logged in");
      fetchDetails();
    } else {
      print("Not logged in");
    }
  }

  void fetchDetails() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;
    if (databaseData['operators'] != null) {
      operatorName = databaseData['operators'][uid]['fullname'];
      operatorPhone = databaseData['operators'][uid]['phoneNumber'];
    }
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
                    Text(
                      operatorName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '+91' + ' ' + operatorPhone,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
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
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      SharedPreferences prefs = await SharedPreferences.getInstance();
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
