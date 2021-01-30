import 'package:flutter/material.dart';
import 'package:nekox_updater/models/asset.dart';
import 'package:nekox_updater/models/release.dart';
import 'package:nekox_updater/network/base.dart';
import 'package:expandable_group/expandable_group_widget.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_package_manager/flutter_package_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GitRelease> _releaseCache = [];
  DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo _android;
  PackageInfo _packageInfo;

  bool _downloading = false;
  DownloadInfo _downloadInfo;
  GitRelease _downloadingRelease;
  bool _hasInternet = true;

  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
    initialRefreshStatus: RefreshStatus.refreshing,
  );

  @override
  void initState() {
    super.initState();

    var statuses = [
      DownloadStatus.STATUS_PAUSED,
      DownloadStatus.STATUS_PENDING,
      DownloadStatus.STATUS_RUNNING,
    ];

    var finishedStatuses = [
      DownloadStatus.STATUS_FAILED,
      DownloadStatus.STATUS_SUCCESSFUL,
    ];

    RUpgrade.stream.listen((e) {
      _downloading = statuses.contains(e.status);
      _downloadInfo = e;
      if (_downloading || finishedStatuses.contains(e.status)) setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<List<GitRelease>> _getReleases() async {
    _android = await _deviceInfo.androidInfo;
    _hasInternet = await GitReleaseFetcher.isConnected(context);
    try {
      _packageInfo = await FlutterPackageManager.getPackageInfo('nekox.messenger');
    } catch (e) {}
    var releases = await GitReleaseFetcher.getReleases(context);
    releases.removeWhere(
      (e) => releases.indexOf(e) > releases.indexWhere((e) => e.name == 'v${_getReleaseName(_packageInfo?.versionName ?? '')}'),
    );
    return releases;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('NekoX Releases'),
      ),
      body: SmartRefresher(
        enablePullDown: !_downloading,
        onRefresh: () async {
          _releaseCache = await _getReleases();
          _refreshController.refreshCompleted();
          setState(() {});
        },
        controller: _refreshController,
        header: WaterDropMaterialHeader(),
        child: _downloading
            ? _downloadIndicator
            : _refreshController.isRefresh
                ? _loading
                : _hasInternet
                    ? _releaseList
                    : _noInternet,
      ),
    );
  }

  Widget get _releaseList => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Installed:'),
                    Text('Latest:'),
                  ],
                ),
                Expanded(
                  child: Padding(padding: EdgeInsets.only(right: 8)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(_packageInfo?.versionName ?? 'N/A'),
                    Text(_releaseCache?.first?.name?.replaceFirst('v', '') ?? 'N/A'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _releaseCache.length,
              itemBuilder: _releaseListItemBuilder,
            ),
          ),
        ],
      );

  Function(BuildContext, int) get _releaseListItemBuilder => (BuildContext ctx, int index) {
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
                  TextSpan(
                    text: _getInstalledIndicator(release.name),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
          items: <ListTile>[
            ...release.assets.map((e) => _getReleaseChild(release, e)),
          ],
        );
      };

  String _getInstalledIndicator(String releaseName) {
    return releaseName == 'v${_getReleaseName(releaseName)}' ? ' - Installed' : '';
  }

  String _getReleaseName(String releaseName) {
    var versionName = _packageInfo?.versionName ?? '';
    if (versionName.isEmpty) return '';
    versionName = versionName.replaceAll(RegExp('(mini|full|apple|emoji)'), '');
    versionName = versionName.replaceAll('-', ' ').trim();
    versionName = versionName.replaceAll(' ', '-');
    return versionName;
  }

  String _getDateStr(DateTime time) => '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year}';

  Widget _getReleaseChild(GitRelease release, GitAsset asset) => ListTile(
        title: Text(asset.getReleaseChildTitle(_android)),
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
                  var sourceRelease = _releaseCache.indexOf(release);
                  var installedRelease = _releaseCache.indexWhere((e) => e.name == 'v${_getReleaseName(_packageInfo?.versionName ?? '')}');
                  if (sourceRelease > installedRelease) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Downgrade warning'),
                        content: Text('Android system restricts downgrade of NekoX'),
                      ),
                    );
                    return;
                  }
                  _downloadingRelease = release;
                  await RUpgrade.upgrade(
                    asset.downloadURL,
                    notificationVisibility: NotificationVisibility.VISIBILITY_HIDDEN,
                    useDownloadManager: false,
                    isAutoRequestInstall: true,
                    fileName: asset.name,
                  );
                },
        ),
      );

  Widget get _loading => Container();

  Widget get _downloadIndicator => Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Downloading ${_downloadingRelease.name}'),
              Text('${GitAsset.getReleaseChildTitleStatic(_downloadInfo.path.substring(_downloadInfo.path.lastIndexOf('/')), _android)}'),
              if (_downloadInfo.maxLength > 0)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    value: _getProgress(),
                  ),
                ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Text('${_downloadInfo.speed.toInt()}KB/s - ${_downloadInfo.planTime.toInt()}s left'),
              Padding(padding: EdgeInsets.only(top: 8)),
              ElevatedButton(
                child: Text('CANCEL'),
                onPressed: () async {
                  await RUpgrade.cancel(_downloadInfo.id);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      );

  double _getProgress() {
    double ret = (_downloadInfo.currentLength / _downloadInfo.maxLength.toDouble());
    // print(ret);
    return ret;
  }

  Widget get _noInternet => Container(
        color: Colors.red,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'No internet connection',
                style: TextStyle(color: Colors.white),
              ),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              FlatButton(
                child: Text('TRY AGAIN'),
                onPressed: () => _refreshController.requestRefresh(),
              ),
            ],
          ),
        ),
      );
}
