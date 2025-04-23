import 'package:flutter_allianz/application/stream_handler.dart';
import 'package:flutter_allianz/config/settings_controller.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/models/value_with_unit.dart';
import 'package:flutter_allianz/main.dart';

/// Represents a data source for charting and streaming, tied to a specific topic and its limits.
///
/// The [Data] class encapsulates data related to a specific topic. It includes functionality
/// to retrieve chart data, subscribe to a data stream, and access related limits for the given topic.
///
/// The class can either fetch data based on a topic and number, or it can be customized with manually
/// provided data and data streams.
/// 
/// Author: Timo Gehrke
class Data {
  final String topic;
  final int number;
  final int? sensorNo;
  final Future<List<dynamic>> data;
  final Stream<double> dataStream;
  final String? title;
  final Map<String, ValueWithUnit> limits;

  Data({
    required this.topic,
    required this.number,
    this.title,
    this.sensorNo,
  }) : 
  data = ControllerHelper.controller.getChartData(
          _prepareTopic(topic, number, sensorNo),
        ),
  dataStream = StreamHandler().getStreamWithTopic(
          _prepareTopic(topic, number, sensorNo),
          number,
          sensorNo: sensorNo,
        ).stream,
  limits = _initializeLimits(topic);

  /// A custom constructor that allows manually providing [data] and [dataStream],
  /// along with the [topic], [number], [title], and [sensorNo].
  Data.custom({
    required this.topic,
    required this.number,
    required this.data,
    required this.dataStream,
    this.title,
    this.sensorNo,
  }) : limits = SettingsController.instance.getSettingsfromTopic(topic);

  /// Returns the limit value for the given [limit] if it exists.
  ///
  /// If the limit exists in the [limits] map, its value is returned; otherwise, `null` is returned.
  double? getLimitValue(Limits limit) {
    if(limits.containsKey(limit.string)) {
       return limits[limit.string]!.value;
    }
    return null;
  }


  /// Prepares the topic by replacing 'X' placeholders with the provided [number] and [sensorNo].
  ///
  /// This is used internally to format the topic string dynamically.
  static String _prepareTopic(String topic, int number, int? sensorNo) {
    return topic
        .replaceFirst('X', number.toString())
        .replaceFirst('X', sensorNo?.toString() ?? '');
  }

  /// Initializes the limits map based on the [topic].
  ///
  /// If the [topic] is empty, it is uses the limits of air quality. Otherwise, limits are fetched from the settings.
  static Map<String, ValueWithUnit> _initializeLimits(String topic) {
    return topic == Categories.boardAirQuality.topic
        ? {
            Limits.lowerLimit.string: ValueWithUnit(0, ''),
            Limits.upperLimit.string: ValueWithUnit(600, ''),
          }
        : SettingsController.instance.getSettingsfromTopic(topic);
  }
}
