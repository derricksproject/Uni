import 'dart:async';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/stream_with_topic.dart';
import 'package:flutter_allianz/network/topics.dart';

/// A class responsible for managing and fetching streams related to various sensor topics.
///
/// The `StreamHandler` provides methods to retrieve sensor data streams based on topics,
/// manage the averaging of data streams, and fetch streams for specific sensors, boards, and air quality indicators.
/// It uses the `ControllerHelper` to get access to the available data streams and processes them to suit specific use cases.
///
/// **Author**: Timo Gehrke
class StreamHandler {

  /// Retrieves a stream for a given topic and sensor number.
  ///
  /// **Parameters**:
  /// - `topic`: The base MQTT topic for the sensor.
  /// - `number`: The number used to replace the placeholder 'X' in the topic.
  /// - `sensorNo`: An optional sensor number used to replace 'X' again if provided.
  ///
  /// **Returns**: A `StreamWithTopic` object, which includes the topic and the corresponding sensor stream.
  StreamWithTopic getStreamWithTopic(String topic,int number, {int? sensorNo}) {
    topic = topic.replaceFirst( 'X', '$number' );
    if(sensorNo != null ) {
    topic = topic.replaceFirst( 'X', '$sensorNo' );
    }
    return StreamWithTopic(topic, ControllerHelper.controller.getTopicStream(topic).asBroadcastStream());
  }

  /// Retrieves an averaged stream of sensor data for a given topic and board number.
  ///
  /// **Parameters**:
  /// - `topic`: The base MQTT topic for the sensor.
  /// - `boardNo`: The board number used to replace 'X' in the topic.
  ///
  /// **Returns**: A `StreamWithTopic` object, which includes the topic and the averaged sensor stream.
  StreamWithTopic getAvgStreamWithTopic(String topic, int boardNo) {
    topic = topic.replaceFirst( 'X', '$boardNo'); 
    Stream<double> avgStream = ControllerHelper.controller.avgStream( 
      [
        for(int n = 1; n <= 4; n++) 
          ControllerHelper.controller
            .getTopicStream(topic.replaceFirst('X', n.toString()))
            .asBroadcastStream(),
      ]
    ).asBroadcastStream();
    return StreamWithTopic(topic, avgStream);
  }

  /// Retrieves an averaged stream of sensor data for a given topic and board number.
  ///
  /// **Parameters**:
  /// - `topic`: The base MQTT topic for the sensor.
  /// - `boardNo`: The board number used to replace 'X' in the topic.
  ///
  /// **Returns**: A `StreamWithTopic` object, which includes the topic and the averaged sensor stream.
  StreamWithTopic getAvgOfAllStreamWithTopic(String topic) {
    int amount = topic.startsWith('board') ? Params.amountBoards : Params.amountPbrs;
    Stream<double> avgStream = ControllerHelper.controller.avgStream( 
      [
        for(int n = 1; n <= amount; n++) 
          ControllerHelper.controller
            .getTopicStream(topic.replaceFirst('X', '$n'))
            .asBroadcastStream(),
      ]
    ).asBroadcastStream();
    return StreamWithTopic(topic, avgStream);
  }

  /// Retrieves a stream of average temperature data for all boards.
  ///
  /// **Returns**: A `Stream<double>` representing the average temperature of all sensorboards.
  Stream<double> getBoardTempAvg() {
    return ControllerHelper.controller.tempAvgStream();
  }

  /// Retrieves a stream of average pressure data for all boards.
  ///
  /// **Returns**: A `Stream<double>` representing the average pressure of all sensorboards.
  Stream<double> getBoardPressAvg() {
    return ControllerHelper.controller.avgStream(
      [
        for(int i = 1; i <= Params.amountBoards; i++) ...[
        ControllerHelper.controller.getTopicStream(Categories.boardPressure.topic.replaceFirst('X', '$i')),
        ]
      ]
    );
  }

  /// Retrieves a stream of AQI (Air Quality Index) data.
  ///
  /// **Returns**: A `Stream<double>` representing the air quality index.
  Stream<double> getAqiStream() {
    return ControllerHelper.controller.aqiStream().asBroadcastStream();
  }

  /// Retrieves all streams for all topics in the system.
  ///
  /// **Returns**: A list of `StreamWithTopic` objects, each representing a topic and its associated stream.
  List<StreamWithTopic> getAllStreams() {
    List<String> topics = fullTopics;
    List<StreamWithTopic> streamList = [];
    for(var topic in topics) {
      StreamWithTopic streamWithTopic = StreamWithTopic(
        topic, 
        ControllerHelper.controller.getTopicStream(topic).asBroadcastStream()
      );
      streamList.add(streamWithTopic);
    }
    return streamList;
  }
}