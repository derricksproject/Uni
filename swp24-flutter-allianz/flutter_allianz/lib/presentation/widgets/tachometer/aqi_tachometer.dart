import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


/// A widget that displays an Air Quality Index (AQI) reading in a radial gauge format.
///
/// This widget listens to a stream of AQI values and updates the gauge accordingly. The gauge uses different
/// color ranges to represent the level of air quality from good to hazardous.
///
/// **Author**: Derrick Nyarko
class AqiTachometer extends StatefulWidget {
  final Stream<double>? sensorStream;

  const AqiTachometer({
    super.key,
    required this.sensorStream, 
  });

  @override
  AQITachometerState createState() => AQITachometerState();
}

  class AQITachometerState extends State<AqiTachometer> {
    double value = 0;
    StreamSubscription<double>? _sensorStreamSubscription;

  @override
  void initState() {
    super.initState();
    _sensorStreamSubscription = widget.sensorStream?.listen((newValue) {
      setState(() {
        value = newValue;
      });
    });
  }

  @override
  void dispose() {
    _sensorStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: [
        RadialAxis(
          showLastLabel: false,
          showFirstLabel: false,
          minimum: 0,
          maximum: 500,
          interval: 500,
          ranges: [
            GaugeRange(
                startValue: 0,
                endValue: 50,
                color: const Color.fromARGB(255, 0, 228, 0)),
            GaugeRange(
                startValue: 50,
                endValue: 100,
                color: const Color.fromARGB(255, 255, 255, 0)),
            GaugeRange(
                startValue: 100,
                endValue: 150,
                color: const Color.fromARGB(255, 255, 126, 0)),
            GaugeRange(
                startValue: 150,
                endValue: 200,
                color: const Color.fromARGB(255, 255, 0, 0)),
            GaugeRange(
                startValue: 200,
                endValue: 300,
                color: const Color.fromARGB(255, 144, 63, 151)),
            GaugeRange(
                startValue: 300,
                endValue: 500,
                color: const Color.fromARGB(255, 126, 0, 35)),
          ],
          pointers: [NeedlePointer(
            value: value,
            needleLength: 0.8,
            needleStartWidth: 2,
            needleEndWidth: 6,
            )],
          annotations: [
            GaugeAnnotation(
              widget: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
              angle: 90,
              positionFactor: 0.7,
            ),
          ],
        ),
      ],
    );
  }
}