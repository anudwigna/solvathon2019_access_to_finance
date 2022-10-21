import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:MunshiG/models/user/user.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import '../services/activity_tracking.dart';
import '../models/app_page_naming.dart';

class UserService {
  UserService._();

  factory UserService() => UserService._();

  Future<DatabaseAndStore> getDatabaseAndStore() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('user.db')),
      store: intMapStoreFactory.store('user'),
    );
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future<void> addUser(User data) async {
    var dbStore = await getDatabaseAndStore();
    await dbStore.store!.add(dbStore.database!, data.toJson());
  }

  Future<User> getAccounts() async {
    var dbStore = await getDatabaseAndStore();
    RecordSnapshot<int?, Map<String, dynamic>>? snapshot = await dbStore.store!.findFirst(dbStore.database!);
    return (snapshot?.value != null) ? User.fromJson(snapshot!.value) : User();
  }

  Future<void> updateUser(User user, bool isAutomated) async {
    var dbStore = await getDatabaseAndStore();
    await dbStore.store!.update(dbStore.database!, user.toJson(), finder: Finder(filter: Filter.equals('phonenumber', user.phonenumber)));
    if (!(isAutomated)) {
      ActivityTracker().otherActivityOnPage(PageName.createProfile, 'Update User', 'Save', 'FlatButton');
    }
  }

  Future<bool> canPerformBackUp() async {
    try {
      var dbStore = await getDatabaseAndStore();
      RecordSnapshot<int?, Map<String, dynamic>>? d = await dbStore.store!.findFirst(dbStore.database!);
      if (d == null) return false;
      if (d.value['name'] != null && d.value['gender'] != null && d.value['phonenumber'] != null && d.value['address'] != null) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> closeDatabase(String subsector) async {
    final db = await getDatabaseAndStore();
    await db.database!.close();
  }
}
