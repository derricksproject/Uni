import 'package:flutter_allianz/data/sensor_data.dart';
import 'package:flutter_allianz/models/chat_message.dart';
import 'package:flutter_allianz/network/mqqt_broker.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/data/backend_controller.dart';
import 'package:test/test.dart';

void main() {
  ControllerHelper.controller =
      Controller("localhost", 8086, "openhab", "password", "openhab_db");
  Controller controller = ControllerHelper.controller;
  BrokerHelper.broker = MqqtBroker("localhost");
  SensorHelper.sensorData = SensorData();

  group("Save and restore Chat [Connection to MQTT required]", () {
    test("append and restore", () {
      List<ChatMessage> list = [
        ChatMessage("user1", "Davey, how you doin?", DateTime.now().toString()),
        ChatMessage("user2", "About as good can be expected.", DateTime.now().toString()),
        ChatMessage("user2", "But the news is not good.", DateTime.now().toString())
      ];
      for (var mesg in list) {
        controller.sendMessage(mesg);
      }

      SensorHelper.sensorData.swapChat("chatbot/user", []);
      expect(SensorHelper.sensorData.getChatValue("chatbot/user"), []);
      controller.restoreChat();
      expect(SensorHelper.sensorData.getChatValue("chatbot/user"), list);
    });
  });
}