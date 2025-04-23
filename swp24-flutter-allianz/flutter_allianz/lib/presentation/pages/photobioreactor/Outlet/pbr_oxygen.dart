import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/presentation/widgets/sensor_display.dart';

/// A StatelessWidget that displays the oxygen data of the photobioreactors.
///
/// This widget fetches the topic related to oxygen from the [Categories] enum
/// and passes it to the [SensorDisplay] widget to present the data on the UI.
/// 
/// **Author**: Timo Gehrke
class PbrOxygen extends StatelessWidget{
  const PbrOxygen({super.key});

  @override
  Widget build(BuildContext context) {
    String topic = Categories.pbrO2G.topic;
    return Column(
      children: [
        Expanded(child: SensorDisplay(topic: topic)),
        Expanded(child: SensorDisplay(topic: Categories.pbrDissolvedO2L.topic)),
      ],
    );
  }
}