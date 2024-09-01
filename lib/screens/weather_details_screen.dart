import 'package:flutter/material.dart';
import 'package:weather_demo/widgets/weather_info.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen(
      {super.key,
      required this.weatherLocationDescription,
      required this.placeId});

  final String weatherLocationDescription;
  final String placeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: WeatherInfo(
            weatherLocationDescription: weatherLocationDescription,
            placeId: placeId));
  }
}
