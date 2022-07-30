import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';

class BookingSlots extends StatefulWidget {
  const BookingSlots({Key? key}) : super(key: key);

  @override
  State<BookingSlots> createState() => _BookingSlotsState();
}

class _BookingSlotsState extends State<BookingSlots> {
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
    );
  }
}
