import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/data/chart_buffer.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/models/chat_message.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_allianz/data/influxdb_client.dart';
import 'package:flutter_allianz/data/aqi/aqi.dart';
import 'package:typed_data/typed_data.dart';
import 'package:flutter_allianz/main.dart';

/// Represents a Controller that can be used to fetch and manage data.
///
/// The `Controller` class provides functionality to query InfluxDB,
/// check if measurements exist, and perform data processing tasks like
/// combining measurements and calculating averages.
///
/// **Author**: Krishnen Ganeshakumar
class Controller {
  late InfluxdbV1 _idb1Cli;
  late final Stream<List<MqttReceivedMessage<dynamic>>>? _mqttStream =
      BrokerHelper.broker.mqttStream;
  late ChartUtils _chartUtil;

  /// Constructs a Controller object that interacts with InfluxDB.
  ///
  /// [idbHostname] - The hostname of the InfluxDB instance.
  /// [idbPort] - The port that the InfluxDB instance listens to.
  /// [idbUsername] - The username for authentication with InfluxDB.
  /// [idbPassword] - The password for authentication with InfluxDB.
  /// [database] - The name of the database to use in InfluxDB.
  Controller(String idbHostname, int idbPort, String idbUsername,
      String idbPassword, String database) {
    _idb1Cli = InfluxdbV1(
      hostname: idbHostname,
      port: idbPort,
      username: idbUsername,
      password: idbPassword,
      database: database,
    );
    _chartUtil = ChartUtils();
  }

  /// Executes a query in InfluxQL and returns the results in a structured format.
  ///
  /// The results are returned as a Map with the following structure:
  /// ```json
  /// {
  ///   "name": "<name_of_measurement>",
  ///   "columns": ["col1", "col2", ...],
  ///   "values": [[value1, value2, ...], ...],
  ///   "message": "<message>"
  /// }
  /// ```
  ///
  /// [influxQL] - The InfluxQL query to execute.
  ///
  /// Returns a Map with the query results or a [Future.error] if the query fails.
  Future<Map<String, dynamic>> query(String influxQL) async {
    late final http.Response response;
    try {
      response = await _idb1Cli.query(influxQL);
    } catch (e) {
      return Future.error(e);
    }
    Map<String, dynamic> newBody =
        jsonDecode(response.body)["results"][0]["series"][0];
    newBody["message"] = "request successful";
    return newBody;
  }

  /// Checks if a specific measurement exists in the InfluxDB.
  ///
  /// [measurement] - The name of the measurement to check for existence.
  ///
  /// Returns `true` if the measurement exists, `false` otherwise.
  /// A [Future.error] is returned if the query fails.
  Future<bool> measurementExists(String measurement) async {
    String influxQL = "select * from $measurement limit 1";
    late final http.Response response;
    try {
      response = await _idb1Cli.query(influxQL);
    } catch (e) {
      return Future.error("caught: $e");
    }
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    return responseMap["results"][0].containsKey("series");
  }

  /// Combines multiple measurements into one and calculates the average.
  ///
  /// This method takes a list of measurements and combines them into a new
  /// measurement. It then computes the average value for each field across
  /// all the combined measurements.
  ///
  /// [measurements] - A list of measurement names to combine.
  /// [combined] - The name of the new combined measurement.
  /// [name] - The name of the result to return.
  ///
  /// Returns a Map with the structure:
  /// ```json
  /// {
  ///   "name": "[name]",
  ///   "columns": ["time", "average"],
  ///   "values": [[timestamp, average], ...],
  ///   "message": "request successful"
  /// }
  /// ```
  /// A [Future.error] is returned if the process fails.
  Future<Map<String, dynamic>> _getMean(
    List<String> measurements,
    String combined,
    String name,
  ) async {
    for (String measurement in measurements) {
      if (await measurementExists(measurement)) {
        String newField = "${measurement}_val";
        String query =
            "select value as  \"$newField\" into \"$combined\" from \"$measurement\"";
        try {
          await _idb1Cli.query(query);
        } catch (e) {
          return Future.error(e);
        }
      }
    }
    late http.Response response;
    if (await measurementExists(combined)) {
      response = await _idb1Cli.query1000(combined);
    } else {
      sleep(const Duration(seconds: 1));
      response = await _idb1Cli.query1000(combined);
    }

    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    List<dynamic> values = decodedResponse["results"][0]["series"][0]["values"];
    List<dynamic> avgValues =
        List<dynamic>.filled(values.length, null, growable: true);

    for (int i = 0; i < values.length; ++i) {
      List<dynamic> value = values[i];
      int valCount = 0;
      double sum = 0;
      for (int j = 1; j < value.length; ++j) {
        if (value[j] != null) {
          sum += value[j];
          ++valCount;
        }
      }
      late List<dynamic> newEntry;
      if (valCount == 0) {
        newEntry = [value[0], null];
      } else {
        newEntry = [value[0], sum / valCount];
      }
      avgValues[i] = newEntry;
    }
    Map<String, dynamic> newBody = {
      "name": name,
      "columns": ["time", "average"],
      "values": avgValues,
      "message": "request successful",
    };
    try {
      _idb1Cli.query("DROP MEASUREMENT $combined"); //Delete measurement
      debugPrint("dropped mesaurement");
    } catch (e) {
      return Future.error(e);
    }
    return newBody;
  }

