/// A class representing a value with an associated unit of measurement.
///
/// The `ValueWithUnit` class is used to store a numerical value along with its corresponding
/// unit of measurement, and provides methods to manage the value, as well as serialize and
/// deserialize it to/from JSON format.
/// 
/// Author: Timo Gehrke
class ValueWithUnit {
  double? value;
  final String unit;

  ValueWithUnit(this.value, this.unit);

  /// Sets the value of the `ValueWithUnit` object.
  ///
  /// **Parameters:**
  /// - `newValue`: The new value to assign to the `ValueWithUnit`.
  void setValue(double? newValue) => value = newValue;

  /// Gets the current value of the `ValueWithUnit` object.
  ///
  /// **Returns:** The current value (of type `double?`).
  double? getValue() => value;

  /// Converts the `ValueWithUnit` object to a JSON representation.
  ///
  /// **Returns:** A map with the `value` and `unit` of the object.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }

  /// Factory constructor to create a `ValueWithUnit` instance from a JSON object.
  ///
  /// **Parameters:**
  /// - `json`: A map containing `value` and `unit`.
  ///
  /// **Returns:** A `ValueWithUnit` instance.
  factory ValueWithUnit.fromJson(Map<String, dynamic> json) {
    return ValueWithUnit(
      json['value'] as double?,
      json['unit'] as String,
    );
  }
}