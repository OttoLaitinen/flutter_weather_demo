import 'package:flutter/material.dart';
import 'package:weather_demo/widgets/weather_search.dart';

class WeatherSearchTab extends StatelessWidget {
  const WeatherSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            WeatherSearch(),
          ],
        ),
      ),
    );
  }
}
