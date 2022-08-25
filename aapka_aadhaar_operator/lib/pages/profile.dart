import 'dart:io';

import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String operatorName = '';
  String operatorPhone = '';
  String operatorEmail = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? path;
  late String url = '';

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
      operatorName = databaseData['operators'][uid]['fullname'];
      operatorPhone = databaseData['operators'][uid]['phoneNumber'];
      operatorEmail = databaseData['operators'][uid]['email'];
      if (databaseData['operators'][uid]['profileImage'] != null) {
        url = databaseData['operators'][uid]['profileImage'];
      }
    });
  }

  @override
  void initState() {
    getData();
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(
      source: source,
    );
    // final pref = await SharedPreferences.getInstance();
    // pref.setString('profile-img', pickedFile!.path);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
    uploadToFirebase();
  }

  Future<String> uploadFile(File image) async {
    String downloadURL;
    String postId = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("images")
        .child("post_$postId.jpg");
    await ref.putFile(image);
    downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  uploadToFirebase() async {
    url = await uploadFile(
        _imageFile!); // this will upload the file and store url in the variable 'url'
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;
    databaseReference
        .child("operators")
        .child(uid)
        .update({"profileImage": url});
    setState(() {});
  }

  // checkPreviousPhoto() async {
  //   final pref = await SharedPreferences.getInstance();
  //   path = pref.getString('profile-img');
  //   print('profile ${path}');
  // }

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
          child: operatorName == ''
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
                        child: CircleAvatar(
                          backgroundImage: url != null
                              ? NetworkImage(url)
                              : AssetImage('assets/logo/profile.png')
                                  as ImageProvider,
                          // : AssetImage('assets/profile.png')
                          //     as ImageProvider  ,
                          // backgroundImage: AssetImage('assets/profile.png'),
                          backgroundColor: Color(0xFFF23F44),
                          radius: 80,

                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                  radius: 23,
                                  backgroundColor: Color(0xFFF23F44),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      takePhoto(ImageSource.gallery);
                                    },
                                  )
                                ),
                              )
                            ],
                          ),
                        ),
                        // child: InkWell(
                        //   onTap: () {},
                        // )),
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
                        operatorName,
                        style: TextStyle(
                            color: Color(0xFFF23F44),
                            letterSpacing: 2,
                            fontSize: 18),
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
                        operatorEmail,
                        style: TextStyle(
                            color: Color(0xFFF23F44),
                            letterSpacing: 2,
                            fontSize: 18),
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
                        operatorPhone,
                        style: TextStyle(
                            color: Color(0xFFF23F44),
                            letterSpacing: 2,
                            fontSize: 18),
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
