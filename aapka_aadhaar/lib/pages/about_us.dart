import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      backgroundColor: Color(0xFFFBF9F6),
      appBar: AppBar(
        title: Text(
          'About Us',
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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'About Us',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
              SizedBox(
                height: 22,
              ),
              Text(
                'What and Why Aadhaar?',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                  'Aadhaar is a 12 digit individual identification number issued by UIDAI. It serves as a proof of identity and nationality pan India. It is acceptable throughout the nation and hence, acts as a portable proof of identity that can be verified through Aadhaar authentication on-line anytime, anywhere.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.justify),
              SizedBox(
                height: 11,
              ),
              Divider(
                height: 60,
                color: Colors.grey.shade400,
                thickness: 1,
              ),
              SizedBox(
                height: 11,
              ),
              Text(
                'What we do? ',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                softWrap: true,
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 18, color: Colors.black),
                  children: [
                    TextSpan(
                        text:
                            'UIDAI has initiated home-updating service wherein the operators - officials of Aadhaar, approach your door steps for your Aadhaar updating and enrollment. Aapka Aadhaar is the authorized service provider of UIDAI and Government of India. We serve as a booking platform for citizens to book the operators as per their availability on current day and next three days. The operator shall arrive at your door step at scheduled time with prior notification of them arriving at your location. Asking the operator for the verification pin, shall provide you the confidence in authenticity of the operator. The name'),
                    TextSpan(
                        text: ' Aapka Aadhaar',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            ' suggests that having your Aadhaar updated or enrolled at the ease and comfort is our responsibility. We wish you happy booking and smoother procedure :)')
                  ],
                ),
              ),
              SizedBox(
                height: 22,
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '- Developed and maintained by',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 18),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      ' Code Apocalypse',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 18),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
