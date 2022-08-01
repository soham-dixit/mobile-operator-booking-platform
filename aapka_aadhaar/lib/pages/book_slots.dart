import 'package:aapka_aadhaar/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookSlots extends StatefulWidget {
  const BookSlots({Key? key}) : super(key: key);

  @override
  State<BookSlots> createState() => _BookSlotsState();
}

class _BookSlotsState extends State<BookSlots> {
  final _currentDate = DateTime.now();
  final _dayFormatter = DateFormat('dd-MM-yyyy');
  final _monthFormatter = DateFormat('MMM');
  List dates = [];

  @override
  Widget build(BuildContext context) {
    dates.clear();
    for (int i = 0; i < 4; i++) {
      final date = _currentDate.add(Duration(days: i));
      dates.add(
        _dayFormatter.format(date),
        // _monthFormatter.format(date),
      );
    }

    print('DATES ------- $dates');
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
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[0],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[1],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[2],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dates[3],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TableCalendar(
          //   firstDay: DateTime.parse(dates[0]),
          //   lastDay: DateTime.parse(dates[3]),
          //   focusedDay: DateTime.parse(dates[0]),
          // ),
          // MyCardWidget(time: '10AM - 11AM'),
        ],
      ),
    );
  }
}

class MyCardWidget extends StatefulWidget {
  String? time;

  MyCardWidget({Key? key, this.time}) : super(key: key);

  @override
  State<MyCardWidget> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardWidget> {
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
            widget.time.toString(),
            style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
          ),
        ),
      ),
    ));
  }
}
