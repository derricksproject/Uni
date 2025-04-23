import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/presentation/widgets/sensor_display.dart';

/// A StatelessWidget that displays the O3 data of the sensorboards.
///
/// This widget fetches the topic related to O3 from the [Categories] enum
/// and passes it to the [SensorDisplay] widget to present the data on the UI.
/// 
/// **Author**: Timo Gehrke
class O3 extends StatelessWidget{
  const O3({super.key});

  @override
  Widget build(BuildContext context) {
    return SensorDisplay(topic: Categories.boardO3.topic);
  }
}