import 'package:MunshiG/models/app_page_naming.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '../models/app_page_naming.dart';

class AppPage {
  AppPage._();

  factory AppPage() => AppPage._();

  Future<DatabaseAndStore> getDatabaseAndStore() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('app_page.db')),
      store: intMapStoreFactory.store('app_page'),
    );
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future<int?> getPageIdByName(String pageName) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(filter: Filter.equals('name', pageName));
    RecordSnapshot<int?, Map<String, dynamic>>? snapshot = await dbStore.store!.findFirst(dbStore.database, finder: finder);
    // print(snapshot.value);
    // print
    if (snapshot == null) return null;
    return snapshot.value['id'];
    // return snapshot.value;
    // return 1;
  }

  Future addPages(int? id, String? name) async {
    var dbStore = await getDatabaseAndStore();
    await dbStore.store!.add(dbStore.database, {'id': id, 'name': name});
  }

  Future<void> initializeAppPages() async {
    var dbStore = await getDatabaseAndStore();
    final List<RecordSnapshot<int?, Map<String, dynamic>>> data = await dbStore.store!.find(dbStore.database);
    PageName().init(data.map((e) {
      return e.value;
    }).toList());
  }

  Future<void> closeDatabase(String subsector) async {
    final db = await getDatabaseAndStore();
    await db.database.close();
  }
}
