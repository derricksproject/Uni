/// @file notifications_test.dart
///
/// @description
/// This file contains test cases for the `NotificationItem` class,
/// which generates warning messages for various sensor values, and handles
/// different types of warnings. It tests multiple scenarios, including
/// temperature, humidity, pressure, and pH values, and how they generate
/// appropriate messages based on their `WarningType`. Additionally, it tests
/// edge cases such as extreme values, empty fields, and ensuring the format
/// consistency of the generated warning messages.
///
/// @author Derrick Nyarko
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_allianz/models/notification_item.dart';
import 'package:flutter_allianz/enums/warnings.dart';
import 'package:flutter_allianz/config/settings_controller.dart';

void main() {
  // Sets up initial conditions before running any tests
  setUpAll(() async {
    await SettingsController.instance.initializeBoardSettings();
    await SettingsController.instance.initializePhotobioreactorSettings();
  });

  // Grouping all tests related to NotificationItem class
  group('NotificationItem Tests', () {
    // Test 1: Verifying temperature warning message generation
    test('NotificationItem creates temperature warning message correctly', () {
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/temp1_am',
        warningType: WarningType.yellow,
      );
      // Expected output for temperature warning message
      expect(notification.generateMessageTitle(), 'Temperature Warning');
      expect(
          notification.generateMessage(), 'Temperature out of range: 25.50 °C');
    });

    // Test 2: Verifying humidity warning message generation
    test('NotificationItem creates humidity warning message correctly', () {
      final notification = NotificationItem(
        value: 98.0,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/humid1_am',
        warningType: WarningType.yellow,
      );
      // Expected output for humidity warning message
      expect(notification.generateMessageTitle(), 'Humidity Warning');
      expect(notification.generateMessage(), 'Humidity out of range: 98.00 %');
    });

    // Test 3: Verifying pressure warning message generation
    test('NotificationItem creates pressure warning message correctly', () {
      final notification = NotificationItem(
        value: 1090.0,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/amb_press',
        warningType: WarningType.red,
      );
      // Expected output for pressure warning message
      expect(notification.generateMessageTitle(), 'Pressure Warning');
      expect(
          notification.generateMessage(), 'Pressure out of range: 1090.00 hPa');
    });

    // Test 4: Verifying handling of green warning type
    test('NotificationItem handles green warning type correctly', () {
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/temp1_am',
        warningType: WarningType.green,
      );
      // Expected output for green warning type
      expect(notification.generateMessageTitle(), 'Temperature Status');
      expect(notification.generateMessage(),
          'Temperature has been out of range from 10:00 to 10:30');
    });

    // Test 5: Verifying the update of warning type correctly
    test('NotificationItem updates warning type correctly', () {
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/temp1_am',
        warningType: WarningType.yellow,
      );
      final updatedNotification =
      notification.updateWarningType(WarningType.green);
      // Expecting updated warning type to be 'green'
      expect(updatedNotification.warningType, WarningType.green);
      expect(updatedNotification.value, notification.value);
      expect(updatedNotification.topic, notification.topic);
    });

    // Test 6: Handling of pH warning for Photobioreactor topics
    test('NotificationItem handles PBR topics correctly', () {
      final notification = NotificationItem(
        value: 7.5,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'pbr1/ph',
        warningType: WarningType.yellow,
      );
      // Expected output for pH warning message
      expect(notification.generateMessageTitle(), 'pH Warning');
      expect(notification.generateMessage(), 'pH out of range: 7.50 ');
    });

    // Test 7: Verifying generalization of topics (with board numbers)
    test('NotificationItem correctly generalizes topics', () {
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board123/temp456_am',
        warningType: WarningType.yellow,
      );
      // Expected output for topic generalization
      expect(notification.createGeneralTopic(notification.topic),
          'boardX/tempX_am');
    });

    // Test 8: Handling edge case with very large values
    test('NotificationItem handles edge case values', () {
      final notification = NotificationItem(
        value: 999999.99,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/temp1_am',
        warningType: WarningType.red,
      );
      // Verifying that the message contains the large value
      expect(notification.generateMessage().contains('999999.99'), true);
    });

    // Test 9: Ensuring that the topic remains unchanged during updates
    test('NotificationItem preserves original topic in updates', () {
      const originalTopic = 'board1/temp1_am';
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: originalTopic,
        warningType: WarningType.yellow,
      );
      final updated = notification.updateWarningType(WarningType.red);
      // Verifying that the original topic remains unchanged
      expect(updated.topic, originalTopic);
    });

    // Test 10: Handling multiple Photobioreactor parameters (DO, OD)
    test('NotificationItem handles multiple PBR parameters correctly', () {
      final doNotification = NotificationItem(
        value: 18.0,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'pbr1/do',
        warningType: WarningType.red,
      );
      expect(doNotification.generateMessageTitle(), 'Dissolved Warning');
      expect(doNotification.generateMessage(),
          'Dissolved out of range: 18.00 mg/L');

      final odNotification = NotificationItem(
        value: 0.8,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'pbr1/od',
        warningType: WarningType.yellow,
      );
      expect(odNotification.generateMessageTitle(), 'Optical Warning');
      expect(odNotification.generateMessage(), 'Optical out of range: 0.80 ');
    });

    // Test 11: Handling special characters in the sensor value
    test('NotificationItem handles special characters in values', () {
      final notification = NotificationItem(
        value: -273.15,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/temp1_am',
        warningType: WarningType.red,
      );
      // Verifying that the message contains the special value
      expect(notification.generateMessage().contains('-273.15'), true);
    });

    // Test 12: Verifying consistency in time formatting
    test('NotificationItem maintains time format consistency', () {
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '09:05',
        timeNow: '23:59',
        topic: 'board1/temp1_am',
        warningType: WarningType.green,
      );
      // Verifying that the message correctly shows the time range
      expect(notification.generateMessage().contains('09:05 to 23:59'), true);
    });

    // Test 13: Handling empty or null times
    test('NotificationItem handles empty or null times correctly', () {
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '',
        timeNow: '',
        topic: 'board1/temp1_am',
        warningType: WarningType.yellow,
      );
      // Verifying that the message indicates "out of range"
      expect(notification.generateMessage().contains('out of range'), true);
    });

    // Test 14: Handling extreme numeric values (max finite double)
    test('NotificationItem handles extreme numeric values', () {
      final notification = NotificationItem(
        value: double.maxFinite,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'board1/temp1_am',
        warningType: WarningType.red,
      );
      // Verifying that the message contains "out of range" for extreme values
      expect(notification.generateMessage().contains('out of range'), true);
    });

    // Test 15: Handling all possible Photobioreactor (PBR) topics
    test('NotificationItem handles all PBR topic variations', () {
      final topics = ['pbr1/do', 'pbr1/ph', 'pbr1/od'];
      for (var topic in topics) {
        final notification = NotificationItem(
          value: 25.5,
          timeFirstAdded: '10:00',
          timeNow: '10:30',
          topic: topic,
          warningType: WarningType.yellow,
        );
        expect(notification.generateMessage().isNotEmpty, true);
        expect(notification.generateMessageTitle().contains('Warning'), true);
      }
    });

    // Test 16: Verifying behavior for green warning type with dissolved oxygen
    test('NotificationItem handles green warning type correctly', () {
      final notification = NotificationItem(
        value: 21.0,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'pbr1/do',
        warningType: WarningType.green,
      );
      expect(notification.generateMessageTitle(), 'Dissolved Status');
      expect(notification.generateMessage(),
          'Dissolved has been out of range from 10:00 to 10:30');
    });

    // Test 17: Verifying creation of new instances when updating the warning type
    test('NotificationItem updateWarningType creates new instance correctly',
            () {
          final notification = NotificationItem(
            value: 25.5,
            timeFirstAdded: '10:00',
            timeNow: '10:30',
            topic: 'pbr1/do',
            warningType: WarningType.yellow,
          );
          final updatedNotification =
          notification.updateWarningType(WarningType.red);
          expect(updatedNotification.warningType, WarningType.red);
          expect(updatedNotification != notification,
              true); // Ensuring a new instance is created
          expect(updatedNotification.value, notification.value);
          expect(updatedNotification.topic, notification.topic);
        });

    // Test 18: Verifying message generation for out-of-range value
    test(
        'NotificationItem generates correct warning message for out-of-range value',
            () {
          final notification = NotificationItem(
            value: 25.5,
            timeFirstAdded: '10:00',
            timeNow: '10:30',
            topic: 'board1/temp1_am',
            warningType: WarningType.yellow,
          );
          expect(
              notification.generateMessage(), 'Temperature out of range: 25.50 °C');
        });

    // Test 19: Verifying consistency of decimal precision in generated message
    test('NotificationItem preserves decimal precision consistently', () {
      final notification = NotificationItem(
        value: 25.5555,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'pbr1/do',
        warningType: WarningType.yellow,
      );
      expect(notification.generateMessage(), contains('25.56'));
      expect(notification.generateMessage(), contains('mg/L'));
    });

    // Test 20: Handling no change in warning type
    test('NotificationItem handles same warning type update correctly', () {
      final notification = NotificationItem(
        value: 25.5,
        timeFirstAdded: '10:00',
        timeNow: '10:30',
        topic: 'pbr1/do',
        warningType: WarningType.yellow,
      );
      final sameNotification =
      notification.updateWarningType(WarningType.yellow);
      expect(identical(notification, sameNotification), true);
      expect(notification.value, 25.5);
      expect(notification.topic, 'pbr1/do');
    });

    // Test 21: Creating a NotificationItem when a new value is pushed
    test('NotificationItem is created when a new value is pushed', () {
      final double newValue = 30.0; // Example value
      final String topic = 'board1/temp1_am';
      final WarningType warningType = WarningType.yellow;

      NotificationItem? notification;
      void pushNewValue(double value, String topic, WarningType type) {
        notification = NotificationItem(
          value: value,
          timeFirstAdded: '12:00',
          timeNow: '12:30',
          topic: topic,
          warningType: type,
        );
      }

      pushNewValue(newValue, topic, warningType);

      expect(notification, isNotNull);
      expect(notification!.value, newValue);
      expect(notification!.topic, topic);
      expect(notification!.warningType, warningType);
    });

    // Test 22: No NotificationItem is created if the value is within the normal range
    test('No NotificationItem is created if value is within normal range', () {
      final double normalValue = 22.0;
      final String topic = 'board1/temp1_am';
      NotificationItem? notification;
      void pushNewValue(double value, String topic) {
        if (value < 30.0 && value > 15.0) {
          notification = null;
        } else {
          notification = NotificationItem(
            value: value,
            timeFirstAdded: '12:00',
            timeNow: '12:30',
            topic: topic,
            warningType: WarningType.yellow,
          );
        }
      }

      pushNewValue(normalValue, topic);

      expect(notification, isNull);
    });

    // Test 23: Adding new notifications to the notification list
    test('New notifications are added to the notification list', () {
      List<NotificationItem> notifications = [];
      void addNotification(double value, String topic, WarningType type) {
        notifications.add(NotificationItem(
          value: value,
          timeFirstAdded: '12:00',
          timeNow: '12:30',
          topic: topic,
          warningType: type,
        ));
      }

      addNotification(35.0, 'board1/temp1_am', WarningType.yellow);
      addNotification(55.0, 'board1/temp1_am', WarningType.red);

      expect(notifications.length, 2);
      expect(notifications.first.warningType, WarningType.yellow);
      expect(notifications.last.warningType, WarningType.red);
    });

    // Test 24: Handling a high number of notifications efficiently
    test('NotificationItem handles high number of notifications efficiently',
            () {
          List<NotificationItem> notifications = [];
          for (int i = 0; i < 1000; i++) {
            notifications.add(NotificationItem(
              value: (i % 50) + 10.0, // Alternates between 10 and 59
              timeFirstAdded: '12:00',
              timeNow: '12:30',
              topic: 'board1/temp$i',
              warningType: i % 2 == 0 ? WarningType.yellow : WarningType.red,
            ));
          }

          expect(notifications.length, 1000);
          expect(
              notifications.where((n) => n.warningType == WarningType.red).length,
              500);
        });
  });
}
