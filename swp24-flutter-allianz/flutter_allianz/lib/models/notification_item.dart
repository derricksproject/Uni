import 'package:flutter_allianz/application/time_handler.dart';
import 'package:flutter_allianz/config/settings_controller.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/models/value_with_unit.dart';
import 'package:flutter_allianz/enums/warnings.dart';

/// A model representing a notification for an out-of-range value from a topic
/// 
/// This class encapsulates the information of a notification, including the time the notification
/// was first added, the current time, the value that triggered the notification, the topic from which
/// the data came, and the warning type associated with the value.
///
/// It also includes methods for generating message content, updating the notification with new
/// warning statuses, and extracting information like units and categories based on the topic.
/// 
/// **Author**: Derrick Nyarko
class NotificationItem {
  final String timeFirstAdded;
  final String timeNow;
  final double value;
  final String topic; 
  final WarningType warningType;

  /// Creates a new instance of [NotificationItem].
  ///
  /// The constructor requires the value, time when the notification was first added, current time,
  /// the topic of the message, and the warning type.
  const NotificationItem({
    required this.value,
    required this.timeFirstAdded,
    required this.timeNow,
    required this.topic,
    required this.warningType,
  });

  /// Generates a message string for the notification based on its value and warning type.
  ///
  /// If the value is out of range, the message will indicate the out-of-range status with the value.
  /// If the warning is green, the message will indicate how long the value has been out of range.
  /// 
  /// Returns the formatted notification message string.
  String generateMessage() {
    String name = getNameFromTopic(topic);
    if(warningType != WarningType.green){
     return '$name out of range: ${value.toStringAsFixed(2)} ${getUnit(topic)}';
    }
    return '$name has been out of range from $timeFirstAdded to $timeNow';
  }

  /// Generates the title message for the notification.
  ///
  /// If the warning type is not green, the title will indicate a warning status.
  /// If the warning type is green, it will indicate the status of the monitored value.
  ///
  /// Returns the formatted message title string.
  String generateMessageTitle() {
    String name = getNameFromTopic(topic);
    if(warningType != WarningType.green) {
      return '$name Warning';
    } 
    return '$name Status';
  }

  /// Retrieves the unit of the value from the settings based on the topic.
  ///
  /// This function generates the generalized topic and looks up the unit from the settings.
  /// 
  /// Returns the unit as a string.
  String getUnit(topic) {
    topic = createGeneralTopic(topic);
    Map<String, ValueWithUnit> map = SettingsController.instance.getSettingsfromTopic(topic);
    return map[Limits.lowerLimit.string]!.unit;
  
  }

  /// Extracts a descriptive name from the given topic. 
  /// This helps map a topic like 'board1/temp1_am' to a more user-friendly name.
  ///
  /// The method creates a generalized topic and maps it to an appropriate category, such as
  /// Photobioreactor or Board. The final name is returned as the category's name.
  ///
  /// Returns the first word of the category name.
  String getNameFromTopic(topic) {
    topic = createGeneralTopic(topic);
    String value = CategoriesExtension.fromTopic(topic)!.name;
    return value.trim().split(' ').first;
  }

  /// Converts a topic to a generalized format by replacing numeric identifiers with placeholders.
  ///
  /// For example, the topic 'board1/temp1_am' will become 'boardX/tempX_am'. This helps to generalize
  /// topics for easier handling in code and reporting.
  ///
  /// Returns the generalized topic string.
  String createGeneralTopic(topic) {
    return topic
        .replaceAll(RegExp(r'board\d+'), 'boardX')
        .replaceAll(RegExp(r'pbr\d+'), 'pbrX')
        .replaceAll(RegExp(r'\d+_am'), 'X_am');
  }

  /// Creates a new [NotificationItem] instance with an updated warning type.
  ///
  /// If the current warning type is the same as the new one, it returns the current instance;
  /// otherwise, a new [NotificationItem] with the updated warning type is created and returned.
  ///
  /// Returns a new or the same [NotificationItem] based on the updated warning type.
  NotificationItem updateWarningType(WarningType newWarningType) {
    if (newWarningType == warningType) return this; 
    return NotificationItem(
      timeFirstAdded: timeFirstAdded,
      timeNow: TimeHandler().getCurrentTime().substring(0, 5),
      value: value,
      topic: topic,
      warningType: newWarningType,
    );
  }
}
