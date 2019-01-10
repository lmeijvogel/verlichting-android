import 'dart:async';

import 'package:flutter/material.dart';
import 'package:verlichting/defs.dart';
import 'package:verlichting/dimmable_light_properties.dart';
import 'package:verlichting/models/light.dart';
import 'package:verlichting/switchable_light_properties.dart';

class LightStateDialog extends StatefulWidget {
  final Light _light;
  final OnChangedCallback _onChange;

  LightStateDialog(this._light, this._onChange);

  _LightStateDialogState createState() => _LightStateDialogState(_light, _onChange);
}

class _LightStateDialogState extends State<LightStateDialog> {
  Light _light;
  Function _onChange;

  _LightStateDialogState(this._light, this._onChange);

  build(BuildContext context) {
    return new SimpleDialog(
      title: Text(_light.displayName),
      children: <Widget>[
        new Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: _createDialogBody(_light))
      ],
    );
  }

  Widget _createDialogBody(Light light) {
    if (light is DimmableLight) {
      return new DimmableLightProperties(light, _lightValueChanged);
    } else if (light is SwitchableLight) {
      return new SwitchableLightProperties(light, _lightValueChanged);
    } else {
      throw "Invalid dialog type";
    }
  }

  Future<void>_lightValueChanged(NewLightState newLightState) {
    return _onChange(newLightState);
  }
}
