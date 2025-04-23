import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/stream_handler.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/settings.dart';
import 'package:flutter_allianz/models/data.dart';
import 'package:flutter_allianz/presentation/widgets/chart.dart';
import 'package:flutter_allianz/presentation/widgets/styled/styled_tabbar.dart';
import 'package:flutter_allianz/presentation/widgets/tachometer/tachometer.dart';

/// A widget that represents individual sensor boards and their associated data
/// in a tab-based interface. It allows the user to view and interact with
/// temperature, humidity, and miscellaneous sensor data for each board.
/// 
/// **Author**: Timo Gehrke
class IndividualSensorBoards extends StatefulWidget {
  final int initialTabIndex;
  
  const IndividualSensorBoards({super.key, required this.initialTabIndex});

  @override
  IndividualSensorboardsState createState() => IndividualSensorboardsState();
}

class IndividualSensorboardsState extends State<IndividualSensorBoards>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _subTabController;
  final StreamHandler streamHandler = StreamHandler();

  final List<Tab> tabs = [
    for(int i = 1; i <= Params.amountBoards; i++)
      Tab(text: 'Board #$i'),
  ];

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this, initialIndex: widget.initialTabIndex);
    _subTabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StyledTabBar(
            controller: _tabController,
            tabs: tabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [for (int i = 1; i <= Params.amountBoards; i++) _buildBoardTabView(i)],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab view for each individual sensor board.
  ///
  /// This method creates a tab view that includes three sub-tabs:
  /// Temperature, Humidity, and Miscellaneous, and displays the appropriate
  /// sensor data for the selected board.
  Widget _buildBoardTabView(int boardNo) {
    return Column(
      children: [
        StyledTabBar(controller: _subTabController, tabs: const [
          Tab(text: 'Temperature'),
          Tab(text: 'Humidity'),
          Tab(text: 'Miscelleneous'),
        ]),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildTab(boardNo, Categories.boardTemperature.topic),
              _buildTab(boardNo, Categories.boardHumidity.topic),
              _buildMiscTab(boardNo),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the temperature or humidity tab view for the selected sensor board.
  ///
  /// This method generates a list of sensor widgets for the given topic
  /// (temperature or humidity) and board number. Each sensor widget consists
  /// of a tachometer and a chart displaying the sensor data.
  Widget _buildTab(int boardNo, String topic) {
    return ListView(
        children: List.generate(4, (i) {
          int sensorNo = i + 1;
          var streamWithTopic = streamHandler.getStreamWithTopic(
            topic,
            boardNo,
            sensorNo: sensorNo,
          );
          return Container(
            decoration: BoxDecoration(border: Border.all(width: 2)),
            height: 250,
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  flex: 1,
                  child: Tachometer(
                      title: 'Sensor $sensorNo',
                      type: SettingsType.board,
                      category: Categories.boardHumidity.name,
                      sensorStream: streamWithTopic.stream),
                ),
                Expanded(
                  flex: 6,
                  child: Chart(
                    title: topic.replaceFirst('boardX/', '').replaceFirst('X_am', ' sensor $sensorNo'),
                    sensorData:
                        [Data(topic: topic, number: boardNo, sensorNo: sensorNo)],
                  ),
                ),
              ],
            ),
          );
        }));
  }

  /// Builds the miscellaneous data tab view for the selected sensor board.
  ///
  /// This method creates a list of miscellaneous sensor categories (CO, CO2, O2, O3, and Pressure),
  /// and for each category, it displays a tachometer and a chart.
  Widget _buildMiscTab(int boardNo) {
    List<Categories> categories = [
      Categories.boardCo,
      Categories.boardCo2,
      Categories.boardO2,
      Categories.boardO3,
      Categories.boardPressure,
    ];

    return ListView(
      children: [
        for (var category in categories)
          Container(
            height: 250,
            decoration: BoxDecoration(border: Border.all(width: 2)),
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  flex: 1,
                  child: Tachometer(
                      type: SettingsType.board,
                      category: category.name,
                      sensorStream: streamHandler
                          .getStreamWithTopic(category.topic, boardNo)
                          .stream),
                ),
                Expanded(
                  flex: 8,
                  child: Chart(
                    sensorData: [Data(topic: category.topic, number: boardNo)],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
