import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/models/value_with_unit.dart';

/// Stores all default limits
/// 
/// **Author**: Timo Gehrke
final Map<String, Map<String, ValueWithUnit>> defaultBoardSettings = {
  Categories.boardTemperature.name: {
    Limits.lowerLimit.string: ValueWithUnit(18, '°C'),
    Limits.yellowLowerLimit.string: ValueWithUnit(18, '°C'),
    Limits.minOk.string: ValueWithUnit(25, '°C'),
    Limits.maxOk.string: ValueWithUnit(32, '°C'),
    Limits.yellowUpperLimit.string: ValueWithUnit(35, '°C'),
    Limits.upperLimit.string: ValueWithUnit(36, '°C'),
  },
  Categories.boardPressure.name: {
    Limits.lowerLimit.string: ValueWithUnit(900, 'hPa'),
    Limits.yellowLowerLimit.string: ValueWithUnit(920, 'hPa'),
    Limits.minOk.string: ValueWithUnit(950, 'hPa'),
    Limits.maxOk.string: ValueWithUnit(1040, 'hPa'),
    Limits.yellowUpperLimit.string: ValueWithUnit(1080, 'hPa'),
    Limits.upperLimit.string: ValueWithUnit(1100, 'hPa'),
  },
  Categories.boardO2.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, '%'),
    Limits.yellowLowerLimit.string: ValueWithUnit(18, '%'),
    Limits.minOk.string: ValueWithUnit(21, '%'),
    Limits.maxOk.string: ValueWithUnit(23, '%'),
    Limits.yellowUpperLimit.string: ValueWithUnit(25, '%'),
    Limits.upperLimit.string: ValueWithUnit(35, '%'),
  },
    Categories.boardCo2.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, 'ppm'),
    Limits.yellowLowerLimit.string: ValueWithUnit(0, 'ppm'),
    Limits.minOk.string: ValueWithUnit(300, 'ppm'),
    Limits.maxOk.string: ValueWithUnit(2900, 'ppm'),
    Limits.yellowUpperLimit.string: ValueWithUnit(3000, 'ppm'),
    Limits.upperLimit.string: ValueWithUnit(4000, 'ppm'),
  },
    Categories.boardCo.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, 'ppm'),
    Limits.yellowLowerLimit.string: ValueWithUnit(0, 'ppm'),
    Limits.minOk.string: ValueWithUnit(0, 'ppm'),
    Limits.maxOk.string: ValueWithUnit(100, 'ppm'),
    Limits.yellowUpperLimit.string: ValueWithUnit(150, 'ppm'),
    Limits.upperLimit.string: ValueWithUnit(200, 'ppm'),
  },
    Categories.boardO3.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, 'ppb'),
    Limits.yellowLowerLimit.string: ValueWithUnit(0, 'ppb'),
    Limits.minOk.string: ValueWithUnit(0, 'ppb'),
    Limits.maxOk.string: ValueWithUnit(100, 'ppb'),
    Limits.yellowUpperLimit.string: ValueWithUnit(150, 'ppb'),
    Limits.upperLimit.string: ValueWithUnit(200, 'ppb'),
  },
    Categories.boardHumidity.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, '%'),
    Limits.yellowLowerLimit.string: ValueWithUnit(0, '%'),
    Limits.minOk.string: ValueWithUnit(40, '%'),
    Limits.maxOk.string: ValueWithUnit(95, '%'),
    Limits.yellowUpperLimit.string: ValueWithUnit(100, '%'),
    Limits.upperLimit.string: ValueWithUnit(100, '%'),
  },
};

