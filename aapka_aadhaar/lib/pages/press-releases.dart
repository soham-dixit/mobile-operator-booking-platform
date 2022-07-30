import 'package:flutter/material.dart';

class PressReleases extends StatefulWidget {
  const PressReleases({Key? key}) : super(key: key);

  @override
  State<PressReleases> createState() => _PressReleasesState();
}

class _PressReleasesState extends State<PressReleases> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Press Releases"),
        backgroundColor: Color(0xFFF23F44),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('UIDAI organizes Workshop on ‘Recent Initiatives for Simplifying Aadhaar usage'),
                  subtitle: Text('1 Jun 2022'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('Clarification on Aadhaar sharing issue by UIDAI'),
                  subtitle: Text('29 May 2022'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('Multiple Ways to establish Veracity of Aadhaar : UIDAI'),
                  subtitle: Text('4 May 2022'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('UIDAI organizes Workshop on ‘Recent Initiatives for Simplifying Aadhaar usage’'),
                  subtitle: Text('22 Apr 2022'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('Digital India Scheme and Aadhaar'),
                  subtitle: Text('30 Mar 2022'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('Inauguration of Gonda, Varanasi, Saharanpur and Moradabad in UP By Minister of State Rajeev Chandrasekhar'),
                  subtitle: Text('21 Dec 2021'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('Inauguration of Gonda, Varanasi, Saharanpur and Moradabad in UP'),
                  subtitle: Text('20 Dec 2021'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
              Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Image(
                    image: AssetImage('./assets/aadhaar-logo.png'),
                    width: 40,
                  ),
                  title: Text('‘Aadhaar 2.0- Ushering the Next Era of Digital Identity and Smart Governance’ workshop from 23rd to 25th November, 2021'),
                  subtitle: Text('25 Nov 2021'),
                  tileColor: Colors.white,
                  onTap: (() {
                    
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
