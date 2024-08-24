import 'package:flutter/material.dart';
import 'package:weather_demo/widgets/async_autocomplete.dart';

class WeatherSearch extends StatelessWidget {
  const WeatherSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[AsyncCityAutocomplete()],
      ),
    );
  }
}
