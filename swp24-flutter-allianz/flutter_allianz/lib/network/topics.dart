import 'package:flutter_allianz/config/params.dart';

/// A list of all MQTT topics used in the application. The topics are dynamically
/// generated based on the number of sensor boards (`Params.amountBoards`) and
/// photobioreactors (`Params.amountPbrs`) configured in the [Params] class.
///
/// **Author**: Steffen Gebhard
final List<String> fullTopics = [
  "chatbot/user",
  "chatbot/mission_control",
  for (int i = 1; i <= Params.amountBoards; i++) ...[
      for (int j = 1; j <= 4; j++) ...[
        "board$i/temp${j}_am",
        "board$i/humid${j}_am",
      ],
      "board$i/amb_press",
      "board$i/o2",
      "board$i/co2",
      "board$i/co",
      "board$i/o3",
  ],

    for (int i = 1; i <= Params.amountPbrs; i++) ...[
      "pbr$i/temp_1",
      "pbr$i/temp_g_2",
      "pbr$i/amb_press_2",
      "pbr$i/do",
      "pbr$i/o2_2",
      "pbr$i/co2_2",
      "pbr$i/rh_2",
      "pbr$i/ph",
      "pbr$i/od",
    ]
];