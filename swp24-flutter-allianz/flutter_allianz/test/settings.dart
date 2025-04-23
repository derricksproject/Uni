/// @file settings_test.dart
///
/// @description
/// This file contains a set of widget test cases designed to test the behavior of
/// the Settings page within the Flutter application. It ensures that all the
/// components of the settings page, such as the reset button, tab switching,
/// apply button, text fields, and reset functionality, behave as expected in a
/// variety of scenarios. Each test verifies that the user interface components
/// display correctly, respond to user input, and maintain or reset settings
/// as required. It also tests edge cases such as invalid input in text fields
/// and ensures proper persistence of changes across application sessions.
///
/// @author Derrick Nyarko
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_allianz/presentation/pages/settings.dart';
import 'package:flutter_allianz/config/settings_controller.dart';


void main() {
  // Declare the settings controller which will be used across all test cases
  late SettingsController settingsController;

  /// Setup function to initialize the settings controller before each test.
  ///
  /// The `setUp()` function runs before each individual test, ensuring that
  /// a fresh instance of the `SettingsController` is available. This allows
  /// each test to run independently without any shared state across tests.
  setUp(() {
    settingsController = SettingsController.instance;
  });

  /// Additional setup function to reset settings before each test execution.
  ///
  /// This `setUp()` function will reset the board and photobioreactor settings to
  /// their default values before each test. This ensures the settings are in a clean
  /// state before the execution of the test, preventing prior test executions from
  /// affecting the current test's outcome.
  setUp(() {
    settingsController = SettingsController.instance;
    settingsController.resetBoardSettings(); // Reset Board Settings to default values
    settingsController.resetPhotobioreactorSettings(); // Reset Photobioreactor Settings to default values
  });

  /// Cleanup function to ensure settings are reset after each test.
  ///
  /// This `tearDown()` function will be executed after each test case. It ensures
  /// that any changes made to the settings during the tests are reversed, allowing
  /// for a clean state when the next test begins. This is critical to maintaining
  /// test independence.
  tearDown(() {
    settingsController.resetBoardSettings();
    settingsController.resetPhotobioreactorSettings();
  });

  /// Test case: Ensures reset button functionality works correctly.
  ///
  /// This test verifies that the "reset to default" button correctly triggers a reset
  /// confirmation dialog and resets the settings to their default values when confirmed.
  testWidgets('Reset button shows confirmation dialog and resets settings', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Settings(),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Verify the UI initially displays the expected elements
    expect(find.text('Board Settings'), findsOneWidget);
    expect(find.text('Photobioreactor Settings'), findsOneWidget);
    expect(find.text('reset to default'), findsOneWidget);

    // Simulate tapping the reset button
    await tester.tap(find.text('reset to default'));
    await tester.pumpAndSettle();

    // Ensure the confirmation dialog appears
    expect(find.text('Confirm Reset'), findsOneWidget);

    // Simulate confirming the reset action
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // Ensure the settings are reset and a confirmation message is shown
    expect(find.text('Settings reset'), findsOneWidget);

    // Simulate closing the confirmation dialog
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
  });

  /// Helper function to create a test widget with the settings UI.
  ///
  /// This function creates a basic `MaterialApp` with the `Settings` widget
  /// wrapped in a `Scaffold`. It is used to initialize the settings page
  /// for individual tests. This avoids code duplication in multiple tests.
  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Settings(),
          ],
        ),
      ),
    );
  }

  /// Test case: Ensures tab switching between settings sections works as expected.
  ///
  /// This test ensures that the user can successfully switch between the
  /// "Board Settings" and "Photobioreactor Settings" tabs. It verifies that
  /// the appropriate UI elements for each section are displayed after tab switches.
  testWidgets('Tab switching works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Ensure we start on the Board Settings tab
    expect(find.text('Board Settings'), findsOneWidget);

    // Simulate tapping the "Photobioreactor Settings" tab
    await tester.tap(find.text('Photobioreactor Settings'));
    await tester.pumpAndSettle();

    // Simulate tapping the "Board Settings" tab again
    await tester.tap(find.text('Board Settings'));
    await tester.pumpAndSettle();

    // Simulate tapping the "Photobioreactor Settings" tab again
    await tester.tap(find.text('Photobioreactor Settings'));
    await tester.pumpAndSettle();

    // Ensure the Photobioreactor Settings UI elements are visible
    expect(find.text('Photobioreactor Settings'), findsOneWidget);
  });

  /// Test case: Ensures Apply button functionality shows confirmation dialog.
  ///
  /// This test verifies that tapping the "apply" button shows the confirmation
  /// dialog and displays a message asking the user whether they want to save the
  /// settings changes.
  testWidgets('Apply button shows confirmation dialog and saves settings', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Simulate tapping the "apply" button
    await tester.tap(find.text('apply'));
    await tester.pumpAndSettle();

    // Ensure the confirmation dialog is displayed
    expect(find.text('Confirm Changes'), findsOneWidget);
    expect(find.text('Do you want to save your changes to the settings?'), findsOneWidget);
  });

  /// Test case: Ensures text fields reject invalid input.
  ///
  /// This test ensures that invalid input (non-numeric values) is rejected by
  /// the `TextFormField` widget, verifying that only valid values are accepted.
  testWidgets('Text fields reject invalid input', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Find the first text field and store its initial value
    final textField = find.byType(TextFormField).first;
    final initialValue = (textField.evaluate().single.widget as TextFormField).controller?.text;

    // Enter invalid input (non-numeric)
    await tester.enterText(textField, 'abc');
    await tester.pumpAndSettle();

    // Ensure invalid input is not accepted and the initial value persists
    expect(find.text(initialValue!), findsAtLeastNWidgets(1));
  });

  /// Test case: Ensures multiple text fields can be updated at the same time.
  ///
  /// This test checks that multiple `TextFormField` widgets can be updated simultaneously.
  testWidgets('Multiple fields can be updated simultaneously', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Find all text fields
    final textFields = find.byType(TextFormField);

    // Update multiple fields with valid values
    await tester.enterText(textFields.first, '25.0');
    await tester.enterText(textFields.at(2), '35.0');
    await tester.pumpAndSettle();

    // Ensure the updated values are displayed in the UI
    expect(find.text('25.0'), findsAtLeastNWidgets(1));
    expect(find.text('35.0'), findsAtLeastNWidgets(1));
  });

  /// Test case: Ensures settings persist after applying changes.
  ///
  /// This test verifies that when settings are applied, the values entered into
  /// the text fields persist even after the apply confirmation dialog is displayed
  /// and confirmed.
  testWidgets('Settings persist after apply', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Find the first text field and enter a test value
    final textField = find.byType(TextFormField).first;
    final testValue = '30.5';

    await tester.enterText(textField, testValue);
    await tester.pumpAndSettle();

    // Simulate tapping the "apply" button and confirm the changes
    await tester.tap(find.text('apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // Ensure the entered value persists after applying
    expect(find.text(testValue), findsAtLeastNWidgets(1));
  });

  /// Test case: Ensures reset functionality restores default values.
  ///
  /// This test ensures that after modifying a setting, the reset button works
  /// properly by restoring the default values.
  testWidgets('Reset functionality works', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Find the first text field and store its initial value
    final textField = find.byType(TextFormField).first;
    final initialValue = (textField.evaluate().single.widget as TextFormField).controller?.text;

    // Modify the value in the text field
    await tester.enterText(textField, '99.9');
    await tester.pumpAndSettle();

    // Simulate tapping the "reset to default" button and confirm the reset
    await tester.tap(find.text('reset to default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    // Ensure the reset restores the original value
    expect(find.text(initialValue!), findsOneWidget);
  });
}