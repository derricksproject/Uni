import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/presentation/widgets/sensor_display.dart';

/// A StatelessWidget that displays the temperatur data of the photobioreactors.
///
/// This widget fetches the topic related to temperatur from the [Categories] enum
/// and passes it to the [SensorDisplay] widget to present the data on the UI.
/// 
/// **Author**: Timo Gehrke
class PbrTemperature extends StatelessWidget{
  const PbrTemperature({super.key});
  
  get streamHandler => null;

  @override
  Widget build(BuildContext context) {
    String topic = Categories.pbrTemperatureG.topic;
    return Column(
      children: [
        Expanded(child: SensorDisplay(topic: topic)),
        Expanded(child: SensorDisplay(topic: Categories.pbrTemperatureL.topic)),
      ],
    );
  }
}