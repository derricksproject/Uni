import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/presentation/widgets/sensor_display.dart';

/// A StatelessWidget that displays the co2 data of the sensorboards.
///
/// This widget fetches the topic related to co2 from the [Categories] enum
/// and passes it to the [SensorDisplay] widget to present the data on the UI.
/// 
/// **Author**: Timo Gehrke
class Co2 extends StatelessWidget {
  const Co2({super.key});

  @override
  Widget build(BuildContext context) {
    return SensorDisplay(
      topic: Categories.boardCo2.topic,
    );
  }
}
