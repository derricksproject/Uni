import 'package:flutter/material.dart';
import 'package:flutter_allianz/enums/page_index.dart';
import 'package:flutter_allianz/presentation/pages/chat.dart';
import 'package:flutter_allianz/presentation/pages/homepage.dart';
import 'package:flutter_allianz/presentation/pages/individual_sensorboards.dart';
import 'package:flutter_allianz/presentation/pages/individual_photobioreactors.dart';
import 'package:flutter_allianz/presentation/pages/photobioreactor/index.dart';
import 'package:flutter_allianz/presentation/pages/sensorboards/index.dart';
import 'package:flutter_allianz/presentation/pages/settings.dart';
import 'package:flutter_allianz/presentation/widgets/navigation_slide.dart';
import 'package:flutter_allianz/presentation/widgets/notifications.dart';

/// A StatefulWidget that serves as the root widget of the app and manages navigation.
/// The widget includes a sidebar navigation, a page view for different pages,
/// and a notification section. It uses a PageController to handle the
/// page switching logic and a ValueNotifier to track the current page index.
///
/// **Author**: Timo Gehrke
class Skeleton extends StatefulWidget {
  Skeleton({this.child, required this.title}) : super(key: Skeleton.globalKey);

  final Widget? child;
  final String title;
  static final GlobalKey<SkeletonState> globalKey = GlobalKey<SkeletonState>();

  static void changePage(PageIndex pageIndex) {
    globalKey.currentState?._changePage(pageIndex);
  }

  @override
  SkeletonState createState() => SkeletonState();
}

/// State class for the [Skeleton] widget that manages navigation and page content.
class SkeletonState extends State<Skeleton> {
  final ValueNotifier<PageIndex> _currentPageIndex =
      ValueNotifier(PageIndex.startPage);
  double smallWidth = 100;
  double expandedWidth = 200;
  double width = 100;

  final PageController _pageController = PageController();

  /// Maps all pages to a PageIndex.
  final Map<PageIndex, Widget> pages = {
    PageIndex.startPage: const StartPage(),
    //PBR Pages
    PageIndex.photobioreactor: const Photobioreactor(),
    PageIndex.pbrTemperature: const PbrTemperature(),
    PageIndex.pbrPressure: const PbrPressure(),
    PageIndex.pbrO2: const PbrOxygen(),
    PageIndex.pbrCo2: const PbrCo2(),
    PageIndex.pbrHumidity: const PbrHumidity(),
    PageIndex.opticalDensity: const OpticalDensity(),
    PageIndex.ph: const Ph(),
    //Sensorboard Pages
    PageIndex.sensorboards: const Sensorboards(),
    PageIndex.temperature: const Temperature(),
    PageIndex.pressure: const Pressure(),
    //Air Quality subPages
    PageIndex.airQuality: AirQuality(),
    PageIndex.o2: const O2(),
    PageIndex.co: const Co(),
    PageIndex.co2: const Co2(),
    PageIndex.o3: const O3(),
    PageIndex.humidity: const Humidity(),

    PageIndex.settings: const Settings(),
    PageIndex.chat: const Chat(),
    PageIndex.boards1:
        const IndividualSensorBoards(initialTabIndex: 0), // Board #1
    PageIndex.boards2:
        const IndividualSensorBoards(initialTabIndex: 1), // Board #2
    PageIndex.boards3:
        const IndividualSensorBoards(initialTabIndex: 2), // Board #3
    PageIndex.boards4:
        const IndividualSensorBoards(initialTabIndex: 3), // Board #4
    PageIndex.pbrs: const IndividualPhotobioreactors(),
    PageIndex.individualCharts:
        const StartPage(), //This shouldnt be called, therefore it returns home.
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: AlignmentDirectional.center,
              width: width,
              padding: const EdgeInsets.only(left: 20),
              child: NavigationSlide(
                onTap: _changeWidth,
                changePage: _changePage,
                currentPageIndex: _currentPageIndex,
              )),
          VerticalDivider(),
          Expanded(
            flex: 12,
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pages.length,
              itemBuilder: (BuildContext context, int index) {
                PageIndex pageEnum = PageIndex.values[index];
                return Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          pageEnum.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Expanded(flex: 30, child: pages[pageEnum]!),
                  ],
                );
              },
            ),
          ),
          VerticalDivider(),
          SizedBox(
            width: 200,
            child: Notifications(),
          ),
        ],
      ),
    );
  }

  /// Function to change the width of the navigation slide panel.
  ///
  /// Toggles between the small width (100) and expanded width (200).
  void _changeWidth() {
    setState(() {
      width = width == smallWidth ? expandedWidth : smallWidth;
    });
  }

  /// Function to change the displayed page in the PageView.
  ///
  /// The page is changed based on the [PageIndex] provided.
  void _changePage(PageIndex pageIndex) {
    if (_pageController.hasClients) {
      _currentPageIndex.value = pageIndex;
      _pageController.jumpToPage(pageIndex.index);
    } else {
      debugPrint("PageController is not ready yet.");
    }
  }
}
