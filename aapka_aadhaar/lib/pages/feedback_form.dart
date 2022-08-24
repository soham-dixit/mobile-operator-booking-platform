import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:form_field_validator/form_field_validator.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key}) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController description = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final nameValidator = MultiValidator([
    PatternValidator(r'^[a-zA-Z ]*$',
        errorText: 'Please Enter a valid Full Name'),
    RequiredValidator(errorText: 'Please Enter a valid Full Name')
  ]);

  final mobileValidator = MultiValidator([
    RequiredValidator(errorText: 'Please enter a mobile number!!'),
    PatternValidator(r'^[6-9]\d{9}$',
        errorText: 'Please Enter a valid 10 digit Mobile Number')
  ]);

  final descriptionValidator =
      MultiValidator([RequiredValidator(errorText: 'Please Enter an Address')]);

  final emailValidator = MultiValidator([
    EmailValidator(errorText: 'Please Enter a valid Email ID'),
    RequiredValidator(errorText: 'Please Enter a valid Email ID')
  ]);

  submitForm() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    final uid = user.uid;

    var data = {
      "name": name.text,
      "email": email.text,
      "phoneNumber": phone.text,
      "intention": _value,
      "description": description.text
    };

    databaseReference.child('feedbacks').child(uid).push().set(data);
    final snackBar = SnackBar(
      content: const Text(
        'Your feedback has been submitted successfully!',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: name,
                            keyboardType: TextInputType.name,
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
                            validator: nameValidator,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
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
                            validator: emailValidator,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          TextFormField(
                            controller: phone,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
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
                            validator: mobileValidator,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            validator: descriptionValidator,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.text,
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
                                  if (formKey.currentState!.validate()) {
                                    submitForm();
                                  }
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
                      ),
                    )))
          ]),
        ));
  }
}
