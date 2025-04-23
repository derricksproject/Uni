import 'dart:io';
import 'package:flutter_allianz/config/settings_controller.dart';
import 'package:path_provider/path_provider.dart';


/// A utility class that handles parameters related to file paths, directories,
/// and settings required for an application.
///
/// The `Params` class manages directories for storing images and configurations,
/// and initializes necessary parameters from the application's settings.
/// 
/// **Author**: Timo Gehrke
class Params {
  static String? imageDirectory;
  static String? configDirectory;
  static String? filePath;
  static List<String> imageExtensions = ['.png','.jpg', '.jpeg', '.bmp','.gif'];
  static String userName = SettingsController.instance.miscSettings["userName"];
  static int amountBoards = SettingsController.instance.miscSettings["amountBoards"];
  static int amountPbrs = SettingsController.instance.miscSettings["amountPBR"];

  // MQTT configs
  static String mqttAddress = "localhost";

  //InfluxDb configs
  static String influxAddress = "localhost";
  static int influxPort = 8086;
  static String influxUser = "openhab";
  static String influxPassword = "password";
  static String influxName = "openhab_db";
  
  static Future<void> initializeParams() async {
    await initializeFilePath();
    

    imageDirectory = '$filePath/images';
    configDirectory = '$filePath/configs';

    await createDirectories();
  }

  static Future<void> initializeFilePath() async {
    final directory = await getApplicationSupportDirectory();
    filePath = directory.path;
  }

  static Future<void> createDirectories() async {
    if (imageDirectory != null) {
      final imageDir = Directory(imageDirectory!);
      if(!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
    }

    if (configDirectory != null) {
      final configDir = Directory(configDirectory!);
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
    }
  }

}