  /// Fetches the historical AQI (Air Quality Index) data from the database.
  /// This method retrieves mean values for different environmental factors
  /// such as oxygen, ozone, carbon dioxide (CO2), carbon monoxide (CO), and humidity,
  /// calculates the AQI for each data point, and returns a list of timestamps and AQI values.
  ///
  /// Returns a list of pairs ([timestamp, aqi_value]) representing the AQI values
  /// for each data point.
  Future<List<dynamic>> _getAQI() async {
    List<String> o2Boards = [];
    List<String> o3Boards = [];
    List<String> co2Boards = [];
    List<String> coBoards = [];
    List<String> humidSensors = [];

    for (int i = 1; i <= Params.amountBoards; i++) {
      o2Boards.add("board${i}_o2");
      o3Boards.add("board${i}_o3");
      coBoards.add("board${i}_co");
      co2Boards.add("board${i}_co2");
      for (int j = 1; j <= 4; j++) {
        humidSensors.add("board${i}_humid${j}_am");
      }
    }
    debugPrint(humidSensors.toString());

    List<dynamic> oxygenMean =
        (await _getMean(o2Boards, "o2Combined", "o2avg"))["values"];
    List<dynamic> ozoneMean =
        (await _getMean(o3Boards, "o3Combined", "o3avg"))["values"];
    List<dynamic> co2Mean =
        (await _getMean(co2Boards, "co2Combined", "co2avg"))["values"];
    List<dynamic> coMean =
        (await _getMean(coBoards, "coCombined", "coavg"))["values"];
    List<dynamic> humidMean =
        (await _getMean(humidSensors, "humidCombined", "humidavg"))["values"];
    List<dynamic> aqiVals = List<dynamic>.empty(growable: true);

    for (int i = 0; i < oxygenMean.length; ++i) {
      int big = 0;
      int index = -1;
      List<int> levels;
      levels = [
        evalOxygen(oxygenMean[i][1]).index,
        evalOzone(ozoneMean[i][1]).index,
        evalco2(co2Mean[i][1]).index,
        evalco(coMean[i][1]).index,
        evalHumid(humidMean[i][1]).index,
      ];
      for (int j = 0; j < 5; ++j) {
        if (big < levels[j]) {
          big = levels[j];
          index = j;
        }
      }
      double value = -1;
      switch (index) {
        case 0:
          value = aqiOxygen(oxygenMean[i][1]);
          aqiVals.add([oxygenMean[i][0], value]);
          break;
        case 1:
          value = aqiOzone(ozoneMean[i][1]);
          aqiVals.add([ozoneMean[i][0], value]);
          break;
        case 2:
          value = aqico2(co2Mean[i][1]);
          aqiVals.add([co2Mean[i][0], value]);
          break;
        case 3:
          value = aqiCo(coMean[i][1]);
          aqiVals.add([coMean[i][0], value]);
          break;
        case 4:
          value = aqiHumid(humidMean[i][1]);
          aqiVals.add([humidMean[i][0], value]);
          break;
      }
    }
    Completer<List<dynamic>> c = Completer();
    c.complete(aqiVals);
    return c.future;
  }

