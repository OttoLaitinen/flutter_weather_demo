import 'dart:convert';
import 'dart:developer';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:weather_demo/data/google_autocomplete_api.dart';
import 'package:weather_demo/providers/search_history_provider.dart';
import 'package:go_router/go_router.dart';

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
    if (!mounted ||
        query == null ||
        query.isEmpty ||
        _controller.text.isEmpty) {
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
    _controller.clear();
    _futurePredictions = _searchGooglePlaces(null);
  }

  @override
  void dispose() {
    // Dispose of the focus node and remove any active overlays
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
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
            onChanged: _onSearchChanged,
            controller: _controller),
        FutureBuilder<Iterable<Prediction>?>(
          future: _futurePredictions,
          builder: (BuildContext context,
              AsyncSnapshot<Iterable<Prediction>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (_controller.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),
                  if (snapshot.hasError)
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          color: Colors.red[700]),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12.0,
                                right: 12.0,
                                top: 16.0,
                                bottom: 16.0),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (snapshot.hasData && snapshot.data!.isNotEmpty) ...[
                    const Text(
                      'Search Results: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Gap(8),
                    ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        final Prediction prediction =
                            snapshot.data!.elementAt(index);
                        return ListTile(
                          dense: true,
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[600],
                          ),
                          contentPadding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          title: Text(
                            prediction.description,
                          ),
                          onTap: () {
                            _futurePredictions = _searchGooglePlaces(null);
                            _controller.clear();

                            context
                                .read<SearchHistoryModel>()
                                .pushToSearchHistory(prediction.description);

                            context
                                .push(Uri(
                                    path: '/weather_result',
                                    queryParameters: {
                                      'weatherLocationDescription':
                                          prediction.description,
                                      'placeId': prediction.placeId
                                    }).toString())
                                .then((value) => setState(() =>
                                    {})); // Rerender the UI to clear the search results
                          },
                        );
                      },
                      separatorBuilder: (_, index) => const SizedBox(height: 4),
                      itemCount: snapshot.data!.length,
                    ),
                  ] else if (_controller.text.isNotEmpty)
                    const Text("No results found")
                ],
              );
            }

            return Column(
              children: [
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.amber[400],
                        strokeWidth: 2,
                      ),
                    ),
                    const Gap(8),
                    const Text("Searching for locations..."),
                  ],
                ),
              ],
            );
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

    if (response.statusCode == 200) {
      return autocompleteResponse.predictions;
    } else {
      // TODO: Add logging to an external service
      throw Exception('Failed to load location suggestions');
    }
  }
}
