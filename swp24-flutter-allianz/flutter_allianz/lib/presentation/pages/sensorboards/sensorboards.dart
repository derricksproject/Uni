import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/stream_handler.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/settings.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/data.dart';
import 'package:flutter_allianz/presentation/pages/sensorboards/index.dart';
import 'package:flutter_allianz/presentation/widgets/chart.dart';
import 'package:flutter_allianz/presentation/widgets/tachometer/aqi_tachometer.dart';
import 'package:flutter_allianz/presentation/widgets/tachometer/tachometer.dart';

/// A StatefulWidget that represents a sensor board for monitoring temperature, pressure, and air quality.
///
/// The `Sensorboards` widget displays:
/// - Tachometers for real-time sensor data for temperature, pressure, and air quality index (AQI).
/// - Diagrams (charts) for visualizing the average values of temperature, pressure, and air quality over time.
/// 
/// **Author**: Timo Gehrke
class Sensorboards extends StatefulWidget {
  const Sensorboards({super.key});

  @override
  SensorboardsState createState() => SensorboardsState();
}

class SensorboardsState extends State<Sensorboards> {
  late final Stream<double> temperatureStream;
  late final Stream<double> pressureStream;
  late final Stream<double> airQualityStream;
  late final StreamHandler streamHandler = StreamHandler();

  @override
  void initState() {
    super.initState();
    temperatureStream = streamHandler.getBoardTempAvg().asBroadcastStream();
    pressureStream = streamHandler.getBoardPressAvg().asBroadcastStream();
    airQualityStream = streamHandler.getAqiStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: tachometerPanel(),
        ),
        Expanded(
          flex: 5,
          child: diagrammPanel(),
        ),
      ],
    );
  }

  /// Builds the tachometer panel displaying real-time sensor data for temperature, pressure, and air quality.
  ///
  /// The tachometer panel consists of three tachometers:
  /// - Temperature sensor
  /// - Pressure sensor
  /// - Air Quality Index (AQI) sensor
  Widget tachometerPanel() {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, 
      children: [
        Expanded(
          child: Tachometer(
            type: SettingsType.board,
            category: 'Temperature',
            sensorStream: temperatureStream,
          ),
        ),
        Expanded(
          child: Tachometer(
            type: SettingsType.board,
            category: 'Pressure',
            sensorStream: pressureStream,
          ),
        ),
        Expanded(
          child: AqiTachometer(
            sensorStream: airQualityStream,
          ),
        ),
      ],
    );
  }

  /// Builds the diagram panel displaying charts for average temperature, pressure, and air quality.
  ///
  /// The diagram panel consists of three charts:
  /// - Temperature chart displaying the average temperature over time.
  /// - Pressure chart displaying the average pressure over time.
  /// - Air Quality chart displaying the air quality index over time.
  Widget diagrammPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Chart(
            sensorData: [
              Data.custom(
                  topic: Categories.boardTemperature.topic,
                  number: 1,
                  data: ControllerHelper.controller.getAvgTempChart(),
                  dataStream: streamHandler.getBoardTempAvg())
            ],
          ),
        ),
        Expanded(
          child: Chart(
            sensorData: [
              Data.custom(
                  topic: Categories.boardPressure.topic,
                  number: 1,
                  data: ControllerHelper.controller.getAvgData(Categories.boardPressure.topic),
                  dataStream: streamHandler.getBoardPressAvg()),
            ],
          ),
        ),
        Expanded(
          child: AirQuality(),
        ),
      ],
    );
  }
}
