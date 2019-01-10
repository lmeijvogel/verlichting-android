import 'package:flutter/material.dart';
import 'package:verlichting/models/light.dart';

class _SwitchableLightState extends State<SwitchableLightProperties> {
  SwitchableLight _light;
  bool _state;

  Function _onChanged;

  _SwitchableLightState(this._light, this._onChanged) {
    this._state = _light.state;
  }

  build(BuildContext context) {
    return new Row(children: [
      Switch(value: _state, onChanged: _lightValueChanged)
    ]);
  }

  _lightValueChanged(bool state) {
    _state = state;
    if (_onChanged != null) {
      _onChanged(NewLightState(state, 0));
    }
  }
}

class SwitchableLightProperties extends StatefulWidget {
  final Light _light;
  final Function _onChange;

  SwitchableLightProperties(this._light, this._onChange);

  _SwitchableLightState createState() =>
      _SwitchableLightState(_light, this._onChange);
}
