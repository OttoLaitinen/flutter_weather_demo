import 'package:flutter/material.dart';

class SearchHistoryModel extends ChangeNotifier {
  final List<String> _weatherSearchHistory = [];

  List<String> get weatherSearchHistory => _weatherSearchHistory;

  void pushToSearchHistory(String locationDescription) {
    if (_weatherSearchHistory.contains(locationDescription)) {
      _weatherSearchHistory.remove(locationDescription);
    }
    _weatherSearchHistory.insert(0, locationDescription);
    notifyListeners();
  }

  void clearWeatherSearchHistory() {
    _weatherSearchHistory.clear();
    notifyListeners();
  }
}
