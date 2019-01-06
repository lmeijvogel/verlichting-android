import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:verlichting/authenticated_request.dart';

final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey();

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

    _refresh();
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

    return AuthenticatedRequest.get("/available_programmes").then((response) {
      List<Programme> programmes = [];

      var programmesJson = jsonDecode(response.body)["availableProgrammes"];

      programmesJson.forEach((key, value) {
        programmes.add(new Programme(key, value));
      });

      _programmesLoaded(programmes);
    });
  }

  _loadCurrentProgramme() {
    AuthenticatedRequest.get("/current_programme").then((response) {
      var programmeJson = jsonDecode(response.body);

      _selectProgrammeById(programmeJson["programme"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: ListView(
                children: _programmeButtons(),
                padding: new EdgeInsets.symmetric(vertical: 0, horizontal: 80),
              )));
    }
  }

  Future<void> _refresh() {
    return _loadProgrammes().then((_) {
      _loadCurrentProgramme();
    });
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
    var path = "/programme/${programme.id}/start";

    AuthenticatedRequest.post(path).then((response) {
      var responseJson = jsonDecode(response.body);

      _selectProgrammeById(responseJson["programme"]);
    });
  }

  _selectProgrammeById(String programmeId) {
    setState(() {
      var programme =
          _programmes.firstWhere((programme) => programme.id == programmeId);

      _currentProgramme = programme;
    });
  }
}

class Programme {
  String id;
  String name;

  Programme(this.id, this.name);
}
