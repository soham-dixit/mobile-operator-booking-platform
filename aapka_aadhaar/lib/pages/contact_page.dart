import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBF9F6),
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Color(0xFFF23F44),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                    title: Text('Toll Free: 1947'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.link,
                      color: Colors.black,
                    ),
                    title: Text('https://uidai.gov.in/contact-support/have-any-questions.html'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.mail_outline_rounded,
                      color: Colors.black,
                    ),
                    title: Text('help@uidai.gov.in'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.black,
                    ),
                    title: Text('Government of India Bangla Sahib Rd, Behind Kali Mandir, Gole Market, New Delhi - 110001'),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {}, 
            label: Text('Register a Complaint'),
            icon: Icon(
              Icons.gpp_bad,
            ),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white),
              backgroundColor:
                  MaterialStateProperty.all(Color(0xFFF23F44)),
              shape: MaterialStateProperty.all<
                  RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {}, 
            label: Text('Check Complaint Status'),
            icon: Icon(
              Icons.task_alt,
            ),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<
                  RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
