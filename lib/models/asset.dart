import 'package:nekox_updater/models/author.dart';

class GitAsset {
  final String name;
  final GitAuthor uploader;
  final String contentType;
  final int size;
  final int downloadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String downloadURL;

  GitAsset({
    this.name,
    this.uploader,
    this.contentType,
    this.size,
    this.downloadCount,
    this.createdAt,
    this.updatedAt,
    this.downloadURL,
  });

  factory GitAsset.fromJSON(Map<String, dynamic> json) => GitAsset(
        name: json['name'],
        uploader: GitAuthor.fromJSON(json['uploader'] ?? {}),
        contentType: json['content_type'],
        size: json['size'],
        downloadCount: json['download_count'],
        createdAt: DateTime.tryParse(json['created_at']),
        updatedAt: DateTime.tryParse(json['updated_at']),
        downloadURL: json['browser_download_url'],
      );
}