  /// Calculates the AQI value based on a tuple of environmental factors:
  /// oxygen (o2), carbon dioxide (co2), carbon monoxide (co), humidity (humid), and ozone (o3).
  ///
  /// The method calculates the individual AQI for each factor and returns the highest AQI value.
  ///
  /// [o2] - The oxygen value.
  /// [co2] - The carbon dioxide value.
  /// [co] - The carbon monoxide value.
  /// [humid] - The humidity value.
  /// [o3] - The ozone value.
  ///
  /// Returns the highest AQI value calculated from the input factors.
  double _getAQIVal(double o2, double co2, double co, double humid, double o3) {
    double o2val = aqiOxygen(o2);
    double co2val = aqico2(co2);
    double coval = aqiCo(co);
    double humval = aqiHumid(humid);
    double o3val = aqiOzone(o3);

    List<double> vals = [
      o2val,
      co2val,
      coval,
      humval,
      o3val,
    ];

    double big = 0;
    for (int i = 0; i < 5; ++i) {
      if (vals[i] > big) {
        big = vals[i];
      }
    }
    return big;
  }

  /// Returns a stream of sensor data from the specified MQTT [topic].
  /// This stream will yield values each time a new message is received on the topic.
  ///
  /// [topic] - The MQTT topic from which to receive the sensor data.
  ///
  /// Yields a [double] value representing the sensor data when a message is received.
  Stream<double> getTopicStream(String topic) async* {
    if (_mqttStream != null) {
      await for (final messages in _mqttStream) {
        for (int i = 0; i < messages.length; ++i) {
          if (messages[i].topic != topic) continue;
          final message = messages[i].payload as MqttPublishMessage;
          final payload = message.payload.message;
          String valAsString =
              MqttPublishPayload.bytesToStringAsString(payload);
          try {
            double senVal = double.parse(valAsString);
            yield senVal;
          } catch (e) {
            debugPrint("MQTT-Message was malformed");
          }
        }
      }
    }
  }

  /// Returns a stream of [ChatMessage] objects received from the specified MQTT [topic].
  /// The stream will yield [ChatMessage] whenever a new chat message is received.
  ///
  /// [topic] - The MQTT topic from which to receive the chat messages.
  ///
  /// Yields a [ChatMessage] object representing a chat message received on the topic.
  Stream<ChatMessage> getChatStream(String topic) async* {
    if (_mqttStream != null) {
      await for (final messages in _mqttStream) {
        for (int i = 0; i < messages.length; ++i) {
          if (messages[i].topic == topic) {
            final message = messages[i].payload as MqttPublishMessage;
            final payload = message.payload.message;
            String valAsString =
                MqttPublishPayload.bytesToStringAsString(payload);
            Map<String, dynamic> payloadMap = jsonDecode(valAsString);
            ChatMessage mesg = ChatMessage.fromJson(payloadMap);
            if (topic == "chatbot/mission_control") {
              _appendChatMesg(mesg, "/cbmission_control.json");
            }
            yield mesg;
          }
        }
      }
    }
  }

  /// Returns a list of [ChatMessage] objects representing recent chat messages
  /// received from the topics "chatbot/user" and "chatbot/mission_control".
  /// The messages are sorted by their timestamps.
  ///
  /// Returns a list of [ChatMessage] objects.
  List<ChatMessage> getChatMessages() {
    List<ChatMessage> mesg =
        (SensorHelper.sensorData.getChatValue("chatbot/user")) +
            (SensorHelper.sensorData.getChatValue("chatbot/mission_control"));
    mesg.sort((a, b) {
      DateTime aTime = DateTime.parse(a.time);
      DateTime bTime = DateTime.parse(b.time);
      return aTime.compareTo(bTime);
    });

    return mesg;
  }

  /// Combines multiple streams and returns a stream representing the sum of the values
  /// emitted by each stream. Each stream's latest value is summed and emitted as the result.
  ///
  /// [streams] - A list of [Stream<double>] to combine.
  ///
  /// Returns a [Stream<double>] that emits the sum of values from the provided streams.
  Stream<double> _sumStream(List<Stream<double>> streams) {
    // Combine the streams using StreamZip
    return StreamZip(_filterNullStreams(streams)).map((values) {
      // Sum the values from the combined streams
      return values.reduce((a, b) => a + b);
    });
  }

