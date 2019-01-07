import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verlichting/authenticated_request.dart';

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

    AuthenticatedRequest.get("/current_lights").then((response) {
      List<Light> lights = [];

      var lightsJson = jsonDecode(response.body)["lights"];

      lightsJson.forEach((light) {
        var newLight;
        switch (light["activation_type"]) {
          case "switch":
            newLight = new SwitchableLight(
                light["node_id"],
                light["name"],
                light["display_name"],
                light["state"]);
            break;
          case "dim":
            newLight = new DimmableLight(
              light["node_id"],
              light["name"],
              light["display_name"],
              light["value"],
            );
            break;
        }

        lights.add(newLight);
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

class DimmableLight extends Light {
  num _oldValue;

  DimmableLight(
    num nodeId,
    String name,
    String displayName,
    num value,
  ) : super(nodeId, name, displayName, false, value) {
    _oldValue = value;
  }

  @override
  bool isOn() => value > 0;

  @override
  Future<NewLightState> toggle(bool newState) {
    var newValue;

    if (newState) {
      newValue = _oldValue > 0 ? _oldValue : 2;
    } else {
      _oldValue = value;
      newValue = 0;
    }

    return AuthenticatedRequest.post("/light/${nodeId}/level/$newValue")
        .then((response) {
      var levelFromServer = jsonDecode(response.body)["level"];

      value = levelFromServer;

      return NewLightState(false, value);
    }).catchError((error) {
      print(error);
    });
  }

  @override
  applyState(NewLightState newLightState) {
    state = newLightState.state;
  }
}

class SwitchableLight extends Light {
  SwitchableLight(
    num nodeId,
    String name,
    String displayName,
    bool state,
  ) : super(nodeId, name, displayName, state, 0);

  @override
  bool isOn() => state;

  @override
  Future<NewLightState> toggle(bool newState) {
    return AuthenticatedRequest.post("/light/$nodeId/switch/$newState")
        .then((response) {
      var stateFromServer = jsonDecode(response.body)["state"];

      this.state = stateFromServer;

      return NewLightState(state, 0);
    });
  }

  @override
  applyState(NewLightState newLightState) {
    state = newLightState.state;
  }
}

abstract class Light {
  num nodeId;
  String name;
  String displayName;
  bool state;
  num value;
  bool waiting = false;

  Light(
    this.nodeId,
    this.name,
    this.displayName,
    this.state,
    this.value,
  );

  bool isOn();

  Future<NewLightState> toggle(bool newState);

  applyState(NewLightState newLightState);
}

class NewLightState {
  bool state;
  num value;

  NewLightState(this.state, this.value);
}
