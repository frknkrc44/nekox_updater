import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nekox_updater/main.dart';
import 'package:nekox_updater/models/release.dart';

class GitReleaseFetcher {
  GitReleaseFetcher._();

  static const _RELEASES_URL = 'https://api.github.com/repos/NekoX-Dev/NekoX/releases';

  static Future<List<GitRelease>> getReleases(BuildContext context) async {
    List<GitRelease> releases = [];

    if (await isNotConnected(context)) {
      return releases;
    }

    var rawData = await http.get(_RELEASES_URL, headers: {
      'User-Agent': 'curl/7.99',
      'Accept': 'application/vnd.github.v3+json',
    });

    if (rawData.statusCode != 200) {
      return releases;
    }

    var json = jsonDecode(rawData.body);

    for (var item in json) {
      try {
        releases.add(GitRelease.fromJSON(item));
      } catch (e, s) {
        print(e);
        print(s);
      }
    }

    return releases;
  }

  static int _latestNetworkErrorTime = 0;

  static Future<bool> isConnected(BuildContext context) async {
    try {
      var result = (await MyApp.connectivity.checkConnectivity()) ?? ConnectivityResult.none;
      if (result == ConnectivityResult.none) {
        var date = DateTime.now();
        if ((date.millisecondsSinceEpoch - _latestNetworkErrorTime) > 5000) {
          _latestNetworkErrorTime = date.millisecondsSinceEpoch;
          debugPrint('No network!');
        }
        return false;
      }
      return true;
    } catch (e, s) {
      return false;
    }
  }

  static Future<bool> isNotConnected(BuildContext context) async => !await isConnected(context);
}
