# Weather Demo

This is a demo project showcasing a weather application built with Flutter.

## Installation

1. Install dependencies: 
```bash
flutter pub get
```
2. Create a `.env` file. You can use `.example.env` as a guide
3. Get an API key from OpenWeatherMap ([link](https://openweathermap.org/)) and for Google Places API ([link](https://developers.google.com/maps/documentation/places/web-service/get-api-key#creating-api-keys)) and add them to the `.env` file.
4. Run the app using `flutter run` or your IDE

## Features

- Autocomplete location search for weather locations using Google Places autocomplete API
- Weather information screen with current weather information from OpenWeatherMap API
- Navigation structure built with GoRouter
- Local state management for (per session) weather search history using Providers

## Known issues

#### Weather data is not found for some more complicated location names

The app currently just passes the location description (e.g. "London, UK") from Google Places API straight to OpenWeatherMap API which then runs geolocating on it and returns the weather data. 

Unfortunately, the OpenWeatherMap API geolocating doesn't always know how to handle all output from Google Places API and returns a "404" for some locations.

Examples of failing locations:
- Helsinki-Uusimaa, Finland
- Toronto NSW, Australia
- Lonavala, Maharashtra, India

This problem could be fixed by running Google's own geolocating on the `placeID` property returned from the Google Places Autocomplete API and then calling OpenWeatherMap API with coordinated but that functionality has not been implemented.

## License

This project including the weather icons is licensed under the MIT License.
