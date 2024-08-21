import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

const Duration fakeAPIDuration = Duration(milliseconds: 200);
const Duration debounceDuration = Duration(milliseconds: 300);

class AsyncCityAutocomplete extends StatefulWidget {
  const AsyncCityAutocomplete({super.key});

  @override
  State<AsyncCityAutocomplete> createState() => _AsyncCityAutocompleteState();
}

class _AsyncCityAutocompleteState extends State<AsyncCityAutocomplete> {
  String? _currentQuery;

  late Iterable<String> _lastOptions = <String>[];

  late final _Debounceable<Iterable<Prediction>?, String> _debouncedSearch;

  // // Calls the "remote" API to search with the given query. Returns null when
  // // the call has been made obsolete.
  // Future<Iterable<String>?> _search(String query) async {
  //   _currentQuery = query;

  //   // In a real application, there should be some error handling here.
  //   final Iterable<String> options = await _FakeAPI.search(_currentQuery!);

  //   // If another search happened after this one, throw away these options.
  //   if (_currentQuery != query) {
  //     return null;
  //   }
  //   _currentQuery = null;

  //   return options;
  // }

  Future<Iterable<Prediction>?> _searchGooglePlaces(String query) async {
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

  @override
  void initState() {
    super.initState();
    _debouncedSearch =
        _debounce<Iterable<Prediction>?, String>(_searchGooglePlaces);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("City search"),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            final Iterable<Prediction>? predictions =
                await _debouncedSearch(textEditingValue.text);
            final Iterable<String>? options =
                predictions?.map((e) => e.description).toList();

            if (options == null) {
              return _lastOptions;
            }
            _lastOptions = options;
            return options;
          },
          onSelected: (String selection) {
            log('You just selected $selection');
          },
        ),
      ],
    );
  }
}

const String _googlePlacesAutocompleteUrl =
    'https://maps.googleapis.com/maps/api/place/autocomplete/json';

class _GooglePlacesAutoCompleteAPI {
  static Future<Iterable<Prediction>> searchForSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        '$_googlePlacesAutocompleteUrl?input=$query&language=en&types=locality&key=${dotenv.env['MAPS_API_KEY']}'));

    final AutocompleteResponse autocompleteResponse =
        AutocompleteResponse.fromJson(jsonDecode(response.body));

    if (response.statusCode == 200 && autocompleteResponse.status == 'OK') {
      return autocompleteResponse.predictions;
    } else {
      debugPrint("Failed!!");
      return [];
    }
  }
}

class AutocompleteResponse {
  final List<Prediction> predictions;
  final String status;

  AutocompleteResponse({
    required this.predictions,
    required this.status,
  });

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return AutocompleteResponse(
      predictions: List<Prediction>.from(
        json['predictions'].map((x) => Prediction.fromJson(x)),
      ),
      status: json['status'],
    );
  }
}

class Prediction {
  final String description;
  final String placeId;

  Prediction({
    required this.description,
    required this.placeId,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
