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
          Container(
            padding: EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.phone
                  ),
                  title: Text('Toll Free: 1947'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.link
                  ),
                  title: Text('https://uidai.gov.in/contact-support/have-any-questions.html'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.mail_outline_rounded
                  ),
                  title: Text('help@uidai.gov.in'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.location_on
                  ),
                  title: Text('Government of India Bangla Sahib Rd, Behind Kali Mandir, Gole Market, New Delhi - 110001'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
