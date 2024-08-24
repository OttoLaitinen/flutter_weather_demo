import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_demo/navigationWidget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_demo/providers/weather_provider.dart';

void main() async {
  await dotenv.load();
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WeatherModel())],
      child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NavigationWidget(),
      theme: ThemeData.from(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade800)),
    );
  }
}
