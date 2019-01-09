import 'package:flutter/material.dart';
import 'package:verlichting/authenticated_request.dart';
import 'package:verlichting/light_state_dialog.dart';
import 'package:verlichting/models/light.dart';

final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey();

class LightsAdjusterWidget extends StatefulWidget {
  final String title = "Lights";

  @override
  _LightsAdjusterState createState() => _LightsAdjusterState();
}

class _LightsAdjusterState extends State<LightsAdjusterWidget> {
  bool _loading = false;
  bool _errorLoading = false;

  List<Light> _lights;

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  void _lightsLoaded(List<Light> lights) {
    setState(() {
      _lights = lights;
      _loading = false;
      _errorLoading = false;
    });
  }

  Future<void> _loadLights() async {
    setState(() {
      _loading = true;
      _errorLoading = false;
    });

    AuthenticatedRequest.get("/current_lights").then((jsonResponse) {
      var lightsJson = jsonResponse.payload["lights"];

      List<Light> lights = [];

      lightsJson.forEach((lightJson) {
        lights.add(Light.fromJson(lightJson));
      });

      _lightsLoaded(lights);
    }, onError: (error) {
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
              Text("Error loading lights"),
            ])),
      );
    } else {
      return Center(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: ListView(
                children: _lightToggles(),
                padding: new EdgeInsets.symmetric(vertical: 0, horizontal: 80),
              )));
    }
  }

  Future<void> _refresh() {
    return _loadLights();
  }

  List<Widget> _lightToggles() {
    if (_lights == null) {
      return [];
    }

    return _lights
        .map((light) => ListTile(
              title: Text(light.displayName),
              enabled: !light.waiting,
              trailing: Switch(
                value: light.isOn(),
                onChanged: (newState) => _switchPressed(light, newState),
              ),
            ))
        .toList();
  }

  _switchPressed(Light light, bool newState) {
    setState(() {
      light.waiting = true;
    });
    light.toggle(newState).then((newLightState) {
      setState(() {
        light.applyState(newLightState);
      });
    }).whenComplete(() {
      light.waiting = false;
    });
  }
}
