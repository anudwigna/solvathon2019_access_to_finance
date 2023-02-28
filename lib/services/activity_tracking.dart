import 'package:MunshiG/models/app_page_naming.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'preference_service.dart';

class ActivityTracker {
  ActivityTracker._();

  factory ActivityTracker() => ActivityTracker._();

  Future<DatabaseAndStore> getDatabaseAndStore() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(
        await _getDbPath('app_activity_tracking.db'),
      ),
      store: intMapStoreFactory.store('app_activity_tracking'),
    );
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  ///action=page to page transactions
  Future pageTransactionActivity(String pageName, {String action = 'Opened'}) async {
    try {
      int id = await PreferenceService.instance.getPageTrackCountIndex();
      PreferenceService.instance.setPageTrackCountIndex(id + 1);
      final int? pageId = getPageIdByName(pageName);
      var dbStore = await getDatabaseAndStore();
      await dbStore.store!.add(dbStore.database, {
        'id': id,
        'action': action,
        'pageId': pageId,
        'pageName': pageName,
        'actionDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {}
  }

  ///action=non-page transctions like dialog, alert etc
  Future otherActivityOnPage(String pageName, String action, String widgetName, String widgetType) async {
    try {
      int id = await PreferenceService.instance.getPageTrackCountIndex();
      PreferenceService.instance.setPageTrackCountIndex(id + 1);
      final int? pageId = getPageIdByName(pageName);
      var dbStore = await getDatabaseAndStore();
      await dbStore.store!.add(dbStore.database, {
        'id': id,
        'action': action,
        'pageId': pageId,
        'pageName': pageName,
        'widgetName': widgetName,
        'widgetType': widgetType,
        'actionDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {}
  }

  int? getPageIdByName(String pageName) {
    if (PageName.pages == null) return null;
    int? pageId;
    final data = PageName.pages!.where((element) => element['name'] == pageName).toList();
    if ((data).isNotEmpty) {
      pageId = data.first['id'];
    }
    return pageId;
  }

  Future<void> closeDatabase(String subsector) async {
    final db = await getDatabaseAndStore();
    await db.database.close();
  }
}
