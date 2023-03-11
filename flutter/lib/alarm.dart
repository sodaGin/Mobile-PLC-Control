import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlarmMana extends StatelessWidget {
  final List<String> alarm;
  AlarmMana({Key key, @required this.alarm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Alarms'),
        ),
        body: (alarm != [])
            ? ListView.builder(
                itemCount: alarm.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      child: ListTile(
                          title: Text('${alarm[index]}',
                              style: TextStyle(color: Colors.red))));
                })
            : (Center(child: Text('no alarms'))));
  }
}

Future<List<String>> fetchAlarms() async {
  try {
    List<String> alarmList = [];
    print('oin');
    final response = await http
        .get('http://' + globals.ipAdr + '/awp/localControl/alarms.io')
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      var json = (jsonDecode(response.body));
      List li = [
        'alr0',
        'alr1',
        'alr2',
        'alr3',
        'alr4',
        'alr5',
        'alr6',
        'alr7',
        'alr8',
        'alr9',
        'alr10',
        'alr11',
        'alr12',
        'alr13',
        'alr14',
        'alr15',
        'alr16',
        'alr17',
        'alr18',
        'alr19',
      ];
      for (var i = 0; i < li.length; i++) {
        var value = json[li[i]]
            .replaceAll(r"&#x27;", "")
            .replaceAll(r"&#x20;", " ")
            .replaceAll(r"&#x2c;", "");
        if (value != '') {
          alarmList.add(value);
        }
      }
      return alarmList;
    }
  } catch (e) {
    return [];
  }
  return [];
}
