import 'package:flutter/material.dart';

class WeatherModel extends ChangeNotifier {
  String? _weatherLocationDescription;
  String? _weatherLocationPlaceId;
  double? _latitude;
  double? _longitude;

  String? get weatherLocationDescription => _weatherLocationDescription;
  String? get weatherLocationPlaceId => _weatherLocationPlaceId;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  void setWeatherLocationPlaceId(String? placeId) {
    _weatherLocationPlaceId = placeId;
    notifyListeners();
  }

  void setWeatherLocationDescription(String? description) {
    _weatherLocationDescription = description;
    notifyListeners();
  }

  void setLatitude(double? lat) {
    _latitude = lat;
    notifyListeners();
  }

  void setLongitude(double? long) {
    _longitude = long;
    notifyListeners();
  }

  void clearWeatherLocation() {
    _weatherLocationPlaceId = null;
    _latitude = null;
    _longitude = null;
    notifyListeners();
  }
}
