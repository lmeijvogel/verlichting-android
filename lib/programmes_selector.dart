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

    _loadProgrammes().then((_) {
      _loadCurrentProgramme();
    });
  }

  void _programmesLoaded(List<Programme> programmes) {
    setState(() {
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
      _currentProgramme = _programmes.firstWhere((programme) {
        return programme.id == programmeId;
      });
    });
  }

  _loadCurrentProgramme() {
    AuthenticatedRequest.get("/current_programme").then((response) {
      var programmeJson = jsonDecode(response.body);

      _currentProgrammeLoaded(programmeJson["programme"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    var programmeButtons = _programmeButtons();

    var contents = _programmeButtons();

    contents.addAll(programmeButtons);

    contents.add(new RaisedButton(
        onPressed: _loadProgrammes, child: new Text("Reload programmes")));

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      var center = Center(
          child: ListView(
        children: contents,
        padding: new EdgeInsets.symmetric(vertical: 0, horizontal: 80),
      ));
      return center;
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
