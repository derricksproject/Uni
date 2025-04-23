import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/notifications_handler.dart';
import 'package:flutter_allianz/application/stream_handler.dart';
import 'package:flutter_allianz/application/time_handler.dart';
import 'package:flutter_allianz/enums/page_index.dart';
import 'package:flutter_allianz/enums/warnings.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/notification_item.dart';
import 'package:flutter_allianz/models/stream_with_topic.dart';
import 'package:flutter_allianz/presentation/pages/skeleton.dart';

/// A widget that displays notifications, system warnings, and sensor status.
///
/// The `Notifications` widget manages real-time notifications by monitoring sensor
/// data streams and checking warning levels. It provides a UI for notifications and
/// allows navigation to corresponding pages for detailed information.
/// 
/// **Author** : Derrick Nyarko
class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => NotificationsState();
}

/// State class for the [Notifications] widget.
///
/// Manages real-time notifications, handles subscriptions to sensor data streams,
/// and updates the UI with warnings and statuses.
class NotificationsState extends State<Notifications> {
  late final List<NotificationItem> notifications;
  final StreamHandler streamHandler = StreamHandler();
  late List<StreamWithTopic> streamList;
  late TimeHandler _timeHandler;
  late String _currentTime;
  late List<StreamSubscription> _subscriptions;
  late final NotificationsHandler notificationsHandler;

