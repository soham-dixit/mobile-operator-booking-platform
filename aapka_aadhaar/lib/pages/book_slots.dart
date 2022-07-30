import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';

class BookSlots extends StatefulWidget {
  const BookSlots({Key? key}) : super(key: key);

  @override
  State<BookSlots> createState() => _BookSlotsState();
}

class _BookSlotsState extends State<BookSlots> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xFFF23F44),
        foregroundColor: Color(0xFFFFFFFF),
        title: Text(
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
              backgroundImage: AssetImage('assets/user_app_logo.png'),
            ),
          ),
        ],
      ),
      body: MyCardWidget(),
    );
  }
}

class MyCardWidget extends StatefulWidget {
  MyCardWidget({Key? key}) : super(key: key);

  @override
  State<MyCardWidget> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardWidget> {
  @override
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: 130,
      height: 90,
      padding: new EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.greenAccent,
        elevation: 10,
        child: ListTile(
          title: Text(
            "10:00 AM - 11:00 AM",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
          ),
        ),
      ),
    ));
  }
}