  /// Filters out null elements from the given list of streams.
  ///
  /// [streams] - A list of [Stream<double>?] that may contain null elements.
  ///
  /// Returns a [List<Stream<double>>] containing only non-null streams.
  List<Stream<double>> _filterNullStreams(List<Stream<double>?> streams) {
    return streams.where((stream) => stream != null).cast<Stream<double>>().toList();
  }

  /// Returns a stream that emits the average of the values from multiple streams.
  /// It computes the average of the values emitted by the provided streams.
  ///
  /// [streams] - A list of [Stream<double>] to calculate the average from.
  /// [topic] - An optional MQTT topic where the average value will be sent.
  ///
  /// Yields the average of the values emitted by the streams.
  Stream<double> avgStream(List<Stream<double>> streams,
      {String? topic}) async* {
    Stream<double> streamsSum = _sumStream(streams);
    await for (double value in streamsSum) {
      double avg = value / streams.length;
      if (topic != null) {
        Uint8Buffer payload = Uint8Buffer();
        payload.addAll(avg.toString().codeUnits);
        final time = DateTime.now();
        SensorHelper.sensorData
            .addValue(topic, payload, time.toIso8601String());
      }
      yield avg;
    }
  }

  /// Returns a [Stream] that emits the average values from all temperature sensors.
  /// If a [boardNum] is provided, only temperature sensors from the specified board
  /// will be included in the average calculation.
  ///
  /// Throws an [ArgumentError] if the provided [boardNum] is not valid.
  Stream<double> tempAvgStream({int? boardNum}) {
    List<Stream<double>> streams = [];

    if (boardNum != null) {
      if (boardNum < 1 || boardNum > Params.amountBoards) {
        throw ArgumentError("Invalid board number: $boardNum");
      }
      for (int j = 1; j <= Params.amountPbrs; j++) {
        streams.add(getTopicStream("board$boardNum/temp${j}_am"));
      }
    } else {
      for (int i = 1; i <= Params.amountBoards; i++) {
        for (int j = 1; j <= Params.amountPbrs; j++) {
          streams.add(getTopicStream("board$i/temp${j}_am"));
        }
      }
    }
    return avgStream(streams);
  }

  /// Returns a [Stream] that emits the average values from all humidity sensors.
  /// If a [boardNum] is provided, only humidity sensors from the specified board
  /// will be included in the average calculation.
  ///
  /// Throws an [ArgumentError] if the provided [boardNum] is not valid.
  Stream<double> humidAvgStream({int? boardNum}) {
    List<Stream<double>> streams = [];

    if (boardNum != null) {
      if (boardNum < 1 || boardNum > Params.amountBoards) {
        throw ArgumentError("Invalid board number: $boardNum");
      }
      for (int j = 1; j <= Params.amountPbrs; j++) {
        streams.add(getTopicStream("board$boardNum/humid${j}_am"));
      }
    } else {
      for (int i = 1; i <= Params.amountBoards; i++) {
        for (int j = 1; j <= Params.amountPbrs; j++) {
          streams.add(getTopicStream("board$i/humid${j}_am"));
        }
      }
    }
    return avgStream(streams);
  }

