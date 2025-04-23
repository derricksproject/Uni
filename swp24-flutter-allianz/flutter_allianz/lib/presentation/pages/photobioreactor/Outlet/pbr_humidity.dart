import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/presentation/widgets/sensor_display.dart';

/// A StatelessWidget that displays the humidity data of the photobioreactors.
///
/// This widget fetches the topic related to humidity from the [Categories] enum
/// and passes it to the [SensorDisplay] widget to present the data on the UI.
/// 
/// **Author**: Timo Gehrke
class PbrHumidity extends StatelessWidget{
  const PbrHumidity({super.key});

  @override
  Widget build(BuildContext context) {
    String topic = Categories.pbrHumidityG.topic;
    return SensorDisplay(topic: topic);
  }
}