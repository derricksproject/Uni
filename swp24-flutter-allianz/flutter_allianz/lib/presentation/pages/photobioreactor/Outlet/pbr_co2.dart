import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/presentation/widgets/sensor_display.dart';

/// A StatelessWidget that displays the co2 data  of the photobioreactors.
///
/// This widget fetches the topic related to co2 from the [Categories] enum
/// and passes it to the [SensorDisplay] widget to present the data on the UI.
/// 
/// **Author**: Timo Gehrke
class PbrCo2 extends StatelessWidget{
  const PbrCo2({super.key});

  @override
  Widget build(BuildContext context) {
    String topic = Categories.pbrCo2G.topic;
    return SensorDisplay(topic: topic);
  }
}