  /// Returns a [Stream] that emits AQI values based on data from relevant sensors (Oxygen, Ozone, CO2, CO, and Humidity).
  /// The emitted AQI values are stored with recent AQI values in a database.
  ///
  /// The stream combines data from sensors, calculates the AQI for each, and returns the highest AQI value.
  Stream<double> aqiStream() {
    List<Stream<double>> o2Streams = [];
    List<Stream<double>> o3Streams = [];
    List<Stream<double>> co2Streams = [];
    List<Stream<double>> coStreams = [];
    List<Stream<double>> humidStreams = [];

    for (int i = 1; i <= Params.amountBoards; i++) {
      o2Streams.add(getTopicStream("board$i/o2"));
      o3Streams.add(getTopicStream("board$i/o3"));
      coStreams.add(getTopicStream("board$i/co"));
      co2Streams.add(getTopicStream("board$i/co2"));
      for (int j = 1; j <= 4; j++) {
        humidStreams.add(getTopicStream("board$i/humid${j}_am"));
      }
    }

    Stream<double> humidAvg = avgStream(humidStreams);
    Stream<double> co2Avg = avgStream(co2Streams);
    Stream<double> coAvg = avgStream(coStreams);
    Stream<double> o2Avg = avgStream(o2Streams);
    Stream<double> o3Avg = avgStream(o3Streams);

    StreamZip zip = StreamZip([humidAvg, co2Avg, coAvg, o2Avg, o3Avg]);

    return zip.map((value) {
      double aqi = _getAQIVal(value[3], value[1], value[2], value[0], value[4]);
      Uint8Buffer payload = Uint8Buffer();
      payload.addAll(aqi.toString().codeUnits);
      final time = DateTime.now();
      SensorHelper.sensorData
          .addValue("aqiValues", payload, time.toIso8601String());
      return aqi;
    });
  }

  /// Returns the last 1000 recorded data points from the specified [topic] as a list of [FlSpot].
  ///
  /// The data points are processed to extract the relevant values and convert them into a format
  /// suitable for charting (i.e., [FlSpot] for plotting).
  Future<List<dynamic>> getChartData(String topic) async {
    List<List<double>> doubleVals = await (getSensorData(topic));
    return _chartUtil.listToFlSpot(doubleVals);
  }

  /// Returns the last 1000 recorded AQI values as a list of [FlSpot] for charting.
  ///
  /// The data points are processed to extract the AQI values and convert them into a format
  Future<List<dynamic>> getChartAqi() async {
    List<List<double>> doubleVals = await _getAqiSensorData();
    return _chartUtil.listToFlSpot(doubleVals);
  }

  /// Retrieves AQI sensor data from a database and MQTT topics and returns it as a list of time-value pairs.
  ///
  /// The method combines AQI values fetched from the database and the recent sensor data to create
  Future<List<List<double>>> _getAqiSensorData() async {
    List<List<double>> numericVals = [];
    try {
      List<dynamic> aqiData = await _getAQI();
      for (int i = 0; i < aqiData.length; ++i) {
        DateTime theTime = DateTime.parse(aqiData[i][0]);
        double timeAsDouble =
            theTime.hour + (theTime.minute / 60.0) + (theTime.second / 3600);
        numericVals.add([timeAsDouble, aqiData[i][1].toDouble()]);
      }
    } catch (e) {
      debugPrint("$e");
      debugPrint("could not reach database");
    }

    try {
      List<List<dynamic>> recentAqi =
          SensorHelper.sensorData.getValue("aqiValues");
      List<List<double>> mqttNumieric = [];

      for (int i = 0; i < recentAqi.length; ++i) {
        DateTime theTime = DateTime.parse(recentAqi[i][0]);
        double timeAsDouble =
            theTime.hour + (theTime.minute / 60.0) + (theTime.second / 3600);

        String valueAsString =
            MqttPublishPayload.bytesToStringAsString(recentAqi[i][1]);
        double value = double.parse(valueAsString);
        mqttNumieric.add([timeAsDouble, value]);
      }

      // Handle overflow if there are more than 1000 records
      if (numericVals.length + mqttNumieric.length >= 1000) {
        int overflow = numericVals.length + mqttNumieric.length - 1000;
        List<List<double>> combined =
            (numericVals.reversed.toList()) + mqttNumieric;
        return combined.getRange(overflow, combined.length - 1).toList();
      }
      return (numericVals.reversed.toList()) + mqttNumieric;
    } catch (e) {
      debugPrint("recent data not available yet");
    }

    return numericVals;
  }

  /// Returns a list of the average pressure values for charting.
  ///
  /// The average pressure values are collected from relevant sensors and formatted for use in charts.
  Future<List<dynamic>> getAvgPressChart() async {
    List<String> humidTopics = [];
    for (int i = 1; i <= Params.amountBoards; i++) {
      humidTopics.add("board$i/amb_press");
    }

    List<List<double>> doubleVals = await getAvgSenData(humidTopics);
    return _chartUtil.listToFlSpot(doubleVals);
  }

