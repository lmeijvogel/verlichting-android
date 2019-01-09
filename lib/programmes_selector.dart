import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verlichting/authenticated_request.dart';
import 'package:verlichting/models/programme.dart';

final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey();

class ProgrammesSelectorWidget extends StatefulWidget {
  final String title = "Programmes";

  @override
  _ProgrammesSelectorState createState() => _ProgrammesSelectorState();
}

class _ProgrammesSelectorState extends State<ProgrammesSelectorWidget> {
  bool _loading = false;
  bool _errorLoading = false;
  String _programmeActivationError;

  List<Programme> _programmes;
  String _currentProgrammeId;

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  void _programmesLoaded(List<Programme> programmes) {
    setState(() {
      _programmes = programmes;
      _loading = false;
      _errorLoading = false;
    });
  }

  Future<void> _loadProgrammes() async {
    setState(() {
      _loading = true;
      _errorLoading = false;
    });

    return AuthenticatedRequest.get("/available_programmes").then((response) {
      List<Programme> programmes = [];

      var programmesJson = jsonDecode(response.body)["availableProgrammes"];

      programmesJson.forEach((key, value) {
        programmes.add(new Programme(key, value));
      });

      _programmesLoaded(programmes);
    }, onError: (error) {
      setState(() {
        _loading = false;
        _errorLoading = true;
      });
    });
  }

  Future<void>_loadCurrentProgramme() {
    return AuthenticatedRequest.get("/current_programme").then((response) {
      var programmeJson = jsonDecode(response.body);

      _selectProgrammeById(programmeJson["programme"]);
    }).catchError((error) {
      setState(() {
        _loading = false;
        _errorLoading = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorLoading) {
      return Center(
        child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
            child: ListView(children: [
              Text("Error loading programmes"),
            ])),
      );
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
    return Future.wait<void>([
     _loadProgrammes(),
    _loadCurrentProgramme()
    ]);
  }

  List<Widget> _programmeButtons() {
    if (_programmes == null) {
      return [];
    }

    return _programmes.map((programme) {
      var active = programme.id == _currentProgrammeId;

      var hasError = programme.id == _programmeActivationError;

      if (active || hasError) {
        var buttonColor =
            hasError ? Colors.red : active ? Colors.blue : Colors.white;

        return RaisedButton(
          onPressed: () {
            _programmeSelected(programme);
          },
          child: Text(programme.name),
          color: buttonColor,
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
    }).catchError((error) {
      setState(() {
        _programmeActivationError = programme.id;
      });
    });
  }

  _selectProgrammeById(String programmeId) {
    setState(() {
      _currentProgrammeId = programmeId;
      _programmeActivationError = null;
    });
  }
}
