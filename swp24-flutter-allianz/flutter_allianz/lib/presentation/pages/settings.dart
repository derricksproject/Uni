import 'package:flutter/material.dart';
import 'package:flutter_allianz/config/settings_controller.dart';
import 'package:flutter_allianz/models/value_with_unit.dart';
import 'package:flutter_allianz/presentation/widgets/styled/styled_tabbar.dart';

/// A widget that displays the settings interface for configuring boards,
/// photobioreactors, and miscellaneous settings.
/// 
/// **Author**: Timo Gehrke
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      flex: 4,
      child: SettingsPanel(),
    );
  }
}

/// The panel that contains the settings for boards, photobioreactors, and miscellaneous settings.
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  SettingsPanelState createState() => SettingsPanelState();
}

class SettingsPanelState extends State<SettingsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final Map<String, Map<String, ValueWithUnit>> boardSettings;
  late final Map<String, Map<String, ValueWithUnit>> photobioreactorSettings;
  final amountBoardsController = TextEditingController();
  final amountPBRController = TextEditingController();
  final userNameController = TextEditingController();

  Map<String, TextEditingController> boardControllers = {};
  Map<String, TextEditingController> photobioreactorControllers = {};

  @override
  void initState() {
    super.initState();
    amountBoardsController.text =
        SettingsController.instance.miscSettings['amountBoards'].toString();
    amountPBRController.text =
        SettingsController.instance.miscSettings['amountPBR'].toString();
    userNameController.text =
        SettingsController.instance.miscSettings['userName'];
    boardSettings = SettingsController.instance.getAllBoardSettings();
    photobioreactorSettings =
        SettingsController.instance.getAllPhotobioreactorSettings();
    _tabController = TabController(length: tabs.length, vsync: this);
    _initializeControllers();
  }

  @override
  void dispose() {
    amountBoardsController.dispose();
    amountPBRController.dispose();
    userNameController.dispose();
    _tabController.dispose();
    boardControllers.forEach((key, controller) {
      controller.dispose();
    });
    photobioreactorControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  List<Tab> tabs = [
    Tab(text: 'Board Settings'),
    Tab(text: 'Photobioreactor Settings'),
    Tab(text: 'Miscellaneous'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StyledTabBar(controller: _tabController, tabs: tabs),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildTab(boardSettings, boardControllers),
                buildTab(photobioreactorSettings, photobioreactorControllers),
                buildMiscTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the miscellaneous settings tab which includes controls for the board amount,
  /// photobioreactor amount, and the user name.
  Widget buildMiscTab() {
    double width = 150;
    return Column(
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: width, child: Text('Board amount: ')),
          buildInputForm(amountBoardsController, TextInputType.number)
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: width, child: Text('PBR amount: ')),
          buildInputForm(amountPBRController, TextInputType.number)
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: width, child: Text('Username: ')),
          buildInputForm(userNameController, TextInputType.text)
        ]),
        ElevatedButton(
          onPressed: () => _showDialog('Confirm Changes',
              'Do you want to save your changes to the settings?', [
            TextButton(
                onPressed: () {
                  onApplySettings();
                  _showDialog(
                    'Restart',
                    'Your changes have been saved. To apply them, please restart the app.',
                    [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                          Navigator.of(context).pop(); 
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  );
                },
                child: const Text('Yes')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No')),
          ]),
          child: const Text('apply'),
        ),
      ],
    );
  }

  /// Saves the current settings when the user applies changes.
  void onApplySettings() {
    final amountBoards = int.tryParse(amountBoardsController.text) ?? 4;
    final amountPBR = int.tryParse(amountPBRController.text) ?? 1;
    final userName = userNameController.text;

    setState(() {
      SettingsController.instance.miscSettings = {
        'amountBoards': amountBoards,
        'amountPBR': amountPBR,
        'userName': userName,
      };
    });
    SettingsController.instance.saveMiscSettings();
  }

  /// Builds an input form for the settings, which allows the user to input values
  /// for specific settings fields.
  Widget buildInputForm(controller, textInputType) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        keyboardType: textInputType,
      ),
    );
  }

  /// Builds a tab with the provided settings and controllers, and renders each of the settings in an editable form.
  Widget buildTab(settings, controllers) {
    return Column(
      children: [
        Expanded(
          flex: 20,
          child: SingleChildScrollView(
            child: Row(
              children: [
                Expanded(flex: 1, child: buildFirstRow(settings)),
                Expanded(
                    flex: 5, child: buildMiddleRows(settings, controllers)),
                Expanded(flex: 1, child: buildUnitRow(settings)),
              ],
            ),
          ),
        ),
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _showDialog('Confirm Changes',
                      'Do you want to save your changes to the settings?', [
                    TextButton(
                        onPressed: () => onApplyPressed(settings, controllers),
                        child: const Text('Yes')),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('No')),
                  ]),
                  child: const Text('apply'),
                ),
                const SizedBox(width: 100),
                ElevatedButton(
                  onPressed: () =>
                      _showResetDialog(() => resetSettings(settings)),
                  child: const Text('reset to default'),
                ),
              ],
            ))
      ],
    );
  }

  /// Builds the first row of settings, displaying the names of the settings.
  Widget buildFirstRow(Map<String, Map<String, ValueWithUnit>> settings) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: settings.length,
        itemBuilder: (context, index) {
          String key = settings.keys.elementAt(index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index == 0)
                const SizedBox(
                  height: 50,
                ),
              const SizedBox(height: 25),
              SizedBox(
                height: 50,
                child: Text(
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.start,
                  key,
                ),
              ),
            ],
          );
        });
  } 

  /// Builds the middle rows of settings, rendering each setting's name, value input,
  /// and unit information.
  Widget buildMiddleRows(Map<String, Map<String, ValueWithUnit>> settings,
      Map<String, TextEditingController> controllers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: settings.length,
      itemBuilder: (context, index) {
        String key = settings.keys.elementAt(index);
        return Row(
          spacing: 20,
          children: settings[key]!.entries.map((entry) {
            String subkey = entry.key;

            return Expanded(
              child: Column(
                children: [
                  if (index == 0)
                    SizedBox(
                      height: 50,
                      width: 400,
                      child: Text(
                        textAlign: TextAlign.center,
                        subkey,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  const SizedBox(height: 25),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: controllers['$key-$subkey'],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Builds the unit row for each setting, displaying the unit next to each setting value.
  Widget buildUnitRow(Map<String, Map<String, ValueWithUnit>> settings) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: settings.length,
        itemBuilder: (context, index) {
          String key = settings.keys.elementAt(index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index == 0)
                const SizedBox(
                  height: 80,
                ),
              const SizedBox(height: 25),
              SizedBox(
                height: 50,
                width: 100,
                child: Text(
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.end,
                  settings[key]!.values.first.unit,
                ),
              ),
            ],
          );
        });
  }

  /// Displays a dialog with a confirmation message and actions.
  void _showDialog(String title, String message, List<Widget> actions) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: actions,
        );
      },
    );
  }

  /// Displays a dialog asking the user for confirmation to reset settings to their default values.
  void _showResetDialog(Function onReset) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reset'),
        content:
            const Text('Do you really want to reset the settings to default?'),
        actions: [
          TextButton(
            onPressed: () async {
              await onReset();
              _showDialog(
                'Settings reset',
                'Settings have been reset to default.',
                [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Applies the settings and saves the changes.
  void onApplyPressed(settings, controllers) {
    setState(() {
      saveControllers(settings, controllers);
      _updateControllers(settings, controllers);
    });

    SettingsController.instance.saveSettings();
    Navigator.of(context).pop();
  }

  /// Saves the controllers' data into the settings.
  void saveControllers(settings, controllers) {
    settings.forEach((key, subMap) {
      subMap.forEach((subkey, valueWithUnit) {
        String? newValueStr = controllers['$key-$subkey']?.text;
        double? newValue = double.tryParse(newValueStr ?? '');
        if (newValue != null) {
          valueWithUnit.value = newValue;
        }
      });
    });
  }

  /// Initializes the controllers with the current settings values.
  void _initializeControllers() {
    // Initialize controllers for board settings
    boardSettings.forEach((key, subMap) {
      subMap.forEach((subkey, valueWithUnit) {
        boardControllers['$key-$subkey'] =
            TextEditingController(text: valueWithUnit.value.toString());
      });
    });
    photobioreactorSettings.forEach((key, subMap) {
      subMap.forEach((subkey, valueWithUnit) {
        photobioreactorControllers['$key-$subkey'] =
            TextEditingController(text: valueWithUnit.value.toString());
      });
    });
  }

  /// Resets the settings to their default values based on the settings type (board or photobioreactor).
  Future<void> resetSettings(
      Map<String, Map<String, ValueWithUnit>> settings) async {
    if (settings == boardSettings) {
      await SettingsController.instance.resetBoardSettings();
      setState(() {
        _initializeControllers();
      });
    } else {
      await SettingsController.instance.resetPhotobioreactorSettings();
      setState(() {
        _initializeControllers();
      });
    }
    SettingsController.instance.saveSettings();
  }

  /// Updates the controllers with the current settings values after applying changes.
  void _updateControllers(Map<String, Map<String, ValueWithUnit>> settings,
      Map<String, TextEditingController> controllers) {
    settings.forEach((key, subMap) {
      subMap.forEach((subkey, value) {
        controllers['$key-$subkey']?.text = value.value?.toString() ?? '';
        setState(() {});
      });
    });
  }
}
