import 'package:flutter/material.dart';
import 'package:verlichting/models/light.dart';

class _DimmableLightState extends State<DimmableLightProperties> {
  Light _light;
  num _value;

  Function _onChanged;

  _DimmableLightState(this._light, this._onChanged) {
    this._value = _light.value;
  }

  build(BuildContext context) {
    return new Row(children: [
      Slider(
          value: _value.toDouble(),
          min: 0.0,
          max: 99.0,
          onChanged: _lightValueChanging,
          onChangeEnd: _lightValueChanged),
      Text(_value.toInt().toString())
    ]);
  }

  _lightValueChanging(num value) {
    setState(() {
      _value = value;
    });
  }

  _lightValueChanged(num value) {
    if (_onChanged != null) {
      _onChanged(NewLightState(false, value));
    }
  }
}

class DimmableLightProperties extends StatefulWidget {
  final Light _light;
  final Function _onChange;

  DimmableLightProperties(this._light, this._onChange);

  _DimmableLightState createState() =>
      _DimmableLightState(_light, this._onChange);
}
