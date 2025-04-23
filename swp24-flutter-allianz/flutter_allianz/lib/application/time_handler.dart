import 'dart:async';

/// A class responsible for handling and formatting time, as well as updating the current time at regular intervals.
///
/// The `TimeHandler` class provides functionality to fetch the current time, format it into a string (HH:MM:SS),
/// and also convert time between string and double representations. The class also includes a periodic timer
/// that updates the current time every second.
///
/// **Author**: Timo Gehrke
class TimeHandler {
  String _currentTime = "";
  Timer? _timer;

  /// Initializes a new instance of the TimeHandler class.
  /// Sets the initial current time and starts the timer that updates the current time every second.
  TimeHandler()  {
    _currentTime = _formatCurrentTime();
    _startTimer();
  }

  /// Starts a periodic timer that updates the current time every second.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _currentTime = _formatCurrentTime();
    });
  }

  /// Converts a time string (HH:MM:SS) into a double representation (hours).
  ///
  /// **Parameters**:
  /// - `time`: The time in "HH:MM:SS" format.
  ///
  /// **Returns**: A `double` representing the time in hours (e.g., 1.5 hours for 1 hour and 30 minutes).
  double timeToDouble(String time) {
    final parts = time.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    final int seconds = int.parse(parts[2]);
    return hour + (minute / 60.0) + (seconds / 3600); 
  }

  /// Converts a double representing time in hours into a time string (HH:MM:SS).
  ///
  /// **Parameters**:
  /// - `hour`: The time represented as a `double`, where the integer part is the hour and the fractional part is the minutes and seconds.
  ///
  /// **Returns**: A time string in the format "HH:MM:SS".
  String formatDoubleToTime(double hour) {
    int intHour = hour.toInt();
    int minutes = ((hour - intHour) * 60).toInt();
    int seconds = (((hour - intHour) * 60 - minutes) * 60).toInt();
    return '${intHour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Returns the current time in the format HH:MM:SS.
  ///
  /// **Returns**: A string representing the current time in the format "HH:MM:SS".
  String _formatCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

   /// Retrieves the current time as a string.
  ///
  /// **Returns**: A string representing the current time in the format "HH:MM:SS".
  String getCurrentTime() {
    return _currentTime;
  }

  /// Stops the timer that updates the current time and cancels any ongoing timer operations.
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes of the `TimeHandler` by stopping the timer.
  void dispose() {
    stopTimer();
  }
}
