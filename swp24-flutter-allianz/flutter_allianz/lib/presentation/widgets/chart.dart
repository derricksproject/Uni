import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_allianz/application/time_handler.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/limits.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/data.dart';

/// A stateful widget that renders a chart for sensor data.
///
/// The [Chart] widget displays real-time and historical data for sensors
/// using the `FlChart` package.
/// and dynamic updates based on live data streams.
/// Author : Ali Danaei
class Chart extends StatefulWidget {
  final List<Data> sensorData;
  final String? title;

  const Chart({super.key, required this.sensorData, this.title});

  @override
  ChartState createState() => ChartState();

}

/// The state class for the [Chart] widget.
///
/// Manages the chart data and live updates
class ChartState extends State<Chart> {
  late String title;
  late double minY;
  late double maxY;
  late String currentTime;
  late Map<String, List<FlSpot>> data;
  late Map<String, bool> visibilityMap;
  final Map<String, StreamSubscription<double>> streamSubscriptions = {};
  final TimeHandler timeHandler = TimeHandler();

  // Used to determine the color of the plots.
  List<MaterialColor> colorList = [
    Colors.blue,
    Colors.red,
    Colors.amber,
    Colors.green,
    Colors.orange,
    Colors.cyan,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();

    title = widget.title ?? (CategoriesExtension.fromTopic(widget.sensorData[0].topic))!.name;

    minY = widget.sensorData[0].getLimitValue(Limits.lowerLimit) ?? 0.0;
    maxY = widget.sensorData[0].getLimitValue(Limits.upperLimit) ?? 0.0;
    currentTime = timeHandler.getCurrentTime();

    final Map<String, Stream<double>> inputStreamsMap = {
      for (int i = 0; i < widget.sensorData.length; i++) i.toString(): widget.sensorData[i].dataStream,
    };

    data = {};
    for (var key in inputStreamsMap.keys) {
      _loadInitialData(key);
    }

    visibilityMap = {};
    for (var key in inputStreamsMap.keys) {
      visibilityMap[key] = true;
      _subscribeToStream(key, inputStreamsMap[key]!);
    }
  }

  /// Loads the initial data for a specific sensor stream.
  ///
  /// **Parameters**:
  /// - [key]: The key representing the sensor stream in the `data` map.
  ///
  /// **Returns**: A `Future` that updates the `data` map with the initial points.
  Future<void> _loadInitialData(String key) async {
    try {
      if(widget.sensorData[int.parse(key)].topic == Categories.boardAirQuality.topic) {
        var futureData = ControllerHelper.controller.getChartAqi();
        final List<FlSpot> initialData = await futureData as List<FlSpot>;
        setState(() {
          data[key] = initialData;
        });
      } else {
        var futureData = widget.sensorData[int.parse(key)].data;
        final List<FlSpot> initialData = await futureData as List<FlSpot>;
        setState(() {
          data[key] = initialData;
        });
      }
    } catch (e) {
      data[key] = [];
    }
  }

  @override
  void dispose() {
    for (var subscription in streamSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
  
  /// Subscribes to a specific sensor stream for live updates.
  ///
  /// **Parameters**:
  /// - [key]: The key representing the sensor stream in the `data` map.
  /// - [stream]: The data stream to subscribe to.
  void _subscribeToStream(String key, Stream<double> stream) {
    streamSubscriptions[key] = stream.listen((value) {
      setState(() {
        currentTime = timeHandler.getCurrentTime();
        data[key]!.add(FlSpot(timeHandler.timeToDouble(currentTime), value));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double currentHour = timeHandler.timeToDouble(currentTime);

    if(data.values.isNotEmpty && data.values.any((list) => list.length > 1)) {
      minY = data.values
      .expand((list) => list)
      .map((spot) => spot.y)
      .reduce((a,b) => a < b ? a : b);

      maxY = data.values
        .expand((list) => list)
        .map((spot) => spot.y)
        .reduce((a,b) => a > b ? a : b); 
    }

    return Stack(
          children: [
            Positioned(
              top: 10, 
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, 
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    drawVerticalLine: false,
                    drawHorizontalLine: true
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        maxIncluded: false,
                        minIncluded: false,
                        reservedSize: 30,
                        showTitles: true,
                        interval: 1/20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            timeHandler.formatDoubleToTime(value).substring(0,5), 
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      minIncluded: false,
                      maxIncluded: false,
                      reservedSize: 30,
                      interval: (maxY - minY) / 2,
                      showTitles: true, 
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary , width: 1),
                      left: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 1),
                    )
    
    
                  ),
                  minX: currentHour - 0.30,
                  maxX: currentHour + 0.10, 
                  minY: minY * 0.8,
                  maxY: maxY * 1.2,
                  clipData: const FlClipData.all(), 
                  lineBarsData: data.keys
                  .where((key) => visibilityMap[key]!)
                  .map((key) {
                    return LineChartBarData(
                      color: colorList[int.parse(key)],
                      spots: data[key]!,
                      isCurved: false,
                      belowBarData: BarAreaData(show: false),
                      dotData: const FlDotData(show: false),
                    );
                  }).toList(),
                ),
              ),
            ),
    
            if(data.keys.length > 1)
              Positioned(
                top: 10,
                left: 30,
                child: Column(
                  children: List.generate(data.keys.length, (index) {
                    String key = index.toString();
                    return Row(
                      children: [
                        Checkbox(
                          value: visibilityMap[key],
                          onChanged: (bool? value) {
                            setState(() {
                              visibilityMap[key] = !visibilityMap[key]!;
                            });
                          },
                        ),
                        Text(
                          widget.sensorData[index].topic.replaceFirst('X', (index+1).toString()).replaceFirst('X_am', ' avg'),
                          style: TextStyle(color: colorList[index]),
                        ),
                        const SizedBox(width: 20,)
                      ],
                    );
                  }),
                ),
              ),
            ],
    ); 
  }
}
