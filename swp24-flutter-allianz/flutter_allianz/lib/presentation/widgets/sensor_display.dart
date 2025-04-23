import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/stream_handler.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/enums/categories.dart';
import 'package:flutter_allianz/enums/settings.dart';
import 'package:flutter_allianz/main.dart';
import 'package:flutter_allianz/models/data.dart';
import 'package:flutter_allianz/presentation/widgets/chart.dart';
import 'package:flutter_allianz/presentation/widgets/tachometer/tachometer.dart';

/// A widget that displays sensor readings along with their corresponding charts.
///
/// This widget renders a row that contains two sections:
/// 1. A set of tachometers for displaying individual sensor values.
/// 2. A chart representing the aggregated data for the sensor values.
///
/// **Author**: Timo Gehrke
class SensorDisplay extends StatelessWidget {
  final String topic;
  final StreamHandler streamHandler = StreamHandler();

  SensorDisplay({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    SettingsType settingsType = topic.startsWith("board") ? SettingsType.board : SettingsType.photobioreactor;
    String type = settingsType == SettingsType.board ? "Board " : "PBR ";
    int amount = settingsType == SettingsType.board ? Params.amountBoards : Params.amountPbrs;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(amount, (index) {
              final stream = streamHandler.getStreamWithTopic(topic, index + 1);
              return Expanded(
                child: Tachometer(
                  title: '$type#${index + 1}',
                  type: settingsType,
                  category: CategoriesExtension.fromTopic(topic)!.name,
                  sensorStream: topic != Categories.boardTemperature.topic &&
                    topic != Categories.boardHumidity.topic 
                    ? stream.stream
                    : streamHandler.getAvgStreamWithTopic(topic, index + 1).stream,
                ),
              );
            }),
          ),
        ),
        Expanded(
            flex: 6,
            child: topic != Categories.boardTemperature.topic &&
                    topic != Categories.boardHumidity.topic
                ? Chart(
                    sensorData: [
                      for (int i = 1; i <= amount; i++)
                        Data(topic: topic, number: i),
                    ],
                  )
                : topic == Categories.boardHumidity.topic
                    ? Chart(
                        sensorData: [
                          for (int i = 1; i <= amount; i++)
                            Data.custom(
                                data: ControllerHelper.controller
                                    .getAvgHumidChart(boardNum: i),
                                dataStream: streamHandler
                                    .getAvgStreamWithTopic(topic, i)
                                    .stream,
                                topic: topic,
                                number: 1)
                        ],
                      )
                    : Chart(
                        sensorData: [
                          for (int i = 1; i <= amount; i++)
                            Data.custom(
                                data: ControllerHelper.controller
                                    .getAvgTempChart(boardNum: i),
                                dataStream: streamHandler
                                    .getAvgStreamWithTopic(topic, i)
                                    .stream,
                                topic: topic,
                                number: 1)
                        ],
                      )
          ),
      ],
    );
  }
}
