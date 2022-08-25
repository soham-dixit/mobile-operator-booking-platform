import 'package:aapka_aadhaar_operator/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
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
                    onTap: contact,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.link,
                      color: Colors.black,
                    ),
                    title: Text(
                        'https://uidai.gov.in/contact-support/have-any-questions.html'),
                    onTap: contactURL,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.mail_outline_rounded,
                      color: Colors.black,
                    ),
                    title: Text('help@uidai.gov.in'),
                    onTap: sendEmail,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.black,
                    ),
                    title: Text(
                        'Government of India Bangla Sahib Rd, Behind Kali Mandir, Gole Market, New Delhi - 110001'),
                    onTap: () => openMap(28.6300847403869, 77.20806041278784),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              launchRegister();
            },
            label: Text('Register a Complaint'),
            icon: Icon(
              Icons.gpp_bad,
            ),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all(Color(0xFFF23F44)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              launchStatus();
            },
            label: Text('Check Complaint Status'),
            icon: Icon(
              Icons.task_alt,
            ),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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

  Future<void> launchRegister() async {
    var url = Uri.parse("https://resident.uidai.gov.in/file-complaint");
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchStatus() async {
    var url = Uri.parse("https://resident.uidai.gov.in/check-complaintstatus");
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  contact() async {
    var url = Uri.parse("tel:1947");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  contactURL() async {
    var url = Uri.parse(
        "https://uidai.gov.in/contact-support/have-any-question.html");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  sendEmail() async {
    var url = Uri.parse("mailto:help@uidai.gov.in");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // openMap(double latitude, double longitude) async {
  //   var googleUrl = Uri.parse(
  //       'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
  //   if (await canLaunchUrl(googleUrl)) {
  //     await launchUrl(googleUrl);
  //   } else {
  //     throw 'Could not open the map.';
  //   }
  // }

  Future<dynamic> openMap(double latitude, double longitude) async {
    var googleUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
