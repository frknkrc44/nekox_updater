import 'package:flutter/material.dart';
import 'package:nekox_updater/models/asset.dart';
import 'package:nekox_updater/models/release.dart';
import 'package:nekox_updater/network/base.dart';
import 'package:expandable_group/expandable_group_widget.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_package_manager/flutter_package_manager.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GitRelease> _releaseCache;
  DeviceInfoPlugin _deviceInfo;
  AndroidDeviceInfo _android;
  PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();

    _deviceInfo = DeviceInfoPlugin();

    var statuses = [
      DownloadStatus.STATUS_PENDING,
      DownloadStatus.STATUS_RUNNING,
    ];

    RUpgrade.stream.listen((e) {
      _downloading = statuses.contains(e.status);
    });
  }

  Future<List<GitRelease>> _getReleases() async {
    _android = await _deviceInfo.androidInfo;
    _packageInfo = await FlutterPackageManager.getPackageInfo('nekox.messenger');
    return GitReleaseFetcher.getReleases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('NekoX Releases'),
      ),
      body: _releaseCache == null
          ? FutureBuilder(
              future: _getReleases(),
              builder: (BuildContext ctx, AsyncSnapshot<List<GitRelease>> snapshot) {
                if (snapshot.data == null) {
                  return _loading;
                }

                _releaseCache = snapshot.data;
                return _releaseList;
              },
            )
          : _releaseList,
    );
  }

  Widget get _releaseList => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Installed: ${_packageInfo.versionName}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _releaseCache.length,
              itemBuilder: (BuildContext ctx, int index) {
                var release = _releaseCache[index];
                return ExpandableGroup(
                  collapsedIcon: Icon(Icons.arrow_drop_down),
                  expandedIcon: Icon(Icons.arrow_drop_up),
                  header: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text.rich(
                      TextSpan(
                        text: '${release.name}\n',
                        children: [
                          TextSpan(
                            text: '${release.author.login}',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          TextSpan(
                            text: ' - ',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          TextSpan(
                            text: _getDateStr(release.createdAt),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                  items: <ListTile>[
                    ...release.assets.map((e) => _getReleaseChild(e)),
                  ],
                );
              },
            ),
          ),
        ],
      );

  String _getDateStr(DateTime time) => '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year}';

  Widget _getReleaseChild(GitAsset asset) => ListTile(
        title: Text(_getReleaseChildTitle(asset)),
        subtitle: Text(
          '${(asset.size.toDouble() / (1 << 20)).toStringAsFixed(2)}MB, ${asset.downloadCount} downloads',
          style: Theme.of(context).textTheme.caption,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.download_outlined,
            color: Theme.of(context).accentColor,
          ),
          onPressed: _downloading
              ? null
              : () async {
                  await RUpgrade.upgrade(
                    asset.downloadURL,
                    useDownloadManager: false,
                    isAutoRequestInstall: true,
                    fileName: asset.name,
                  );
                },
        ),
      );

  bool _downloading = false;

  String _getReleaseChildTitle(GitAsset asset) {
    var name = asset.name.split('-');
    List<String> out = [];

    for (var item in name) {
      switch (item) {
        case 'full':
          out.add('Full');
          break;
        case 'fullAppleEmoji':
          out.add('Full Applemoji');
          break;
        case 'mini':
          out.add('Mini');
          break;
        case 'miniAppleEmoji':
          out.add('Mini Applemoji');
          break;
        case 'arm64':
          out.add('ARMv8');
          _isAbiSupported(out, 'arm64-v8a');
          break;
        case 'armeabi':
          out.add('ARMv7');
          _isAbiSupported(out, 'armeabi-v7a');
          break;
        case 'x86':
          out.add(item);
          _isAbiSupported(out, item);
          break;
        case 'x86_64':
          out.add(item);
          _isAbiSupported(out, item);
          break;
      }

      if (item.contains('NoGcm')) {
        out.add('FOSS');
      }
    }

    return out.join(' ');
  }

  void _isAbiSupported(List<String> out, String abiName) {
    if (!_android.supportedAbis.contains(abiName)) {
      out.add('(Incompatible)');
    }
  }

  Widget get _loading => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        ),
      );
}
