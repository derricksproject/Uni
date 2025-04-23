
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_allianz/network/mqqt_broker.dart';
import 'package:flutter_allianz/data/sensor_data.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/config/settings_controller.dart';
import 'package:flutter_allianz/presentation/pages/skeleton.dart';
import 'package:flutter_allianz/data/backend_controller.dart';

/// A helper class to manage the MQTT broker connection.
class BrokerHelper {
  static late final MqqtBroker broker;
}

/// A helper class to manage sensor data.
class SensorHelper {
  static late final SensorData sensorData;
}

/// A helper class to manage backend operations via the `Controller`.
class ControllerHelper {
  static late final Controller controller;
}


/// Establishes a connection to the MQTT broker.
///
/// The function continuously attempts to connect to the broker until
/// the connection is successfully established. It retries every 5 seconds
Future<void> connect() async {
  while (!BrokerHelper.broker.connectionStatus) {
    try {
      await BrokerHelper.broker.connect();
    } catch (e) {
      debugPrint("Connection failed: $e");
    }
    await Future.delayed(Duration(seconds: 5));
  }
}


/// The main entry point for the Flutter application.
///
/// This function initializes all necessary components asynchronously before starting the application.
/// - Ensures Flutter bindings are initialized.
/// - Loads miscellaneous and core application settings.
/// - Configures the MQTT broker connection.
/// - Initializes application parameters.
/// - Establishes sensor data handling and controller setup.
/// - Restores chat data before launching the app.
///
/// **Starts**: The `MyApp` widget as the root of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Params.initializeParams();
  await SettingsController.instance.loadMiscSettings();

  BrokerHelper.broker = MqqtBroker(Params.mqttAddress);
  connect();
  SensorHelper.sensorData = SensorData();
  ControllerHelper.controller = Controller(Params.influxAddress, Params.influxPort, Params.influxUser, Params.influxPassword, Params.influxName);
  ControllerHelper.controller.restoreChat();

  
  
  await SettingsController.instance.loadSettings();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MyApp());
  });
}

/// Builds the main application widget tree.
///
/// - Uses `MaterialApp` with system-controlled light and dark themes.
/// - Dark theme: `ThemeData.dark()`, Light theme: `ThemeData.light()`.
/// - `themeMode: ThemeMode.system` allows automatic theme switching.
/// - Sets `Skeleton` as the home widget, which serves as the main dashboard.
///
/// **Returns**: A configured `MaterialApp` widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.system,
      home: Skeleton(title: 'Dashboard'),
    );
  }
}

