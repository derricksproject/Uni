import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/page_index.dart';

/// A stateful widget that renders a navigation menu with collapsible tiles.
///
/// The `NavigationSlide` widget provides a sidebar navigation menu that supports
/// hierarchical expansion for categories like Sensorboards and Photobioreactors.
///
/// It allows the user to navigate between different pages and sub-pages.
/// Author : Gagan Lal.
class NavigationSlide extends StatefulWidget {
  final Function onTap;
  final Function changePage;
  final ValueNotifier<PageIndex> currentPageIndex;

  const NavigationSlide({super.key, required this.onTap, required this.changePage, required this.currentPageIndex});

  @override
  NavigationSlideState createState() => NavigationSlideState();
}


/// The state class for the [NavigationSlide] widget.
///
/// Manages the state of selected pages, expansion tiles, and menu interactions.
class NavigationSlideState extends State<NavigationSlide> {
  late Map<PageIndex, bool> _previousExpansionState;
  PageIndex _currentPageIndex = PageIndex.startPage;

  List<PageIndex> boardPages = [
    PageIndex.boards1,
    PageIndex.boards2,
    PageIndex.boards3,
    PageIndex.boards4,
  ];

  final Map<PageIndex, bool> _tileExpansionState = {
    PageIndex.sensorboards: false,
    PageIndex.airQuality: false,
    PageIndex.photobioreactor: false,
    PageIndex.individualCharts: false,
  };
  @override
  void initState() {
    widget.currentPageIndex.addListener(_currentPageIndexListener);
    _previousExpansionState = Map.from(_tileExpansionState);
    super.initState();
  }

  @override
  void dispose() {
    widget.currentPageIndex.removeListener(_currentPageIndexListener);
    super.dispose();
  }

  void _currentPageIndexListener() {
    setState(() {
      _currentPageIndex = widget.currentPageIndex.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: ListView(
          shrinkWrap: true,
            children: [
              buildListTile(icon: Icons.home, pageIndex: PageIndex.startPage),
              buildExpansionTile(
                landingPageIndex: PageIndex.sensorboards,
                icon: Icons.developer_board, 
                title: '', 
                children: <Widget>[
                  buildListTile(title: 'Overview', pageIndex: PageIndex.sensorboards),
                  Divider(),
                  buildListTile(title: 'Temperature', pageIndex: PageIndex.temperature),
                  buildListTile(title: 'Pressure', pageIndex: PageIndex.pressure),
                  buildExpansionTile(
                    landingPageIndex: PageIndex.airQuality,
                    icon: Icons.air_sharp,
                    title: '',
                    children: <Widget>[
                      buildListTile(title: 'O\u2082', pageIndex: PageIndex.o2),
                      buildListTile(title: 'CO\u2082', pageIndex: PageIndex.co2),
                      buildListTile(title: 'CO', pageIndex: PageIndex.co),
                      buildListTile(title: 'O\u2083', pageIndex: PageIndex.o3),
                      buildListTile(title: 'Humidity', pageIndex: PageIndex.humidity),
                    ],
                  ),
                ],
              ),
              buildExpansionTile(
                landingPageIndex: PageIndex.photobioreactor,
                icon: Icons.grass, 
                title: '',
                children: [
                  buildListTile(title: 'Overview', pageIndex: PageIndex.photobioreactor),
                  buildListTile(title: 'Temperature', pageIndex: PageIndex.pbrTemperature),
                  buildListTile(title: 'Pressure', pageIndex: PageIndex.pbrPressure),
                  buildListTile(title: 'Oxygen', pageIndex: PageIndex.pbrO2),
                  buildListTile(title: 'CO\u2082', pageIndex: PageIndex.pbrCo2),
                  buildListTile(title: 'Humidity', pageIndex: PageIndex.pbrHumidity),
                  buildListTile(title: 'Optical Density', pageIndex: PageIndex.opticalDensity),
                  buildListTile(title: 'pH', pageIndex: PageIndex.ph),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.dashboard_outlined),
                trailing: const SizedBox(),
                title: const Text(''),
                onExpansionChanged:(bool isExpanded) {
                  setState(() {
                    _tileExpansionState[PageIndex.individualCharts] = isExpanded;
                  });
                  _callOnTap();
                  },
                children: [
                  buildListTile(title: 'Boards', pageIndex: PageIndex.boards1),
                  buildListTile(title: 'PBRs', pageIndex: PageIndex.pbrs)
                ],
              ),
              buildListTile(icon: Icons.forum_outlined,  pageIndex: PageIndex.chat),
              buildListTile(icon: Icons.settings, pageIndex: PageIndex.settings),
              ],
          ),
      ),
    );
  }

  /// Builds a navigation tile for individual pages.
  ///
  /// **Parameters**:
  /// - [icon]: Icon to display on the tile.
  /// - [title]: Title of the tile.
  /// - [pageIndex]: The corresponding [PageIndex] of the page.
  ///
  /// **Returns**: A [Container] widget containing a [ListTile].
  Widget buildListTile(
    {IconData? icon, 
    String? title, 
    required PageIndex pageIndex}) {
    bool isSelected = boardPages.contains(pageIndex)
      ?  boardPages.contains(_currentPageIndex)
      : _currentPageIndex == pageIndex;
    return Container(
      color: isSelected ? Colors.blue : Theme.of(context).colorScheme.surface,
      child: ListTile(
              leading: Icon(icon),
              title: Text(title ?? ''),
              onTap: () {
                setState(() {
                  _currentPageIndex = pageIndex;
                });
                widget.changePage(pageIndex);
              },
            ),
    );
  }

  /// Builds an expandable navigation tile.
  ///
  /// **Parameters**:
  /// - [icon]: Icon to display on the tile.
  /// - [landingPageIndex]: The primary [PageIndex] for the expandable section.
  /// - [title]: Title of the expandable section.
  /// - [children]: List of child widgets (sub-navigation tiles).
  ///
  /// **Returns**: A [Container] widget containing an [ExpansionTile].
  Widget buildExpansionTile({
    IconData? icon,
    required PageIndex landingPageIndex,
    required String title,    
    required List<Widget> children,
  }) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ExpansionTile(
        onExpansionChanged: (bool isExpanded) {
          setState(() {
            _tileExpansionState[landingPageIndex] = isExpanded;
          });
          _callOnTap();
        },
        leading: Icon(icon),
        title: Text(title),
        trailing: const SizedBox(),
        children: [Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the `onTap` callback and manages tile expansion state.
  ///
  /// Closes nested tiles if a parent tile is collapsed, and toggles
  /// the menu expansion state if the number of expanded tiles changes.
  void _callOnTap() {
    if(_tileExpansionState[PageIndex.sensorboards] == false 
      && _tileExpansionState[PageIndex.airQuality] == true) {
        _tileExpansionState[PageIndex.airQuality] = false;
      }
    int expandedBefore = _previousExpansionState.values.where((isExpanded) => isExpanded).length;
    int expandedNow = _tileExpansionState.values.where((isExpanded) => isExpanded).length;
    if (expandedBefore == 0 || expandedNow == 0) {
      widget.onTap();
    }
    _previousExpansionState = Map.from(_tileExpansionState);
  }
}


