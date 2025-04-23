/// Enum representing the various threshold limits for sensor readings.
///
/// **Author**: Timo Gehrke
enum Limits {
  lowerLimit,
  yellowLowerLimit,
  minOk,
  maxOk,
  yellowUpperLimit,
  upperLimit,
}

extension LimitsExtension on Limits {
  String get string {
    switch (this) {
      case Limits.lowerLimit:
        return 'Lower Limit';
      case Limits.yellowLowerLimit:
        return 'Yellow Lower Limit';
      case Limits.minOk:
        return 'Min OK';
      case Limits.maxOk:
        return 'Max OK';
      case Limits.yellowUpperLimit:
        return 'Yellow Upper Limit';
      case Limits.upperLimit:
        return 'Upper Limit';
    }
  }
}
