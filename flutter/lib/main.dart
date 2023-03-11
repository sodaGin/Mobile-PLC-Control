import 'package:flutter/material.dart';
import 'alarm.dart';
import 'states.dart';
import 'functions.dart';
import 'parameter.dart';
import 'globals.dart' as globals;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Box Control',
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MBLocalControl(),
    );
  }
}

class MBLocalControl extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MBLocalControlState();
  }
}

class _MBLocalControlState extends State<MBLocalControl> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      new Status(),
      new Para(),
      new Funct()
    ];
    List<String> ala = [];
    return Scaffold(
      appBar: AppBar(title: Text('Box Control'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notification_important),
          tooltip: 'Settings',
          onPressed: () {
            fetchAlarms().then((_alr) {
              setState(() => ala = _alr);
            }).whenComplete(() => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AlarmMana(alarm: ala)),
                ));
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('PLC IP-Address'),
                      //content:
                      contentPadding: const EdgeInsets.all(25.0),
                      content: new Row(
                        children: <Widget>[
                          Expanded(
                            child: new TextField(
                                autofocus: true,
                                decoration: new InputDecoration(
                                    labelText: globals.ipAdr,
                                    hintText: 'Change IP-Address'),
                                keyboardType: TextInputType.number,
                                onSubmitted: (text) => {
                                      globals.ipAdr = text,
                                    }),
                          ),
                        ],
                      ),
                    ));
          },
        )
      ]),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_sharp),
            label: 'States',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create_sharp),
            label: 'Parameter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow_sharp),
            label: 'Functions',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
