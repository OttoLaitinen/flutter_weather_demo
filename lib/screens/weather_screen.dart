import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_demo/providers/weather_provider.dart';
import 'package:weather_demo/widgets/placeholder.dart';
import 'package:weather_demo/widgets/weather_info.dart';
import 'package:weather_demo/widgets/weather_search.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final placeId = context.watch<WeatherModel>().weatherLocationPlaceId;
    final weatherLocationDescription =
        context.watch<WeatherModel>().weatherLocationDescription;

    final renderWeatherInfo =
        placeId != null && weatherLocationDescription != null;

    return Column(
      children: [
        Visibility(visible: !renderWeatherInfo, child: const WeatherSearch()),
        if (renderWeatherInfo)
          WeatherInfo(
              weatherLocationDescription: weatherLocationDescription,
              placeId: placeId),
      ],
    );
  }
}