  /// Returns a list of the average humidity values for charting, either for all boards
  /// or a specific board if [boardNum] is provided.
  Future<List<dynamic>> getAvgHumidChart({int? boardNum}) async {
    List<String> topics = [];
    for (int i = 1; i <= Params.amountBoards; i++) {
      for (int j = 1; j <= 4; j++) {
        topics.add("board$i/humid${j}_am");
      }
    }

    if (boardNum != null && boardNum >= 1 && boardNum <= Params.amountBoards) {
      int start = (boardNum - 1) * 4;
      int end = start + 4;
      List<List<double>> doubleVals =
          await getAvgSenData(topics.getRange(start, end).toList());
      return _chartUtil.listToFlSpot(doubleVals);
    }
    List<List<double>> doubleVals = await getAvgSenData(topics);
    return _chartUtil.listToFlSpot(doubleVals);
  }

  /// Returns a list of the average temperature values for charting, either for all boards
  /// or a specific board if [boardNum] is provided.
  Future<List<dynamic>> getAvgTempChart({int? boardNum}) async {
    List<String> topics = [];
    for (int i = 1; i <= Params.amountBoards; i++) {
      for (int j = 1; j <= 4; j++) {
        topics.add('board$i/temp${j}_am');
      }
    }

    if (boardNum != null && boardNum >= 1 && boardNum <= Params.amountBoards) {
      int start = (boardNum - 1) * 4;
      int end = start + 4;
      List<List<double>> doubleVals =
          await getAvgSenData(topics.getRange(start, end).toList());
      return _chartUtil.listToFlSpot(doubleVals);
    }
    List<List<double>> doubleVals = await getAvgSenData(topics);
    return _chartUtil.listToFlSpot(doubleVals);
  }

  Future<List<dynamic>> getAvgData(String topic) async {
    List<String> topics = [];
    int amount = topic.startsWith('board') ? Params.amountBoards : Params.amountPbrs;
    for(int i = 0; i < amount; i++) {
      topics.add(topic.replaceFirst("X", "${i+1}"));
    }
    List<List<double>> doubleVals = await getAvgSenData(topics);
    return _chartUtil.listToFlSpot(doubleVals);
  }

  /// Returns the average values for a list of [topics] and returns them as time-value pairs.
  ///
  /// This method calculates the mean of the sensor data for each topic and formats the result into
  /// time-value pairs suitable for charting or further analysis.
  Future<List<List<double>>> getAvgSenData(List<String> topics) async {
    List<String> measurements = topics.map((topic) {
      return topic.replaceAll(RegExp(r'/'), r'_');
    }).toList();

    List<List<double>> numericVals = [[]];
    try {
      List<dynamic> list =
          (await _getMean(measurements, "combined", "MEAN"))["values"];
      for (int i = 0; i < list.length; ++i) {
        DateTime theTime = DateTime.parse(list[i][0]);
        double timeAsDouble =
            theTime.hour + (theTime.minute / 60.0) + (theTime.second / 3600);
        numericVals.add([timeAsDouble, list[i][1].toDouble()]);
      }
    } catch (e) {
      debugPrint("could not reach database");
    }

    List<List<List<dynamic>>> senData = [];
    for (int i = 0; i < topics.length; ++i) {
      senData.add(SensorHelper.sensorData.getValue(topics[i]));
    }

    List<List<double>> mqttNumeric = [];

    int row = senData[0].length;
    int col = senData.length;

    for (int j = 0; j < row; ++j) {
      double sum = 0;
      DateTime theTime = DateTime.parse(senData[0][j][0]);
      double timeAsDouble =
          theTime.hour + (theTime.minute / 60.0) + (theTime.second / 3600);
      for (int i = 0; i < col; ++i) {
        sum += double.parse(
            MqttPublishPayload.bytesToStringAsString(senData[i][j][1]));
      }
      mqttNumeric.add([timeAsDouble, sum / col]);
    }

    // Handle Overflow
    if (numericVals.length + mqttNumeric.length >= 1000) {
      int overflow = numericVals.length + mqttNumeric.length - 1000;
      List<List<double>> combined =
          (numericVals.reversed.toList()) + mqttNumeric;
      return combined.getRange(overflow, combined.length - 1).toList();
    }
    return (numericVals.reversed.toList()) + mqttNumeric;
  }

