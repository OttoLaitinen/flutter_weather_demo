import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gap/gap.dart';
import 'package:weather_demo/providers/search_history_provider.dart';
import 'package:provider/provider.dart';

class InfoTab extends StatefulWidget {
  const InfoTab({super.key});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  Future<PackageInfo>? _packageInfo;
  @override
  void initState() {
    _packageInfo = PackageInfo.fromPlatform();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> weatherHistory =
        context.read<SearchHistoryModel>().weatherSearchHistory;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Gap(
              8,
            ),
            const Text(
              'Basic information about the app.',
            ),
            const Gap(
              16,
            ),
            const Text(
              'App information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(
              8,
            ),
            FutureBuilder<PackageInfo>(
                future: _packageInfo,
                builder: (context, snapshot) {
                  Widget buildAppInfo(PackageInfo packageInfo) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('App name: ${packageInfo.appName}'),
                        Text('Version: ${packageInfo.version}'),
                      ],
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return const Text('Failed to load app information.');
                    }
                    if (snapshot.hasData) {
                      return buildAppInfo(snapshot.data!);
                    }
                  }
                  return const Text('Loading app information...');
                }),
            const Gap(16),
            const Text(
              'Last 5 locations (only per session)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            if (weatherHistory.isEmpty)
              const Text('No weather search history available.')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weatherHistory
                    .take(5)
                    .map((String location) => Text(location))
                    .toList(),
              ),
            const Gap(16),
            const Text(
              'Credits',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Developer: Otto A. Laitinen',
            ),
            const Text(
              'Weather icons: Otto A. Laitinen',
            ),
            const Text(
              'Weather data: OpenWeatherMap',
            ),
            const Text(
              'Location autocomplete: Google Places API',
            ),
            const Text(
              'Everything else: The internet probably',
            )
          ],
        ),
      ),
    );
  }
}
