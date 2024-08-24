import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:weather_demo/data/open_weather_api_current_weather.dart';
import 'package:weather_demo/providers/weather_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo(
      {super.key,
      required this.weatherLocationDescription,
      required this.placeId});

  final String weatherLocationDescription;
  final String placeId;

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  Future<WeatherResponse>? _currentWeather;

  @override
  void initState() {
    super.initState();
    _currentWeather = _OpenWeatherCurrentWeatherAPI.getWeatherForLocationName(
        widget.weatherLocationDescription);
  }

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      log("Clearing weather location");
      context.read<WeatherModel>().clearWeatherLocation();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FutureBuilder<WeatherResponse>(
            future: _currentWeather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final WeatherResponse weather = snapshot.data!;
                  return WeatherInfoDisplay(
                      currentWeather: weather,
                      weatherLocationDescription:
                          widget.weatherLocationDescription);
                } else if (snapshot.hasError) {
                  log("Error: ${snapshot.error}");
                  return const Text("Failed to load weather");
                }
              }

              return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()));
            },
          ),
          const Gap(24),
          Center(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[300],
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0)),
              child: const Text(
                "Change location",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherInfoDisplay extends StatelessWidget {
  const WeatherInfoDisplay(
      {super.key,
      required this.currentWeather,
      required this.weatherLocationDescription});

  final WeatherResponse currentWeather;
  final String weatherLocationDescription;

  @override
  Widget build(BuildContext context) {
    final String temperature =
        currentWeather.main.temp?.round().toString() ?? 'N/A';

    final String weatherDescription = currentWeather.weather.first.description;
    final String formattedWeatherDescription = weatherDescription
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    final String iconCode = currentWeather.weather.first.icon;
    final String iconUrl = 'assets/weatherIcons/$iconCode.png';

    return Column(
      children: [
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Image.asset(iconUrl,
              errorBuilder: (ctx, error, stackTrace) => Image.asset('01d.png')),
        ),
        Row(
          children: [
            const Icon(Icons.pin_drop),
            const Gap(4),
            Text(weatherLocationDescription,
                style: const TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold)),
          ],
        ),
        const Gap(8),
        Row(
          textBaseline: TextBaseline.values[0],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                  textBaseline: TextBaseline.values[0],
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(temperature,
                        style: const TextStyle(
                            fontSize: 104.0,
                            fontWeight: FontWeight.w100,
                            height: 1.0)),
                    Text('°C',
                        style: TextStyle(
                            fontSize: 48.0,
                            fontWeight: FontWeight.w200,
                            color: Colors.grey[600]))
                  ]),
            ),
            Expanded(
              flex: 1,
              child: Text(
                formattedWeatherDescription,
                style: const TextStyle(fontSize: 20.0),
                textAlign: TextAlign.right,
              ),
            )
          ],
        )
      ],
    );
  }
}

class _OpenWeatherCurrentWeatherAPI {
  static const String _openWeatherMapApiUrl =
      'https://api.openweathermap.org/data/2.5/weather?units=metric';

  static Future<WeatherResponse> getWeatherForLocationName(
      String locationName) async {
    final response = await http.get(Uri.parse(
        '$_openWeatherMapApiUrl&q=$locationName&appid=${dotenv.env['OPEN_WEATHER_API_KEY']}'));

    final WeatherResponse weatherResponse =
        WeatherResponse.fromJson(jsonDecode(response.body));

    if (response.statusCode == 200) {
      return weatherResponse;
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
