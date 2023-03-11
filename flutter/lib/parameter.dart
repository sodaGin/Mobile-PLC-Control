import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

class Para extends StatefulWidget {
  Para({Key key}) : super(key: key);

  @override
  _ParameterState createState() => _ParameterState();
}

class _ParameterState extends State<Para> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  // ignore: unused_field
  Timer _timer;
  Parameters parameters = Parameters(par: []);
  // ignore: unused_field
  Future<http.Response> _futureFunction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  Future<Null> _refresh() {
    return fetchParameters().then((_fct) {
      setState(() => parameters = _fct);
    });
  }

  refreshDelay() {
    _timer = new Timer(const Duration(milliseconds: 300), () {
      _refresh();
    });
  }

  getBool(index) {
    return Container(
        height: 80,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Container(
                  width: double.infinity,
                  child: Text(parameters.par[index].name)),
            ),
            Expanded(
              flex: 3,
              child: Container(
                  width: double.infinity,
                  height: 70,
                  padding: EdgeInsets.all(5.0),
                  child: Checkbox(
                      value: (parameters.par[index].value == '1'),
                      activeColor: Colors.orange[700],
                      onChanged: (bool newValue) {
                        setState(() {
                          _futureFunction = postParameters(
                              parameters.par[index].add,
                              (parameters.par[index].value == '1')
                                  ? 'false'
                                  : 'true');
                          _futureFunction =
                              postParametersNew(parameters.par[index].add);
                          refreshDelay();
                        });
                      })),
            )
          ],
        ));
  }

  getRealInt(index) {
    return Container(
        height: 80,
        padding: EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          child: TextField(
            controller: TextEditingController()
              ..text = parameters.par[index].value,
            onSubmitted: (text) => {
              setState(() {
                _futureFunction =
                    postParameters(parameters.par[index].add, text);
                _futureFunction = postParametersNew(parameters.par[index].add);
                refreshDelay();
              }),
            },
            decoration: new InputDecoration(
              labelText:
                  '${parameters.par[index].name} ${parameters.par[index].si}',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              (parameters.par[index].type == 'real')
                  ? FilteringTextInputFormatter.allow(RegExp(r"^\d+\.?\d{0,2}"))
                  : FilteringTextInputFormatter.digitsOnly
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return (RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: (parameters.par.length != 0)
            ? ListView.builder(
                padding: EdgeInsets.fromLTRB(3, 12, 3, 3),
                itemCount: parameters.par.length,
                itemBuilder: (BuildContext context, int index) {
                  if (parameters.par[index].type == 'bool') {
                    return getBool(index);
                  }
                  if (parameters.par[index].type == 'real') {
                    return getRealInt(index);
                  }
                  if (parameters.par[index].type == 'int') {
                    return getRealInt(index);
                  }
                  return null;
                })
            : (Center(child: Text('No parameter available')))));
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Param {
  final String name;
  final String value;
  final String input;
  final String locked;
  final String min;
  final String max;
  final String visible;
  final String newVal;
  final String type;
  final String add;
  final String si;
  const Param(this.name, this.value, this.input, this.locked, this.min,
      this.max, this.visible, this.newVal, this.type, this.add, this.si);
}

Future<Parameters> fetchParameters() async {
  try {
    final response = await http
        .get('http://' + globals.ipAdr + '/awp/localControl/parameter.io')
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(response.body);
      return Parameters.fromJson(jsonDecode(response.body));
    }
  } catch (e) {
    return Parameters(par: []);
  }
  return Parameters(par: []);
}

Future<http.Response> postParametersNew(String pa) async {
  var url = 'http://' + globals.ipAdr + '/awp/localControl/parameter_new.io';
  Map data = {'"webserverData".' + pa + '.new': 'true'};
  var response = await http.post(url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: data);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return null;
  }
  return null;
}

Future<http.Response> postParameters(String pa, input) async {
  var url = 'http://' + globals.ipAdr + '/awp/localControl/parameter_input.io';
  Map data = {'"webserverData".' + pa + '.input': input};

  var response = await http.post(url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: data);

  if (response.statusCode == 200) {}
  return null;
}

class Parameters {
  final List<Param> par;
  Parameters({this.par});
  factory Parameters.fromJson(Map<String, dynamic> json) {
    List li = [
      'par00',
      'par01',
      'par02',
      'par03',
      'par04',
      'par05',
      'par06',
      'par07',
      'par08',
      'par09',
    ];
    List<Param> parameterList = new List();
    for (var i = 0; i < li.length; i++) {
      print(json[li[i]]['visible']);
      if (json[li[i]]['visible'] == '1') {
        print('in');
        parameterList.add(Param(
            json[li[i]]['name']
                .replaceAll(r"&#x27;", "")
                .replaceAll(r"&#x20;", " "),
            json[li[i]]['value'],
            json[li[i]]['input'],
            json[li[i]]['locked'],
            json[li[i]]['min'],
            json[li[i]]['max'],
            json[li[i]]['visible'],
            json[li[i]]['newVal'],
            json[li[i]]['type'].replaceAll(r"&#x27;", ""),
            li[i],
            json[li[i]]['si']
                .replaceAll(r"&#x27;", "")
                .replaceAll(r"&#x28;", "(")
                .replaceAll(r"&#x29;", ")")
                .replaceAll(r"&#x20;", " ")));
      }
    }
    print(parameterList);
    return Parameters(par: parameterList);
  }
}
