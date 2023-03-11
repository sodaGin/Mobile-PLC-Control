import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Funct extends StatefulWidget {
  Funct({Key key}) : super(key: key);

  @override
  _FunctionState createState() => _FunctionState();
}

class _FunctionState extends State<Funct> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  // ignore: unused_field
  Timer _timer;
  Functions functions = Functions(fct: []);
  // ignore: unused_field
  Future<http.Response> _futureFunction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  Future<Null> _refresh() {
    return fetchFunctions().then((_fct) {
      setState(() => functions = _fct);
    });
  }

  refreshDelay() {
    _timer = new Timer(const Duration(milliseconds: 250), () {
      _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return (RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: (functions.fct.length != 0)
            ? ListView.builder(
                itemCount: functions.fct.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: 80,
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: functions.fct[index].locked == '1'
                            ? null
                            : () => {
                                  setState(() {
                                    _futureFunction =
                                        postFunctions(functions.fct[index].add);
                                  }),
                                  refreshDelay()
                                },
                        style: ButtonStyle(
                          backgroundColor: (functions.fct[index].fault == '1')
                              ? MaterialStateProperty.all(Colors.red)
                              : (functions.fct[index].active == '1')
                                  ? MaterialStateProperty.all(Colors.blue)
                                  : MaterialStateProperty.all(Colors.grey[300]),
                        ),
                        child: Text(
                          '${functions.fct[index].name}',
                          style: TextStyle(
                              fontSize: 24,
                              color: functions.fct[index].locked == '1'
                                  ? null
                                  : Colors.black),
                        ),
                      ));
                })
            : (Center(child: Text('No functions available')))));
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Func {
  final String name;
  final String active;
  final String locked;
  final String visible;
  final String fault;
  final String add;
  const Func(
      this.name, this.active, this.locked, this.visible, this.fault, this.add);
}

Future<Functions> fetchFunctions() async {
  try {
    final response = await http
        .get('http://' + globals.ipAdr + '/awp/localControl/functions.io')
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Functions.fromJson(jsonDecode(response.body));
    }
  } catch (e) {
    return Functions(fct: []);
  }
  return Functions(fct: []);
}

Future<http.Response> postFunctions(String func) async {
  var url = 'http://' + globals.ipAdr + '/awp/localControl/function_button.io';
  Map data = {'"webserverData".' + func + '.button': 'true'};
  var response = await http.post(url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: data);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    fetchFunctions();
  }
  return null;
}

class Functions {
  final List<Func> fct;
  Functions({this.fct});
  factory Functions.fromJson(Map<String, dynamic> json) {
    List li = [
      'fct00',
      'fct01',
      'fct02',
      'fct03',
      'fct04',
      'fct05',
      'fct06',
      'fct07',
      'fct08',
      'fct09',
    ];
    List<Func> statusList = [];
    for (var i = 0; i < li.length; i++) {
      if (json[li[i]]['visible'] == '1') {
        statusList.add(Func(
            json[li[i]]['name']
                .replaceAll(r"&#x27;", "")
                .replaceAll(r"&#x20;", " "),
            json[li[i]]['active'],
            json[li[i]]['locked'],
            json[li[i]]['visible'],
            json[li[i]]['fault'],
            li[i]));
      }
    }
    return Functions(fct: statusList);
  }
}
