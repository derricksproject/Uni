import 'package:flutter_allianz/data/sensor_data.dart';
import 'package:flutter_allianz/models/chat_message.dart';
import 'package:flutter_allianz/network/mqqt_broker.dart';
// ignore: depend_on_referenced_packages
import 'package:test/test.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/data/backend_controller.dart';

void main() {
  ControllerHelper.controller =
      Controller("localhost", 8086, "openhab", "password", "openhab_db");
  Controller controller = ControllerHelper.controller;
  BrokerHelper.broker = MqqtBroker("localhost");
  SensorHelper.sensorData = SensorData();

  group("Influx Test [Connection to InfluxDB is required]", () {
    test("Check for non existent measurement", () async {
      bool existence =
          await controller.measurementExists("This_should_not_exist");
      expect(existence, false);
    });

    test("Check for existent measurement", () async {
      bool existence = await controller.measurementExists("board1_temp1_am");
      expect(existence, true);
    });

    test("Correct query", () async {
      Map<String, dynamic> responseMap =
          await controller.query("select * from board1_temp1_am limit 1");

      expect(responseMap["name"], "board1_temp1_am");
      expect(responseMap["columns"][0], "time");
      expect(responseMap["columns"][1], "value");
      expect(responseMap["values"].length, 1);
    });

    test("Correct query2", () async {
      Map<String, dynamic> responseMap =
          await controller.query("select * from board1_temp1_am limit 1000");

      expect(responseMap["name"], "board1_temp1_am");
      expect(responseMap["columns"][0], "time");
      expect(responseMap["columns"][1], "value");
      expect(responseMap["values"].length, 1000);
    });

    test("Bad query", () async {
      expect(controller.query("select * form board1_temp1_am limt -1"),
          throwsA(predicate((e) => e == "Bad Request")));
    });
  });

  group("MQTT Test [Connection to MQTT-Broker is required]", () {
    test("getTopicStream with existing topic", () async {
      await connect();
      Stream<double> stream = controller.getTopicStream("board4/o3");
      stream.listen((value) {
        expect(value.runtimeType, double);
      });
    });

    test("aqiStream test", () async {
      await connect();
      Stream<double> stream = controller.aqiStream();
      stream.listen((value) {
        expect(value.runtimeType, double);
      });
    });

    test("avgStream test", () async {
      List<Stream<double>> boards = [
        controller.getTopicStream("board1/o3"),
        controller.getTopicStream("board2/o3"),
        controller.getTopicStream("board3/o3"),
        controller.getTopicStream("board4/o3"),
      ];

      await connect();
      Stream<double> stream = controller.avgStream(boards);
      stream.listen((value) {
        expect(value.runtimeType, double);
      });
    });

    test("ChatStream test", () async {
      await connect();
      Stream<ChatMessage> stream =
          controller.getChatStream("chatbot/mission_control");
      stream.listen((value) {
        expect(value.runtimeType, ChatMessage);
      });
    });

    test("tempAvg test", () async {
      await connect();
      Stream<double> stream = controller.tempAvgStream();
      stream.listen((value) {
        expect(value.runtimeType, double);
      });
    });

    test("humidAvg test", () async {
      await connect();
      Stream<double> stream = controller.humidAvgStream();
      stream.listen((value) {
        expect(value.runtimeType, double);
      });
    });
  });
}
