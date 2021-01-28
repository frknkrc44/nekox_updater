import 'package:nekox_updater/models/asset.dart';
import 'package:nekox_updater/models/author.dart';

class GitRelease {
  final String url;
  final String name;
  final GitAuthor author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<GitAsset> assets;

  GitRelease({
    this.url,
    this.name,
    this.author,
    this.createdAt,
    this.updatedAt,
    this.assets,
  });

  factory GitRelease.fromJSON(Map<String, dynamic> json) => GitRelease(
        url: json['url'],
        name: json['name'],
        author: GitAuthor.fromJSON(json['author'] ?? {}),
        createdAt: DateTime.tryParse(json['created_at'] ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
        assets: (json['assets'] ?? []).map<GitAsset>((e) => GitAsset.fromJSON(e)).toList(),
      );
}
