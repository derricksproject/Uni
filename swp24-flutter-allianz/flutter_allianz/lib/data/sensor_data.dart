
import 'package:flutter_allianz/models/chat_message.dart';
import 'package:flutter_allianz/network/topics.dart';
import 'package:typed_data/typed_data.dart';

/// This class represents a storage system for sensor data and chat messages
/// that have been received via MQTT.
///
/// It maintains two separate collections: one for storing sensor values and 
/// one for storing chat messages. Each type of data is indexed by its respective
/// MQTT topic or key.
/// 
/// **Author**: Krishnen Ganeshakumar 
class SensorData {
  final Map<String, List<List<dynamic>>> _values = {
    for (var topic in fullTopics) topic: [],
    "aqiValues": [],
  };

  final Map<String, List<ChatMessage>> _chatValues = {
    "chatbot/user": [],
    "chatbot/mission_control": [],
  };

  /// Stores a sensor data value in the storage.
  ///
  /// This method stores the given [value] as a [Uint8Buffer] in the internal 
  /// storage and associates it with the given [key] (typically the MQTT topic).
  /// The [time] parameter is used to record the timestamp when the value was received.
  ///
  /// [key] - The key (usually the MQTT topic) under which the sensor data is stored.
  /// [value] - The sensor data as a [Uint8Buffer].
  /// [time] - The timestamp when the data was received.
  ///
  /// Throws an [ArgumentError] if the given [key] does not exist in the storage.
  void addValue(String key, Uint8Buffer value, String time) {
    if (_values.containsKey(key)) {
      _values[key]!.add([time, value]);
    } else {
      throw ArgumentError("Key $key does not exist in storage.");
    }
  }

  /// Stores a chat message in the storage.
  ///
  /// This method stores the provided [message] (a [ChatMessage]) in the internal 
  /// storage, indexed by the given [key] (usually the MQTT topic for chat).
  ///
  /// [key] - The key (usually the MQTT topic) under which the chat message is stored.
  /// [message] - The chat message to be stored, represented as a [ChatMessage].
  ///
  /// Throws an [ArgumentError] if the given [key] does not exist in the storage.
  void addChatValue(String key, ChatMessage message) {
    if (_chatValues.containsKey(key)) {
      _chatValues[key]!.add(message);
    } else {
      throw ArgumentError("Key $key does not exist in storage.");
    }
  }

  /// Retrieves the stored values for a specific key (non-chat data).
  ///
  /// This method returns a list of [List<dynamic>] representing the stored sensor 
  /// values for a given [key]. Each list contains a timestamp and a corresponding 
  /// sensor value.
  ///
  /// [key] - The key (usually the MQTT topic) for which to retrieve the stored values.
  ///
  /// Returns a list of [List<dynamic>] where each list contains the timestamp and 
  /// the sensor data.
  ///
  /// Throws an [ArgumentError] if the given [key] does not exist in the storage.
  List<List<dynamic>> getValue(String key) {
    if (_values.containsKey(key)) {
      return _values[key]!;
    } else {
      throw ArgumentError("Key $key does not exist in storage.");
    }
  }

  /// Retrieves the stored chat messages for a specific key.
  ///
  /// This method returns a list of [ChatMessage] objects representing the stored
  /// chat messages for the given [key].
  ///
  /// [key] - The key (usually the MQTT topic) for which to retrieve the stored chat messages.
  ///
  /// Returns a list of [ChatMessage] objects representing the chat messages stored 
  /// under the given [key].
  ///
  /// Throws an [ArgumentError] if the given [key] does not exist in the storage.
  List<ChatMessage> getChatValue(String key) {
    if (_chatValues.containsKey(key)) {
      return _chatValues[key]!;
    } else {
      throw ArgumentError("Key $key does not exist in storage.");
    }
  }



  /// Replaces the current chat messages for a specific key with new messages.
  ///
  /// This method allows you to replace the existing list of chat messages under 
  /// a specific [key] with a new list of [ChatMessage] objects.
  ///
  /// [key] - The key (usually the MQTT topic) for which to replace the stored chat messages.
  /// [newMessages] - A list of [ChatMessage] objects that will replace the existing chat messages.
  ///
  /// Throws an [ArgumentError] if the given [key] does not exist in the storage.
  void swapChat(String key, List<ChatMessage> newMessages) {
    if (_chatValues.containsKey(key)) {
      _chatValues[key] = newMessages;
      return;
    } else {
      throw ArgumentError("Key $key does not exist in storage.");
    }
  }
}
