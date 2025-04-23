import 'package:fl_chart/fl_chart.dart';

/// A utility class that provides methods for working with charts and data transformations.
///
/// The [ChartUtils] class offers helper methods for constructing and manipulating chart data.
/// It provides functionality to convert a list of data points into a format that can be used 
/// by the `fl_chart` package, specifically converting a list of coordinate pairs into a list 
/// of `FlSpot` objects used by charts.
/// 
/// **Author**: Steffen Gebhard
class ChartUtils {
  ChartUtils();

  /// Converts a list of coordinate pairs (represented as a list of lists) into a list of [FlSpot] objects.
  ///
  /// This method takes a list of data points where each data point is represented as a list 
  /// with two double values: [x, y] coordinates. 
  /// If any data pair doesn't contain exactly two values, it is ignored.
  ///
  /// [list] - A list of lists where each inner list contains two double values, representing an (x, y) coordinate pair.
  /// 
  /// Returns: A list of [FlSpot] objects, which can be used to plot data points on a chart.
  List<FlSpot> listToFlSpot(List<List<double>> list) {
    List<FlSpot> result = List<FlSpot>.empty(growable: true);
    for (var data in list) {
      if (data.length != 2) continue;
      result.add(FlSpot(data[0], data[1]));
    }
    return result;
  }
}
