import 'dart:convert';

import 'package:verlichting/authenticated_request.dart';

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

    return AuthenticatedRequest.post("/light/$nodeId/level/$newValue")
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
    return AuthenticatedRequest.post("/light/$nodeId/switch/${newState ? "on" : "off"}")
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