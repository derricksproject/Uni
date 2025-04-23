import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/stream_handler.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/settings.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/data.dart';
import 'package:flutter_allianz/presentation/widgets/chart.dart';
import 'package:flutter_allianz/presentation/widgets/styled/styled_tabbar.dart';
import 'package:flutter_allianz/presentation/widgets/tachometer/tachometer.dart';

/// A StatefulWidget that represents the Photobioreactor (PBR) monitoring system.
///
/// This widget displays two tabs for monitoring the following:
/// - Outlet: Includes sensor data related to the outlet (temperature, pressure, CO2, O2, and humidity).
/// - Liquid: Includes sensor data related to the liquid side (temperature, dissolved oxygen, pH, and optical density).
///
/// Each tab contains a set of tachometers and charts that display real-time sensor data.
///
/// **Author**: Timo Gehrke
class Photobioreactor extends StatefulWidget {
  const Photobioreactor({super.key});

  @override
  State<Photobioreactor> createState() => _PhotobioreactorState();
}

class _PhotobioreactorState extends State<Photobioreactor>
    with SingleTickerProviderStateMixin {
  late final StreamHandler streamHandler = StreamHandler();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  List<Categories> pbrCategoriesOutlet = [
    Categories.pbrTemperatureG,
    Categories.pbrPressureG,
    Categories.pbrCo2G,
    Categories.pbrO2G,
    Categories.pbrHumidityG,
  ];

  List<Categories> pbrCategoriesLiquid = [
    Categories.pbrTemperatureL,
    Categories.pbrDissolvedO2L,
    Categories.pbrPHL,
    Categories.pbrOpticalDensityL,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StyledTabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Outlet'),
              Tab(text: 'Liquid'),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                _buildTabView(pbrCategoriesOutlet),
                _buildTabView(pbrCategoriesLiquid),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Outlet tab view containing tachometers and charts for outlet sensors.
  ///
  /// The Outlet tab displays sensor data related to the outlet, including:
  /// - Temperature
  /// - Pressure
  /// - CO2
  /// - O2
  /// - Humidity
  ///
  /// The data is shown in tachometers as well as line charts.
  Widget _buildTabView(List<Categories> pbrCategories) {
    SettingsType type = SettingsType.photobioreactor;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
              children: pbrCategories.map((category) {
            return Expanded(
              child: Tachometer(
                type: type,
                category: category.name,
                sensorStream: streamHandler
                    .getAvgOfAllStreamWithTopic(category.topic)
                    .stream,
              ),
            );
          }).toList()),
        ),
        Expanded(
          flex: 5,
          child: Column(
              children: pbrCategories.map((category) {
            return Expanded(
              child: Chart(
                sensorData: [
                  Data.custom(
                      data: ControllerHelper.controller
                          .getAvgData(category.topic),
                      dataStream: streamHandler
                          .getAvgOfAllStreamWithTopic(category.topic)
                          .stream,
                      topic: category.topic,
                      number: 1),
                ],
              ),
            );
          }).toList()),
        ),
      ],
    );
  }
}
