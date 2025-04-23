import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/config/settings_controller.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/enums/settings.dart';
import 'package:flutter_allianz/models/value_with_unit.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// A widget that displays a tachometer-style gauge to visualize sensor values.
///
/// This widget listens to a stream of sensor values and updates the tachometer needle
/// accordingly. It uses a radial gauge to represent the sensor value within specified limits.
/// The gauge is color-coded to indicate different levels of the sensor value, such as OK, warning, or out of bounds.
///
/// **Author**: Derrick Nyarko
class Tachometer extends StatefulWidget {
  final SettingsType type;
  final String category;
  final Stream<double>? sensorStream;
  final String? title;

  const Tachometer({
    super.key,
    required this.type,
    required this.category,
    required this.sensorStream,
    this.title,
  });

  @override
  TachometerState createState() => TachometerState();
}

class TachometerState extends State<Tachometer> {
  double value = 0;
  StreamSubscription<double>? _sensorStreamSubscription;

  @override
  void initState() {
    super.initState();
    _sensorStreamSubscription = widget.sensorStream?.listen((newValue) {
      setState(() {
        value = newValue;
      });
    });
  }

  @override
  void dispose() {
    _sensorStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, ValueWithUnit> values =
        SettingsController.instance.getSettings(widget.type, widget.category);

    double getValue(String key) => values[key]?.value ?? 0.0;
    String unit = values['Min OK']?.unit ?? 'Unknown';
    double minimum = getValue(Limits.lowerLimit.string);
    double yellowLowerLimit = getValue(Limits.yellowLowerLimit.string);
    double minOk = getValue(Limits.minOk.string);
    double maxOk = getValue(Limits.maxOk.string);
    double yellowUpperLimit = getValue(Limits.yellowUpperLimit.string);
    double maximum = getValue(Limits.upperLimit.string);

    return Column(
      children: [
        if (widget.title != null)
          Container(
            height: 20,
            alignment: Alignment.center,
            child: Text(
              '${widget.title}',
            ),
          ),
        Expanded(
          child: SfRadialGauge(
            axes: [
              RadialAxis(
                canScaleToFit: true,
                showLastLabel: false,
                showFirstLabel: false,
                minimum: minimum,
                maximum: maximum,
                interval: maximum,
                ranges: [
                  GaugeRange(
                      startValue: minimum,
                      endValue: yellowLowerLimit,
                      color: Colors.red),
                  GaugeRange(
                      startValue: yellowLowerLimit,
                      endValue: minOk,
                      color: Colors.yellow),
                  GaugeRange(
                      startValue: minOk, endValue: maxOk, color: Colors.green),
                  GaugeRange(
                      startValue: maxOk,
                      endValue: yellowUpperLimit,
                      color: Colors.yellow),
                  GaugeRange(
                      startValue: yellowUpperLimit,
                      endValue: maximum,
                      color: Colors.red),
                ],
                pointers: [
                  NeedlePointer(
                    value: value,
                    needleLength: 0.8,
                    needleStartWidth: 2,
                    needleEndWidth: 6,
                  )
                ],
                annotations: [
                  GaugeAnnotation(
                    widget: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${value.toStringAsFixed(1)} $unit',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.7,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
