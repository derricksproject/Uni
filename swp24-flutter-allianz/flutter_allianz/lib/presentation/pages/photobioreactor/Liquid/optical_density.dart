import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/presentation/widgets/sensor_display.dart';

/// A StatelessWidget that displays the optical density data of the photobioreactors.
///
/// This widget fetches the topic related to optical density from the [Categories] enum
/// and passes it to the [SensorDisplay] widget to present the data on the UI.
/// 
/// **Author**: Timo Gehrke
class OpticalDensity extends StatelessWidget{
  const OpticalDensity({super.key});

  @override
  Widget build(BuildContext context) {
    String topic = Categories.pbrOpticalDensityL.topic;
    return SensorDisplay(topic: topic); 
  }
}