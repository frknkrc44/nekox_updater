import 'package:device_info/device_info.dart';
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

  String getReleaseChildTitle(AndroidDeviceInfo _android) => getReleaseChildTitleStatic(this.name, _android);

  static String getReleaseChildTitleStatic(String assetName, AndroidDeviceInfo _android) {
    var nameArray = assetName.split('-');
    List<String> out = [];

    for (var item in nameArray) {
      switch (item) {
        case 'full':
          out.add('Full');
          break;
        case 'fullAppleEmoji':
          out.add('Full Applemoji');
          break;
        case 'fullNoEmoji':
          out.add('Full NoEmoji');
          break;
        case 'fullTwitterEmoji':
          out.add('Full Twemoji');
          break;
        case 'mini':
          out.add('Mini');
          break;
        case 'miniAppleEmoji':
          out.add('Mini Applemoji');
          break;
        case 'miniNoEmoji':
          out.add('Mini NoEmoji');
          break;
        case 'miniTwitterEmoji':
          out.add('Mini Twemoji');
          break;
        case 'arm64':
          out.add('ARMv8');
          _isAbiSupported(_android, out, 'arm64-v8a');
          break;
        case 'armeabi':
          out.add('ARMv7');
          _isAbiSupported(_android, out, 'armeabi-v7a');
          break;
        case 'x86':
          out.add(item);
          _isAbiSupported(_android, out, item);
          break;
        case 'x86_64':
          out.add(item);
          _isAbiSupported(_android, out, item);
          break;
      }

      if (item.contains('NoGcm')) {
        out.add('FOSS');
      }
    }

    return out.join(' ');
  }

  static void _isAbiSupported(AndroidDeviceInfo _android, List<String> out, String abiName) {
    if (!_android.supportedAbis.contains(abiName)) {
      out.add('(Incompatible)');
    }
  }
}
