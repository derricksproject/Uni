import 'package:flutter_allianz/config/settings_controller.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/enums/warnings.dart';

/// A handler for determining notification levels based on configurable limits.
/// 
/// Author: Timo Gehrke
class NotificationsHandler {

  /// Checks the [value] for a given [topic] and returns a [WarningType] based on the configured limits.
  /// 
  /// - Retrives the settings for the provided [topic] from [SettingsController].
  /// - Compares the [value] against thresholds defined in [Limits].
  /// 
  /// Parameters:
  /// - [topic]: The topic whose settings determine the warning thresholds.
  /// - [value]: The value to be checked against the thresholds.
  /// 
  /// Returns:
  /// - [WarningType.red]: If the value is outside the yellow limits.
  /// - [WarningType.green] If the value is within the "OK" range.
  /// - [WarningType.yellow]: For any other case.
  WarningType checkValue (String topic, double value) {
    var settings = SettingsController.instance.getSettingsfromTopic(topic);
    double yellowLowerLimit = settings[Limits.yellowLowerLimit.string]!.value!;
    double yellowUpperLimit = settings[Limits.yellowUpperLimit.string]!.value!;
    double minOk = settings[Limits.minOk.string]!.value!;
    double maxOk = settings[Limits.maxOk.string]!.value!;
    
    if(value < yellowLowerLimit || value > yellowUpperLimit) {
        return WarningType.red;
      } else if (value >= minOk && value <= maxOk) {
        return WarningType.green;
      } else {
        return WarningType.yellow;
      }
  }
}