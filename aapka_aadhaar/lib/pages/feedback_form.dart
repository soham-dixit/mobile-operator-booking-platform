import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key}) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController intention = TextEditingController();
  TextEditingController description = TextEditingController();

  submitForm() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;

    databaseReference.child('feedbacks').child(uid).set({"name": name , "email":email, "phoneNumber": phone , "description" : description});
  }

  String? _value = 'Complaint';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawer(),
        backgroundColor: Color(0xFFFBF9F6),
        appBar: AppBar(
          title: Text(
            'Contact Us',
            style: TextStyle(
              fontFamily: 'Poppins',
              // fontSize: 16
            ),
          ),
          backgroundColor: Color(0xFFF23F44),
          foregroundColor: Colors.white,
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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
                padding: const EdgeInsets.all(28.0),
                child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Name',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Email ID',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        TextFormField(
                          controller: phone,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Mobile Number',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Text(
                          'Intention Of Contact',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  activeColor: Color(0xFFF23F44),
                                  value: 'Complaint',
                                  groupValue: _value,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _value = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Complaint'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  activeColor: Color(0xFFF23F44),
                                  value: 'Feedback',
                                  groupValue: _value,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _value = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Feedback'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  activeColor: Color(0xFFF23F44),
                                  value: 'Suggestion',
                                  groupValue: _value,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _value = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Suggestion'),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        TextFormField(
                          maxLines: null,
                          minLines: 2,
                          controller: description,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Kindly Elaborate',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xFFFFFFFF)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                submitForm();
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xFFF23F44)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )))
          ]),
        ));
  }
}
