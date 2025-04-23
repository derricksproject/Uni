import 'package:flutter_allianz/enums/settings.dart';

/// Enum representing various categories of sensors and their associated measurements.
///
/// These categories are used to organize and label sensor data, both for board sensors
/// and photobioreactor (PBR) sensors. Each category corresponds to a specific measurement
/// or metric being monitored.
/// 
/// **Author**: Timo Gehrke
enum Categories {
  boardTemperature,
  boardPressure,
  boardAirQuality,
  boardO2,
  boardCo,
  boardCo2,
  boardO3,
  boardHumidity,

  pbrTemperatureL,
  pbrTemperatureG,
  pbrPressureG,
  pbrDissolvedO2L,
  pbrO2G,
  pbrCo2G,
  pbrHumidityG,
  pbrOpticalDensityL,
  pbrPHL,
}

/// Extension providing utility methods for the `Categories` enum.
///
/// This extension includes methods to retrieve sensor topics and names as strings,
/// as well as utility methods to map topics and names to their corresponding categories.
extension CategoriesExtension on Categories {

  /// Returns the topic associated with the given sensor category.
  ///
  /// Topics represent the MQTT or communication topic associated with the sensor.
  /// Each category has a specific topic it listens to for updates.
  String get topic{
    switch(this) {
      case Categories.boardPressure:
        return 'boardX/amb_press';
      case Categories.boardO2:
        return 'boardX/o2';
      case Categories.boardCo2:
        return 'boardX/co2';
      case Categories.boardCo:
        return 'boardX/co';
      case Categories.boardO3:
        return 'boardX/o3';
      case Categories.boardTemperature:
        return 'boardX/tempX_am';
      case Categories.boardHumidity:
        return 'boardX/humidX_am';
      case Categories.boardAirQuality:
        return '';
      case Categories.pbrPressureG:
        return 'pbrX/amb_press_2';
      case Categories.pbrO2G:
        return 'pbrX/o2_2';
      case Categories.pbrCo2G:
        return 'pbrX/co2_2';
      case Categories.pbrTemperatureG:
        return 'pbrX/temp_g_2';
      case Categories.pbrTemperatureL:
        return 'pbrX/temp_1';
      case Categories.pbrDissolvedO2L:
        return 'pbrX/do';
      case Categories.pbrOpticalDensityL:
        return 'pbrX/od';
      case Categories.pbrPHL:
        return 'pbrX/ph';
      case Categories.pbrHumidityG:
        return 'pbrX/rh_2';  
    }
  }


  /// Returns the name associated with the given sensor category.
  ///
  /// Names are human-readable strings that describe the specific sensor or measurement
  /// associated with a category. Mainly used as titles.
  ///
  String get name{
    switch(this) {
      case Categories.pbrPressureG:
        return 'Pressure (Outlet, g)';
      case Categories.pbrO2G:
        return 'Oxygen (Outlet, g)';
      case Categories.pbrCo2G:
        return 'Carbondioxide (Outlet, g)';
      case Categories.pbrTemperatureG:
        return 'Temperature (Outlet, g)';
      case Categories.pbrTemperatureL:
        return 'Temperature (Reactor, l)';
      case Categories.pbrDissolvedO2L:
        return 'Dissolved Oxygen (Reactor, l)';
      case Categories.pbrOpticalDensityL:
        return 'Optical Density (Reactor, l)';
      case Categories.pbrPHL:
        return 'pH (Reactor, l)';
      case Categories.pbrHumidityG:
        return 'Humidity (Outlet, g)';
      case Categories.boardPressure:
        return 'Pressure';
      case Categories.boardO2:
        return 'Oxygen';
      case Categories.boardCo2:
        return 'Carbondioxide';
      case Categories.boardCo:
        return 'Carbonmonooxide';
      case Categories.boardO3:
        return 'Ozon';
      case Categories.boardTemperature:
        return 'Temperature';
      case Categories.boardHumidity:
        return 'Humidity';
      case Categories.boardAirQuality:
        return 'Air Quality';
    }
  }

  /// Returns the `Categories` enum value corresponding to the provided topic string.
  ///
  /// This method helps in determining the category of a sensor from its associated topic.
    static Categories? fromTopic(String topic) {
    try {
      return Categories.values.firstWhere(
        (category) => category.topic == topic
      );
    } catch (e) {
      return null;
    }
  }

  /// Returns the `Categories` enum value corresponding to the provided name string.
  ///
  /// This method helps in determining the category of a sensor from its human-readable name.
  static Categories? fromName(String name) {
    try {
      return Categories.values.firstWhere(
      (category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Returns the SettingsType corresponding to the provided topic string.
  ///
  /// This method helps in determining the category of a sensor from its human-readable name.
  static SettingsType getSettingsTypeFromTopic(String topic) {
    if(topic.startsWith("board")) {
      return SettingsType.board;
    }
    return SettingsType.photobioreactor;
  }
}