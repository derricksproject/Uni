import 'dart:convert';
import 'package:flutter_allianz/config/default_settings.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/data/services/file_service.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/enums/settings.dart';
import 'package:flutter_allianz/models/value_with_unit.dart';
import 'package:path_provider/path_provider.dart';

/// The `SettingsController` class manages the application settings, including
/// board settings, photobioreactor settings, and miscellaneous settings. It
/// provides functionality to load, save, reset, and manage settings for various
/// categories and devices. The settings are stored in JSON format, and the
/// controller allows for both initialization with default values and loading
/// from saved configurations.
///
/// **Author**: Timo Gehrke
class SettingsController {
  String filePath = '${Params.configDirectory}/configs';

  SettingsController._privateConstructor();
  static final SettingsController _instance =
      SettingsController._privateConstructor();
  static SettingsController get instance => _instance;

  late Map<String, Map<String, ValueWithUnit>> _boardSettings = {};
  late Map<String, Map<String, ValueWithUnit>> _photobioreactorSettings = {};
  late Map<String, Map<String, ValueWithUnit>> combinedSettings = {
    ..._boardSettings,
    ..._photobioreactorSettings,
  };

  late Map<String, dynamic> miscSettings = {};

  /// Helper method to create a map of settings for a category.
  ///
  /// The map is composed of limit values represented by `ValueWithUnit` for different ranges
  /// (lower limit, yellow limits, min/max OK limits, etc.) for a specific unit of measurement.
  Map<String, ValueWithUnit> createMap(
      double lowerLimit,
      double yellowLowerLimit,
      double minOk,
      double maxOk,
      double yellowUpperLimit,
      double upperLimit,
      String unit) {
    Map<String, ValueWithUnit> result = {
      Limits.lowerLimit.string: ValueWithUnit(lowerLimit, unit),
      Limits.yellowLowerLimit.string: ValueWithUnit(yellowLowerLimit, unit),
      Limits.minOk.string: ValueWithUnit(minOk, unit),
      Limits.maxOk.string: ValueWithUnit(maxOk, unit),
      Limits.yellowUpperLimit.string: ValueWithUnit(yellowUpperLimit, unit),
      Limits.upperLimit.string: ValueWithUnit(upperLimit, unit)
    };

    return result;
  }

  /// Resets the board settings to default values from the `defaultBoardSettings`.
  Future<void> resetBoardSettings() async {
    defaultBoardSettings.forEach((category, defaultValues) {
      if (_boardSettings.containsKey(category)) {
        defaultValues.forEach((key, defaultValue) {
          if (_boardSettings[category]!.containsKey(key)) {
            _boardSettings[category]![key]!.setValue(defaultValue.getValue());
          } else {
            _boardSettings[category]![key] = defaultValue;
          }
        });
      } else {
        _boardSettings[category] = defaultValues;
      }
    });
  }

  /// Resets the photobioreactor settings to default values from `defaultPbrSettings`.
  Future<void> resetPhotobioreactorSettings() async {
    defaultPbrSettings.forEach((category, defaultValues) {
      if (_photobioreactorSettings.containsKey(category)) {
        defaultValues.forEach((key, defaultValue) {
          if (_photobioreactorSettings[category]!.containsKey(key)) {
            _photobioreactorSettings[category]![key]!
                .setValue(defaultValue.getValue());
          } else {
            _photobioreactorSettings[category]![key] = defaultValue;
          }
        });
      } else {
        _photobioreactorSettings[category] = defaultValues;
      }
    });
  }

  /// Initializes the standard board settings with the default values.
  Future<void> initializeBoardSettings() async {
    _boardSettings = {
      Categories.boardTemperature.name: createMap(18, 18, 25, 32, 35, 36, '°C'),
      Categories.boardPressure.name:
          createMap(900, 920, 950, 1040, 1080, 1100, 'hPa'),
      Categories.boardO2.name: createMap(0, 18, 21, 23, 25, 35, '%'),
      Categories.boardCo2.name: createMap(0, 0, 300, 2900, 3000, 4000, 'ppm'),
      Categories.boardCo.name: createMap(0, 0, 0, 100, 150, 200, 'ppm'),
      Categories.boardO3.name: createMap(0, 0, 0, 100, 150, 200, 'ppb'),
      Categories.boardHumidity.name: createMap(0, 0, 40, 95, 100, 100, '%')
    };
  }

