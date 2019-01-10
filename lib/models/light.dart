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

    return _setValue(newValue);
  }

  @override
  applyState(NewLightState newLightState) {
    value = newLightState.value.toInt();
  }

  @override
  Future<void> applyAndStartState(NewLightState newLightState) {
    return _setValue(newLightState.value).then((newLightValue) => applyState(newLightState));
  }

  Future<NewLightState> _setValue(num newValue) {
    var newIntValue = newValue.toInt();

    return AuthenticatedRequest.post("/light/$nodeId/level/$newIntValue")
        .then((jsonResponse) {
      var levelFromServer = jsonResponse.payload["level"];

      value = levelFromServer;

      return NewLightState(false, value);
    }).catchError((error) {
      print(error);
    });
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
        .then((jsonResponse) {
      var stateFromServer = jsonResponse.payload["state"];

      this.state = stateFromServer;

      return NewLightState(state, 0);
    });
  }

  @override
  applyState(NewLightState newLightState) {
    state = newLightState.state;
  }

  @override
  Future<void> applyAndStartState(NewLightState newLightState) {
    // TODO: implement applyAndStartState
    return null;
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
  Future<void> applyAndStartState(NewLightState newLightState);

  static Light fromJson(dynamic light) {
    switch (light["activation_type"]) {
      case "switch":
        return new SwitchableLight(light["node_id"], light["name"],
            light["display_name"], light["state"]);
      case "dim":
        return new DimmableLight(
          light["node_id"],
          light["name"],
          light["display_name"],
          light["value"],
        );
        break;
      default:
        throw "Unknown light type ${light["activation_type"]}";
    }
  }
}

class NewLightState {
  bool state;
  num value;

  NewLightState(this.state, this.value);
}