  /// Fetches recent sensor data corresponding to [key].
  ///
  /// This method retrieves data from both the database and MQTT sources. It checks if the
  /// [key] corresponds to a chat topic, in which case it will fetch data from the chatbot instead.
  /// The result is returned as a list of pairs, where each pair consists of:
  /// - `time` (double): Time in hours, formatted as a decimal, e.g., 2.5 hours.
  /// - `value` (double): The sensor data value at that time.
  ///
  /// If the [key] is related to a chat topic (e.g., "chatbot/user" or "chatbot/mission_control"),
  /// it returns data from the chatbot instead.
  ///
  /// If more than 1000 data points are fetched, only the most recent 1000 values are returned.
  ///
  /// [key]: A string that represents the identifier for the sensor data.
  ///
  /// Returns a `List<List<double>>`, where each sublist contains [time, value].
  getSensorData(key) async {
    if (key == "chatbot/user" || key == "chatbot/mission_control") {
      return SensorHelper.sensorData.getChatValue(key);
    }
    // Turn topic into measurement
    String keyMeasurement = key.replaceAll(RegExp(r'/'), r'_');

    List<List<double>> numericVals = [];
    try {
      if (await measurementExists(keyMeasurement)) {
        String fluxQuery =
            "SELECT * FROM $keyMeasurement ORDER BY time DESC LIMIT 1000";
        List<dynamic> list = (await query(fluxQuery))["values"];
        for (int i = 0; i < list.length; ++i) {
          DateTime theTime = DateTime.parse(list[i][0]);
          double timeAsDouble =
              theTime.hour + (theTime.minute / 60.0) + (theTime.second / 3600);
          numericVals.add([timeAsDouble, list[i][1].toDouble()]);
        }
      }
    } catch (e) {
      debugPrint("could not reach Database");
    }
    List<dynamic> mqttdata = SensorHelper.sensorData.getValue(key);
    List<List<double>> mqttNumieric = [];

    for (int i = 0; i < mqttdata.length; ++i) {
      DateTime theTime = DateTime.parse(mqttdata[i][0]);
      double timeAsDouble =
          theTime.hour + (theTime.minute / 60.0) + (theTime.second / 3600);

      String valueAsString =
          MqttPublishPayload.bytesToStringAsString(mqttdata[i][1]);
      double value = double.parse(valueAsString);
      mqttNumieric.add([timeAsDouble, value]);
    }

    if (numericVals.length + mqttNumieric.length >= 1000) {
      int overflow = numericVals.length + mqttNumieric.length - 1000;
      List<List<double>> combined =
          (numericVals.reversed.toList()) + mqttNumieric;
      return combined.getRange(overflow, combined.length - 1).toList();
    }
    return (numericVals.reversed.toList()) + mqttNumieric;
  }

  /// Formats the given [message] into a JSON-compatible string and publishes it to the 'chatbot/user' topic.
  ///
  /// This method converts a `ChatMessage` into a JSON string and publishes it via the MQTT broker.
  /// If the message size exceeds 200MB, an error is returned.
  ///
  /// [message]: The `ChatMessage` object to be sent.
  ///
  /// Throws a `Future.error` if the message is too large to be sent.
  Future<void> sendMessage(ChatMessage message) async {
    _appendChatMesg(message, "/cbuser.json");
    final String mesgAsString = jsonEncode(message.toJson());
    if (mesgAsString.length >= 200000000) {
      return Future.error("Message is too large");
    } else {
      BrokerHelper.broker.publishMessage("chatbot/user", mesgAsString);
    }
  }

