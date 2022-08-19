import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
                backgroundImage: AssetImage('assets/logo/logo.png'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFF23F44),
                    radius: 80,
                  ),
                ),
                Divider(
                  height: 60,
                  color: Colors.grey.shade400,
                  thickness: 1,
                ),
                Text(
                  'NAME',
                  style: TextStyle(
                      color: Colors.black,
                      letterSpacing: 2,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                AutoSizeText(
                  'Kush Agarwal',
                  style: TextStyle(
                      color: Color(0xFFF23F44), letterSpacing: 2, fontSize: 18),
                  maxLines: 1,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'EMAIL ID',
                  style: TextStyle(
                      color: Colors.black,
                      letterSpacing: 2,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                AutoSizeText(
                  'agarwalkushajay@gmail.com',
                  style: TextStyle(
                      color: Color(0xFFF23F44), letterSpacing: 2, fontSize: 18),
                  maxLines: 1,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'MOBILE NUMBER',
                  style: TextStyle(
                      color: Colors.black,
                      letterSpacing: 2,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                AutoSizeText(
                  '9892598604',
                  style: TextStyle(
                      color: Color(0xFFF23F44), letterSpacing: 2, fontSize: 18),
                  maxLines: 1,
                ),
                Divider(
                  height: 40,
                  color: Colors.grey[400],
                  thickness: 1,
                ),
              ],
            ),
          ),
        ));
  }
}