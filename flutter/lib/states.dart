import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Status extends StatefulWidget {
  Status({Key key}) : super(key: key);
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  States states = States(sta: []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  Future<Null> _refresh() {
    return fetchStates().then((_sta) {
      setState(() => states = _sta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return (RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: (states.sta.length != 0)
            ? ListView.builder(
                itemCount: states.sta.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          height: 60,
                          child: Row(children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                    '${states.sta[index].name} ${states.sta[index].si}',
                                    style: TextStyle(
                                        color: (states.sta[index].alarm == '1')
                                            ? Colors.red
                                            : Colors.black)),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: (states.sta[index].type == 'bool')
                                    ? (states.sta[index].value == '1')
                                        ? Text("ON ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    (states.sta[index].alarm ==
                                                            '1')
                                                        ? Colors.red
                                                        : Colors.black,
                                                fontSize: 24))
                                        : Text("OFF",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    (states.sta[index].alarm ==
                                                            '1')
                                                        ? Colors.red
                                                        : Colors.black))
                                    : Text("${states.sta[index].value}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (states.sta[index].alarm == '1')
                                                    ? Colors.red
                                                    : Colors.black))),
                          ])));
                })
            : (Center(child: Text('No states available')))));
  }
}

class Stat {
  final String name;
  final String value;
  final String alarm;
  final String visible;
  final String type;
  final String si;
  const Stat(
      this.name, this.value, this.alarm, this.visible, this.type, this.si);
}

Future<States> fetchStates() async {
  try {
    final response = await http
        .get('http://' + globals.ipAdr + '/awp/localControl/states.io')
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      print('is 200');
      return States.fromJson(jsonDecode(response.body));
    }
  } catch (e) {
    print('error');
    print(e);
    return States(sta: []);
  }
  print('Nothing happend');
  return States(sta: []);
}

class States {
  final List<Stat> sta;

  States({this.sta});
  factory States.fromJson(Map<String, dynamic> json) {
    List li = [
      'sta00',
      'sta01',
      'sta02',
      'sta03',
      'sta04',
      'sta05',
      'sta06',
      'sta07',
      'sta08',
      'sta09',
    ];
    print(li);
    List<Stat> statusList = [];
    for (var i = 0; i < li.length; i++) {
      print(json[li[i]]['visible'] == '1');
      if (json[li[i]]['visible'] == '1') {
        print(json[li[i]]['name']);
        statusList.add(Stat(
            json[li[i]]['name']
                .replaceAll(r"&#x27;", "")
                .replaceAll(r"&#x20;", " "),
            json[li[i]]['value'],
            json[li[i]]['alarm'],
            json[li[i]]['visible'],
            json[li[i]]['type'].replaceAll(r"&#x27;", ""),
            json[li[i]]['si']
                .replaceAll(r"&#x27;", "")
                .replaceAll(r"&#x28;", "(")
                .replaceAll(r"&#x29;", ")")
                .replaceAll(r"&#x20;", " ")));
      }
    }
    return States(sta: statusList);
  }
}
