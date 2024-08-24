import 'dart:convert';
import 'dart:developer';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:weather_demo/data/google_autocomplete_api.dart';
import 'package:weather_demo/providers/weather_provider.dart';

const Duration fakeAPIDuration = Duration(milliseconds: 200);
const Duration debounceDuration = Duration(milliseconds: 400);

class AsyncCityAutocomplete extends StatefulWidget {
  const AsyncCityAutocomplete({super.key});

  @override
  State<AsyncCityAutocomplete> createState() => _AsyncCityAutocompleteState();
}

class _AsyncCityAutocompleteState extends State<AsyncCityAutocomplete> {
  String? _currentQuery;
  Timer? _debounceTimer;
  final TextEditingController _controller = TextEditingController();

  late Future<Iterable<Prediction>?> _futurePredictions;

  Future<Iterable<Prediction>?> _searchGooglePlaces(String? query) async {
    if (!mounted || query == null || query.isEmpty) {
      return null;
    }
    _currentQuery = query;

    // In a real application, there should be some error handling here.
    final Iterable<Prediction> options =
        await _GooglePlacesAutoCompleteAPI.searchForSuggestions(_currentQuery!);

    // If another search happened after this one, throw away these options.
    if (_currentQuery != query) {
      return null;
    }

    _currentQuery = null;

    return options;
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(debounceDuration, () {
      setState(() {
        _futurePredictions = _searchGooglePlaces(query);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _futurePredictions = _searchGooglePlaces(null);
  }

  @override
  void dispose() {
    // Dispose of the focus node and remove any active overlays
    log("Disposing");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
            decoration: const InputDecoration(
                hintText: 'Enter a city', border: OutlineInputBorder()),
            onTapOutside: (event) => setState(() {
                  _controller.clear();
                }),
            onChanged: _onSearchChanged,
            controller: _controller),
        FutureBuilder<Iterable<Prediction>?>(
          future: _futurePredictions,
          builder: (BuildContext context,
              AsyncSnapshot<Iterable<Prediction>?> snapshot) {
            log("Snapshot: ${snapshot.connectionState}");
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Column(
                  children: snapshot.data!.map((Prediction prediction) {
                    return ListTile(
                      title: Text(prediction.description),
                      onTap: () {
                        log("Selected: ${prediction.description}");
                        _futurePredictions = _searchGooglePlaces(null);
                        context
                            .read<WeatherModel>()
                            .setWeatherLocationDescription(
                                prediction.description);
                        context
                            .read<WeatherModel>()
                            .setWeatherLocationPlaceId(prediction.placeId);
                      },
                    );
                  }).toList(),
                );
              }
              if (_controller.text.isEmpty) {
                log("IS EMPTY");
                return const SizedBox.shrink();
              }
              log("No results found");
              return const Text("No results found");
            }

            return const CircularProgressIndicator();
          },
        ),
      ],
    );
  }
}

class _GooglePlacesAutoCompleteAPI {
  static const String _googlePlacesAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  static Future<Iterable<Prediction>> searchForSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        '$_googlePlacesAutocompleteUrl?input=$query&language=en&types=locality&key=${dotenv.env['MAPS_API_KEY']}'));

    final AutocompleteResponse autocompleteResponse =
        AutocompleteResponse.fromJson(jsonDecode(response.body));

    if (response.statusCode == 200 && autocompleteResponse.status == 'OK') {
      return autocompleteResponse.predictions;
    } else {
      throw Exception('Failed to load location suggestions');
    }
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}

// An exception indicating that a network request has failed.
class _NetworkException implements Exception {
  const _NetworkException();
}