  @override
  void initState() {
    super.initState();
    notificationsHandler = NotificationsHandler();
    notifications = [];
    _subscriptions = [];
    _timeHandler = TimeHandler();
    _currentTime = _timeHandler.getCurrentTime().substring(0, 5);
    streamList = streamHandler.getAllStreams();

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      String newTime = _timeHandler.getCurrentTime().substring(0, 5);
      if (_currentTime != newTime) {
        setState(() {
          _currentTime = newTime;
        });
      }
    });

    for (var stream in streamList) {
      var subscription = stream.stream.listen((value) {
        WarningType warning =
            notificationsHandler.checkValue(stream.topic, value);
        notify(stream.topic, value, warning);
      });
      _subscriptions.add(subscription);
    }
  }

  @override
  void dispose() {
    _timeHandler.dispose();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }

    super.dispose();
  }

  /// Handles notifications when a warning is detected in a sensor stream.
  ///
  /// This method checks whether a notification for the given `topic` already exists.
  /// If a notification exists and the warning level has changed, it updates the existing
  /// notification with the new warning level. If no notification exists or if the
  /// warning level is not `WarningType.green`, it adds a new notification.
  ///
  /// **Parameters**:
  /// - `topic`: A `String` representing the MQTT topic associated with the sensor stream.
  /// - `value`: A `double` representing the current sensor value. 
  /// - `warning`: A `WarningType` value indicating the warning level.
  void notify(String topic, double value, WarningType warning) {
    bool notificationExists =
        notifications.any((notification) => notification.topic == topic);

    if (notificationExists) {
      NotificationItem existingNotification = notifications
          .firstWhere((notification) => notification.topic == topic);

      if (existingNotification.warningType != warning) {
        setState(() {
          notifications.remove(existingNotification);
          notifications.add(existingNotification.updateWarningType(warning));
          notifications.sort(
              (a, b) => b.warningType.index.compareTo(a.warningType.index));
        });
      }
    } else {
      if (warning != WarningType.green) {
        addNotification(topic, warning, value);
      }
    }
  }

  /// Adds a new notification to the list of notifications.
  ///
  /// This method creates a new `NotificationItem` with the provided `topic`, `warning` level,
  /// and `value` of the sensor. It adds the notification to the list of notifications
  /// and updates the state of the widget to reflect the changes.
  ///
  /// **Parameters**:
  /// - `topic`: A `String` representing the MQTT topic of the notification.
  /// - `warning`: A `WarningType` value representing the severity of the warning.
  /// - `value`: A `double` representing the sensor value that triggered the warning.
  void addNotification(String topic, WarningType warning, double value) {
    setState(() {
      notifications.add(NotificationItem(
          value: value,
          timeFirstAdded: _currentTime,
          timeNow: _currentTime,
          topic: topic,
          warningType: warning));
    });
  }

  /// Builds the main UI of the Notifications widget.
  ///
  /// **Returns**: A `Container` displaying the current time, system warnings,
  /// and a list of active notifications.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _currentTime,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          WarningLamp(label: "Sensorboards", warning: boardCheck()),
          WarningLamp(
            label: "Photobioreaktor",
            warning: pbrCheck(),
          ),
          WarningLamp(
            label: "MQTT Connection",
            warning: mqttCheck(),
          ),
          Text(
            'Last update: ${DateTime.now().toString().split('.').first}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const Divider(),
          const Text(
            "Notifications:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Center(
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                width: 250,
                child: ListView.separated(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: notificationTile(notification));
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 8); // Add space between tiles
                  },
                ),
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  /// Builds a notification tile.
  ///
  /// **Parameters**:
  /// - `notification`: The [NotificationItem] to display.
  ///
  /// **Returns**: A `Container` styled based on the warning level.
  Widget notificationTile(NotificationItem notification) {
    return Container(
      width: 300,
      color: notification.warningType == WarningType.red
          ? const Color.fromARGB(150, 244, 67, 54)
          : (notification.warningType == WarningType.yellow
              ? const Color.fromARGB(150, 255, 255, 0)
              : const Color.fromARGB(150, 76, 255, 79)),
      child: Column(
        children: [
          ListTile(
            onTap: () => Skeleton.changePage(
                PageIndexExtension.indexFromTopic(notification.topic)),
            leading: notification.warningType != WarningType.green
                ? Icon(Icons.warning,
                    color: notification.warningType == WarningType.red
                        ? Colors.red
                        : Colors.white)
                : null,
            title: Column(children: [
              Container(
                alignment: Alignment.topRight,
                child: Text(
                  style: Theme.of(context).textTheme.labelSmall,
                  notification.timeFirstAdded,
                  textAlign: TextAlign.right,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  style: Theme.of(context).textTheme.titleMedium,
                  notification.generateMessageTitle(),
                  softWrap: true,
                ),
              ),
              Text(
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium,
                notification.generateMessage(),
                softWrap: true,
              ),
            ]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.bottomLeft,
                child: notification.warningType == WarningType.green
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            notifications.remove(notification);
                          });
                        },
                      )
                    : null,
              ),
              Container(
                width: 80,
                alignment: Alignment.centerLeft,
                child: Text(
                  style: Theme.of(context).textTheme.labelSmall,
                  notification.topic
                      .replaceAll('/', ' ')
                      .replaceFirst('_am', ''),
                  softWrap: true,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Checks the status of the MQTT connection.
  ///
  /// This method evaluates the connection status of the MQTT broker and
  /// returns a corresponding warning level based on whether the connection
  /// is active or not.
  ///
  /// **Returns**:
  /// - `WarningType.green`: If the MQTT broker connection is established.
  /// - `WarningType.red`: If the MQTT broker connection is not established.
  WarningType mqttCheck() {
    return BrokerHelper.broker.connectionStatus
        ? WarningType.green
        : WarningType.red;
  }

  /// Checks the overall status of the sensorboards.
  ///
  /// This method checks all notifications related to the sensorboards and
  /// determines the highest warning level across them.
  ///
  /// **Returns**:
  /// - The highest warning level (`WarningType.green`, `WarningType.yellow`, or `WarningType.red`)
  ///   among all the notifications related to the sensorboards.
  WarningType boardCheck() {
    WarningType highestWarning = WarningType.green;
    for (var notification in notifications) {
      if (notification.topic.startsWith('board')) {
        if (notification.warningType.index > highestWarning.index) {
          highestWarning = notification.warningType;
        }
      }
    }
    return highestWarning;
  }

  /// Checks the overall status of the photobioreactors.
  ///
  /// This method checks all notifications related to the photobioreactors and
  /// determines the highest warning level across them.
  ///
  /// **Returns**:
  /// - The highest warning level (`WarningType.green`, `WarningType.yellow`, or `WarningType.red`)
  ///   among all the notifications related to the photobioreactors.
  WarningType pbrCheck() {
    WarningType highestWarning = WarningType.green;
    for (var notification in notifications) {
      if (notification.topic.startsWith('pbr')) {
        if (notification.warningType.index > highestWarning.index) {
          highestWarning = notification.warningType;
        }
      }
    }
    return highestWarning;
  }
}

/// A widget that displays a warning lamp with a label.
///
/// This widget is used to represent the status of a specific system (e.g.,
/// sensorboards or photobioreactors) by showing a warning icon (lamp)
/// alongside a label. The icon's color and type change based on the warning status.
///
/// - **Green:** Represents a normal status with a check mark icon and green color.
/// - **Yellow:** Represents a warning status with a warning icon and yellow color.
/// - **Red:** Represents a critical status with a warning icon and red color.
class WarningLamp extends StatelessWidget {
  final String label;
  final WarningType warning;

  const WarningLamp({
    super.key,
    required this.label,
    required this.warning,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    switch (warning) {
      case WarningType.green:
        icon = Icons.check_sharp;
        iconColor = Colors.green;
      case WarningType.yellow:
        icon = Icons.warning;
        iconColor = Colors.yellow;
      case WarningType.red:
        icon = Icons.warning_outlined;
        iconColor = Colors.red;
    }
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
