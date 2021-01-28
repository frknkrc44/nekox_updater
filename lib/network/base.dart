import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nekox_updater/models/release.dart';

class GitReleaseFetcher {
  GitReleaseFetcher._();

  static const _RELEASES_URL = 'https://api.github.com/repos/NekoX-Dev/NekoX/releases';

  static Future<List<GitRelease>> getReleases() async {
    var rawData = await http.get(_RELEASES_URL, headers: {
      'Accept': 'application/vnd.github.v3+json',
    });

    List<GitRelease> releases = [];

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
}
