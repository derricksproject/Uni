import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/stream_handler.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/settings.dart';
import 'package:flutter_allianz/models/data.dart';
import 'package:flutter_allianz/presentation/widgets/chart.dart';
import 'package:flutter_allianz/presentation/widgets/styled/styled_tabbar.dart';
import 'package:flutter_allianz/presentation/widgets/tachometer/tachometer.dart';

/// A widget that represents individual photobioreactors (PBRs) and their associated
/// outlet and inlet data in a tab-based interface.
/// 
/// **Author**: Timo Gehrke
class IndividualPhotobioreactors extends StatefulWidget {
  const IndividualPhotobioreactors({super.key});

  @override
  IndividualPhotobioreactorsState createState() =>
      IndividualPhotobioreactorsState();
}

class IndividualPhotobioreactorsState extends State<IndividualPhotobioreactors>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _subTabController;
  final StreamHandler streamHandler = StreamHandler();

  final List<Tab> tabs = [
    for(int i = 1; i <= Params.amountPbrs; i++)
      Tab(text: 'PBR #$i'),
  ];

  final List<Tab> subTabs = [
    const Tab(
      text: 'Outlet',
    ),
    const Tab(
      text: 'Inlet',
    )
  ];

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    _subTabController = TabController(length: subTabs.length, vsync: this);
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
              children: [
                for(int i = 1; i <= Params.amountPbrs; i++)
                  _buildPbrTabView(i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab view for each individual photobioreactor (PBR).
  /// 
  /// Displays a tab view that includes the outlet and inlet sub-tabs for the selected PBR.
  Widget _buildPbrTabView(int pbrNo) {
    List<Categories> outletCategories = [
      Categories.pbrTemperatureG,
      Categories.pbrPressureG,
      Categories.pbrO2G,
      Categories.pbrCo2G,
      Categories.pbrHumidityG,
    ];
    List<Categories> inletCategories = [
      Categories.pbrTemperatureL,
      Categories.pbrDissolvedO2L,
      Categories.pbrPHL,
      Categories.pbrOpticalDensityL,
    ];
    return Column(
      children: [
        StyledTabBar(controller: _subTabController, tabs: subTabs),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildOutletTab(pbrNo, outletCategories),
              _buildOutletTab(pbrNo, inletCategories),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the outlet or inlet tab view for the selected PBR.
  /// 
  /// This view displays a list of widgets for each category (e.g., temperature, pressure)
  /// in the specified outlet or inlet data, showing a tachometer and chart.
  Widget _buildOutletTab(
      int pbrNo, List<Categories> categories) {
    return ListView(
      children: [
        for (var category in categories)
          Container(
            decoration: BoxDecoration(border: Border.all(width: 2)),
            height: 250,
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  child: Tachometer(
                    type: SettingsType.photobioreactor,
                    category: category.name,
                    sensorStream: StreamHandler()
                        .getStreamWithTopic(category.topic, pbrNo)
                        .stream,
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Chart(sensorData: [Data(topic: category.topic, number: pbrNo)]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
