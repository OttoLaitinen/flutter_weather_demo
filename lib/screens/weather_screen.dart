import 'package:flutter/material.dart';
import 'package:weather_demo/widgets/async_autocomplete.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[AsyncCityAutocomplete()],
        ),
      ),
    );
  }
}