final Map<String, Map<String, ValueWithUnit>> defaultPbrSettings = {
  Categories.pbrTemperatureL.name: {
    Limits.lowerLimit.string: ValueWithUnit(18, '°C'),
    Limits.yellowLowerLimit.string: ValueWithUnit(18, '°C'),
    Limits.minOk.string: ValueWithUnit(25, '°C'),
    Limits.maxOk.string: ValueWithUnit(32, '°C'),
    Limits.yellowUpperLimit.string: ValueWithUnit(35, '°C'),
    Limits.upperLimit.string: ValueWithUnit(36, '°C'),
  },
  Categories.pbrTemperatureG.name: {
    Limits.lowerLimit.string: ValueWithUnit(18, '°C'),
    Limits.yellowLowerLimit.string: ValueWithUnit(18, '°C'),
    Limits.minOk.string: ValueWithUnit(25, '°C'),
    Limits.maxOk.string: ValueWithUnit(32, '°C'),
    Limits.yellowUpperLimit.string: ValueWithUnit(35, '°C'),
    Limits.upperLimit.string: ValueWithUnit(36, '°C'),
  },
  Categories.pbrPressureG.name: {
    Limits.lowerLimit.string: ValueWithUnit(900, 'hPa'),
    Limits.yellowLowerLimit.string: ValueWithUnit(920, 'hPa'),
    Limits.minOk.string: ValueWithUnit(950, 'hPa'),
    Limits.maxOk.string: ValueWithUnit(1040, 'hPa'),
    Limits.yellowUpperLimit.string: ValueWithUnit(1080, 'hPa'),
    Limits.upperLimit.string: ValueWithUnit(1100, 'hPa'),
  },
  Categories.pbrDissolvedO2L.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, 'mg/L'),
    Limits.yellowLowerLimit.string: ValueWithUnit(3, 'mg/L'),
    Limits.minOk.string: ValueWithUnit(5, 'mg/L'),
    Limits.maxOk.string: ValueWithUnit(15, 'mg/L'),
    Limits.yellowUpperLimit.string: ValueWithUnit(16, 'mg/L'),
    Limits.upperLimit.string: ValueWithUnit(20, 'mg/L'),
  },
  Categories.pbrO2G.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, '%'),
    Limits.yellowLowerLimit.string: ValueWithUnit(18, '%'),
    Limits.minOk.string: ValueWithUnit(21, '%'),
    Limits.maxOk.string: ValueWithUnit(35, '%'),
    Limits.yellowUpperLimit.string: ValueWithUnit(35, '%'),
    Limits.upperLimit.string: ValueWithUnit(35, '%'),
  },
  Categories.pbrCo2G.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, 'ppm'),
    Limits.yellowLowerLimit.string: ValueWithUnit(0, 'ppm'),
    Limits.minOk.string: ValueWithUnit(0, 'ppm'),
    Limits.maxOk.string: ValueWithUnit(400, 'ppm'),
    Limits.yellowUpperLimit.string: ValueWithUnit(1000, 'ppm'),
    Limits.upperLimit.string: ValueWithUnit(3000, 'ppm'),
  },
  Categories.pbrHumidityG.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, '%'),
    Limits.yellowLowerLimit.string: ValueWithUnit(18, '%'),
    Limits.minOk.string: ValueWithUnit(21, '%'),
    Limits.maxOk.string: ValueWithUnit(35, '%'),
    Limits.yellowUpperLimit.string: ValueWithUnit(35, '%'),
    Limits.upperLimit.string: ValueWithUnit(35, '%'),
  },
  Categories.pbrPHL.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, ''),
    Limits.yellowLowerLimit.string: ValueWithUnit(5, ''),
    Limits.minOk.string: ValueWithUnit(6, ''),
    Limits.maxOk.string: ValueWithUnit(11, ''),
    Limits.yellowUpperLimit.string: ValueWithUnit(12, ''),
    Limits.upperLimit.string: ValueWithUnit(14, ''),
  },
  Categories.pbrOpticalDensityL.name: {
    Limits.lowerLimit.string: ValueWithUnit(0, ''),
    Limits.yellowLowerLimit.string: ValueWithUnit(0, ''),
    Limits.minOk.string: ValueWithUnit(0.1, ''),
    Limits.maxOk.string: ValueWithUnit(0.9, ''),
    Limits.yellowUpperLimit.string: ValueWithUnit(1, ''),
    Limits.upperLimit.string: ValueWithUnit(1, ''),
  },
};