  /// Saves both sent and received chat messages to files for future retrieval.
  ///
  /// This method reads chat messages from "chatbot/user" and "chatbot/mission_control",
  /// formats them, and stores them in separate files for persistence:
  /// - `rec_chat.json` for received messages
  /// - `sen_chat.json` for sent messages
  void saveChat() async {
    try {
      List<ChatMessage> recMessages =
          SensorHelper.sensorData.getChatValue("chatbot/mission_control");
      List<String> recForFile = recMessages
          .map((value) => value.mesgForFile())
          .map((value) => jsonEncode(value))
          .toList();

      String recToWrite = "{\"chat\":[";
      recToWrite += recForFile
          .getRange(1, recForFile.length)
          .fold(recForFile[0], (String prev, String next) => "$prev,$next");
      recToWrite += "]}";

      File recFd = File("${Params.configDirectory!}/rec_chat.json");
      recFd.writeAsStringSync(recToWrite);

      List<ChatMessage> senMessages =
          SensorHelper.sensorData.getChatValue("chatbot/user");
      List<String> senForFile = senMessages
          .map((value) => value.mesgForFile())
          .map((value) => jsonEncode(value))
          .toList();

      String senToWrite = "{\"chat\":[";
      senToWrite += senForFile
          .getRange(1, senForFile.length)
          .fold(senForFile[0], (String prev, String next) => "$prev,$next");
      senToWrite += "]}";

      File senFd = File("${Params.configDirectory!}/sen_chat.json");
      senFd.writeAsStringSync(senToWrite);
    } catch (e) {
      debugPrint("Error saving chat: $e");
    }
  }

  /// Restores chat history from stored files to memory.
  ///
  /// This method attempts to read chat history from two files:
  /// - `cbmission_control.json` for received messages
  /// - `cbuser.json` for sent messages
  ///
  /// It restores the messages into the system for later use, ensuring that chat data is persistent across app restarts.
  void restoreChat() {
    try {
      File recFd = File("${Params.configDirectory!}/cbmission_control.json");
      if (recFd.existsSync()) {
        String recChatLog = recFd.readAsStringSync();
        Map<String, dynamic> recChatMap = jsonDecode(recChatLog);
        List<dynamic> lst = recChatMap["chat"]
            .map((value) => ChatMessage.mesgFromFile(value))
            .toList();
        List<ChatMessage> recChtMsgs = [];
        for (var value in lst) {
          recChtMsgs.add(value);
        }
        SensorHelper.sensorData.swapChat("chatbot/mission_control", recChtMsgs);
      }
      File senFd = File("${Params.configDirectory!}/cbuser.json");
      if (senFd.existsSync()) {
        String recChatLog = senFd.readAsStringSync();
        Map<String, dynamic> recChatMap = jsonDecode(recChatLog);
        List<dynamic> lst = recChatMap["chat"]
            .map((value) => ChatMessage.mesgFromFile(value))
            .toList();
        List<ChatMessage> recChtMsgs = [];
        for (var value in lst) {
          recChtMsgs.add(value);
        }
        SensorHelper.sensorData.swapChat("chatbot/user", recChtMsgs);
      }
    } catch (e) {
      debugPrint("Error reading chat: $e");
    }
  }

  /// Appends a [message] to the specified file [fileName] in the config directory.
  ///
  /// This method ensures that the provided chat message is added to the respective chat log file.
  /// If the file doesn't exist, it creates a new one and stores the message there.
  ///
  /// [message]: The `ChatMessage` object to append to the file.
  /// [fileName]: The name of the file where the message should be appended (e.g., `/cbuser.json`).
  void _appendChatMesg(ChatMessage message, String fileName) {
    try {
      debugPrint(Params.configDirectory);
      File fd = File(Params.configDirectory! + fileName);
      if (fd.existsSync()) {
        String messages = fd.readAsStringSync();
        Map<String, dynamic> messagesMap = jsonDecode(messages);
        List<dynamic> mesgList = messagesMap["chat"];
        Map<String, dynamic> newMessage = message.mesgForFile();
        mesgList.add(newMessage);
        Map<String, dynamic> newContent = {
          "chat": mesgList,
        };
        fd.writeAsStringSync(jsonEncode(newContent));
      } else {
        List<dynamic> mesgList = List<dynamic>.empty(growable: true);
        Map<String, dynamic> newMessage = message.mesgForFile();
        mesgList.add(newMessage);
        Map<String, dynamic> newContent = {
          "chat": mesgList,
        };
        fd.writeAsStringSync(jsonEncode(newContent));
      }
    } catch (e) {
      debugPrint("Error appending chat message to file $fileName: $e");
    }
  }
}
