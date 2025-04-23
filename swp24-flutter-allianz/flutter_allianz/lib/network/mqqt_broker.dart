// ignore_for_file: duplicate_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/chat_message.dart';

import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/network/topics.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// A class representing an MQTT client to connect, subscribe, and publish messages to an MQTT broker.
///
/// The MqqtBroker class manages the connection to an MQTT broker, subscribes to predefined topics, 
/// listens for incoming messages, and publishes messages to the broker. It also handles 
/// reconnection attempts if the connection to the broker is lost.
///
/// **Author**: Steffen Gebhard
class MqqtBroker {
  late MqttServerClient client;
  late String address;
  late Stream<List<MqttReceivedMessage>>? mqttStream;
  bool connectionStatus = false;

  final List<String> topics = fullTopics;

  /// Constructs an [MqqtBroker] object, initializing the MQTT client with the given [brokerAddress].
  /// 
  /// The constructor sets the broker's address, creates an MQTT server client, and assigns the
  /// callback functions for handling connection and disconnection events.
  ///
  /// [brokerAddress] - The address of the MQTT broker to connect to.
  MqqtBroker(brokerAddress) {
    address = brokerAddress;
    client = MqttServerClient('127.0.0.1', '123');
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
  }

  /// Callback function that is triggered when the MQTT client successfully connects to the broker.
  ///
  /// It updates the [connectionStatus] to `true` and subscribes to the topics defined in the class.
  void onConnected() {
    connectionStatus = true;
    debugPrint('Connected to MQTT Broker');
    subscribeToTopics();
  }

  /// Callback function that is triggered when the MQTT client disconnects from the broker.
  ///
  /// It sets [connectionStatus] to `false` and attempts to reconnect to the broker.
  Future<void> onDisconnected() async {
    connectionStatus = false;
    debugPrint('Disconnected from MQTT Broker. Trying to reconnect...');
    connect();
  }

  Future<void> connect() async {
    try {
      await client.connect();
    } catch (e) {
      debugPrint("Connection failed: $e");
    }
  }

  /// Subscribes the MQTT client to a list of topics.
  ///
  /// This method subscribes to all topics defined in the [topics] list and listens for incoming
  /// messages on those topics. It also processes the messages and stores either chat data or sensor data.
  void subscribeToTopics() {
    for (var topic in topics) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
    mqttStream = client.updates?.asBroadcastStream();

    client.updates?.listen((List<MqttReceivedMessage> messages) {
      final message = messages[0].payload as MqttPublishMessage;
      final payload = message.payload.message;
      final receivedTopic = messages[0].topic;
      final time = DateTime.now();

      if (receivedTopic == "chatbot/user" ||
          receivedTopic == "chatbot/mission_control") {
        String valAsString = MqttPublishPayload.bytesToStringAsString(payload);
        Map<String, dynamic> payloadMap = jsonDecode(valAsString);
        ChatMessage mesg = ChatMessage.fromJson(payloadMap);
        SensorHelper.sensorData.addChatValue(receivedTopic, mesg);
      } else {
        SensorHelper.sensorData
            .addValue(receivedTopic, payload, time.toIso8601String());
      }
    });
  }

  /// Publishes a message to the specified topic on the MQTT broker.
  ///
  /// This method sends a message to the broker using the given [topic] and [payload].
  ///
  /// [topic] - The MQTT topic where the message should be published.
  /// [payload] - The message to send to the topic.
  void publishMessage(String topic, String payload) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    debugPrint('Message published to $topic: ');
  }

  /// Disconnects the MQTT client from the broker.
  ///
  /// This method gracefully disconnects the client from the broker.
  void disconnect() {
    client.disconnect();
  }
}
