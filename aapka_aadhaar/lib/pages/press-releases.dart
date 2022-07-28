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
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Text('Press Release Title'),
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
