import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:verlichting/credentials.dart';

class ProgrammesSelectorWidget extends StatefulWidget {
  final String title = "Programmes";

  @override
  _ProgrammesSelectorState createState() => _ProgrammesSelectorState();
}

class _ProgrammesSelectorState extends State<ProgrammesSelectorWidget> {
  bool _loading = false;
  List<Programme> _programmes;
  Programme _currentProgramme;

  @override
  void initState() {
    super.initState();

    _loadProgrammes().then((_) { _loadCurrentProgramme(); });
  }

  void _programmesLoaded(List<Programme> programmes) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _programmes = programmes;
      _loading = false;
    });
  }

  Future<void> _loadProgrammes() {
    setState(() {
      _loading = true;
    });

    String basicAuth = 'Basic ' +
        base64Encode(utf8
            .encode('${CONNECTION_INFO.username}:${CONNECTION_INFO.password}'));

    return http.get(CONNECTION_INFO.host + "/available_programmes",
        headers: {HttpHeaders.authorizationHeader: basicAuth}).then((response) {
      List<Programme> programmes = [];

      var programmesJson = jsonDecode(response.body)["availableProgrammes"];

      programmesJson.forEach((key, value) {
        programmes.add(new Programme(key, value));
      });

      _programmesLoaded(programmes);
    });

  }

  _currentProgrammeLoaded(String programmeId) {
    setState(() {
      _currentProgramme = _programmes.firstWhere((programme) { return programme.id == programmeId; });
    });
  }

  _loadCurrentProgramme() {
    String basicAuth = 'Basic ' +
        base64Encode(utf8
            .encode('${CONNECTION_INFO.username}:${CONNECTION_INFO.password}'));

    http.get(CONNECTION_INFO.host + "/current_programme",
        headers: {HttpHeaders.authorizationHeader: basicAuth}).then((response) {

          var programmeJson = jsonDecode(response.body);

          _currentProgrammeLoaded(programmeJson["programme"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    var contents = _programmeButtons();

    contents.add(new RaisedButton(
        onPressed: _loadProgrammes, child: new Text("Reload programmes")));

    if (_loading) {
      return Center(
        child: CircularProgressIndicator()
      );
    } else {
      return Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: contents,
        ),
      );
    }
  }

  List<Widget> _programmeButtons() {
    if (_programmes == null) {
      return [];
    }

    return _programmes.map((programme) {
      var active =
          _currentProgramme != null && (programme.id == _currentProgramme.id);

      if (active) {
        return RaisedButton(
          onPressed: () {
            _programmeSelected(programme);
          },
          child: Text(programme.name),
          color: Colors.blue,
          textColor: Colors.white,
        );
      } else {
        return FlatButton(
          onPressed: () {
            _programmeSelected(programme);
          },
          child: Text(programme.name),
        );
      }
    }).toList();
  }

  _programmeSelected(Programme programme) {
    var url = "/programme/${programme.id}/start";

    String basicAuth = 'Basic ' +
        base64Encode(utf8
            .encode('${CONNECTION_INFO.username}:${CONNECTION_INFO.password}'));

    http.post(CONNECTION_INFO.host + url,
        headers: {HttpHeaders.authorizationHeader: basicAuth}).then((response) {

      setState(() {
        _currentProgramme = programme;
      });
    });
  }
}

class Programme {
  String id;
  String name;

  Programme(this.id, this.name);
}