  /// Initializes the standard photobioreactor settings with the default values..
  Future<void> initializePhotobioreactorSettings() async {
    _photobioreactorSettings = {
      Categories.pbrTemperatureL.name:
          createMap(18, 18, 25, 32, 35, 36, '°C'),
      Categories.pbrTemperatureG.name:
          createMap(18, 18, 25, 32, 35, 36, '°C'),
      Categories.pbrPressureG.name:
          createMap(900, 920, 950, 1040, 1080, 1100, 'hPa'),
      Categories.pbrDissolvedO2L.name:
          createMap(0, 3, 5, 15, 16, 20, 'mg/L'),
      Categories.pbrO2G.name: createMap(0, 18, 21, 35, 35, 35, '%'),
      Categories.pbrCo2G.name:
          createMap(0, 0, 0, 400, 1000, 3000, 'ppm'),
      Categories.pbrHumidityG.name:
          createMap(0, 18, 21, 35, 35, 35, '%'),
      Categories.pbrPHL.name: createMap(0, 5, 6, 11, 12, 14, ''),
      Categories.pbrOpticalDensityL.name:
          createMap(0, 0, 0.1, 0.9, 1, 1, ''),
    };
  }

  /// Saves all settings as a JSON file.
  Future<void> saveSettings() async {
    final combinedSettings = {
      'boardSettings': _boardSettings,
      'photobioreactorSettings': _photobioreactorSettings,
    };

    await FileService().saveAsJson(combinedSettings, filePath);
  }

  /// Saves miscellaneous settings to a JSON file.
  Future<void> saveMiscSettings() async {
    final directory = await getApplicationSupportDirectory();
    await FileService()
        .saveAsJson(miscSettings, "${directory.path}/configs/miscConfigs.json");
  }

  /// Loads miscellaneous settings from a JSON file.
  Future<void> loadMiscSettings() async {
    final directory = await getApplicationSupportDirectory();
    String? jsonString = await FileService()
        .loadJson("${directory.path}/configs/miscConfigs.json");
    if (jsonString != null) {
      miscSettings = jsonDecode(jsonString);
    } else {
      miscSettings = {
        "userName": "NewUser123",
        "amountBoards": 4,
        "amountPBR": 1,
      };
      saveMiscSettings();
    }
  }

  /// Loads all settings (board and photobioreactor) from a JSON file.
  Future<void> loadSettings() async {
    String? jsonString = await FileService().loadJson(filePath);
    if (jsonString != null) {
      Map<String, dynamic> decodedMap = jsonDecode(jsonString);
      if (decodedMap['boardSettings'] != null) {
        final boardSettingsRaw =
            decodedMap['boardSettings'] as Map<String, dynamic>;
        boardSettingsRaw.forEach((key, value) {
          _boardSettings[key] = Map<String, ValueWithUnit>.from(
            (value as Map).map((innerKey, innerValue) {
              var decodedValue = innerValue as Map<String, dynamic>;
              return MapEntry(innerKey, ValueWithUnit.fromJson(decodedValue));
            }),
          );
        });
      }

      if (decodedMap['photobioreactorSettings'] != null) {
        final photobioreactorSettingsRaw =
            decodedMap['photobioreactorSettings'] as Map<String, dynamic>;
        photobioreactorSettingsRaw.forEach((key, value) {
          _photobioreactorSettings[key] = Map<String, ValueWithUnit>.from(
            (value as Map).map((innerKey, innerValue) {
              var decodedValue = innerValue as Map<String, dynamic>;
              return MapEntry(innerKey, ValueWithUnit.fromJson(decodedValue));
            }),
          );
        });
      }
    } else {
      initializeBoardSettings();
      initializePhotobioreactorSettings();
      saveSettings();
    }
  }

  /// Returns the settings for a specific category and key, based on the specified `SettingsType`.
  Map<String, ValueWithUnit> getSettings(SettingsType type, String key) {
    final Map<String, Map<String, ValueWithUnit>> settings =
        type == SettingsType.board ? _boardSettings : _photobioreactorSettings;

    if (!settings.containsKey(key)) {
      throw ArgumentError('Key not found: $key');
    }
    return settings[key]!;
  }

  /// Retrieves settings from a specific category based on a topic string.
  Map<String, ValueWithUnit> getSettingsfromTopic(String topic) {
    topic = topic
        .replaceAll(RegExp(r'board\d+'), 'boardX')
        .replaceAll(RegExp(r'pbr\d+'), 'pbrX')
        .replaceAll(RegExp(r'\d+_am'), 'X_am');

    String? key = CategoriesExtension.fromTopic(topic)?.name;
    if (combinedSettings.containsKey(key)) {
      return combinedSettings[key]!;
    } else {
      throw ArgumentError('No settings found for category: $key');
    }
  }

  /// Returns all the board settings as a map.
  Map<String, Map<String, ValueWithUnit>> getAllBoardSettings() {
    return _boardSettings;
  }

   /// Returns all the photobioreactor settings as a map.
  Map<String, Map<String, ValueWithUnit>> getAllPhotobioreactorSettings() {
    return _photobioreactorSettings;
  }
}
