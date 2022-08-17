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
                  style: TextStyle(color: Colors.grey, letterSpacing: 2),
                ),
                SizedBox(
                  height: 10,
                ),
                AutoSizeText(
                  'Kush Agarwal',
                  style: TextStyle(
                      color: Color(0xFFF23F44), letterSpacing: 2, fontSize: 28),
                  maxLines: 1,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'EMAIL ID',
                  style: TextStyle(color: Colors.grey, letterSpacing: 2),
                ),
                SizedBox(
                  height: 10,
                ),
                AutoSizeText(
                  'agarwalkushajay@gmail.com',
                  style: TextStyle(
                      color: Color(0xFFF23F44), letterSpacing: 2, fontSize: 28),
                  maxLines: 1,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOBILE NUMBER',
                          style:
                              TextStyle(color: Colors.grey, letterSpacing: 2),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        AutoSizeText(
                          '9892598604',
                          style: TextStyle(
                              color: Color(0xFFF23F44),
                              letterSpacing: 2,
                              fontSize: 28),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.edit),
                      color: Color(0xFFF23F44),
                    )
                  ],
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
