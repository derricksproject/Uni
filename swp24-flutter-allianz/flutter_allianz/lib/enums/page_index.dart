/// Enum representing all aviable pages.
///
/// **Author**: Timo Gehrke
enum PageIndex {
  startPage,
  //PBR Pages
  photobioreactor,
  opticalDensity,
  pbrHumidity,
  pbrO2,
  pbrCo2,
  pbrTemperature,
  pbrPressure,
  ph,
  //Board Pages
  sensorboards,
  temperature,
  pressure,
  //Air Quality subPages
  airQuality,
  o2,
  co2,
  co,
  o3,
  humidity,

  settings,
  chat,
  //Individual Boards/PBRs
  individualCharts,
  boards1,
  boards2,
  boards3,
  boards4,
  pbrs,
}

extension PageIndexExtension on PageIndex {
  String get title {
    switch (this) {
      case PageIndex.startPage:
        return 'Dashboard';
      // Sensorboard Pages
      case PageIndex.sensorboards:
        return 'Sensorboards';
      case PageIndex.temperature:
        return 'Temperature - All Boards';
      case PageIndex.pressure:
        return 'Pressure - All Boards';
      // Air Quality Subpages
      case PageIndex.airQuality:
        return 'Air Quality - All Boards';
      case PageIndex.co2:
        return 'CO\u2082 - All Boards';
      case PageIndex.o2:
        return 'O\u2082 - All Boards';
      case PageIndex.co:
        return 'CO - All Boards';
      case PageIndex.o3:
        return 'O\u2083 - All Boards';
      case PageIndex.humidity:
        return 'Humidity - All Boards';
      // PBR Pages
      case PageIndex.photobioreactor:
        return 'Photobioreactor';
      case PageIndex.pbrTemperature:
        return 'Temperature - All Photobioreactors';
      case PageIndex.pbrPressure:
        return 'Pressure - All Photobioreactors';
      case PageIndex.pbrO2:
        return 'O\u2802 - All Photobioreactors';
      case PageIndex.pbrCo2:
        return 'CO\u2082 - All Photobioreactors';
      case PageIndex.pbrHumidity:
        return 'Humidity - All Photobioreactors';
      case PageIndex.opticalDensity:
        return 'Optical Density - All Photobioreactors';
      case PageIndex.ph:
        return 'pH - All Photobioreactors';

      case PageIndex.settings:
        return 'Settings';
      case PageIndex.chat:
        return 'Chat';

      case PageIndex.individualCharts:
        return 'Individual Charts';
      case PageIndex.pbrs:
        return 'Individual Photobioreactors';
      case PageIndex.boards1:
        return 'Individual Sensor Boards';
      case PageIndex.boards2:
        return 'Boards #2';
      case PageIndex.boards3:
        return 'Boards #3';
      case PageIndex.boards4:
        return 'Boards #4';
    }
  }

  static PageIndex indexFromTopic(topic) {
    topic = topic
        .replaceAll(RegExp(r'board\d+'), 'boardX')
        .replaceAll(RegExp(r'pbr\d+'), 'pbrX')
        .replaceAll(RegExp(r'\d+_am'), 'X_am');
    switch (topic) {
      case 'boardX/amb_press':
        return PageIndex.pressure;
      case 'boardX/o2':
        return PageIndex.o2;
      case 'boardX/co2':
        return PageIndex.co2;
      case 'boardX/co':
        return PageIndex.co;
      case 'boardX/o3':
        return PageIndex.o3;
      case 'boardX/tempX_am':
        return PageIndex.temperature;
      case 'boardX/humidX_am':
        return PageIndex.humidity;

      case 'pbrX/amb_press_2':
        return PageIndex.pbrPressure;
      case 'pbrX/o2_2':
        return PageIndex.pbrO2;
      case 'pbrX/co2_2':
        return PageIndex.pbrCo2;
      case 'pbrX/temp_g_2':
        return PageIndex.pbrTemperature;
      case 'pbrX/temp_1':
        return PageIndex.pbrTemperature;
      case 'pbrX/do':
        return PageIndex.pbrO2;
      case 'pbrX/od':
        return PageIndex.opticalDensity;
      case 'pbrX/ph':
        return PageIndex.ph;
      case 'pbrX/rh_2':
        return PageIndex.humidity;

      default:
        return PageIndex.startPage;
    }
  }
}
