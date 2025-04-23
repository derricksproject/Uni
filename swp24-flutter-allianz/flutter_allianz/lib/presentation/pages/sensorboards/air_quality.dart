import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/models/value_with_unit.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/data.dart';
import 'package:flutter_allianz/presentation/widgets/chart.dart';

/// A StatelessWidget that displays the air quality data of the sensorboards.
///
/// **Author**: Timo Gehrke
class AirQuality extends StatelessWidget {
  final Map<String, ValueWithUnit> limitMap = {
    Limits.lowerLimit.string: ValueWithUnit(0, ''),
    Limits.upperLimit.string: ValueWithUnit(600, ''),
  };

  AirQuality({super.key});

  @override
  Widget build(BuildContext context) {
    ControllerHelper.controller.aqiStream().asBroadcastStream();
    return Chart(
      sensorData: [Data(topic: Categories.boardAirQuality.topic, number: 1)],
    );
  }
}