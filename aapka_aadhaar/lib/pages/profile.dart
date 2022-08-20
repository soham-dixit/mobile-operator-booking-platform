import 'dart:io';
import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = '';
  String userPhone = '';
  String userEmail = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? path;

  getData() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    DatabaseEvent event = await databaseReference.once();
    Map<dynamic, dynamic> databaseData = event.snapshot.value as Map;

    // final pref = await SharedPreferences.getInstance();
    // final key = pref.getString('operator-key');
    setState(() {
      userName = databaseData['users'][uid]['fullname'];
      userPhone = databaseData['users'][uid]['phoneNumber'];
      userEmail = databaseData['users'][uid]['email'];
    });
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(
      source: source,
    );
    final pref = await SharedPreferences.getInstance();
    pref.setString('profile-img', pickedFile!.path);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  checkPreviousPhoto() async {
    final pref = await SharedPreferences.getInstance();
    path = pref.getString('profile-img');
    print('profile ${path}');
  }

  @override
  void initState() {
    getData();
    checkPreviousPhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawer(),
        appBar: AppBar(
          backgroundColor: Color(0xFFF23F44),
          foregroundColor: Color(0xFFFFFFFF),
          title: const Text(
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
                backgroundImage: AssetImage('assets/logo/logo.png'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: userName == ''
              ? Container(
                  padding: EdgeInsets.only(top: 300),
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(30, 40, 30, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: InkWell(
                          child: CircleAvatar(
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : path == null
                                    ? AssetImage('assets/logo/profile.png')
                                        as ImageProvider
                                    : FileImage(File(path.toString())),
                            // : AssetImage('assets/profile.png')
                            //     as ImageProvider  ,
                            // backgroundImage: AssetImage('assets/profile.png'),
                            radius: 80,
                          ),
                          onTap: () {
                            takePhoto(ImageSource.gallery);
                          },
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontFamily: 'Poppins'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        userName,
                        style: TextStyle(
                            color: Color(0xFFF23F44),
                            letterSpacing: 2,
                            fontSize: 18,
                            fontFamily: 'Poppins'),
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'EMAIL ID',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontFamily: 'Poppins'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            userEmail,
                            style: TextStyle(
                                color: Color(0xFFF23F44),
                                // letterSpacing: 2,
                                fontSize: 18,
                                fontFamily: 'Poppins'),
                            maxLines: 1,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit),
                            color: Color(0xFFF23F44),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'MOBILE NUMBER',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontFamily: 'Poppins'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            userPhone,
                            style: TextStyle(
                                color: Color(0xFFF23F44),
                                letterSpacing: 2,
                                fontSize: 18,
                                fontFamily: 'Poppins'),
                            maxLines: 1,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit),
                            color: Color(0xFFF23F44),
                          ),
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
